import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:digipad_flutter/data/local/gallery_storage.dart';
import '../data/photo_sync_config.dart';
import '../data/photo_sync_http_server.dart';
import '../platform/photo_sync_platform.dart';
import 'photo_sync_host_state.dart';

/// Cubit managing the HOST (tótem) device logic:
/// 1. Start hotspot (native)
/// 2. Start HTTP server
/// 3. Generate QR code data
/// 4. Receive images → save to disk + Sembast gallery
///
/// Images are persisted via [GalleryStorage] (Sembast) so they are
/// available across the entire app (Virtual Mirror, etc.).
class PhotoSyncHostCubit extends Cubit<PhotoSyncHostState> {
  final PhotoSyncPlatform _platform = PhotoSyncPlatform();
  final GalleryStorage storage;

  PhotoSyncHttpServer? _httpServer;
  PhotoSyncConfig? _config;

  PhotoSyncHostCubit(this.storage) : super(const PhotoSyncHostInitial());

  /// Initialize gallery from Sembast, then start hosting.
  Future<void> startHosting() async {
    emit(const PhotoSyncHostStarting());

    try {
      // Ensure storage is initialized before use
      await storage.init();
      
      // Load previously synced images from Sembast
      final existingImages = await storage.loadImages();

      // 1. Start native hotspot (Android only)
      final hotspotInfo = await _platform.startHotspot();

      String ssid;
      String password;
      String hostIp;

      if (hotspotInfo != null) {
        ssid = hotspotInfo['ssid'] ?? '';
        password = hotspotInfo['password'] ?? '';
        hostIp = hotspotInfo['gateway'] ?? '';

        if (hostIp.isEmpty || hostIp == '0.0.0.0' || hostIp == '127.0.0.1') {
          hostIp = await PhotoSyncPlatform.getLocalIpDart() ?? '192.168.43.1';
        }
        if (hostIp.isEmpty || hostIp == '0.0.0.0' || hostIp == '127.0.0.1') {
          hostIp = '192.168.43.1';
        }
      } else {
        // Fallback: use current network IP (for testing / WiFi already shared)
        hostIp = await PhotoSyncPlatform.getLocalIpDart() ?? '0.0.0.0';
        ssid = 'DigiPad-Sync';
        password = 'digipad123';
      }

      // 2. Create config
      _config = PhotoSyncConfig(
        ssid: ssid,
        password: password,
        hostIp: hostIp,
        port: 8080,
      );

      // 3. Start HTTP server
      _httpServer = PhotoSyncHttpServer(port: _config!.port);
      _httpServer!.onImageReceived = _onImageReceived;
      _httpServer!.onClientConnected = _onClientConnected;
      await _httpServer!.start();

      // 4. Emit ready state with existing gallery images
      emit(PhotoSyncHostReady(
        qrData: _config!.toQrData(),
        ssid: ssid,
        receivedImages: existingImages,
      ));
    } catch (e) {
      debugPrint('[PhotoSyncHostCubit] Error starting host: $e');
      emit(PhotoSyncHostError('Error al iniciar: $e'));
    }
  }

  void _onClientConnected(String clientIp) {
    final currentState = state;
    if (currentState is PhotoSyncHostReady) {
      final updatedClients = Set<String>.from(currentState.connectedClients)
        ..add(clientIp);
      emit(currentState.copyWith(connectedClients: updatedClients));
    }
  }

  Future<void> _onImageReceived(Uint8List imageBytes, String fileName) async {
    try {
      // 1. Save file to app documents directory (persistent storage)
      final dir = await getApplicationDocumentsDirectory();
      final syncDir = Directory('${dir.path}/photo_sync');
      if (!await syncDir.exists()) {
        await syncDir.create(recursive: true);
      }

      final file = File('${syncDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      // 2. Register in Sembast gallery (same DB used by Virtual Mirror)
      await storage.saveImage(file);

      debugPrint(
          '[PhotoSyncHostCubit] Image saved to gallery: ${file.path} '
          '(${imageBytes.length} bytes)');

      // 3. Update UI state
      final currentState = state;
      if (currentState is PhotoSyncHostReady) {
        final updatedImages = [file, ...currentState.receivedImages];
        emit(currentState.copyWith(
          receivedImages: updatedImages,
          hasNewImage: true,
        ));

        // Reset animation flag after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (state is PhotoSyncHostReady) {
          emit((state as PhotoSyncHostReady).copyWith(hasNewImage: false));
        }
      }
    } catch (e) {
      debugPrint('[PhotoSyncHostCubit] Error saving image: $e');
    }
  }

  /// Delete an image from both disk and Sembast.
  Future<void> deleteImage(File file) async {
    await storage.deleteImage(file);
    final currentState = state;
    if (currentState is PhotoSyncHostReady) {
      final updatedImages = currentState.receivedImages
          .where((f) => f.path != file.path)
          .toList();
      emit(currentState.copyWith(receivedImages: updatedImages));
    }
  }

  /// Stop hosting: shutdown HTTP server and hotspot.
  Future<void> stopHosting() async {
    await _httpServer?.stop();
    _httpServer = null;
    try {
      await _platform.stopHotspot();
    } on MissingPluginException catch (_) {
      // Platform channel not available (e.g. hot restart)
    } catch (e) {
      debugPrint('[PhotoSyncHostCubit] Error stopping hotspot: $e');
    }
    _config = null;
    emit(const PhotoSyncHostInitial());
  }

  @override
  Future<void> close() async {
    await stopHosting();
    return super.close();
  }
}
