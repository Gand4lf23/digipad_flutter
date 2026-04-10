import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:digipad_flutter/data/local/gallery_storage.dart';
import 'package:digipad_flutter/features/nearby_sync/nearby_preferences.dart';
import 'package:digipad_flutter/features/nearby_sync/nearby_service.dart';
import 'nearby_client_state.dart';

/// Manages the CLIENTE role.
///
/// Lifecycle:
///   startDiscovery() → NearbyClientDiscovering (lists found endpoints)
///   connectToEndpoint(id) → NearbyClientConnected
///   captureAndSendPhoto() → captures, saves locally, sends via Nearby
///   forgetEndpoint() → clears saved endpoint, back to Idle
class NearbyClientCubit extends Cubit<NearbyClientState> {
  final GalleryStorage _storage;
  final NearbyPreferences _prefs;
  final NearbyService _nearby;
  final ImagePicker _picker = ImagePicker();

  StreamSubscription<Map<String, String>>? _foundSub;
  StreamSubscription<NearbyConnectionEvent>? _connSub;

  // All endpoints found during the current discovery cycle
  final Map<String, String> _foundEndpoints = {};

  NearbyClientCubit({
    required GalleryStorage storage,
    NearbyPreferences? prefs,
    NearbyService? nearbyService,
  }) : _storage = storage,
       _prefs = prefs ?? NearbyPreferences(),
       _nearby = nearbyService ?? NearbyService.instance,
       super(const NearbyClientIdle());

  // ── Start discovery ────────────────────────────────────────────────────────

  Future<void> startDiscovery() async {
    if (state is NearbyClientDiscovering) return;
    _foundEndpoints.clear();

    final granted = await _requestPermissions();
    if (!granted) {
      emit(
        const NearbyClientError(
          'Se necesitan permisos de Bluetooth y Ubicación.\n'
          'Habilitarlos en Ajustes › Aplicaciones › Digipad › Permisos.',
        ),
      );
      return;
    }

    emit(const NearbyClientDiscovering());

    // Stop any previous discovery session first
    await _nearby.stopDiscovery();

    // Listen for found endpoints
    _foundSub?.cancel();
    _foundSub = _nearby.endpointFound.listen((ep) {
      _foundEndpoints.addAll(ep);
      if (state is NearbyClientDiscovering) {
        emit(
          NearbyClientDiscovering(foundEndpoints: Map.from(_foundEndpoints)),
        );
      }
    });

    // Listen for disconnections while connected
    _connSub?.cancel();
    _connSub = _nearby.connectionEvents.listen(_onConnectionEvent);

    final ok = await _nearby.startDiscovery('DigiPad-Client');
    if (!ok) {
      emit(
        const NearbyClientError(
          'No se pudo iniciar la búsqueda. '
          'Verifica que Bluetooth y WiFi estén activos.',
        ),
      );
    }
  }

  // ── Connect to a found endpoint ────────────────────────────────────────────

  Future<void> connectToEndpoint(String endpointId) async {
    emit(const NearbyClientConnecting());
    final endpointName = _foundEndpoints[endpointId] ?? endpointId;

    await _nearby.stopDiscovery(); // Stop discovery after choosing
    _foundSub?.cancel();

    final ok = await _nearby.connectToEndpoint(endpointId, 'DigiPad-Client');
    if (!ok) {
      emit(
        NearbyClientError(
          'No se pudo conectar con "$endpointName". Intenta de nuevo.',
        ),
      );
      return;
    }
    // Connection result will be emitted via _onConnectionEvent
  }

