import 'dart:io';
import 'dart:ui';
import 'package:digipad_flutter/screens/native_impl/optical_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:digipad_flutter/l10n/l10n.dart';

class NativeSplitScreen extends StatefulWidget {
  const NativeSplitScreen({super.key});

  @override
  State<NativeSplitScreen> createState() => _NativeSplitScreenState();
}

class _NativeSplitScreenState extends State<NativeSplitScreen>
    with WidgetsBindingObserver {
  MethodChannel? _channel;
  final ImagePicker _picker = ImagePicker();

  bool _detectionEnabled = true;
  bool _torchEnabled = false;
  bool _frontCamera = false;
  bool _overlayVisible = true;

  bool _streamDetections = false;

  String? _lastPhotoPath;
  bool _lastPhotoWasFront = false;
  // Store detections specifically for the last captured/picked photo
  Map<String, dynamic>? _lastPhotoDetections; // Make it nullable

  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  bool _isCapturing = false;

  static const Color _backgroundColor = Color(0xFF121212);
  static const Color _accentColor = Colors.deepPurpleAccent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkCameraPermission();
    }
  }

  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      if (mounted) {
        setState(() {
          _hasPermission = status.isGranted;
          _isCheckingPermission = false;
        });

        if (status.isDenied) {
          await _requestCameraPermission();
        }
      }
    } catch (e) {
      debugPrint('Error checking permission: $e');
      if (mounted) setState(() => _isCheckingPermission = false);
    }
  }

  Future<void> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();

      if (mounted) {
        setState(() => _hasPermission = status.isGranted);

        if (status.isPermanentlyDenied) {
          _showSettingsDialog();
        }
      }
    } catch (e) {
      debugPrint('Error requesting permission: $e');
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          context.l10n.cameraRequiredTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          context.l10n.cameraRequiredContent,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: Text(
              context.l10n.openSettings,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(child: CircularProgressIndicator(color: _accentColor)),
      );
    }

    if (!_hasPermission) {
      return _buildPermissionRequestUI();
    }

    const viewType = 'native-left-view';

    final Map<String, dynamic> creationParams = <String, dynamic>{
      'modelPath': 'assets/model3.tflite',
      'labelPath': 'assets/labels.txt',
    };

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 7,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        if (Platform.isAndroid)
                          AndroidView(
                            viewType: viewType,
                            layoutDirection: TextDirection.ltr,
                            creationParams: creationParams,
                            creationParamsCodec: const StandardMessageCodec(),
                            onPlatformViewCreated: _onPlatformViewCreated,
                          )
                        else if (Platform.isIOS)
                          UiKitView(
                            viewType: viewType,
                            layoutDirection: TextDirection.ltr,
                            creationParams: creationParams,
                            creationParamsCodec: const StandardMessageCodec(),
                            onPlatformViewCreated: _onPlatformViewCreated,
                          )
                        else
                          Center(
                            child: Text(
                              context.l10n.platformNotSupported,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        _buildGuideBox(),
                      ],
                    ),
                  ),
                ),
                Expanded(flex: 3, child: _buildControlPanel()),
              ],
            ),
            _buildBackButton(context),
            if (_isCapturing)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideBox() {
    final width = MediaQuery.of(context).size.width >= 768
        ? 400.0
        : (MediaQuery.of(context).size.width * 0.57);

    return Positioned(
      top: MediaQuery.of(context).size.width >= 768
          ? (MediaQuery.of(context).size.height) * 0.15
          : (MediaQuery.of(context).size.height) * 0.25,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Container(
            width: width,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white.withOpacity(0.3), size: 40),
                const SizedBox(height: 8),
                Text(
                  context.l10n.placeReferenceHere,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 16.0,
      left: 16.0,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onPlatformViewCreated(int id) async {
    _channel = MethodChannel('native-left-view/$id');

    _channel!.setMethodCallHandler((call) async {
      if (call.method == 'onDetections') {
        try {
          final data = Map<String, dynamic>.from(call.arguments);
          // Update the live detections
          setState(() {});
        } catch (e) {
          debugPrint("Error parsing detection data: $e");
        }
      }
    });

    await Future.wait([
      _channel!.invokeMethod('setDetectionEnabled', {
        'enabled': _detectionEnabled,
      }),
      _channel!.invokeMethod('setTorch', {'enabled': _torchEnabled}),
      _channel!.invokeMethod('setFrontCamera', {'front': _frontCamera}),
      _channel!.invokeMethod('setOverlayVisible', {'visible': _overlayVisible}),
      _channel!.invokeMethod('setStreamDetections', {
        'enabled': _streamDetections,
        'throttleMs': 50,
      }),
    ]);
  }

  List<Map<String, double>> _inflateDetections(dynamic rawList) {
    if (rawList == null) return [];

    final List<double> list = (rawList is List)
        ? rawList.map((e) => (e as num).toDouble()).toList()
        : (rawList as List<double>);

    List<Map<String, double>> result = [];
    for (int i = 0; i < list.length; i += 2) {
      if (i + 1 < list.length) {
        result.add({'x': list[i], 'y': list[i + 1]});
      }
    }
    return result;
  }

  Widget _buildPermissionRequestUI() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 100, color: Colors.white24),
              const SizedBox(height: 24),
              Text(
                context.l10n.cameraPermissionRequired,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.cameraPermissionExplain,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _accentColor),
                onPressed: _requestCameraPermission,
                child: Text(
                  context.l10n.grantPermission,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      color: _backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompactSwitch(
                label: context.l10n.detectionLabel,
                value: _detectionEnabled,
                onChanged: (v) {
                  setState(() => _detectionEnabled = v);
                  _channel?.invokeMethod('setDetectionEnabled', {'enabled': v});
                },
              ),
              _buildCompactSwitch(
                label: context.l10n.overlayLabel,
                value: _overlayVisible,
                onChanged: (v) {
                  setState(() => _overlayVisible = v);
                  _channel?.invokeMethod('setOverlayVisible', {'visible': v});
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconButton(
                      icon: Icons.photo_library,
                      onPressed: _pickFromGallery,
                    ),
                    const SizedBox(width: 24),
                    _buildPhotoButton(),
                    const SizedBox(width: 24),
                    _buildIconButton(
                      icon: Icons.flip_camera_ios_outlined,
                      onPressed: () {
                        setState(() => _frontCamera = !_frontCamera);
                        _channel?.invokeMethod('setFrontCamera', {
                          'front': _frontCamera,
                        });
                      },
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildLastPhotoThumbnail(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: _accentColor,
          inactiveThumbColor: Colors.grey[400],
          inactiveTrackColor: Colors.grey[800],
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 30),
      onPressed: onPressed,
    );
  }

  Widget _buildPhotoButton() {
    return SizedBox(
      width: 70,
      height: 70,
      child: ElevatedButton(
        onPressed: _isCapturing ? null : _capturePhoto,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
          side: const BorderSide(color: _accentColor, width: 4),
          padding: EdgeInsets.zero,
        ),
        child: _isCapturing
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: _accentColor,
                ),
              )
            : const Icon(Icons.camera, color: _accentColor, size: 35),
      ),
    );
  }

  Widget _buildLastPhotoThumbnail() {
    // Only show thumbnail if a photo path is set AND its detections are available
    if (_lastPhotoPath == null || _lastPhotoDetections == null) {
      return const SizedBox(width: 48, height: 48);
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OpticalEditorScreen(
              imagePath: _lastPhotoPath!,
              detections: _lastPhotoDetections!,
              isFrontCamera: _lastPhotoWasFront,
            ),
          ),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white38, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            File(_lastPhotoPath!),
            fit: BoxFit.cover,
            key: ValueKey(_lastPhotoPath),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    if (_isCapturing) return;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Show loading
      setState(() => _isCapturing = true);

      final String path = image.path;
      final result = await _channel?.invokeMethod('detectFromImage', {
        'path': path,
      });

      if (result != null) {
        final Map<String, dynamic> rawMap = Map<String, dynamic>.from(result);

        final Map<String, dynamic> detections = {
          'circles': _inflateDetections(rawMap['circles']),
          'eyes': _inflateDetections(rawMap['eyes']),
        };

        if (mounted) {
          setState(() {
            _lastPhotoPath = path;
            _lastPhotoWasFront = false;
            _lastPhotoDetections = detections; // Store specific detections
            _isCapturing = false;
          });

          final List circles = detections['circles'] as List;

          // With the threshold lowered in Android, we should find 4 circles more often
          if (circles.length == 4) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OpticalEditorScreen(
                  imagePath: path,
                  detections: detections,
                  isFrontCamera: false,
                ),
              ),
            );
          } else {
            // Helpful error message for debugging
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.detectionIncomplete(circles.length)),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } else {
        if (mounted) setState(() => _isCapturing = false);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final result = await _channel?.invokeMethod('capturePhoto');

      if (result != null && result is Map) {
        final String? nativePath = result['path'] as String?;
        final Map<String, dynamic> rawDetections = Map.from(
          result['detections'],
        );

        if (nativePath != null) {
          final Map<String, dynamic> detectionsSnapshot = {
            'circles': _inflateDetections(rawDetections['circles']),
            'eyes': _inflateDetections(rawDetections['eyes']),
          };

          final bool wasFront = _frontCamera;

          if (mounted) {
            setState(() {
              _lastPhotoPath = nativePath;
              _lastPhotoWasFront = wasFront;
              // Store the detections for this captured image
              _lastPhotoDetections = detectionsSnapshot;
            });

            // CHECK: Only navigate if exactly 4 circles are found
            final List circles = detectionsSnapshot['circles'] as List;
            if (circles.length == 4) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OpticalEditorScreen(
                    imagePath: nativePath,
                    detections: detectionsSnapshot, // This is already correct
                    isFrontCamera: wasFront,
                  ),
                ),
              );
            } else {
              // Show error if circles != 4
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Capture failed: Found ${circles.length} circles (4 required). Try adjusting lighting or distance.",
                  ),
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error capturing photo: $e");
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }
}
