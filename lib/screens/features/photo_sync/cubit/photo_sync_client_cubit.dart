import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:digipad_flutter/data/local/gallery_storage.dart';
import '../data/photo_sync_config.dart';
import '../data/photo_sync_http_client.dart';
import '../data/photo_sync_preferences.dart';
import '../platform/photo_sync_platform.dart';
import 'photo_sync_client_state.dart';

/// Cubit managing the CLIENT (vendor phone) device logic:
/// 1. Scan QR / load saved config
/// 2. Connect to HOST WiFi
/// 3. Capture photo
/// 4. Save photo locally (disk + Sembast gallery)
/// 5. Upload photo to HOST
///
/// Photos are saved to both the app's file system AND Sembast gallery,
/// so they are instantly available in Virtual Mirror and other modules
/// on this device too.
class PhotoSyncClientCubit extends Cubit<PhotoSyncClientState> {
  final PhotoSyncPlatform _platform = PhotoSyncPlatform();
  final PhotoSyncPreferences _preferences = PhotoSyncPreferences();
  final ImagePicker _picker = ImagePicker();
  final GalleryStorage storage;

  PhotoSyncConfig? _config;
  PhotoSyncHttpClient? _httpClient;

  PhotoSyncClientCubit(this.storage) : super(const PhotoSyncClientInitial()) {
    _checkSavedConfig();
  }

  Future<void> _checkSavedConfig() async {
    final hasConfig = await _preferences.hasConfig();
    emit(PhotoSyncClientInitial(hasSavedConfig: hasConfig));
  }

  /// Start QR scanning.
  void startScanning() {
    emit(const PhotoSyncClientScanning());
  }

  /// Process QR code data after scanning.
  Future<void> onQrScanned(String qrData) async {
    try {
      _config = PhotoSyncConfig.fromQrData(qrData);
      await _connectToHost(_config!);
    } catch (e) {
      debugPrint('[PhotoSyncClientCubit] QR parse error: $e');
      emit(const PhotoSyncClientError('Código QR inválido'));
    }
  }

  /// Attempt auto-reconnect using saved config.
  Future<void> autoReconnect() async {
    final config = await _preferences.loadConfig();
    if (config == null) {
      emit(const PhotoSyncClientError('No hay configuración guardada'));
      return;
    }

    _config = config;
    await _connectToHost(config);
  }

  Future<void> _connectToHost(PhotoSyncConfig config) async {
    emit(PhotoSyncClientConnecting(ssid: config.ssid));

    try {
      // 1. Try to connect to WiFi
      final connected = await _platform.connectToWifi(
        config.ssid,
        config.password,
      );

      if (!connected) {
        debugPrint(
            '[PhotoSyncClientCubit] WiFi connect returned false, trying ping anyway...');
      }

      // 2. Wait a bit for connection to stabilize
      await Future.delayed(const Duration(seconds: 2));

      // 3. Verify connectivity with ping
      _httpClient = PhotoSyncHttpClient(config);
      final reachable = await _httpClient!.ping();

      if (reachable) {
        // Save config for future auto-reconnect
        await _preferences.saveConfig(config);
        emit(PhotoSyncClientConnected(config: config));
      } else {
        emit(const PhotoSyncClientError(
            'No se pudo conectar al tótem.\nVerificá que estás cerca del dispositivo.'));
      }
    } catch (e) {
      debugPrint('[PhotoSyncClientCubit] Connection error: $e');
      emit(PhotoSyncClientError('Error de conexión: $e'));
    }
  }

  /// Capture a photo using the camera and upload it to the HOST.
  /// The photo is saved locally (disk + Sembast) before uploading,
  /// so the vendor always has a local copy.
  Future<void> captureAndUpload() async {
    if (_httpClient == null || _config == null) return;

    final currentState = state;
    if (currentState is! PhotoSyncClientConnected) return;

    try {
      // 1. Take photo — HQ for app usage
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (photo == null) return; // User cancelled

      emit(currentState.copyWith(isUploading: true, statusMessage: null));

      // 2. Read bytes
      final bytes = await photo.readAsBytes();

      // 3. Save locally to disk + Sembast gallery
      await _saveLocally(bytes);

      // 4. Upload to HOST
      final success = await _httpClient!.uploadImage(bytes);

      if (success) {
        emit(currentState.copyWith(
          isUploading: false,
          statusMessage: '¡Foto enviada!',
          uploadSuccess: true,
        ));
      } else {
        emit(currentState.copyWith(
          isUploading: false,
          statusMessage: 'Error al enviar. Intentá de nuevo.',
          uploadSuccess: false,
        ));
      }

      // Clear status after delay
      await Future.delayed(const Duration(seconds: 3));
      if (state is PhotoSyncClientConnected) {
        emit((state as PhotoSyncClientConnected).copyWith(
          statusMessage: null,
          uploadSuccess: null,
        ));
      }
    } catch (e) {
      debugPrint('[PhotoSyncClientCubit] Capture/upload error: $e');
      if (state is PhotoSyncClientConnected) {
        emit((state as PhotoSyncClientConnected).copyWith(
          isUploading: false,
          statusMessage: 'Error: $e',
          uploadSuccess: false,
        ));
      }
    }
  }

  /// Save image to disk AND register in Sembast gallery.
  Future<void> _saveLocally(Uint8List bytes) async {
    try {
      await storage.init(); // Ensure initialized
      final dir = await getApplicationDocumentsDirectory();
      final syncDir = Directory('${dir.path}/photo_sync_sent');
      if (!await syncDir.exists()) {
        await syncDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${syncDir.path}/photo_$timestamp.jpg');
      await file.writeAsBytes(bytes);

      // Register in Sembast so it appears in Virtual Mirror gallery
      await storage.saveImage(file);

      debugPrint('[PhotoSyncClientCubit] Photo saved to gallery: ${file.path}');
    } catch (e) {
      debugPrint('[PhotoSyncClientCubit] Error saving locally: $e');
    }
  }

  /// Reset to initial state.
  void reset() {
    _config = null;
    _httpClient = null;
    _checkSavedConfig();
  }

  /// Clear saved config.
  Future<void> clearSavedConfig() async {
    await _preferences.clearConfig();
    _config = null;
    _httpClient = null;
    emit(const PhotoSyncClientInitial(hasSavedConfig: false));
  }
}
