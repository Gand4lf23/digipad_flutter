import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'optical_logic_controller.dart';
import 'optical_painter.dart';

class OpticalEditorScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> detections;
  final bool isFrontCamera;

  const OpticalEditorScreen({
    super.key,
    required this.imagePath,
    required this.detections,
    this.isFrontCamera = false,
  });

  @override
  State<OpticalEditorScreen> createState() => _OpticalEditorScreenState();
}

class _OpticalEditorScreenState extends State<OpticalEditorScreen> {
  late OpticalController _controller;
  late File _imageFile;
  Size? _imageSize;
  final TransformationController _transformationController =
      TransformationController();

  bool _isMoveMode = false;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _imageFile = File(widget.imagePath);
    _controller = OpticalController();
    _loadImageAndInit();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _transformationController.dispose();
    super.dispose();
  }

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
          Map<String, dynamic> safeDetections = Map.from(widget.detections);
          List<dynamic> rawEyes = safeDetections['eyes'] ?? [];
          List<dynamic> rawCircles = safeDetections['circles'] ?? [];

          if (rawEyes.length < 2) {
            double centerY = 0.5;
            double centerX = 0.5;

            if (rawCircles.isNotEmpty) {
              double sumX = 0;
              double maxY = 0;

              for (var c in rawCircles) {
                final circle = Map<String, dynamic>.from(c);
                double x = (circle['x'] as num).toDouble();
                double y = (circle['y'] as num).toDouble();

                sumX += x;
                if (y > maxY) maxY = y;
              }

              centerX = sumX / rawCircles.length;

              centerY = maxY + 0.10;

              if (centerY > 0.9) centerY = 0.85;
            }

            final defaultRightEye = {'x': centerX - 0.08, 'y': centerY};

            final defaultLeftEye = {'x': centerX + 0.08, 'y': centerY};

            safeDetections['eyes'] = [defaultRightEye, defaultLeftEye];

            debugPrint(
              "⚠️ Eyes not detected. Generated defaults at Y=$centerY",
            );
          }

          _controller.initialize(safeDetections, _imageSize!);
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
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isMoveMode ? Icons.pan_tool : Icons.zoom_in,
                color: _isMoveMode ? Colors.greenAccent : Colors.white,
              ),
              tooltip: _isMoveMode
                  ? "Switch to Edit Mode"
                  : "Switch to Zoom Mode",
              onPressed: () {
                setState(() {
                  _isMoveMode = !_isMoveMode;
                });
              },
            ),
            Consumer<OpticalController>(
              builder: (context, controller, child) {
                final bool hasSelection =
                    controller.selectedPoint != null ||
                    controller.selectedLensSide != null;

                if (!hasSelection) return const SizedBox.shrink();

                return IconButton(
                  icon: const Icon(Icons.check, color: Colors.cyanAccent),
                  onPressed: () {
                    _controller.handleTap(Offset.zero, 1.0, Offset.zero);
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Consumer<OpticalController>(
                    builder: (context, controller, _) {
                      return InteractiveViewer(
                        transformationController: _transformationController,
                        maxScale: 5.0,
                        minScale: 1.0,
                        boundaryMargin: const EdgeInsets.all(double.infinity),
                        panEnabled: _isMoveMode,
                        scaleEnabled: _isMoveMode,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double scaleX =
                                constraints.maxWidth / _imageSize!.width;
                            final double scaleY =
                                constraints.maxHeight / _imageSize!.height;
                            final double scale = scaleX < scaleY
                                ? scaleX
                                : scaleY;

                            final double displayW = _imageSize!.width * scale;
                            final double displayH = _imageSize!.height * scale;

                            final double offsetX =
                                (constraints.maxWidth - displayW) / 2;
                            final double offsetY =
                                (constraints.maxHeight - displayH) / 2;

                            return GestureDetector(
                              onPanDown: _isMoveMode
                                  ? null
                                  : (details) {
                                      controller.handleTap(
                                        details.localPosition,
                                        scale,
                                        Offset(offsetX, offsetY),
                                      );
                                    },
                              onPanUpdate: _isMoveMode
                                  ? null
                                  : (details) {
                                      controller.handleDrag(
                                        details.delta,
                                        scale,
                                      );
                                    },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.flip(
                                    flipX: widget.isFrontCamera,
                                    child: Image.file(
                                      _imageFile,
                                      fit: BoxFit.contain,
                                      width: constraints.maxWidth,
                                      height: constraints.maxHeight,
                                    ),
                                  ),
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
                                      selectedLensSide:
                                          controller.selectedLensSide,
                                      imageSize: _imageSize!,
                                      scale: scale,
                                      offset: Offset(offsetX, offsetY),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  _buildNudgeControls(),
                ],
              ),
            ),
            Expanded(flex: 2, child: _buildInfoPanel()),
          ],
        ),
      ),
    );
  }

  Widget _buildNudgeControls() {
    return Consumer<OpticalController>(
      builder: (context, controller, child) {
        if (controller.selectedPoint == null || _isMoveMode) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _arrowButton(
                  Icons.keyboard_arrow_up,
                  () => controller.nudgeSelectedPoint(0, -1),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _arrowButton(
                      Icons.keyboard_arrow_left,
                      () => controller.nudgeSelectedPoint(-1, 0),
                    ),
                    const SizedBox(width: 40, height: 40),
                    _arrowButton(
                      Icons.keyboard_arrow_right,
                      () => controller.nudgeSelectedPoint(1, 0),
                    ),
                  ],
                ),
                _arrowButton(
                  Icons.keyboard_arrow_down,
                  () => controller.nudgeSelectedPoint(0, 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback action) {
    return GestureDetector(
      onTapDown: (_) {
        action();
        _holdTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          action();
        });
      },
      onTapUp: (_) => _holdTimer?.cancel(),
      onTapCancel: () => _holdTimer?.cancel(),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem("IPD (DI)", r.ipd, isLarge: true),
                  _statItem("Bridge", r.bridge),
                ],
              ),
              const Divider(color: Colors.white24),
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
              if (ctrl.selectedLensSide != null && !_isMoveMode)
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
                        value: 0,
                        min: -20,
                        max: 20,
                        activeColor: Colors.cyanAccent,
                        onChanged: (val) {},
                        onChangeEnd: (val) {
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
