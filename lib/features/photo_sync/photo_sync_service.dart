import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

const _kServiceId = 'ar.com.digipad.photosync';
const _kStrategy = Strategy.P2P_STAR;

class PhotoSyncFile {
  final String tempPath;
  final String fileName;
  final double? angle;
  final String? patientFirstName;
  final String? patientLastName;
  final String? captureDate;
  const PhotoSyncFile({
    required this.tempPath,
    required this.fileName,
    this.angle,
    this.patientFirstName,
    this.patientLastName,
    this.captureDate,
  });
}

class PhotoSyncConnectionEvent {
  final String endpointId;
  final String endpointName;
  final bool isConnected;
  const PhotoSyncConnectionEvent({
    required this.endpointId,
    required this.endpointName,
    required this.isConnected,
  });
}

/// Singleton Nearby Connections wrapper.
///
/// Totem side: call [startAdvertising], listen to [connectionEvents] and [fileReceived].
/// Client side: call [startDiscovery], listen to [endpointFound], call
/// [requestConnection] and [sendPhoto].
/// Both sides call [stopAll] on dispose.
class PhotoSyncService {
  PhotoSyncService._();
  static final PhotoSyncService instance = PhotoSyncService._();

  final _connectionCtrl =
      StreamController<PhotoSyncConnectionEvent>.broadcast();
  final _endpointFoundCtrl =
      StreamController<MapEntry<String, String>>.broadcast();
  final _fileReceivedCtrl = StreamController<PhotoSyncFile>.broadcast();

  Stream<PhotoSyncConnectionEvent> get connectionEvents =>
      _connectionCtrl.stream;
  Stream<MapEntry<String, String>> get endpointFound =>
      _endpointFoundCtrl.stream;
  Stream<PhotoSyncFile> get fileReceived => _fileReceivedCtrl.stream;

  final _connectedEndpoints = <String, String>{}; // id → name
  final _pendingFiles = <int, PhotoSyncFile>{}; // payloadId → file info
  String? _nextFileName;
  double? _nextAngle;
  String? _nextPatientFirstName;
  String? _nextPatientLastName;
  String? _nextCaptureDate;

  bool _advertising = false;
  bool _discovering = false;