  /// Auto-reconnect using the last saved endpoint.
  /// If found during discovery, connects automatically — silently.
  Future<void> tryAutoReconnect() async {
    final saved = await _prefs.loadEndpoint();
    if (saved == null) return;

    // Start discovery and wait briefly for the saved endpoint to appear
    await startDiscovery();

    // Give the discovery 8 seconds to find the last endpoint
    for (int i = 0; i < 16; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_foundEndpoints.containsKey(saved.id)) {
        await connectToEndpoint(saved.id);
        return;
      }
      if (state is! NearbyClientDiscovering) return; // user navigated away
    }
    // Stay in discovering state — user can tap manually
  }

  // ── Connection events ─────────────────────────────────────────────────────

  void _onConnectionEvent(NearbyConnectionEvent event) {
    if (event.connected) {
      // Persist for next session
      _prefs.saveEndpoint(event.endpointId, event.endpointName);

      emit(
        NearbyClientConnected(
          endpointId: event.endpointId,
          endpointName: event.endpointName,
        ),
      );
    } else {
      final current = state;
      if (current is NearbyClientConnected &&
          current.endpointId == event.endpointId) {
        emit(
          const NearbyClientError(
            'Se perdió la conexión con el Tótem.\n'
            'Toca "Buscar Tótem" para reconectar.',
          ),
        );
      }
    }
  }

  // ── Capture and send ─────────────────────────────────────────────────────

  Future<void> captureAndSendPhoto() async {
    final current = state;
    if (current is! NearbyClientConnected) {
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (photo == null) {
        return;
      }

      // Re-validate state after async camera call (Activity may have changed)
      if (state is! NearbyClientConnected) {
        return;
      }
      final activeState = state as NearbyClientConnected;

      emit(activeState.copyWith(isSending: true));

      // 1. Save locally (never fail the upload if this fails)
      try {
        await _saveLocally(photo.path);
      } catch (e) {
        debugPrint(e.toString());
      }

      // 2. Read bytes and send via Nearby
      final bytes = Uint8List.fromList(await File(photo.path).readAsBytes());
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final ok = await _nearby.sendImage(
        endpointId: activeState.endpointId,
        bytes: bytes,
        fileName: fileName,
      );

      if (ok) {
        final newCount = activeState.sentCount + 1;
        emit(NearbyClientSendSuccess(newCount));
        await Future.delayed(const Duration(milliseconds: 700));
        if (state is NearbyClientSendSuccess) {
          emit(
            NearbyClientConnected(
              endpointId: activeState.endpointId,
              endpointName: activeState.endpointName,
              sentCount: newCount,
            ),
          );
        }
      } else {
        emit(activeState.copyWith(isSending: false));
        emit(
          const NearbyClientError(
            'Error al enviar la foto. La conexión pudo haberse perdido.',
          ),
        );
      }
    } catch (e) {
      emit(const NearbyClientError('Error inesperado al enviar la foto.'));
    }
  }

  // ── Forget / disconnect ────────────────────────────────────────────────────

  Future<void> forgetAndDisconnect() async {
    final current = state;
    if (current is NearbyClientConnected) {
      await _nearby.disconnectFromEndpoint(current.endpointId);
    }
    await _prefs.clearEndpoint();
    _foundEndpoints.clear();
    _foundSub?.cancel();
    _connSub?.cancel();
    await _nearby.stopAll();
    emit(const NearbyClientIdle());
  }

  // ── Hard Reset ────────────────────────────────────────────────────────────

  Future<void> stopClient() async {
    final current = state;
    if (current is NearbyClientConnected) {
      await _nearby.disconnectFromEndpoint(current.endpointId);
    }
    _foundEndpoints.clear();
    _foundSub?.cancel();
    _connSub?.cancel();
    await _nearby.stopAll();
    emit(const NearbyClientIdle());
  }

  Future<void> restartClient() async {
    await stopClient();
    await Future.delayed(const Duration(milliseconds: 500));
    await startDiscovery();
  }

  // ── Reset to idle ─────────────────────────────────────────────────────────

  Future<void> reset() async {
    _foundEndpoints.clear();
    _foundSub?.cancel();
    _connSub?.cancel();
    await _nearby.stopDiscovery();
    emit(const NearbyClientIdle());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _saveLocally(String originalFilePath) async {
    await _storage.init();
    final dir = await getApplicationDocumentsDirectory();
    final syncDir = Directory('${dir.path}/nearby_sync_sent');
    if (!await syncDir.exists()) await syncDir.create(recursive: true);
    final dest = File(
      '${syncDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await File(originalFilePath).copy(dest.path);
    await _storage.saveImage(dest);
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
      Permission.nearbyWifiDevices,
    ].request();
    // On Android 12+, Bluetooth Scan/Connect/Advertise are the primary requirements.
    // Location is often reported as denied if Nearby Wifi Devices is granted.
    final scanOk = statuses[Permission.bluetoothScan]?.isGranted ?? false;
    final connectOk = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
    final advertiseOk =
        statuses[Permission.bluetoothAdvertise]?.isGranted ?? false;
    final locationOk =
        statuses[Permission.locationWhenInUse]?.isGranted ?? false;
    final wifiOk = statuses[Permission.nearbyWifiDevices]?.isGranted ?? false;

    // Successful if (Modern Bluetooth) OR (Legacy Location) OR (Nearby Wifi)
    return (scanOk && connectOk && advertiseOk) || locationOk || wifiOk;
  }

  @override
  Future<void> close() async {
    _foundSub?.cancel();
    _connSub?.cancel();
    return super.close();
  }
}
