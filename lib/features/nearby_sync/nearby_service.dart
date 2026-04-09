import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:digipad_flutter/features/nearby_sync/debug_logger.dart';
import 'package:digipad_flutter/features/nearby_sync/device_capabilities.dart';

/// Identifies this app's Nearby service across all devices.
const _kServiceId = 'ar.com.digipad.photosync';

/// Strategy: STAR allows one-to-many (host acts as a central node).
/// Helps with TV roles acting as access points.
const _kStrategy = Strategy.P2P_STAR;

/// Wire-protocol message types (sent as a 1-byte prefix in every BYTES payload)
/// so the receiver knows how to decode the rest.
class _MsgType {
  static const int image = 1;
  static const int ping = 2;
}

/// A received image from a connected client.
class NearbyReceivedImage {
  final String endpointId;
  final String fileName;
  final Uint8List bytes;
  const NearbyReceivedImage({
    required this.endpointId,
    required this.fileName,
    required this.bytes,
  });
}

/// Connection event from the perspective of the local device.
class NearbyConnectionEvent {
  final String endpointId;
  final String endpointName;
  final bool connected;
  const NearbyConnectionEvent({
    required this.endpointId,
    required this.endpointName,
    required this.connected,
  });
}

/// Single source of truth for all Nearby Connections logic.
///
/// Usage:
///   - Totem: call [startAdvertising], listen to [connectionEvents],
///     [imageReceived].
///   - Client: call [startDiscovery], listen to [endpointFound],
///     call [connectToEndpoint], call [sendImage].
///
/// Both roles call [stopAll] on dispose.
class NearbyService {
  NearbyService._();
  static final NearbyService instance = NearbyService._();

  // ── Streams ────────────────────────────────────────────────────────────────

  final _connectionCtrl =
      StreamController<NearbyConnectionEvent>.broadcast();
  Stream<NearbyConnectionEvent> get connectionEvents => _connectionCtrl.stream;

  final _imageCtrl = StreamController<NearbyReceivedImage>.broadcast();
  Stream<NearbyReceivedImage> get imageReceived => _imageCtrl.stream;

  // endpointId → endpointName
  final _endpointFoundCtrl =
      StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get endpointFound => _endpointFoundCtrl.stream;

  // Track currently-connected endpoints (endpointId → name)
  final Map<String, String> connectedEndpoints = {};

  // Chunks accumulator: payloadId → accumulated bytes
  // Nearby sends BYTES payloads in a single chunk, but we use this for safety.
  final Map<int, Uint8List> _payloadChunks = {};

  bool _advertising = false;
  bool _discovering = false;

  // ── Advertising (Totem) ────────────────────────────────────────────────────

  Future<bool> startAdvertising(String deviceName) async {
    DebugLogger.instance.info('[Nearby] startAdvertising as "$deviceName"');
    
    // Capability Check
    final caps = await CapabilitiesService.getCapabilities();
    if (!caps.isLocationEnabled || !caps.isBluetoothEnabled || !caps.isWifiEnabled) {
      DebugLogger.instance.info('[Nearby] startAdvertising failed: Location=${caps.isLocationEnabled}, BT=${caps.isBluetoothEnabled}, WiFi=${caps.isWifiEnabled}');
      return false; 
    }
    
    if (caps.isAndroidTV && !caps.supportsNearby) {
      DebugLogger.instance.info('[Nearby] Unsupported Android TV -> trigger fallback.');
      return false; // Force fallback layer above to start HTTP server/hotspot
    }

    try {
      if (Platform.isAndroid) {
        await CapabilitiesService.startForegroundService();
      }
    } catch (_) {}

    final delays = [500, 1000, 2000];
    
    for (var i = 0; i <= delays.length; i++) {
      try {
        final ok = await Nearby().startAdvertising(
          deviceName,
          _kStrategy,
          onConnectionInitiated: _onConnectionInitiated,
          onConnectionResult: _onConnectionResult,
          onDisconnected: _onDisconnected,
          serviceId: _kServiceId,
        );
        _advertising = ok;
        return ok;
      } catch (e) {
        DebugLogger.instance.error('[Nearby] startAdvertising error (attempt ${i + 1}): $e');
        if (i < delays.length) {
          await Future.delayed(Duration(milliseconds: delays[i]));
        }
      }
    }
    
    DebugLogger.instance.info('[Nearby] startAdvertising failed after retries.');
    try {
      if (Platform.isAndroid) {
        await CapabilitiesService.stopForegroundService();
      }
    } catch (_) {}
    return false;
  }

