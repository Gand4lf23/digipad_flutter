import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeSplitScreen extends StatefulWidget {
  const NativeSplitScreen({super.key});

  @override
  State<NativeSplitScreen> createState() => _NativeSplitScreenState();
}

class _NativeSplitScreenState extends State<NativeSplitScreen> {
  MethodChannel? _channel;
  bool _detectionEnabled = true;
  bool _torchEnabled = false;
  bool _frontCamera = false;
  bool _overlayVisible = true;
  String? _lastPhotoPath;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const viewType = 'native-left-view';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Row(
          children: [
            // Occupy ~70% of the screen for the native Android view
            Expanded(
              flex: 7,
              child: AndroidView(
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: {'text': 'Hello from Flutter!'},
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: (id) async {
                  _channel = MethodChannel('native-left-view/$id');
                  // Receive detection positions for logging
                  _channel!.setMethodCallHandler((call) async {
                    if (call.method == 'onDetections') {
                      final args = (call.arguments as Map?) ?? {};
                      final boxes = (args['boxes'] as List?) ?? const [];
                      final time = args['time'];
                      debugPrint('Detections (${boxes.length}) in ${time}ms');
                      for (final b in boxes) {
                        final m = b as Map;
                        debugPrint(
                          'box: x1=${m['x1']} y1=${m['y1']} x2=${m['x2']} y2=${m['y2']} cx=${m['cx']} cy=${m['cy']} w=${m['w']} h=${m['h']} cls=${m['cls']}',
                        );
                      }
                    }
                  });
                  // Apply initial states
                  await _channel?.invokeMethod('setDetectionEnabled', {
                    'enabled': _detectionEnabled,
                  });
                  await _channel?.invokeMethod('setTorch', {
                    'enabled': _torchEnabled,
                  });
                  await _channel?.invokeMethod('setFrontCamera', {
                    'front': _frontCamera,
                  });
                  await _channel?.invokeMethod('setOverlayVisible', {
                    'visible': _overlayVisible,
                  });
                },
              ),
            ),

            // Right side - Flutter UI
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.black,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    const Text(
                      'Controls',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_channel == null) return;
                        try {
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(context);
                          final path = await _channel!.invokeMethod<String>(
                            'capturePhoto',
                          );
                          setState(() => _lastPhotoPath = path);
                          if (path != null) {
                            nav.push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    CapturedImageScreen(imagePath: path),
                              ),
                            );
                            messenger.showSnackBar(
                              SnackBar(content: Text('Saved: $path')),
                            );
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Capture failed')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                    if (_lastPhotoPath != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Last photo: $_lastPhotoPath',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                    const Divider(color: Colors.white24),
                    SwitchListTile(
                      title: const Text(
                        'Detection',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _detectionEnabled,
                      onChanged: (v) async {
                        setState(() => _detectionEnabled = v);
                        await _channel?.invokeMethod('setDetectionEnabled', {
                          'enabled': v,
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Flash (torch)',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _torchEnabled,
                      onChanged: (v) async {
                        setState(() => _torchEnabled = v);
                        await _channel?.invokeMethod('setTorch', {
                          'enabled': v,
                        });
                      },
                      activeColor: Colors.yellow,
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Frontal camera',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _frontCamera,
                      onChanged: (v) async {
                        setState(() => _frontCamera = v);
                        await _channel?.invokeMethod('setFrontCamera', {
                          'front': v,
                        });
                      },
                      activeColor: Colors.lightBlueAccent,
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Overlay',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _overlayVisible,
                      onChanged: (v) async {
                        setState(() => _overlayVisible = v);
                        await _channel?.invokeMethod('setOverlayVisible', {
                          'visible': v,
                        });
                      },
                      activeColor: Colors.purpleAccent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void navigatorPushImage(BuildContext context, String imagePath) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CapturedImageScreen(imagePath: imagePath),
    ),
  );
}

class CapturedImageScreen extends StatelessWidget {
  final String imagePath;
  const CapturedImageScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captured Image')),
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}
