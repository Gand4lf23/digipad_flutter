import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:digipad_flutter/features/photo_sync/photo_sync_preferences.dart';
import 'package:digipad_flutter/features/photo_sync/photo_sync_service.dart';
import 'client_state.dart';

class ClientCubit extends Cubit<ClientState> {
  final PhotoSyncService _service;
  final PhotoSyncPreferences _prefs;
  final ImagePicker _picker = ImagePicker();

  StreamSubscription<MapEntry<String, String>>? _foundSub;
  StreamSubscription<PhotoSyncConnectionEvent>? _connSub;

  String? _targetTotemName;
  String? _connectedEndpointId;

  ClientCubit({PhotoSyncService? service})
      : _service = service ?? PhotoSyncService.instance,
        _prefs = PhotoSyncPreferences(),
        super(const ClientIdle());

  // ── Initialization ─────────────────────────────────────────────────────────

  /// On launch: auto-discover the last paired Totem, or show QR scanner.
  Future<void> init() async {
    final savedName = await _prefs.loadLastTotemName();
    if (savedName != null) {
      await _discoverFor(savedName);
    } else {
      emit(const ClientScanning());
    }
  }

  // ── QR pairing ─────────────────────────────────────────────────────────────

  /// Called when the QR scanner reads a Totem code.
  /// Expected format: "digipad-totem:{totemName}"
  Future<void> pairWithToken(String token) async {
    final name = token.startsWith('digipad-totem:')
        ? token.substring('digipad-totem:'.length).trim()
        : token.trim();
    if (name.isEmpty) return;
    await _discoverFor(name);
  }

  // ── Discovery ──────────────────────────────────────────────────────────────

  Future<void> _discoverFor(String totemName) async {
    _targetTotemName = totemName;
    emit(ClientDiscovering(targetName: totemName));

    final granted = await _service.requestPermissions();
    if (!granted) {
      emit(ClientError(
        'Se necesitan permisos de Bluetooth y Ubicación.\n'
        'Habilitarlos en Ajustes › Aplicaciones › Digipad › Permisos.',
        lastTotemName: totemName,
      ));
      return;
    }

    final myName = await _prefs.getOrCreateClientName();

    _connSub?.cancel();
    _connSub = _service.connectionEvents.listen(_onConnectionEvent);

    _foundSub?.cancel();
    _foundSub = _service.endpointFound.listen((entry) async {
      if (entry.value == _targetTotemName) {
        // Found the target Totem — connect and stop further discovery.
        _foundSub?.cancel();
        await _service.stopDiscovery();
        if (state is ClientDiscovering) {
          emit(const ClientConnecting());
          await _service.requestConnection(myName, entry.key);
        }
      }
    });

    final ok = await _service.startDiscovery(myName);
    if (!ok && state is ClientDiscovering) {
      emit(ClientError(
        'No se pudo iniciar la búsqueda.\n'
        'Verificá que Bluetooth y WiFi estén activos.',
        lastTotemName: totemName,
      ));
    }
  }

  // ── Connection events ──────────────────────────────────────────────────────

  void _onConnectionEvent(PhotoSyncConnectionEvent event) {
    if (event.isConnected) {
      _connectedEndpointId = event.endpointId;
      _prefs.saveLastTotemName(event.endpointName);
      emit(ClientConnected(
        endpointId: event.endpointId,
        endpointName: event.endpointName,
      ));
    } else {
      if (state is ClientConnected || state is ClientConnecting) {
        _connectedEndpointId = null;
        emit(ClientError(
          'Se perdió la conexión con el Tótem.',
          lastTotemName: _targetTotemName,
        ));
      }
    }
  }

  // ── Send photo ─────────────────────────────────────────────────────────────

  Future<void> sendFromGallery() async {
    if (state is! ClientConnected || _connectedEndpointId == null) return;
    final photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo == null || state is! ClientConnected) return;
    await _sendFile(photo.path);
  }

  Future<void> sendFile(File file) async {
    if (state is! ClientConnected || _connectedEndpointId == null) return;
    await _sendFile(file.path);
  }

  Future<void> _sendFile(String filePath) async {
    final current = state;
    if (current is! ClientConnected) return;
    final endpointId = _connectedEndpointId!;

    emit(current.copyWith(isSending: true));
    final ok = await _service.sendPhoto(endpointId, filePath);

    if (ok) {
      final newCount = current.sentCount + 1;
      emit(ClientSendSuccess(newCount));
      await Future.delayed(const Duration(milliseconds: 700));
      if (state is ClientSendSuccess) {
        emit(ClientConnected(
          endpointId: current.endpointId,
          endpointName: current.endpointName,
          sentCount: newCount,
        ));
      }
    } else {
      debugPrint('[ClientCubit] sendPhoto failed');
      emit(current.copyWith(isSending: false));
    }
  }

  // ── Disconnect / forget ────────────────────────────────────────────────────

  Future<void> forgetTotem() async {
    final endpointId = _connectedEndpointId;
    if (endpointId != null) await _service.disconnectFrom(endpointId);
    _connectedEndpointId = null;
    _targetTotemName = null;
    _foundSub?.cancel();
    _connSub?.cancel();
    await _service.stopAll();
    await _prefs.clearLastTotemName();
    emit(const ClientScanning());
  }

  Future<void> retryDiscovery() async {
    final name = _targetTotemName;
    if (name != null) {
      await _discoverFor(name);
    } else {
      emit(const ClientScanning());
    }
  }

  @override
  Future<void> close() async {
    _foundSub?.cancel();
    _connSub?.cancel();
    await _service.stopAll();
    return super.close();
  }
}
