import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'photo_sync_config.dart';

/// HTTP client for the CLIENT device to communicate with the HOST.
/// Sends images via POST /upload, checks connectivity via GET /ping.
class PhotoSyncHttpClient {
  final PhotoSyncConfig config;
  static const _timeout = Duration(seconds: 10);
  static const _maxRetries = 2;

  PhotoSyncHttpClient(this.config);

  /// Ping the host to verify connectivity.
  /// Returns true if the host is reachable.
  Future<bool> ping() async {
    try {
      final client = HttpClient()..connectionTimeout = _timeout;
      final request = await client.getUrl(
        Uri.parse('http://${config.hostIp}:${config.port}/ping'),
      );
      final response = await request.close().timeout(_timeout);
      client.close();
      return response.statusCode == HttpStatus.ok;
    } catch (e) {
      debugPrint('[PhotoSyncClient] Ping failed: $e');
      return false;
    }
  }

  /// Upload image bytes to the host with automatic retry.
  /// Returns true on success.
  Future<bool> uploadImage(Uint8List imageBytes) async {
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          debugPrint(
              '[PhotoSyncClient] Retry attempt $attempt/$_maxRetries');
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }

        final client = HttpClient()..connectionTimeout = _timeout;
        final request = await client.postUrl(
          Uri.parse(config.uploadUrl),
        );

        request.headers.contentType = ContentType('image', 'jpeg');
        request.contentLength = imageBytes.length;
        request.add(imageBytes);

        final response = await request.close().timeout(_timeout);
        client.close();

        if (response.statusCode == HttpStatus.ok) {
          debugPrint(
              '[PhotoSyncClient] Upload successful (${imageBytes.length} bytes)');
          return true;
        }

        debugPrint(
            '[PhotoSyncClient] Upload failed with status ${response.statusCode}');
      } catch (e) {
        debugPrint('[PhotoSyncClient] Upload error: $e');
      }
    }

    debugPrint('[PhotoSyncClient] All upload attempts failed');
    return false;
  }
}
