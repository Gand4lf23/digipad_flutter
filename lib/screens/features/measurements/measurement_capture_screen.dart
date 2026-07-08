import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:digipad_flutter/screens/features/measurements/optical_editor_screen.dart';
import 'package:digipad_flutter/data/local/gallery_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:digipad_flutter/l10n/l10n.dart';

class MeasurementCaptureScreen extends StatefulWidget {
  const MeasurementCaptureScreen({super.key});

  @override
  State<MeasurementCaptureScreen> createState() =>
      _MeasurementCaptureScreenState();
}

class _MeasurementCaptureScreenState extends State<MeasurementCaptureScreen>
    with WidgetsBindingObserver {
  MethodChannel? _channel;
  final ImagePicker _picker = ImagePicker();

  late final ValueNotifier<bool> _galleryModeNotifier;

  bool _detectionEnabled = true;
  final bool _torchEnabled = false;
  bool _frontCamera = false;
  bool _overlayVisible = true;
  final bool _streamDetections = false;

  String? _lastPhotoPath;
  bool _lastPhotoWasFront = false;
  Map<String, dynamic>? _lastPhotoDetections;

  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  bool _isCapturing = false;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final ValueNotifier<double> _pantoscopicAngleNotifier = ValueNotifier(0.0);
  int _lastAccelMs = 0;

  static const Color _backgroundColor = Color(0xFF121212);
  static const Color _accentColor = Colors.deepPurpleAccent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _galleryModeNotifier = ValueNotifier<bool>(true);
    _galleryModeNotifier.addListener(_onGalleryModeChanged);

    _accelerometerSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      if (nowMs - _lastAccelMs < 100) return; // ~10 fps is enough for display
      _lastAccelMs = nowMs;
      // Pantoscopic angle = deviation from vertical.
      // 0° when phone is upright (screen facing user); ~15° when tilted naturally
      // during measurement. atan2(|xz|, -y) gives 0° at rest and grows as the
      // device tilts away from vertical regardless of which lateral axis tilts.
      final tilt = sqrt(event.x * event.x + event.z * event.z);
      _pantoscopicAngleNotifier.value = atan2(event.z, event.y) * (180 / pi);
      debugPrint(
        '[PantoAngle] '
        'x=${event.x.toStringAsFixed(2)} '
        'y=${event.y.toStringAsFixed(2)} '
        'z=${event.z.toStringAsFixed(2)} | '
        'tilt=${tilt.toStringAsFixed(2)} | '
        'θ=${_pantoscopicAngleNotifier.value.toStringAsFixed(1)}°',
      );
    });

    _checkCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _accelerometerSubscription?.cancel();
    _pantoscopicAngleNotifier.dispose();
    _galleryModeNotifier.removeListener(_onGalleryModeChanged);
    _galleryModeNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkCameraPermission();
    }
  }

  void _onGalleryModeChanged() {
    final isGalleryOnly = _galleryModeNotifier.value;
    if (_channel != null) {
      _channel!.invokeMethod('setDetectionEnabled', {
        'enabled': isGalleryOnly ? false : _detectionEnabled,
      });
      _channel!.invokeMethod('setOverlayVisible', {
        'visible': isGalleryOnly ? false : _overlayVisible,
      });
      _channel!.invokeMethod('setStreamDetections', {
        'enabled': isGalleryOnly ? false : _streamDetections,
        'throttleMs': 50,
      });
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
        child: ValueListenableBuilder<bool>(
          valueListenable: _galleryModeNotifier,
          builder: (context, isGalleryOnly, child) {
            return Stack(
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
                                creationParamsCodec:
                                    const StandardMessageCodec(),
                                onPlatformViewCreated: _onPlatformViewCreated,
                              )
                            else if (Platform.isIOS)
                              UiKitView(
                                viewType: viewType,
                                layoutDirection: TextDirection.ltr,
                                creationParams: creationParams,
                                creationParamsCodec:
                                    const StandardMessageCodec(),
                                onPlatformViewCreated: _onPlatformViewCreated,
                              )
                            else
                              Center(
                                child: Text(
                                  context.l10n.platformNotSupported,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),

                            if (isGalleryOnly)
                              Container(
                                color: _backgroundColor,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.photo_camera_outlined,
                                        size: 80,
                                        color: Colors.white24,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        context.l10n.nativeSplitGalleryOnlyHint,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              _buildGuideBox(),
                          ],
                        ),
                      ),
                    ),
                    Expanded(flex: 3, child: _buildControlPanel(isGalleryOnly)),
                  ],
                ),
                _buildBackButton(context),
                _buildGalleryToggle(),
                if (!isGalleryOnly) _buildInclinometerOverlay(),
                if (_isCapturing)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 14),
                          const Text(
                            'Analizando...',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGalleryToggle() {
    return Positioned(
      top: 16.0,
      right: 16.0,
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              _galleryModeNotifier.value
                  ? context.l10n.nativeSplitModeGallery
                  : context.l10n.nativeSplitModeCamera,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              height: 24,
              child: Switch(
                value: _galleryModeNotifier.value,
                onChanged: (val) {
                  _galleryModeNotifier.value = val;
                },
                activeThumbColor: _accentColor,
                activeTrackColor: _accentColor.withValues(alpha: 0.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInclinometerOverlay() {
    return Positioned(
      top: 80.0,
      right: 16.0,
      child: ValueListenableBuilder<double>(
        valueListenable: _pantoscopicAngleNotifier,
        builder: (context, angle, _) {
          final isGoodAngle = angle >= 0 && angle <= 15;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isGoodAngle ? Colors.greenAccent : Colors.redAccent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.screen_rotation,
                  color: isGoodAngle ? Colors.greenAccent : Colors.redAccent,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  '${angle.toStringAsFixed(1)}°',
                  style: TextStyle(
                    color: isGoodAngle ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuideBox() {
    final width = MediaQuery.of(context).size.width >= 768
        ? 400.0
        : (MediaQuery.of(context).size.width * 0.8);

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
                color: Colors.white.withValues(alpha: 0.5),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.placeReferenceHere,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
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
                color: Colors.black.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
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
      if (!mounted) return;
      // onDetections: native sends detection overlay data; handled natively
    });

    final isGalleryOnly = _galleryModeNotifier.value;

    await Future.wait([
      _channel!.invokeMethod('setDetectionEnabled', {
        'enabled': isGalleryOnly ? false : _detectionEnabled,
      }),
      _channel!.invokeMethod('setTorch', {'enabled': _torchEnabled}),
      _channel!.invokeMethod('setFrontCamera', {'front': _frontCamera}),
      _channel!.invokeMethod('setOverlayVisible', {
        'visible': isGalleryOnly ? false : _overlayVisible,
      }),
      _channel!.invokeMethod('setStreamDetections', {
        'enabled': isGalleryOnly ? false : _streamDetections,
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

  Widget _buildControlPanel(bool isGalleryOnly) {
    return Container(
      color: _backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (!isGalleryOnly)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCompactSwitch(
                  label: context.l10n.detectionLabel,
                  value: _detectionEnabled,
                  onChanged: (v) {
                    setState(() => _detectionEnabled = v);
                    _channel?.invokeMethod('setDetectionEnabled', {
                      'enabled': v,
                    });
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
                      onPressed: () => _showGalleryOptions(),
                    ),
                    const SizedBox(width: 24),
                    _buildPhotoButton(isGalleryOnly),
                    const SizedBox(width: 24),
                    if (!isGalleryOnly)
                      _buildIconButton(
                        icon: Icons.flip_camera_ios_outlined,
                        onPressed: () {
                          setState(() => _frontCamera = !_frontCamera);
                          _channel?.invokeMethod('setFrontCamera', {
                            'front': _frontCamera,
                          });
                        },
                      )
                    else
                      const SizedBox(width: 48),
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
          activeThumbColor: _accentColor,
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

  Widget _buildPhotoButton(bool isGalleryOnly) {
    return SizedBox(
      width: 70,
      height: 70,
      child: ElevatedButton(
        onPressed: _isCapturing
            ? null
            : (isGalleryOnly
                  ? () => _pickImage(ImageSource.camera)
                  : _capturePhoto),
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
            : Icon(
                isGalleryOnly ? Icons.camera_alt : Icons.camera,
                color: _accentColor,
                size: 35,
              ),
      ),
    );
  }

  Widget _buildLastPhotoThumbnail() {
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

  Future<void> _processImagePath(String path, {double? angle}) async {
    setState(() => _isCapturing = true);
    // Let the loading overlay render for at least one frame before blocking
    // on the native channel (especially fast on emulator).
    await Future.delayed(const Duration(milliseconds: 80));

    try {
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
          final List circles = detections['circles'] as List;
          final int found = circles.length;

          setState(() {
            _lastPhotoPath = path;
            _lastPhotoWasFront = false;
            _lastPhotoDetections = detections;
            _isCapturing = false;
          });

          // Avisar si la detección fue parcial, pero siempre abrir el editor.
          // El controlador coloca puntos genéricos (tipo anteojos) para los no detectados.
          if (found < 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.detectionIncomplete(found)),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OpticalEditorScreen(
                imagePath: path,
                detections: detections,
                isFrontCamera: false,
                pantoscopicAngle: angle,
              ),
            ),
          );
        }
      } else {
        if (mounted) setState(() => _isCapturing = false);
      }
    } catch (e) {
      debugPrint("Error picking/processing image: $e");
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isCapturing) return;
    // Snapshot the angle before opening the picker: for a camera shot the phone
    // is still in measurement position right now; after the system camera opens
    // orientation may change completely.
    final double? angleSnapshot =
        source == ImageSource.camera ? _pantoscopicAngleNotifier.value : null;
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image == null) return;
      // Show loading overlay immediately before detection starts
      if (mounted) setState(() => _isCapturing = true);
      await _processImagePath(
        image.path,
        angle: angleSnapshot,
      );
    } catch (e) {
      debugPrint("Error capturing using image picker: $e");
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _showInternalGallery() {
    showDialog(
      context: context,
      builder: (ctx) => _InternalGalleryDialog(
        onProcessImage: (path) {
          Navigator.of(ctx).pop();
          _processImagePath(path);
        },
      ),
    );
  }

  void _showGalleryOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: Text(
                context.l10n.galleryTitle,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sd_storage, color: Colors.white),
              title: Text(
                context.l10n.vmInternalGallery,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showInternalGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);
    // Capture angle NOW — before the native call plays the shutter sound and
    // runs TFLite detection (which can take several hundred ms). By the time
    // the native call returns the user may have already moved the device.
    final double angleAtCapture = _pantoscopicAngleNotifier.value;

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
          final List circles = detectionsSnapshot['circles'] as List;
          final int found = circles.length;

          if (mounted) {
            setState(() {
              _lastPhotoPath = nativePath;
              _lastPhotoWasFront = wasFront;
              _lastPhotoDetections = detectionsSnapshot;
            });

            // Avisar si la detección fue parcial, pero siempre abrir el editor.
            if (found < 4) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.captureFailed(found)),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 2),
                ),
              );
            }

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OpticalEditorScreen(
                  imagePath: nativePath,
                  detections: detectionsSnapshot,
                  isFrontCamera: wasFront,
                  pantoscopicAngle: angleAtCapture,
                ),
              ),
            );
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

// ── Internal gallery dialog with real-time updates, X delete, multi-select ───

class _InternalGalleryDialog extends StatefulWidget {
  final void Function(String path) onProcessImage;
  const _InternalGalleryDialog({required this.onProcessImage});

  @override
  State<_InternalGalleryDialog> createState() => _InternalGalleryDialogState();
}

class _InternalGalleryDialogState extends State<_InternalGalleryDialog> {
  bool _selecting = false;
  final Set<String> _selected = {};

  void _enterSelect(File file) {
    setState(() {
      _selecting = true;
      _selected.add(file.path);
    });
  }

  void _toggleSelect(File file) {
    setState(() {
      if (_selected.contains(file.path)) {
        _selected.remove(file.path);
        if (_selected.isEmpty) _selecting = false;
      } else {
        _selected.add(file.path);
      }
    });
  }

  void _exitSelect() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  Future<bool> _confirmDelete(int count) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.grey.shade800,
            title: Text(
              count == 1 ? '¿Eliminar foto?' : 'Eliminar $count fotos',
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              count == 1
                  ? '¿Estás seguro de que querés eliminar esta foto?'
                  : '¿Eliminar las $count fotos seleccionadas?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Eliminar',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteSingle(File file) async {
    final ok = await _confirmDelete(1);
    if (!ok || !mounted) return;
    await GalleryStorage.instance.deleteImage(file);
  }

  Future<void> _deleteSelected(List<File> allImages) async {
    final files =
        allImages.where((f) => _selected.contains(f.path)).toList();
    if (files.isEmpty) return;
    final ok = await _confirmDelete(files.length);
    if (!ok || !mounted) return;
    for (final f in files) {
      await GalleryStorage.instance.deleteImage(f);
    }
    _exitSelect();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade700),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: StreamBuilder<List<File>>(
          stream: GalleryStorage.instance.watchImages(),
          builder: (ctx, snap) {
            final images = snap.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.vmInternalGallery,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                if (_selecting) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${_selected.length} seleccionada${_selected.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _deleteSelected(images),
                        icon: const Icon(Icons.delete_rounded,
                            size: 16, color: Colors.redAccent),
                        label: const Text('Eliminar',
                            style: TextStyle(color: Colors.redAccent)),
                        style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact),
                      ),
                      TextButton(
                        onPressed: _exitSelect,
                        style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact),
                        child: const Text('Cancelar',
                            style: TextStyle(color: Colors.white38)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Expanded(
                  child: snap.connectionState == ConnectionState.waiting &&
                          images.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : images.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.no_photography,
                                      size: 64, color: Colors.white24),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.l10n.vmNoImages,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                final file = images[index];
                                final isSelected =
                                    _selected.contains(file.path);
                                return GestureDetector(
                                  onTap: _selecting
                                      ? () => _toggleSelect(file)
                                      : () =>
                                          widget.onProcessImage(file.path),
                                  onLongPress: _selecting
                                      ? null
                                      : () => _enterSelect(file),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 150),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: isSelected
                                          ? Border.all(
                                              color:
                                                  const Color(0xFF6C63FF),
                                              width: 3)
                                          : Border.all(
                                              color: Colors.transparent,
                                              width: 3),
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(9),
                                          child: Image.file(file,
                                              fit: BoxFit.cover),
                                        ),
                                        if (_selecting)
                                          Positioned(
                                            top: 6,
                                            left: 6,
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 150),
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(
                                                        0xFF6C63FF)
                                                    : Colors.black54,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white60,
                                                    width: 1.5),
                                              ),
                                              child: isSelected
                                                  ? const Icon(
                                                      Icons.check_rounded,
                                                      color: Colors.white,
                                                      size: 15)
                                                  : null,
                                            ),
                                          ),
                                        if (!_selecting)
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _deleteSingle(file),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade900
                                                      .withValues(alpha: 0.85),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 18),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
