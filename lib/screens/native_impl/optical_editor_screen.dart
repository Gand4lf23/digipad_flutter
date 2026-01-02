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
          _controller.initialize(widget.detections, _imageSize!);
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
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
          title: const Text("Ajuste Medidas"),
          backgroundColor: const Color(0xFF1C1C1E),
          actions: [
            IconButton(
              icon: Icon(
                _isMoveMode ? Icons.pan_tool : Icons.zoom_in,
                color: _isMoveMode ? Colors.greenAccent : Colors.white,
              ),
              onPressed: () => setState(() => _isMoveMode = !_isMoveMode),
            ),

            Builder(
              builder: (context) {
                if (_isMoveMode || _controller.selectedPoint != null) {
                  return IconButton(
                    icon: const Icon(Icons.check, color: Colors.cyanAccent),
                    onPressed: () {
                      setState(() => _isMoveMode = false);
                      _controller.selectedPoint = null;
                      _controller.notifyListeners();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 50,
              color: Colors.grey[900],
              child: Consumer<OpticalController>(
                builder: (context, ctrl, _) => Row(
                  children: [
                    Checkbox(
                      value: ctrl.showCircles,
                      activeColor: Colors.cyanAccent,
                      onChanged: (v) => ctrl.toggleCircles(v!),
                    ),
                    if (!ctrl.showCircles)
                      const Text(
                        "Guías",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),

                    if (ctrl.showCircles) ...[
                      Expanded(
                        child: Slider(
                          value: ctrl.referenceCircleDiameter,
                          min: 40,
                          max: 90,
                          divisions: 50,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white24,
                          onChanged: (v) => ctrl.setReferenceDiameter(v),
                        ),
                      ),
                      Text(
                        "Ref: ${ctrl.referenceCircleDiameter.round()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    const VerticalDivider(color: Colors.white24, width: 20),

                    Switch(
                      value: ctrl.isBifocal,
                      activeColor: Colors.orangeAccent,
                      onChanged: (v) => ctrl.toggleBifocal(v),
                    ),
                    if (ctrl.isBifocal) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_drop_up,
                          color: Colors.white,
                        ),
                        onPressed: () => ctrl.adjustBifocalLine(-5),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        onPressed: () => ctrl.adjustBifocalLine(5),
                      ),
                    ],
                  ],
                ),
              ),
            ),

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
                                    child: Image.file(_imageFile),
                                  ),
                                  CustomPaint(
                                    size: Size(
                                      constraints.maxWidth,
                                      constraints.maxHeight,
                                    ),
                                    painter: OpticalPainter(
                                      points: controller.points,
                                      selectedPoint: controller.selectedPoint,
                                      scale: scale,
                                      offset: Offset(offsetX, offsetY),

                                      showCircles: controller.showCircles,
                                      refDiameterMm:
                                          controller.referenceCircleDiameter,
                                      calcRadiusPxR:
                                          controller.calcRadiusPxRight,
                                      calcRadiusPxL:
                                          controller.calcRadiusPxLeft,
                                      pixelFactor: controller.pixelFactor,
                                      isBifocal: controller.isBifocal,
                                      bifocalOffset:
                                          controller.bifocalLineOffset,
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
        _holdTimer = Timer.periodic(
          const Duration(milliseconds: 50),
          (_) => action(),
        );
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
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Consumer<OpticalController>(
      builder: (context, ctrl, _) {
        return Container(
          color: const Color(0xFF121212),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem("IPD (DI)", ctrl.di, isLarge: true),
                  _statItem("Puente", ctrl.puente),
                  _statItem("Aro Anc", ctrl.aroAnc),
                  _statItem("Aro Alt", ctrl.aroAlt),
                ],
              ),
              const Divider(color: Colors.white24),

              Row(
                children: [
                  Expanded(
                    child: _eyeStat(
                      "Ojo Der (P1)",
                      ctrl.dnpRight,
                      ctrl.altRight,
                      ctrl.diametroRight,
                    ),
                  ),
                  Container(width: 1, height: 60, color: Colors.white24),
                  Expanded(
                    child: _eyeStat(
                      "Ojo Izq (P2)",
                      ctrl.dnpLeft,
                      ctrl.altLeft,
                      ctrl.diametroLeft,
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
          "Alt: ${height.toStringAsFixed(1)}",
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          "Diam: ${diam.toStringAsFixed(1)}",
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}
