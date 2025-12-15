import 'dart:io';
import 'dart:ui';
import 'package:digipad_flutter/screens/native_impl/optical_logic_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'optical_painter.dart';

class OpticalEditorScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> detections;

  const OpticalEditorScreen({
    super.key,
    required this.imagePath,
    required this.detections,
  });

  @override
  State<OpticalEditorScreen> createState() => _OpticalEditorScreenState();
}

class _OpticalEditorScreenState extends State<OpticalEditorScreen> {
  late OpticalController _controller;
  late File _imageFile;
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _imageFile = File(widget.imagePath);
    _controller = OpticalController();
    _loadImageAndInit();
  }

  // Async load image dimensions
  Future<void> _loadImageAndInit() async {
    try {
      final bytes = await _imageFile.readAsBytes();
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();

      if (mounted) {
        setState(() {
          _imageSize = Size(
            frame.image.width.toDouble(),
            frame.image.height.toDouble(),
          );
          // Pass the new map structure to the controller
          _controller.initialize(widget.detections, _imageSize!);
        });
      }
    } catch (e) {
      debugPrint("Error loading image for editor: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageSize == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Adjust Measurements"),
          backgroundColor: const Color(0xFF1C1C1E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.cyanAccent),
              onPressed: () {
                final results = _controller.results;
                if (results.isValid) {
                  Navigator.pop(context, results.toMap());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Invalid Calibration. Please align the reference circles.",
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // ---------------------
            // EDITOR AREA
            // ---------------------
            Expanded(
              flex: 3,
              child: Consumer<OpticalController>(
                builder: (context, controller, _) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate rendering metrics to map gestures correctly
                      final double scaleX =
                          constraints.maxWidth / _imageSize!.width;
                      final double scaleY =
                          constraints.maxHeight / _imageSize!.height;

                      // Use BoxFit.contain logic
                      final double scale = scaleX < scaleY ? scaleX : scaleY;

                      final double displayW = _imageSize!.width * scale;
                      final double displayH = _imageSize!.height * scale;

                      final double offsetX =
                          (constraints.maxWidth - displayW) / 2;
                      final double offsetY =
                          (constraints.maxHeight - displayH) / 2;

                      return GestureDetector(
                        onPanDown: (details) {
                          controller.handleTap(
                            details.localPosition,
                            scale,
                            Offset(offsetX, offsetY),
                          );
                        },
                        onPanUpdate: (details) {
                          controller.handleDrag(details.delta, scale);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 1. Background Image
                            Image.file(
                              _imageFile,
                              fit: BoxFit.contain,
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                            ),
                            // 2. Interactive Overlay
                            CustomPaint(
                              size: Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ),
                              painter: OpticalPainter(
                                points: controller.points,
                                leftLens: controller.leftLensRect,
                                rightLens: controller.rightLensRect,
                                selectedPoint: controller.selectedPoint,
                                selectedLensSide: controller.selectedLensSide,
                                imageSize: _imageSize!,
                                scale:
                                    scale, // Ensure painter knows scale if needed for stroke width
                                offset: Offset(offsetX, offsetY),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ---------------------
            // RESULTS PANEL
            // ---------------------
            Expanded(flex: 2, child: _buildInfoPanel()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Consumer<OpticalController>(
      builder: (context, ctrl, _) {
        final r = ctrl.results;
        return Container(
          color: const Color(0xFF121212),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Global Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem("IPD (DI)", r.ipd, isLarge: true),
                  _statItem("Bridge", r.bridge),
                ],
              ),
              const Divider(color: Colors.white24),
              // Eye Specific Stats
              Row(
                children: [
                  Expanded(
                    child: _eyeStat(
                      "Right Eye",
                      r.dnpRight,
                      r.heightRight,
                      r.diameterRight,
                    ),
                  ),
                  Container(width: 1, height: 60, color: Colors.white24),
                  Expanded(
                    child: _eyeStat(
                      "Left Eye",
                      r.dnpLeft,
                      r.heightLeft,
                      r.diameterLeft,
                    ),
                  ),
                ],
              ),
              // Lens Adjustment Slider
              if (ctrl.selectedLensSide != null)
                Row(
                  children: [
                    Text(
                      "Lens Size (${ctrl.selectedLensSide!.toUpperCase()}):",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value:
                            0, // In a real app, bind this to a relative offset or the actual lens width
                        min: -20,
                        max: 20,
                        activeColor: Colors.cyanAccent,
                        onChanged: (val) {
                          // Optional: Realtime visual feedback
                        },
                        onChangeEnd: (val) {
                          // Resizing logic via slider (adjust width/height)
                          ctrl.resizeSelectedLens(val, val);
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _statItem(String label, double value, {bool isLarge = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.white,
            fontSize: isLarge ? 28 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text("mm", style: TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _eyeStat(String side, double dnp, double height, double diam) {
    return Column(
      children: [
        Text(
          side,
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "DNP: ${dnp.toStringAsFixed(1)}",
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          "Height: ${height.toStringAsFixed(1)}",
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          "Eff. Diam: ${diam.toStringAsFixed(1)}",
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}