  Future<void> stopAdvertising() async {
    _advertising = false;
    await Nearby().stopAdvertising();
    try {
      if (Platform.isAndroid) {
        await CapabilitiesService.stopForegroundService();
      }
    } catch (_) {}
    DebugLogger.instance.info('[Nearby] Advertising stopped');
  }

  // ── Discovery (Client) ────────────────────────────────────────────────────

  Future<bool> startDiscovery(String deviceName) async {
    DebugLogger.instance.info('[Nearby] startDiscovery as "$deviceName"');
    
    final caps = await CapabilitiesService.getCapabilities();
    if (!caps.isLocationEnabled || !caps.isBluetoothEnabled || !caps.isWifiEnabled) {
      DebugLogger.instance.info('[Nearby] startDiscovery failed: Prerequisites not met');
      return false;
    }

    final delays = [500, 1000, 2000];
    for (var i = 0; i <= delays.length; i++) {
      try {
        final ok = await Nearby().startDiscovery(
          deviceName,
          _kStrategy,
          onEndpointFound: (id, name, serviceId) {
            DebugLogger.instance.info('[Nearby] Endpoint found: $name ($id)');
            _endpointFoundCtrl.add({id: name});
          },
          onEndpointLost: (id) {
            DebugLogger.instance.info('[Nearby] Endpoint lost: $id');
          },
          serviceId: _kServiceId,
        );
        _discovering = ok;
        return ok;
      } catch (e) {
        DebugLogger.instance.error('[Nearby] startDiscovery error (attempt ${i + 1}): $e');
        if (i < delays.length) {
          await Future.delayed(Duration(milliseconds: delays[i]));
        }
      }
    }
    return false;
  }

  Future<void> stopDiscovery() async {
    _discovering = false;
    await Nearby().stopDiscovery();
    DebugLogger.instance.info('[Nearby] Discovery stopped');
  }

  // ── Connection (Client initiates) ────────────────────────────────────────

