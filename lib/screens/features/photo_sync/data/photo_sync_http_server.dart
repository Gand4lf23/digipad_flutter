import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Callback when an image is received from a CLIENT.
typedef OnImageReceived = void Function(Uint8List imageBytes, String fileName);

/// Callback when a client connects or sends a heartbeat.
typedef OnClientConnected = void Function(String clientIp);

/// Lightweight HTTP server running on the HOST device.
/// Accepts POST /upload with raw JPEG body.
/// Also provides GET /ping for client connectivity checks.
class PhotoSyncHttpServer {
  HttpServer? _server;
  final int port;
  OnImageReceived? onImageReceived;
  OnClientConnected? onClientConnected;

  PhotoSyncHttpServer({this.port = 8080});

  bool get isRunning => _server != null;

  /// Start the HTTP server on the given port.
  Future<void> start() async {
    if (_server != null) return;

    _server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );

    debugPrint('[PhotoSyncServer] Listening on port $port');

    _server!.listen(
      _handleRequest,
      onError: (error) {
        debugPrint('[PhotoSyncServer] Server error: $error');
      },
    );
  }

  /// Stop the server.
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    debugPrint('[PhotoSyncServer] Stopped');
  }

  void _handleRequest(HttpRequest request) async {
    // Enable CORS for local network
    request.response.headers.set('Access-Control-Allow-Origin', '*');
    request.response.headers
        .set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.set('Access-Control-Allow-Headers', '*');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    final path = request.uri.path;
    debugPrint(
        '[PhotoSyncServer] ${request.method} $path from ${request.connectionInfo?.remoteAddress.address}');

    try {
      if (request.method == 'GET' && path == '/ping') {
        await _handlePing(request);
      } else if (request.method == 'POST' && path == '/upload') {
        await _handleUpload(request);
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('Not Found');
        await request.response.close();
      }
    } catch (e) {
      debugPrint('[PhotoSyncServer] Error handling request: $e');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.write('Internal Server Error');
        await request.response.close();
      } catch (_) {}
    }
  }

  Future<void> _handlePing(HttpRequest request) async {
    final clientIp = request.connectionInfo?.remoteAddress.address ?? 'unknown';
    onClientConnected?.call(clientIp);

    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    request.response.write('{"status":"ok"}');
    await request.response.close();
  }

  Future<void> _handleUpload(HttpRequest request) async {
    final clientIp = request.connectionInfo?.remoteAddress.address ?? 'unknown';
    onClientConnected?.call(clientIp);

    // Read all bytes from request body
    final chunks = <List<int>>[];
    await for (final chunk in request) {
      chunks.add(chunk);
    }

    final bytes = Uint8List.fromList(
      chunks.expand((chunk) => chunk).toList(),
    );

    if (bytes.isEmpty) {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write('Empty body');
      await request.response.close();
      return;
    }

    // Generate filename with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'photo_sync_$timestamp.jpg';

    debugPrint(
        '[PhotoSyncServer] Received ${bytes.length} bytes from $clientIp');
    onImageReceived?.call(bytes, fileName);

    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    request.response.write('{"status":"ok","fileName":"$fileName"}');
    await request.response.close();
  }
}
