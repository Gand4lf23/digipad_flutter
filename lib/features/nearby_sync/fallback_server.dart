import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'nearby_service.dart';

class FallbackServer {
  static HttpServer? _server;
  static final _imageCtrl = StreamController<NearbyReceivedImage>.broadcast();

  static Stream<NearbyReceivedImage> get imageReceived => _imageCtrl.stream;

  static Future<bool> startServer() async {
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);

      _server!.listen((HttpRequest request) async {
        if (request.method == 'POST' && request.uri.path == '/upload') {
          try {
            final List<int> bytes = [];
            await for (var chunk in request) {
              bytes.addAll(chunk);
            }
            final fileName =
                'fallback_${DateTime.now().millisecondsSinceEpoch}.jpg';
            _imageCtrl.add(
              NearbyReceivedImage(
                endpointId: 'fallback-client',
                fileName: fileName,
                bytes: Uint8List.fromList(bytes),
              ),
            );
            request.response
              ..statusCode = HttpStatus.ok
              ..write('OK');
          } catch (e) {
            request.response
              ..statusCode = HttpStatus.internalServerError
              ..write('Error: $e');
          } finally {
            await request.response.close();
          }
        } else {
          request.response
            ..statusCode = HttpStatus.notFound
            ..write('Not found');
          await request.response.close();
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
  }
}
