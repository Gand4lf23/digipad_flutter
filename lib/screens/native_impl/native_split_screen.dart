import 'dart:io';
import 'dart:ui';
import 'package:digipad_flutter/screens/native_impl/optical_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class NativeSplitScreen extends StatefulWidget {
  const NativeSplitScreen({super.key});

  @override
  State<NativeSplitScreen> createState() => _NativeSplitScreenState();
}

class _NativeSplitScreenState extends State<NativeSplitScreen> {
  MethodChannel? _channel;

  // State variables
  bool _detectionEnabled = true;
  bool _torchEnabled = false;
  bool _frontCamera = false;
  bool _overlayVisible = true;
  String? _lastPhotoPath;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  bool _isCapturing = false;

  // Store the latest detections received from Native side
  // Format: { circles: [{x,y}...], eyes: [{x,y}...] }
  Map<String, dynamic> _latestDetections = {'circles': [], 'eyes': []};

  // UI constants
  static const Color _backgroundColor = Color(0xFF121212);
  static const Color _accentColor = Colors.deepPurpleAccent;
  static const Color _controlPanelColor = Color(0xFF1C1C1E);

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      if (mounted) {
        setState(() {
          _hasPermission = status.isGranted;
          _isCheckingPermission = false;
        });
        if (!_hasPermission) {
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
      if (!mounted) return;
      setState(() => _hasPermission = status.isGranted);

      if (status.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
      } else if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to use this feature.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error requesting permission: $e');
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _controlPanelColor,
        title: const Text(
          'Camera Permission Required',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Camera access has been permanently denied. Please enable it in the app settings to use this feature.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(color: _accentColor),
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
                    // Removed Screenshot widget wrapper
                    child: AndroidView(
                      viewType: viewType,
                      onPlatformViewCreated: _onPlatformViewCreated,
                      creationParamsCodec: const StandardMessageCodec(),
                    ),
                  ),
                ),
                Expanded(flex: 3, child: _buildControlPanel()),
              ],
            ),
            _buildBackButton(context),
          ],
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

    // Listen for callbacks from Kotlin
    _channel!.setMethodCallHandler((call) async {
      if (call.method == 'onDetections') {
        // Update the latest detections without calling setState to avoid lag
        // The data comes as { circles: [], eyes: [] }
        try {
          final data = Map<String, dynamic>.from(call.arguments);
          _latestDetections = data;
        } catch (e) {
          debugPrint("Error parsing detection data: $e");
        }
      }
    });

    // Initialize Native View Settings
    await Future.wait([
      _channel!.invokeMethod('setDetectionEnabled', {
        'enabled': _detectionEnabled,
      }),
      _channel!.invokeMethod('setTorch', {'enabled': _torchEnabled}),
      _channel!.invokeMethod('setFrontCamera', {'front': _frontCamera}),
      _channel!.invokeMethod('setOverlayVisible', {'visible': _overlayVisible}),
    ]);
  }

  Widget _buildPermissionRequestUI() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.camera_alt, size: 100, color: Colors.white24),
              const SizedBox(height: 24),
              const Text(
                'Camera Permission Required',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This feature requires access to your camera to capture images and perform detections.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _requestCameraPermission,
                icon: const Icon(Icons.security),
                label: const Text('Grant Permission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: openAppSettings,
                child: const Text(
                  'Open App Settings',
                  style: TextStyle(color: Colors.white54),
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
                label: 'Detection',
                value: _detectionEnabled,
                onChanged: (v) {
                  setState(() => _detectionEnabled = v);
                  _channel?.invokeMethod('setDetectionEnabled', {'enabled': v});
                },
              ),
              _buildCompactSwitch(
                label: 'Overlay',
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
                      icon: _torchEnabled ? Icons.flash_on : Icons.flash_off,
                      onPressed: () {
                        setState(() => _torchEnabled = !_torchEnabled);
                        _channel?.invokeMethod('setTorch', {
                          'enabled': _torchEnabled,
                        });
                      },
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
    if (_lastPhotoPath == null) {
      return const SizedBox(width: 48, height: 48);
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OpticalEditorScreen(
              imagePath: _lastPhotoPath!,
              detections: _latestDetections, // Pass existing detections
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

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      // 1. Trigger Native Capture
      // The Kotlin code saves the file and returns the absolute path string
      final String? nativePath = await _channel?.invokeMethod<String>(
        'capturePhoto',
      );

      if (nativePath != null) {
        // 2. Capture the current detections at this moment
        final Map<String, dynamic> detectionsSnapshot = Map.from(
          _latestDetections,
        );

        if (mounted) {
          setState(() {
            _lastPhotoPath = nativePath;
          });

          print("Detections at capture: $detectionsSnapshot");

          // 3. Navigate to preview
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OpticalEditorScreen(
                imagePath: nativePath,
                detections: detectionsSnapshot,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error capturing photo: $e");
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }
}

// class CapturedImageScreen extends StatelessWidget {
//   final String imagePath;
//   final Map<String, dynamic> detections;

//   const CapturedImageScreen({
//     super.key,
//     required this.imagePath,
//     required this.detections,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF121212),
//       appBar: AppBar(
//         title: const Text('Captured Image'),
//         backgroundColor: const Color(0xFF1C1C1E),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: InteractiveViewer(child: Image.file(File(imagePath))),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16),
//             color: Colors.black54,
//             child: Text(
//               "Detected: ${detections['circles'].length} circles, ${detections['eyes'].length} eyes",
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