  Future<bool> connectToEndpoint(String endpointId, String myName) async {
    DebugLogger.instance.info('[Nearby] Requesting connection to $endpointId');
    final delays = [500, 1000, 2000];
    for (var i = 0; i <= delays.length; i++) {
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
          DebugLogger.instance.error('[Nearby] requestConnection error (attempt ${i + 1}): $e');
          if (i < delays.length) {
            await Future.delayed(Duration(milliseconds: delays[i]));
          }
        }
    }
    return false;
  }

  Future<void> disconnectFromEndpoint(String endpointId) async {
    await Nearby().disconnectFromEndpoint(endpointId);
    connectedEndpoints.remove(endpointId);
  }

  Future<void> stopAll() async {
    connectedEndpoints.clear();
    _payloadChunks.clear();
    if (_advertising) await stopAdvertising();
    if (_discovering) await stopDiscovery();
    await Nearby().stopAllEndpoints();
    DebugLogger.instance.info('[Nearby] All endpoints stopped');
  }

  // ── Send image ────────────────────────────────────────────────────────────

  /// Send image [bytes] to a single connected [endpointId].
  ///
  /// Protocol: [_MsgType.image (1 byte)] [fileName bytes (UTF-8)]
  ///           [null-separator (1 byte 0x00)] [image bytes]
  Future<bool> sendImage({
    required String endpointId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    debugPrint('[Nearby] Sending image "$fileName" to $endpointId '
        '(${bytes.lengthInBytes} bytes)');
    try {
      final nameBytes = Uint8List.fromList(fileName.codeUnits);
      final payload = Uint8List(1 + nameBytes.length + 1 + bytes.length);
      payload[0] = _MsgType.image;
      payload.setRange(1, 1 + nameBytes.length, nameBytes);
      payload[1 + nameBytes.length] = 0x00; // separator
      payload.setRange(1 + nameBytes.length + 1, payload.length, bytes);

      await Nearby().sendBytesPayload(endpointId, payload);
      DebugLogger.instance.info('[Nearby] Image sent successfully');
      return true;
    } catch (e) {
      DebugLogger.instance.error('[Nearby] sendImage error: $e');
      return false;
    }
  }

  // ── Private connection callbacks ──────────────────────────────────────────

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    debugPrint('[Nearby] Connection initiated: ${info.endpointName} ($id), '
        'incoming=${info.isIncomingConnection}');
    // Auto-accept all connections (non-technical UX).
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: _onPayloadReceived,
      onPayloadTransferUpdate: _onPayloadTransferUpdate,
    );
  }

  void _onConnectionResult(String id, Status status) {
    DebugLogger.instance.info('[Nearby] Connection result: $id → $status');
    if (status == Status.CONNECTED) {
      connectedEndpoints[id] = id; // name is updated below via streams
      _connectionCtrl.add(NearbyConnectionEvent(
        endpointId: id,
        endpointName: id,
        connected: true,
      ));
    } else {
      connectedEndpoints.remove(id);
      _connectionCtrl.add(NearbyConnectionEvent(
        endpointId: id,
        endpointName: id,
        connected: false,
      ));
    }
  }

  void _onDisconnected(String id) {
    DebugLogger.instance.info('[Nearby] Disconnected: $id');
    connectedEndpoints.remove(id);
    _connectionCtrl.add(NearbyConnectionEvent(
      endpointId: id,
      endpointName: id,
      connected: false,
    ));
  }

  // ── Payload handling ─────────────────────────────────────────────────────

  void _onPayloadReceived(String endpointId, Payload payload) {
    if (payload.type == PayloadType.BYTES) {
      final data = payload.bytes;
      if (data == null || data.isEmpty) return;
      _decodePayload(endpointId, data);
    } else if (payload.type == PayloadType.FILE) {
      // We use BYTES only for images; FILE type not expected in this protocol.
      DebugLogger.instance.info('[Nearby] Unexpected FILE payload from $endpointId');
    }
  }

  void _onPayloadTransferUpdate(
      String endpointId, PayloadTransferUpdate update) {
    debugPrint('[Nearby] Transfer $endpointId — '
        'id=${update.id} status=${update.status} '
        '${update.bytesTransferred}/${update.totalBytes}');
  }

  void _decodePayload(String endpointId, Uint8List data) {
    if (data.isEmpty) return;
    final type = data[0];

    if (type == _MsgType.image) {
      // Find null separator
      int sep = -1;
      for (int i = 1; i < data.length; i++) {
        if (data[i] == 0x00) {
          sep = i;
          break;
        }
      }
      if (sep == -1) {
        DebugLogger.instance.info('[Nearby] Malformed image payload from $endpointId');
        return;
      }
      final fileName = String.fromCharCodes(data.sublist(1, sep));
      final imageBytes = data.sublist(sep + 1);
      debugPrint('[Nearby] Image received from $endpointId: "$fileName" '
          '(${imageBytes.length} bytes)');
      _imageCtrl.add(NearbyReceivedImage(
        endpointId: endpointId,
        fileName: fileName,
        bytes: imageBytes,
      ));
    } else if (type == _MsgType.ping) {
      DebugLogger.instance.info('[Nearby] Ping from $endpointId');
    } else {
      DebugLogger.instance.info('[Nearby] Unknown payload type: $type from $endpointId');
    }
  }

  void dispose() {
    _connectionCtrl.close();
    _imageCtrl.close();
    _endpointFoundCtrl.close();
  }
}
