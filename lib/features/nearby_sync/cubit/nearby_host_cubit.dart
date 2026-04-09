import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:digipad_flutter/data/local/gallery_storage.dart';
import 'package:digipad_flutter/features/nearby_sync/nearby_service.dart';
import 'package:digipad_flutter/features/nearby_sync/fallback_server.dart';
import 'package:digipad_flutter/features/nearby_sync/debug_logger.dart';
import 'nearby_host_state.dart';

/// Manages the TÓTEM role.
///
/// Lifecycle:
///   HomeScreen creates one instance; it stays alive for the session.
///   startAdvertising() → NearbyHostAdvertising
///   Photos arrive via NearbyService.imageReceived → saved + state updated.
///   stopAdvertising() → NearbyHostIdle
class NearbyHostCubit extends Cubit<NearbyHostState> {
  final GalleryStorage _storage;
  final NearbyService _nearby;

  StreamSubscription<NearbyConnectionEvent>? _connSub;
  StreamSubscription<NearbyReceivedImage>? _imageSub;
  StreamSubscription<NearbyReceivedImage>? _fallbackImageSub;

  NearbyHostCubit({
    required GalleryStorage storage,
    NearbyService? nearbyService,
  })  : _storage = storage,
        _nearby = nearbyService ?? NearbyService.instance,
        super(const NearbyHostIdle());

  // ── Start advertising ────────────────────────────────────────────────────

  Future<void> startAdvertising() async {
    if (state is NearbyHostAdvertising) return;

    emit(const NearbyHostAdvertising());

    try {
      // Request all permissions needed by Nearby Connections
      final granted = await _requestPermissions();
      if (!granted) {
        emit(
          const NearbyHostError(
            'Se necesitan permisos de Bluetooth y Ubicación para el Tótem.\n'
            'Habilitarlos en Ajustes › Aplicaciones › Digipad › Permisos.',
          ),
        );
        return;
      }

      await _storage.init();

      // Subscribe to connection events
      _connSub?.cancel();
      _connSub = _nearby.connectionEvents.listen(_onConnectionEvent);

      // Subscribe to incoming images
      _imageSub?.cancel();
      _imageSub = _nearby.imageReceived.listen(_onImageReceived);

      final ok = await _nearby.startAdvertising('DigiPad-Totem');
      if (!ok) {
        DebugLogger.instance.warning('[NearbyHostCubit] Nearby failed, triggering FallbackServer');
        final fallbackOk = await FallbackServer.startServer();
        if (!fallbackOk) {
          emit(
            const NearbyHostError(
              'No se pudo iniciar el Tótem ni la conexión de respaldo. '
              'Verifica que Bluetooth y WiFi estén activos.',
            ),
          );
          return;
        } else {
          DebugLogger.instance.info('[NearbyHostCubit] FallbackServer started successfully.');
          _fallbackImageSub?.cancel();
          _fallbackImageSub = FallbackServer.imageReceived.listen(_onImageReceived);
        }
      }

      final images = await _storage.loadImages();
      emit(NearbyHostAdvertising(photoCount: images.length));
      DebugLogger.instance.info('[NearbyHostCubit] Advertising started. '
          'Photos stored: ${images.length}');
    } catch (e) {
      DebugLogger.instance.error('[NearbyHostCubit] startAdvertising error: $e');
      emit(NearbyHostError('Error al iniciar el Tótem: $e'));
    }
  }

  // ── Stop advertising ─────────────────────────────────────────────────────

  Future<void> stopAdvertising() async {
    _connSub?.cancel();
    _imageSub?.cancel();
    _fallbackImageSub?.cancel();
    await _nearby.stopAll();
    await FallbackServer.stopServer();
    emit(const NearbyHostIdle());
    DebugLogger.instance.info('[NearbyHostCubit] Stopped advertising');
  }

  // ── Hard Reset ────────────────────────────────────────────────────────────

  Future<void> stopTotem() async {
    DebugLogger.instance.info('[NearbyHostCubit] HARD STOP called');
    await stopAdvertising();
    // Re-ensure streams are disposed
    _connSub?.cancel();
    _imageSub?.cancel();
    _fallbackImageSub?.cancel();
  }

  Future<void> restartTotem() async {
    DebugLogger.instance.info('[NearbyHostCubit] RESTART called');
    await stopTotem();
    await Future.delayed(const Duration(milliseconds: 500));
    await startAdvertising();
  }

  // ── Connection events ─────────────────────────────────────────────────────

  void _onConnectionEvent(NearbyConnectionEvent event) {
    final current = state;
    if (current is! NearbyHostAdvertising) return;

    final clients = List<String>.from(current.connectedClientIds);
    if (event.connected) {
      if (!clients.contains(event.endpointId)) clients.add(event.endpointId);
      DebugLogger.instance.info('[NearbyHostCubit] Client connected: ${event.endpointId}');
    } else {
      clients.remove(event.endpointId);
      DebugLogger.instance.info('[NearbyHostCubit] Client disconnected: ${event.endpointId}');
    }
    emit(current.copyWith(connectedClientIds: clients));
  }

  // ── Image received ────────────────────────────────────────────────────────

  Future<void> _onImageReceived(NearbyReceivedImage img) async {
    DebugLogger.instance.info('[NearbyHostCubit] Image received: ${img.fileName} '
        '(${img.bytes.length} bytes)');
    try {
      final file = await _saveImageToStorage(img.bytes, img.fileName);
      await _storage.saveImage(file);

      final current = state;
      if (current is NearbyHostAdvertising) {
        emit(current.copyWith(photoCount: current.photoCount + 1));
      }
      DebugLogger.instance.info('[NearbyHostCubit] Image saved: ${file.path}');
    } catch (e) {
      DebugLogger.instance.error('[NearbyHostCubit] Failed to save image: $e');
    }
  }

  Future<File> _saveImageToStorage(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final syncDir = Directory('${dir.path}/nearby_sync_received');
    if (!await syncDir.exists()) await syncDir.create(recursive: true);

    // Use timestamp to avoid collisions even with same fileName
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = fileName.contains('.') ? fileName.split('.').last : 'jpg';
    final file = File('${syncDir.path}/photo_$ts.$ext');
    await file.writeAsBytes(bytes);
    return file;
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
      Permission.nearbyWifiDevices,
    ].request();

    DebugLogger.instance.info('[NearbyHostCubit] Permissions: '
        '${statuses.map((k, v) => MapEntry(k.toString(), v.toString()))}');

    // On Android 12+, Bluetooth Scan/Connect/Advertise are the primary requirements.
    // Location is often reported as denied if Nearby Wifi Devices is granted.
    final scanOk = statuses[Permission.bluetoothScan]?.isGranted ?? false;
    final connectOk = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
    final advertiseOk = statuses[Permission.bluetoothAdvertise]?.isGranted ?? false;
    final locationOk = statuses[Permission.locationWhenInUse]?.isGranted ?? false;
    final wifiOk = statuses[Permission.nearbyWifiDevices]?.isGranted ?? false;

    // Successful if (Modern Bluetooth) OR (Legacy Location)
    return (scanOk && connectOk && advertiseOk) || locationOk || wifiOk;
  }

  @override
  Future<void> close() async {
    await stopAdvertising();
    return super.close();
  }
}