  // ── Permissions ────────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
      Permission.nearbyWifiDevices,
    ].request();

    // Android 12+: Bluetooth trio is sufficient.
    // Android 8–11: location is the requirement.
    // Android 13+: nearbyWifiDevices can substitute.
    final bt = (statuses[Permission.bluetoothScan]?.isGranted ?? false) &&
        (statuses[Permission.bluetoothConnect]?.isGranted ?? false) &&
        (statuses[Permission.bluetoothAdvertise]?.isGranted ?? false);
    final loc = statuses[Permission.locationWhenInUse]?.isGranted ?? false;
    final wifi = statuses[Permission.nearbyWifiDevices]?.isGranted ?? false;
    return bt || loc || wifi;
  }

  // ── Advertising (Totem) ────────────────────────────────────────────────────

  Future<bool> startAdvertising(String totemName) async {
    if (_advertising) return true;
    try {
      final ok = await Nearby().startAdvertising(
        totemName,
        _kStrategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: _kServiceId,
      );
      _advertising = ok;
      debugPrint('[PhotoSync] Advertising as "$totemName": $ok');
      return ok;
    } catch (e) {
      debugPrint('[PhotoSync] startAdvertising error: $e');
      return false;
    }
  }

  Future<void> stopAdvertising() async {
    _advertising = false;
    try {
      await Nearby().stopAdvertising();
    } catch (_) {}
  }

  // ── Discovery (Client) ────────────────────────────────────────────────────

  Future<bool> startDiscovery(String myName) async {
    if (_discovering) await stopDiscovery();
    try {
      final ok = await Nearby().startDiscovery(
        myName,
        _kStrategy,
        onEndpointFound: (id, name, _) {
          debugPrint('[PhotoSync] Endpoint found: $name ($id)');
          _endpointFoundCtrl.add(MapEntry(id, name));
        },
        onEndpointLost: (id) {
          debugPrint('[PhotoSync] Endpoint lost: $id');
        },
        serviceId: _kServiceId,
      );
      _discovering = ok;
      debugPrint('[PhotoSync] Discovery started as "$myName": $ok');
      return ok;
    } catch (e) {
      debugPrint('[PhotoSync] startDiscovery error: $e');
      return false;
    }
  }

  Future<void> stopDiscovery() async {
    _discovering = false;
    try {
      await Nearby().stopDiscovery();
    } catch (_) {}
  }

  // ── Connection ─────────────────────────────────────────────────────────────

  Future<bool> requestConnection(String myName, String endpointId) async {
    try {
      await Nearby().requestConnection(
        myName,
        endpointId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
      return true;
    } catch (e) {
      debugPrint('[PhotoSync] requestConnection error: $e');
      return false;
    }
  }

  Future<void> disconnectFrom(String endpointId) async {
    _connectedEndpoints.remove(endpointId);
    try {
      await Nearby().disconnectFromEndpoint(endpointId);
    } catch (_) {}
  }

  Future<void> stopAll() async {
    _advertising = false;
    _discovering = false;
    _connectedEndpoints.clear();
    _pendingFiles.clear();
    _nextFileName = null;
    _nextAngle = null;
    _nextPatientFirstName = null;
    _nextPatientLastName = null;
    _nextCaptureDate = null;
    try {
      await Nearby().stopAllEndpoints();
    } catch (_) {}
    try {
      await Nearby().stopAdvertising();
    } catch (_) {}
    try {
      await Nearby().stopDiscovery();
    } catch (_) {}
  }

  // ── Sending ────────────────────────────────────────────────────────────────

  /// Sends [filePath] to [endpointId] via a FILE payload.
  ///
  /// Sends a tiny BYTES payload with the original filename first so the
  /// receiver can use a meaningful name when saving to storage.
  Future<bool> sendPhoto(String endpointId, String filePath) async {
    try {
      final name = filePath.replaceAll('\\', '/').split('/').last;
      final meta = Uint8List.fromList(utf8.encode(jsonEncode({'name': name})));
      await Nearby().sendBytesPayload(endpointId, meta);
      await Nearby().sendFilePayload(endpointId, filePath);
      debugPrint('[PhotoSync] Sent "$name" to $endpointId');
      return true;
    } catch (e) {
      debugPrint('[PhotoSync] sendPhoto error: $e');
      return false;
    }
  }

  // ── Private callbacks ──────────────────────────────────────────────────────

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    debugPrint('[PhotoSync] Connection initiated: ${info.endpointName} ($id)');
    _connectedEndpoints[id] = info.endpointName;
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: _onPayloadReceived,
      onPayloadTransferUpdate: _onPayloadTransferUpdate,
    );
  }

  void _onConnectionResult(String id, Status status) {
    debugPrint('[PhotoSync] Result: $id → $status');
    if (status == Status.CONNECTED) {
      _connectionCtrl.add(PhotoSyncConnectionEvent(
        endpointId: id,
        endpointName: _connectedEndpoints[id] ?? id,
        isConnected: true,
      ));
    } else {
      final name = _connectedEndpoints.remove(id) ?? id;
      _connectionCtrl.add(PhotoSyncConnectionEvent(
        endpointId: id,
        endpointName: name,
        isConnected: false,
      ));
    }
  }

  void _onDisconnected(String id) {
    debugPrint('[PhotoSync] Disconnected: $id');
    final name = _connectedEndpoints.remove(id) ?? id;
    _connectionCtrl.add(PhotoSyncConnectionEvent(
      endpointId: id,
      endpointName: name,
      isConnected: false,
    ));
  }

  void _onPayloadReceived(String endpointId, Payload payload) {
    if (payload.type == PayloadType.BYTES && payload.bytes != null) {
      try {
        final meta = jsonDecode(utf8.decode(payload.bytes!)) as Map;
        _nextFileName = meta['name'] as String?;
        final av = meta['pantoscopic_angle'];
        _nextAngle = av != null ? (av as num).toDouble() : null;
        _nextPatientFirstName = meta['patient_first_name'] as String?;
        _nextPatientLastName = meta['patient_last_name'] as String?;
        _nextCaptureDate = meta['capture_date'] as String?;
      } catch (_) {}
      return;
    }

    if (payload.type == PayloadType.FILE && payload.uri != null) {
      final name = _nextFileName ??
          'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final angle = _nextAngle;
      final firstName = _nextPatientFirstName;
      final lastName = _nextPatientLastName;
      final captureDate = _nextCaptureDate;
      _nextFileName = null;
      _nextAngle = null;
      _nextPatientFirstName = null;
      _nextPatientLastName = null;
      _nextCaptureDate = null;
      // Store the raw URI string — on Android 10+ this is a content:// URI,
      // NOT a file path. Calling toFilePath() on it throws UnsupportedError.
      // The actual copy is deferred to _onFileReceived via copyFileAndDeleteOriginal().
      _pendingFiles[payload.id] = PhotoSyncFile(
        tempPath: payload.uri!,
        fileName: name,
        angle: angle,
        patientFirstName: firstName,
        patientLastName: lastName,
        captureDate: captureDate,
      );
      debugPrint('[PhotoSync] FILE started: id=${payload.id}, name=$name, uri=${payload.uri}');
    }
  }

  void _onPayloadTransferUpdate(
      String endpointId, PayloadTransferUpdate update) {
    if (update.status == PayloadStatus.SUCCESS) {
      final file = _pendingFiles.remove(update.id);
      if (file != null) {
        debugPrint('[PhotoSync] FILE complete: ${file.fileName}');
        _fileReceivedCtrl.add(file);
      }
    } else if (update.status == PayloadStatus.FAILURE) {
      _pendingFiles.remove(update.id);
      debugPrint('[PhotoSync] FILE transfer failed: id=${update.id}');
    }
  }
}
