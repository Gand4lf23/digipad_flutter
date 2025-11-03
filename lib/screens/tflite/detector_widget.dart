import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:digipad_flutter/screens/tflite/box_widget.dart';
import 'package:digipad_flutter/screens/tflite/models/recognition.dart';
import 'package:digipad_flutter/screens/tflite/models/screen_params.dart';
import 'package:digipad_flutter/screens/tflite/service/detector_service.dart';
import 'package:digipad_flutter/screens/tflite/stats_widget.dart';
import 'package:flutter/material.dart';

/// [DetectorWidget] sends each frame for inference
class DetectorWidget extends StatefulWidget {
  /// Constructor
  const DetectorWidget({super.key});

  @override
  State<DetectorWidget> createState() => _DetectorWidgetState();
}

class _DetectorWidgetState extends State<DetectorWidget>
    with WidgetsBindingObserver {
  /// List of available cameras
  late List<CameraDescription> cameras;

  /// Controller
  CameraController? _cameraController;

  // use only when initialized, so - not null
  get _controller => _cameraController!;

  /// Object Detector is running on a background [Isolate].
  Detector? _detector;
  StreamSubscription? _subscription;

  /// Results to draw bounding boxes
  List<Recognition>? results;

  /// Realtime stats
  Map<String, String>? stats;

  /// Flag to indicate that initialization is in progress
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStateAsync();
  }

  Future<void> _initStateAsync() async {
    // Prevent re-initialization if already in progress
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      // Step 1: Initialize Camera
      cameras = await availableCameras();
      _cameraController = CameraController(
        cameras[1], // cameras[0] for back-camera, cameras[1] for front-camera
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();

      // Step 2: Initialize Detector
      _detector = await Detector.start();

      // Step 3: Listen to detector's results stream
      _subscription = _detector?.resultsStream.stream.listen((values) {
        if (mounted) {
          print('values: stats: $stats, recognitions: $results');
          // Check if the widget is still in the tree
          setState(() {
            results = values['recognitions'];
            stats = values['stats'];
          });
        }
      });

      // Step 4: Start the camera stream only after everything is ready
      await _controller.startImageStream(onLatestImageAvailable);

      ScreenParams.previewSize = _controller.value.previewSize;

      if (!mounted) return;
      // Añade estas dos líneas
      ScreenParams.screenPreviewSize = MediaQuery.of(context).size;
      ScreenParams.inputImageSize = const Size(
        480,
        480,
      ); // O el tamaño de tu modelo
    } catch (e) {
      print('Error during initialization: $e');
    }

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while initializing
    if (_cameraController == null ||
        !_controller.value.isInitialized ||
        _isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    // Use a variable to avoid multiple calculations
    final aspect = 1 / _controller.value.aspectRatio;

    return Stack(
      children: [
        AspectRatio(aspectRatio: aspect, child: CameraPreview(_controller)),
        // Stats
        _statsWidget(),
        // Bounding boxes
        AspectRatio(aspectRatio: aspect, child: _boundingBoxes()),
      ],
    );
  }

  Widget _statsWidget() => (stats != null)
      ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.white.withAlpha(150),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: stats!.entries
                    .map((e) => StatsWidget(e.key, e.value))
                    .toList(),
              ),
            ),
          ),
        )
      : const SizedBox.shrink();

  /// Returns Stack of bounding boxes
  Widget _boundingBoxes() {
    if (results == null) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: results!.map((box) => BoxWidget(result: box)).toList(),
    );
  }

  /// Callback to receive each frame [CameraImage] and pass it to the detector
  void onLatestImageAvailable(CameraImage cameraImage) {
    // Ensure detector is initialized before processing frames
    if (_detector != null && (!_detector!.resultsStream.isClosed)) {
      _detector?.processFrame(cameraImage);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_cameraController == null || !_controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.inactive:
        _stopEverything();
        break;
      case AppLifecycleState.resumed:
        _initStateAsync();
        break;
      default:
    }
  }

  Future<void> _stopEverything() async {
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    _cameraController = null;
    _detector?.stop();
    _subscription?.cancel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopEverything();
    super.dispose();
  }
}
