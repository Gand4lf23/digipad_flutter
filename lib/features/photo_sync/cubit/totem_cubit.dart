import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';

import 'package:digipad_flutter/data/local/gallery_storage.dart';
import 'package:digipad_flutter/features/photo_sync/photo_sync_preferences.dart';
import 'package:digipad_flutter/features/photo_sync/photo_sync_service.dart';
import 'totem_state.dart';

class TotemCubit extends Cubit<TotemState> {
  final GalleryStorage _storage;
  final PhotoSyncService _service;
  final PhotoSyncPreferences _prefs;

  StreamSubscription<PhotoSyncConnectionEvent>? _connSub;
  StreamSubscription<PhotoSyncFile>? _fileSub;

  TotemCubit({
    required GalleryStorage storage,
    PhotoSyncService? service,
  }) : _storage = storage,
       _service = service ?? PhotoSyncService.instance,
       _prefs = PhotoSyncPreferences(),
       super(const TotemIdle());

  // ── Start ──────────────────────────────────────────────────────────────────

  Future<void> startTotem() async {
    if (state is TotemActive) return;
    emit(const TotemStarting());

    final granted = await _service.requestPermissions();
    if (!granted) {
      emit(const TotemError(
        'Se necesitan permisos de Bluetooth y Ubicación.\n'
        'Habilitarlos en Ajustes › Aplicaciones › Digipad › Permisos.',
      ));
      return;
    }

    await _storage.init();

    _connSub?.cancel();
    _connSub = _service.connectionEvents.listen(_onConnectionEvent);

    _fileSub?.cancel();
    _fileSub = _service.fileReceived.listen(_onFileReceived);

    final name = await _prefs.getOrCreateTotemName();
    final ok = await _service.startAdvertising(name);

    if (!ok) {
      emit(const TotemError(
        'No se pudo iniciar el Tótem.\n'
        'Verificá que Bluetooth, WiFi y Ubicación estén activos.',
      ));
      return;
    }

    final images = await _storage.loadImages();
    emit(TotemActive(totemName: name, photoCount: images.length));
  }

  // ── Stop ───────────────────────────────────────────────────────────────────

  Future<void> stopTotem() async {
    _connSub?.cancel();
    _fileSub?.cancel();
    await _service.stopAll();
    emit(const TotemIdle());
  }

  // ── Connection events ──────────────────────────────────────────────────────

  void _onConnectionEvent(PhotoSyncConnectionEvent event) {
    final current = state;
    if (current is! TotemActive) return;
    final clients = List<String>.from(current.connectedClientIds);
    if (event.isConnected) {
      if (!clients.contains(event.endpointId)) clients.add(event.endpointId);
    } else {
      clients.remove(event.endpointId);
    }
    emit(current.copyWith(connectedClientIds: clients));
  }

  // ── File received ──────────────────────────────────────────────────────────

  Future<void> _onFileReceived(PhotoSyncFile file) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final syncDir = Directory('${dir.path}/totem_received');
      if (!await syncDir.exists()) await syncDir.create(recursive: true);

      final ext = file.fileName.contains('.')
          ? file.fileName.split('.').last
          : 'jpg';
      final destPath =
          '${syncDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.$ext';

      // file.tempPath is a content:// URI on Android 10+.
      // We must use the plugin's ContentResolver-backed copy method instead of
      // File.copy(), which cannot open content URIs.
      await Nearby().copyFileAndDeleteOriginal(file.tempPath, destPath);

      final dest = File(destPath);
      await _storage.saveImage(dest);
      // GalleryStorage stream fires → TotemScreen's StreamBuilder auto-updates

      final current = state;
      if (current is TotemActive) {
        emit(current.copyWith(photoCount: current.photoCount + 1));
      }
    } catch (e) {
      debugPrint('[TotemCubit] Error saving received file: $e');
    }
  }

  @override
  Future<void> close() async {
    await stopTotem();
    return super.close();
  }
}
