import 'dart:io';
import 'package:flutter/foundation.dart';

/// States for the HOST device in photo sync.
@immutable
abstract class PhotoSyncHostState {
  const PhotoSyncHostState();
}

/// Initial state — nothing started yet.
class PhotoSyncHostInitial extends PhotoSyncHostState {
  const PhotoSyncHostInitial();
}

/// Starting the hotspot and HTTP server.
class PhotoSyncHostStarting extends PhotoSyncHostState {
  const PhotoSyncHostStarting();
}

/// HOST is active and waiting for clients.
class PhotoSyncHostReady extends PhotoSyncHostState {
  /// QR data string to display.
  final String qrData;

  /// SSID of the hotspot.
  final String ssid;

  /// List of connected client IPs.
  final Set<String> connectedClients;

  /// Received images (file paths on device).
  final List<File> receivedImages;

  /// Whether a new image was just received (for animation trigger).
  final bool hasNewImage;

  const PhotoSyncHostReady({
    required this.qrData,
    required this.ssid,
    this.connectedClients = const {},
    this.receivedImages = const [],
    this.hasNewImage = false,
  });

  PhotoSyncHostReady copyWith({
    String? qrData,
    String? ssid,
    Set<String>? connectedClients,
    List<File>? receivedImages,
    bool? hasNewImage,
  }) {
    return PhotoSyncHostReady(
      qrData: qrData ?? this.qrData,
      ssid: ssid ?? this.ssid,
      connectedClients: connectedClients ?? this.connectedClients,
      receivedImages: receivedImages ?? this.receivedImages,
      hasNewImage: hasNewImage ?? this.hasNewImage,
    );
  }
}

/// Error state.
class PhotoSyncHostError extends PhotoSyncHostState {
  final String message;
  const PhotoSyncHostError(this.message);
}
