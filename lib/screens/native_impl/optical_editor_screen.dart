import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'dart:math' as math;
import 'package:digipad_flutter/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
  Size? _viewportSize;
  final TransformationController _transformationController =
      TransformationController();

  bool _isMoveMode = false;
  bool _showAjustePanel = false;
  Timer? _holdTimer;

  double _imageRotation = 0.0;

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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _applyAutoRotation();
          _applyAutoZoom();
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _applyAutoRotation() {
    Offset? pRight;
    Offset? pLeft;

    for (var p in _controller.points) {
      if (p.type == DetectionType.pupilRight) pRight = p.position;
      if (p.type == DetectionType.pupilLeft) pLeft = p.position;
    }

    if (pRight == null || pLeft == null) return;

    final double dy = pLeft.dy - pRight.dy;
    final double dx = pLeft.dx - pRight.dx;

    double angle = math.atan2(dy, dx);

    if (angle > math.pi / 2) {
      angle -= math.pi;
    } else if (angle < -math.pi / 2) {
      angle += math.pi;
    }

    if (angle.abs() > 0.01) {
      setState(() {
        _imageRotation = -angle;
      });
      debugPrint(
        "🔄 Auto-rotation: ${(_imageRotation * 180 / math.pi).toStringAsFixed(1)}° applied",
      );
    } else {
      setState(() => _imageRotation = 0.0);
    }
  }

  void _applyAutoZoom() {
    final targetTypes = [
      DetectionType.lensRightTop,
      DetectionType.lensLeftTop,
      DetectionType.lensRightBottom,
      DetectionType.lensLeftBottom,
      DetectionType.pupilRight,
      DetectionType.pupilLeft,
    ];

    final points = _controller.points
        .where((p) => targetTypes.contains(p.type))
        .map((p) => p.position)
        .toList();

    if (points.length < 2) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || _imageSize == null) return;

    final Size viewportSize = renderBox.size;

    double minX = points.map((p) => p.dx).reduce(math.min);
    double maxX = points.map((p) => p.dx).reduce(math.max);
    double minY = points.map((p) => p.dy).reduce(math.min);
    double maxY = points.map((p) => p.dy).reduce(math.max);

    final double rawCenterX = (minX + maxX) / 2;
    final double rawCenterY = (minY + maxY) / 2;
    final double rawWidth = maxX - minX;

    final double scaleX = viewportSize.width / _imageSize!.width;
    final double scaleY = viewportSize.height / _imageSize!.height;
    final double fitScale = math.min(scaleX, scaleY);

    final double offsetX =
        (viewportSize.width - (_imageSize!.width * fitScale)) / 2;
    final double offsetY =
        (viewportSize.height - (_imageSize!.height * fitScale)) / 2;

    final double currentVisualX = (rawCenterX * fitScale) + offsetX;
    final double currentVisualY = (rawCenterY * fitScale) + offsetY;

    final double calculatedZoom =
        (viewportSize.width * 0.85) / (rawWidth * fitScale);
    final double targetZoom = calculatedZoom.clamp(1.5, 4.0);
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final double screenTargetX = viewportSize.width * 0.5;
    final double screenTargetY = viewportSize.height * (isTablet ? 0.7 : 0.7);

    final double translationX = screenTargetX - (currentVisualX * targetZoom);
    final double translationY = screenTargetY - (currentVisualY * targetZoom);

    final Matrix4 matrix = Matrix4.identity();
    matrix[0] = targetZoom;
    matrix[5] = targetZoom;
    matrix[12] = translationX;
    matrix[13] = translationY;

    _transformationController.value = matrix;
  }

  void _resetZoom() {
    setState(() => _imageRotation = 0.0);
    _transformationController.value = Matrix4.identity();
  }

  /// Un-rotate a touch position from the rotated widget's local space
  /// back to the original image-aligned coordinate space.
  ///
  /// The GestureDetector lives inside Transform.rotate, so Flutter already
  /// delivers localPosition in the rotated frame. We need to reverse that
  /// rotation around the widget center before passing to the controller,
  /// which works entirely in original image pixel coordinates.
  Offset _unrotatePosition(Offset rotatedPos, BoxConstraints constraints) {
    if (_imageRotation == 0.0) return rotatedPos;
    final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
    final d = rotatedPos - center;
    final cos = math.cos(-_imageRotation);
    final sin = math.sin(-_imageRotation);
    return center + Offset(d.dx * cos - d.dy * sin, d.dx * sin + d.dy * cos);
  }

  /// Un-rotate a drag delta vector from screen space to image space.
  Offset _unrotateDelta(Offset delta) {
    if (_imageRotation == 0.0) return delta;
    final cos = math.cos(-_imageRotation);
    final sin = math.sin(-_imageRotation);
    return Offset(
      delta.dx * cos - delta.dy * sin,
      delta.dx * sin + delta.dy * cos,
    );
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
          title: Text(context.l10n.measureAdjustments),
          backgroundColor: const Color(0xFF1C1C1E),
          actions: [
            TextButton(
              onPressed: _resetZoom,
              child: Text(
                context.l10n.resetZoom,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _showResultsSheet,
              tooltip: context.l10n.shareResults,
            ),
            IconButton(
              icon: Icon(
                Icons.tune,
                color: _showAjustePanel ? Colors.orangeAccent : Colors.white,
              ),
              onPressed: () =>
                  setState(() => _showAjustePanel = !_showAjustePanel),
              tooltip: context.l10n.calibration,
            ),
            IconButton(
              icon: Icon(
                _isMoveMode ? Icons.pan_tool : Icons.zoom_in,
                color: _isMoveMode ? Colors.greenAccent : Colors.white,
              ),
              onPressed: () => setState(() => _isMoveMode = !_isMoveMode),
              tooltip: _isMoveMode
                  ? context.l10n.editMode
                  : context.l10n.zoomMode,
            ),

            Builder(
              builder: (context) {
                if (_isMoveMode || _controller.selectedPoint != null) {
                  return IconButton(
                    icon: const Icon(Icons.check, color: Colors.cyanAccent),
                    onPressed: () {
                      setState(() {
                        _isMoveMode = false;
                        _showAjustePanel = false;
                      });
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
            _buildTopControls(),
            if (_showAjustePanel) _buildCalibrationPanel(),
            Expanded(
              flex: 3,
              child: Stack(
                children: [_buildImageViewer(), _buildNudgeControls()],
              ),
            ),
            Expanded(flex: 2, child: _buildInfoPanel()),
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer() {
    return Consumer<OpticalController>(
      builder: (context, controller, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_viewportSize !=
                  Size(constraints.maxWidth, constraints.maxHeight)) {
                setState(() {
                  _viewportSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                });
              }
            });

            return InteractiveViewer(
              transformationController: _transformationController,
              maxScale: 5.0,
              minScale: 1.0,
              panEnabled: _isMoveMode,
              scaleEnabled: _isMoveMode,
              child: Transform.rotate(
                angle: _imageRotation,
                alignment: Alignment.center,
                child: _buildImageContent(constraints, controller),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImageContent(
    BoxConstraints constraints,
    OpticalController controller,
  ) {
    final double scaleX = constraints.maxWidth / _imageSize!.width;
    final double scaleY = constraints.maxHeight / _imageSize!.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;
    final double displayW = _imageSize!.width * scale;
    final double displayH = _imageSize!.height * scale;
    final double offsetX = (constraints.maxWidth - displayW) / 2;
    final double offsetY = (constraints.maxHeight - displayH) / 2;

    return GestureDetector(
      onPanDown: _isMoveMode
          ? null
          : (details) {
              // Flutter delivers localPosition already in the rotated widget's
              // coordinate frame (because the GestureDetector is a child of
              // Transform.rotate). We must un-rotate it back to image space
              // before passing to the controller.
              final unrotated = _unrotatePosition(
                details.localPosition,
                constraints,
              );
              controller.handleTap(unrotated, scale, Offset(offsetX, offsetY));
            },
      onPanUpdate: _isMoveMode
          ? null
          : (details) {
              // delta is in screen space — un-rotate so the point follows the
              // finger correctly even when the image is tilted.
              final unrotatedDelta = _unrotateDelta(details.delta);
              controller.handleDrag(unrotatedDelta, scale);
            },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.flip(
            flipX: widget.isFrontCamera,
            child: Image.file(_imageFile),
          ),
          CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: OpticalPainter(
              rotation: _imageRotation,
              points: controller.points,
              selectedPoint: controller.selectedPoint,
              scale: scale,
              offset: Offset(offsetX, offsetY),
              showCircles: controller.showCircles,
              refDiameterMmRight: controller.referenceCircleDiameterRight,
              refDiameterMmLeft: controller.referenceCircleDiameterLeft,
              calcRadiusPxR: controller.calcRadiusPxRight,
              calcRadiusPxL: controller.calcRadiusPxLeft,
              pixelFactorX: controller.pixelFactorX,
              pixelFactorY: controller.pixelFactorY,
              isBifocal: controller.isBifocal,
              bifocalOffset: controller.bifocalLineOffset,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Container(
      height: 80,
      color: Colors.grey[900],
      child: Consumer<OpticalController>(
        builder: (context, ctrl, _) => Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: ctrl.showCircles,
                  activeColor: Colors.cyanAccent,
                  onChanged: (v) => ctrl.toggleCircles(v!),
                ),
                Text(
                  context.l10n.guides,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const Spacer(),
                Switch(
                  value: ctrl.isBifocal,
                  activeColor: Colors.orangeAccent,
                  onChanged: (v) => ctrl.toggleBifocal(v),
                ),
                if (ctrl.isBifocal) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_up, color: Colors.white),
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
            if (ctrl.showCircles)
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "👁️ ${context.l10n.rightEyeP1}:",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: ctrl.referenceCircleDiameterRight,
                              min: 40,
                              max: 90,
                              divisions: 50,
                              activeColor: Colors.cyanAccent,
                              onChanged: (v) =>
                                  ctrl.setReferenceDiameterRight(v),
                            ),
                          ),
                          Text(
                            "${ctrl.referenceCircleDiameterRight.round()}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "👁️ ${context.l10n.leftEyeP2}:",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: ctrl.referenceCircleDiameterLeft,
                              min: 40,
                              max: 90,
                              divisions: 50,
                              activeColor: Colors.greenAccent,
                              onChanged: (v) =>
                                  ctrl.setReferenceDiameterLeft(v),
                            ),
                          ),
                          Text(
                            "${ctrl.referenceCircleDiameterLeft.round()}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[850],
      child: Consumer<OpticalController>(
        builder: (context, ctrl, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "⚙️ ${context.l10n.calibration}",
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // --- AJUSTE HORIZONTAL ---
            Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    context.l10n.horizontalAdjustment,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: ctrl.ajusteHorizontal,
                    min: 0.8,
                    max: 1.2,
                    divisions: 40,
                    activeColor: Colors.cyanAccent,
                    onChanged: (v) => ctrl.setAjusteHorizontal(v),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    ctrl.ajusteHorizontal.toStringAsFixed(2),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            // --- AJUSTE VERTICAL ---
            Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    context.l10n.verticalAdjustment,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: ctrl.ajusteVertical,
                    min: 0.8,
                    max: 1.2,
                    divisions: 40,
                    activeColor: Colors.greenAccent,
                    onChanged: (v) => ctrl.setAjusteVertical(v),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    ctrl.ajusteVertical.toStringAsFixed(2),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
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
              // Fondo más transparente para dejar ver un poco la imagen debajo
              color: Colors.black.withOpacity(0.4),
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
                    // Redujimos drásticamente el espacio central (antes era 40)
                    const SizedBox(width: 16, height: 16),
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
        // Redujimos el tamaño del botón (antes 50x50, ahora 38x38)
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          // Botón ligeramente translúcido
          color: Colors.grey[800]!.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        // Ícono más pequeño (antes 30, ahora 24)
        child: Icon(icon, color: Colors.white, size: 24),
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
                  _statItem(
                    context,
                    context.l10n.ipdDi,
                    ctrl.di,
                    isLarge: true,
                  ),
                  _statItem(context, context.l10n.bridge, ctrl.puente),
                  _statItem(context, context.l10n.frameW, ctrl.aroAnc),
                  _statItem(context, context.l10n.frameH, ctrl.aroAlt),
                ],
              ),
              const Divider(color: Colors.white24),
              Row(
                children: [
                  Expanded(
                    child: _eyeStat(
                      context,
                      context.l10n.rightEyeP1,
                      ctrl.dnpRight,
                      ctrl.altRight,
                      ctrl.diametroRight,
                    ),
                  ),
                  Container(width: 1, height: 60, color: Colors.white24),
                  Expanded(
                    child: _eyeStat(
                      context,
                      context.l10n.leftEyeP2,
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

  Widget _statItem(
    BuildContext context,
    String label,
    double value, {
    bool isLarge = false,
  }) {
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
        Text(
          context.l10n.unitMm,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }

  Widget _eyeStat(
    BuildContext context,
    String side,
    double dnp,
    double height,
    double diam,
  ) {
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
          context.l10n.dnpShort(dnp.toStringAsFixed(1)),
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          context.l10n.heightShort(height.toStringAsFixed(1)),
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          context.l10n.diamShort(diam.toStringAsFixed(1)),
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  void _showResultsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ResultsSheet(controller: _controller),
    );
  }
}

class _ResultsSheet extends StatelessWidget {
  final OpticalController controller;
  const _ResultsSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "📋 ${context.l10n.measurementsResultsTitle}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _resultRow(
                  context,
                  context.l10n.ipdDi,
                  controller.di,
                  highlight: true,
                ),
                _resultRow(context, context.l10n.bridge, controller.puente),
                _resultRow(context, context.l10n.frameW, controller.aroAnc),
                _resultRow(context, context.l10n.frameH, controller.aroAlt),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _expandedEyeBox(
                context,
                context.l10n.rightEye,
                controller.dnpRight,
                controller.altRight,
                controller.diametroRight,
              ),
              const SizedBox(width: 12),
              _expandedEyeBox(
                context,
                context.l10n.leftEye,
                controller.dnpLeft,
                controller.altLeft,
                controller.diametroLeft,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy),
                  label: Text(context.l10n.copyLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareResults(context),
                  icon: const Icon(Icons.share),
                  label: Text(context.l10n.shareLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _expandedEyeBox(
    BuildContext context,
    String label,
    double dnp,
    double alt,
    double diam,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _resultRow(
              context,
              context.l10n.dnpShort(dnp.toStringAsFixed(1)),
              dnp,
              compact: true,
            ),
            _resultRow(
              context,
              context.l10n.heightShort(alt.toStringAsFixed(1)),
              alt,
              compact: true,
            ),
            _resultRow(
              context,
              context.l10n.diamShort(diam.toStringAsFixed(1)),
              diam,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(
    BuildContext context,
    String label,
    double value, {
    bool highlight = false,
    bool compact = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 4 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: compact ? 12 : 14,
            ),
          ),
          Text(
            "${value.toStringAsFixed(1)} ${context.l10n.unitMm}",
            style: TextStyle(
              color: highlight ? Colors.cyanAccent : Colors.white,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getResultsText(BuildContext context) =>
      "${context.l10n.ipdDi}: ${controller.di.toStringAsFixed(1)} ${context.l10n.unitMm}\n"
      "${context.l10n.bridge}: ${controller.puente.toStringAsFixed(1)} ${context.l10n.unitMm}";

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _getResultsText(context)));
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _shareResults(BuildContext context) async {
    await SharePlus.instance.share(
      ShareParams(
        text: _getResultsText(context),
        subject: context.l10n.measurementsShareSubject,
      ),
    );
    if (context.mounted) Navigator.pop(context);
  }
}
