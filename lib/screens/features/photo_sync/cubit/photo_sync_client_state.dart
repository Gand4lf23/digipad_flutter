import 'package:flutter/foundation.dart';
import '../data/photo_sync_config.dart';

/// States for the CLIENT device in photo sync.
@immutable
abstract class PhotoSyncClientState {
  const PhotoSyncClientState();
}

/// Initial — nothing started.
class PhotoSyncClientInitial extends PhotoSyncClientState {
  /// True if a previously saved config exists.
  final bool hasSavedConfig;
  const PhotoSyncClientInitial({this.hasSavedConfig = false});
}

/// Scanning QR code.
class PhotoSyncClientScanning extends PhotoSyncClientState {
  const PhotoSyncClientScanning();
}

/// Connecting to WiFi hotspot.
class PhotoSyncClientConnecting extends PhotoSyncClientState {
  final String ssid;
  const PhotoSyncClientConnecting({required this.ssid});
}

/// Connected and ready to capture photos.
class PhotoSyncClientConnected extends PhotoSyncClientState {
  final PhotoSyncConfig config;
  /// True while a photo is being uploaded.
  final bool isUploading;
  /// Message to display (success/error).
  final String? statusMessage;
  /// True if the last upload was successful.
  final bool? uploadSuccess;

  const PhotoSyncClientConnected({
    required this.config,
    this.isUploading = false,
    this.statusMessage,
    this.uploadSuccess,
  });

  PhotoSyncClientConnected copyWith({
    PhotoSyncConfig? config,
    bool? isUploading,
    String? statusMessage,
    bool? uploadSuccess,
  }) {
    return PhotoSyncClientConnected(
      config: config ?? this.config,
      isUploading: isUploading ?? this.isUploading,
      statusMessage: statusMessage,
      uploadSuccess: uploadSuccess,
    );
  }
}

/// Error state.
class PhotoSyncClientError extends PhotoSyncClientState {
  final String message;
  const PhotoSyncClientError(this.message);
}
