import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'dart:math' as math;
import 'package:digipad_flutter/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

import 'optical_logic_controller.dart';
import 'optical_painter.dart';

class OpticalEditorScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> detections;
  final bool isFrontCamera;
  final double? pantoscopicAngle;

  const OpticalEditorScreen({
    super.key,
    required this.imagePath,
    required this.detections,
    this.isFrontCamera = false,
    this.pantoscopicAngle,
  });

  @override
  State<OpticalEditorScreen> createState() => _OpticalEditorScreenState();
}

class _OpticalEditorScreenState extends State<OpticalEditorScreen> {
  late OpticalController _controller;
  late File _imageFile;
  Size? _imageSize;
  int _activePointers = 0;
  final TransformationController _transformationController =
      TransformationController();
  final WidgetsToImageController _screenshotController =
      WidgetsToImageController();
  late final TextEditingController _calibrationHorizontalController;
  late final TextEditingController _calibrationVerticalController;
  late final TextEditingController _calibrationAngleController;
  late final FocusNode _calibrationHorizontalFocusNode;
  late final FocusNode _calibrationVerticalFocusNode;
  late final FocusNode _calibrationAngleFocusNode;
  bool _isSyncingCalibrationText = false;

  bool _isMoveMode = false;
  bool _showAjustePanel = false;
  Timer? _holdTimer;

  double _imageRotation = 0.0;
  double _currentScale = 1.0;
  bool _isPointSelected = false;

  @override
  void initState() {
    super.initState();
    _imageFile = File(widget.imagePath);
    _controller = OpticalController();
    _controller.pantoscopicAngle = widget.pantoscopicAngle;
    _calibrationHorizontalController = TextEditingController(
      text: _formatCalibrationValue(_controller.ajusteHorizontal),
    );
    _calibrationVerticalController = TextEditingController(
      text: _formatCalibrationValue(_controller.ajusteVertical),
    );
    _calibrationAngleController = TextEditingController(
      text: _controller.pantoscopicAngle?.toStringAsFixed(1) ?? '0.0',
    );
    _calibrationHorizontalFocusNode = FocusNode();
    _calibrationVerticalFocusNode = FocusNode();
    _calibrationAngleFocusNode = FocusNode();
    _controller.addListener(_syncCalibrationTextFromController);
    _controller.addListener(_onControllerChanged);
    _transformationController.addListener(_onTransformChanged);
    _loadImageAndInit();
  }

  void _onTransformChanged() {
    final s = _transformationController.value.getMaxScaleOnAxis();
    if ((s - _currentScale).abs() > 0.01) {
      setState(() => _currentScale = s);
    }
  }

  void _onControllerChanged() {
    final selected = _controller.selectedPoint != null;
    if (selected != _isPointSelected) {
      setState(() => _isPointSelected = selected);
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.removeListener(_syncCalibrationTextFromController);
    _calibrationHorizontalController.dispose();
    _calibrationVerticalController.dispose();
    _calibrationAngleController.dispose();
    _calibrationHorizontalFocusNode.dispose();
    _calibrationVerticalFocusNode.dispose();
    _calibrationAngleFocusNode.dispose();
    super.dispose();
  }

  String _formatCalibrationValue(double value) {
    if (value > 2) return '2';

    return value.toStringAsFixed(3);
  }

  void _syncCalibrationTextFromController() {
    if (!mounted) return;
    if (_isSyncingCalibrationText) return;

    _isSyncingCalibrationText = true;

    try {
      if (!_calibrationHorizontalFocusNode.hasFocus) {
        final next = _formatCalibrationValue(_controller.ajusteHorizontal);
        if (_calibrationHorizontalController.text != next) {
          _calibrationHorizontalController.value = TextEditingValue(
            text: next,
            selection: TextSelection.collapsed(offset: next.length),
          );
        }
      }

      if (!_calibrationVerticalFocusNode.hasFocus) {
        final next = _formatCalibrationValue(_controller.ajusteVertical);
        if (_calibrationVerticalController.text != next) {
          _calibrationVerticalController.value = TextEditingValue(
            text: next,
            selection: TextSelection.collapsed(offset: next.length),
          );
        }
      }

      if (!_calibrationAngleFocusNode.hasFocus) {
        final next = _controller.pantoscopicAngle?.toStringAsFixed(1) ?? '0.0';
        if (_calibrationAngleController.text != next) {
          _calibrationAngleController.value = TextEditingValue(
            text: next,
            selection: TextSelection.collapsed(offset: next.length),
          );
        }
      }
    } finally {
      _isSyncingCalibrationText = false;
    }
  }

  void _applyCalibrationValue({
    required OpticalController controller,
    required bool isHorizontal,
    required String rawValue,
  }) {
    final normalized = rawValue.trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null) return;

    final clamped = parsed.clamp(0.0, 2.0);
    if (isHorizontal) {
      controller.setAjusteHorizontal(clamped);
    } else {
      controller.setAjusteVertical(clamped);
    }
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
          _transformationController.value = Matrix4.identity();
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

  void _resetZoom() {
    setState(() => _imageRotation = 0.0);
    _transformationController.value = Matrix4.identity();
  }

  Offset _unrotatePosition(Offset rotatedPos, BoxConstraints constraints) {
    if (_imageRotation == 0.0) return rotatedPos;
    final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
    final d = rotatedPos - center;
    final cos = math.cos(-_imageRotation);
    final sin = math.sin(-_imageRotation);
    return center + Offset(d.dx * cos - d.dy * sin, d.dx * sin + d.dy * cos);
  }

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
      child: WidgetsToImage(
        controller: _screenshotController,
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
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
                    color: _showAjustePanel
                        ? Colors.orangeAccent
                        : Colors.white,
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
                          _controller.deselect();
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
        ),
      ),
    );
  }

  Widget _buildImageViewer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double scaleX = constraints.maxWidth / _imageSize!.width;
        final double scaleY = constraints.maxHeight / _imageSize!.height;
        final double scale = scaleX < scaleY ? scaleX : scaleY;
        final double offsetX = (constraints.maxWidth - _imageSize!.width * scale) / 2;
        final double offsetY = (constraints.maxHeight - _imageSize!.height * scale) / 2;

        // Allow pan when in move mode OR when zoomed in without a point selected.
        final bool canPan = _isMoveMode || (_currentScale > 1.01 && !_isPointSelected);

        return InteractiveViewer(
          transformationController: _transformationController,
          maxScale: 5.0,
          minScale: 1.0,
          panEnabled: canPan,
          scaleEnabled: true,
          child: Transform.rotate(
            angle: _imageRotation,
            alignment: Alignment.center,
            child: _buildImageContent(constraints, scale, offsetX, offsetY),
          ),
        );
      },
    );
  }

  Widget _buildImageContent(
    BoxConstraints constraints,
    double scale,
    double offsetX,
    double offsetY,
  ) {
    return Listener(
      onPointerDown: (e) {
        _activePointers++;
        if (!_isMoveMode && _activePointers == 1) {
          final unrotated = _unrotatePosition(e.localPosition, constraints);
          _controller.handleTap(unrotated, scale, Offset(offsetX, offsetY));
        }
      },
      onPointerMove: (e) {
        // Only drag a point when exactly 1 finger AND a point is selected.
        // 2-finger gestures go to InteractiveViewer for pinch/pan.
        if (!_isMoveMode && _activePointers == 1 && _controller.selectedPoint != null) {
          final unrotatedDelta = _unrotateDelta(e.delta);
          _controller.handleDrag(unrotatedDelta, scale);
        }
      },
      onPointerUp: (_) { if (_activePointers > 0) _activePointers--; },
      onPointerCancel: (_) { if (_activePointers > 0) _activePointers--; },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Transform.flip(
              flipX: widget.isFrontCamera,
              child: Image.file(
                _imageFile,
                fit: BoxFit.contain,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              ),
            ),
          ),
          // Only this painter rebuilds when controller notifies (points move, etc.)
          ListenableBuilder(
            listenable: _controller,
            builder: (_, _) => CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: OpticalPainter(
                rotation: _imageRotation,
                points: _controller.points,
                selectedPoint: _controller.selectedPoint,
                scale: scale,
                offset: Offset(offsetX, offsetY),
                showCircles: _controller.showCircles,
                refDiameterMmRight: _controller.referenceCircleDiameterRight,
                refDiameterMmLeft: _controller.referenceCircleDiameterLeft,
                calcRadiusPxR: _controller.calcRadiusPxRight,
                calcRadiusPxL: _controller.calcRadiusPxLeft,
                pixelFactorX: _controller.pixelFactorX,
                pixelFactorY: _controller.pixelFactorY,
                isBifocal: _controller.isBifocal,
                bifocalOffset: _controller.bifocalLineOffset,
              ),
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
                  activeThumbColor: Colors.orangeAccent,
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
                              min: 20,
                              max: 90,
                              divisions: 70,
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
                              min: 20,
                              max: 90,
                              divisions: 70,
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
                    min: 0.0,
                    max: 2.0,
                    divisions: 1000,
                    activeColor: Colors.cyanAccent,
                    onChanged: (v) => ctrl.setAjusteHorizontal(v),
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: TextField(
                    controller: _calibrationHorizontalController,
                    focusNode: _calibrationHorizontalFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyanAccent),
                      ),
                    ),
                    onSubmitted: (value) => _applyCalibrationValue(
                      controller: ctrl,
                      isHorizontal: true,
                      rawValue: value,
                    ),
                    onEditingComplete: () => _applyCalibrationValue(
                      controller: ctrl,
                      isHorizontal: true,
                      rawValue: _calibrationHorizontalController.text,
                    ),
                  ),
                ),
              ],
            ),

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
                    min: 0.0,
                    max: 2.0,
                    divisions: 1000,
                    activeColor: Colors.greenAccent,
                    onChanged: (v) => ctrl.setAjusteVertical(v),
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: TextField(
                    controller: _calibrationVerticalController,
                    focusNode: _calibrationVerticalFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.greenAccent),
                      ),
                    ),
                    onSubmitted: (value) => _applyCalibrationValue(
                      controller: ctrl,
                      isHorizontal: false,
                      rawValue: value,
                    ),
                    onEditingComplete: () => _applyCalibrationValue(
                      controller: ctrl,
                      isHorizontal: false,
                      rawValue: _calibrationVerticalController.text,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    'Ángulo Pantoscópico',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: ctrl.pantoscopicAngle ?? 0.0,
                    min: 0.0,
                    max: 30.0,
                    divisions: 300,
                    activeColor: Colors.orangeAccent,
                    onChanged: (v) => ctrl.setPantoscopicAngle(v),
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: TextField(
                    controller: _calibrationAngleController,
                    focusNode: _calibrationAngleFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orangeAccent),
                      ),
                    ),
                    onSubmitted: (value) {
                      final val = double.tryParse(value.replaceAll(',', '.'));
                      if (val != null) ctrl.setPantoscopicAngle(val.clamp(0.0, 45.0));
                    },
                    onEditingComplete: () {
                      final val = double.tryParse(_calibrationAngleController.text.replaceAll(',', '.'));
                      if (val != null) ctrl.setPantoscopicAngle(val.clamp(0.0, 45.0));
                    },
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
              color: Colors.black.withValues(alpha: 0.4),
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
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.grey[800]!.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),

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
                  if (ctrl.pantoscopicAngle != null)
                    _statItem(
                      context, 
                      'Ángulo Pant.', 
                      ctrl.pantoscopicAngle!,
                      unit: '°',
                    ),
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
    String unit = '',
  }) {
    final displayUnit = unit.isEmpty ? context.l10n.unitMm : unit;
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
          displayUnit,
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
      builder: (context) => _ResultsSheet(
        controller: _controller,
        screenshotController: _screenshotController,
        pantoscopicAngle: widget.pantoscopicAngle,
      ),
    );
  }
}

class _ResultsSheet extends StatelessWidget {
  final OpticalController controller;
  final WidgetsToImageController screenshotController;
  final double? pantoscopicAngle;

  const _ResultsSheet({
    required this.controller,
    required this.screenshotController,
    this.pantoscopicAngle,
  });

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
                if (controller.pantoscopicAngle != null)
                  _resultRow(
                    context, 
                    'Ángulo Pantoscópico', 
                    controller.pantoscopicAngle!,
                    unit: '°',
                  ),
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
    String unit = '',
  }) {
    final displayUnit = unit.isEmpty ? context.l10n.unitMm : unit;
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
            "${value.toStringAsFixed(1)} $displayUnit",
            style: TextStyle(
              color: highlight ? Colors.cyanAccent : Colors.white,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getResultsText(BuildContext context) {
    final buffer = StringBuffer()
      ..writeln(context.l10n.measurementsResultsTitle)
      ..writeln(
        "${context.l10n.ipdDi}: ${controller.di.toStringAsFixed(1)} ${context.l10n.unitMm}",
      );

    if (controller.pantoscopicAngle != null) {
      buffer.writeln("Ángulo Pantoscópico: ${controller.pantoscopicAngle!.toStringAsFixed(1)} °");
    }

    buffer
      ..writeln(
        "${context.l10n.bridge}: ${controller.puente.toStringAsFixed(1)} ${context.l10n.unitMm}",
      )
      ..writeln(
        "${context.l10n.frameW}: ${controller.aroAnc.toStringAsFixed(1)} ${context.l10n.unitMm}",
      )
      ..writeln(
        "${context.l10n.frameH}: ${controller.aroAlt.toStringAsFixed(1)} ${context.l10n.unitMm}",
      )
      ..writeln()
      ..writeln("${context.l10n.rightEye}:")
      ..writeln(
        "${context.l10n.dnpShort(controller.dnpRight.toStringAsFixed(1))} ${context.l10n.unitMm}",
      )
      ..writeln(
        "${context.l10n.heightShort(controller.altRight.toStringAsFixed(1))} ${context.l10n.unitMm}",
      )
      ..writeln(
        "${context.l10n.diamShort(controller.diametroRight.toStringAsFixed(1))} ${context.l10n.unitMm}",
      )
      ..writeln()
      ..writeln("${context.l10n.leftEye}:")
      ..writeln(
        "${context.l10n.dnpShort(controller.dnpLeft.toStringAsFixed(1))} ${context.l10n.unitMm}",
      )
      ..writeln(
        "${context.l10n.heightShort(controller.altLeft.toStringAsFixed(1))} ${context.l10n.unitMm}",
      )
      ..writeln(
        "${context.l10n.diamShort(controller.diametroLeft.toStringAsFixed(1))} ${context.l10n.unitMm}",
      );

    return buffer.toString().trim();
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _getResultsText(context)));
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _shareResults(BuildContext context) async {
    try {
      final bytes = await screenshotController.capture();

      if (bytes != null) {
        await SharePlus.instance.share(
          ShareParams(
            text: _getResultsText(context),
            subject: context.l10n.measurementsShareSubject,
            files: [
              XFile.fromData(
                bytes,
                name: 'measurements.png',
                mimeType: 'image/png',
              ),
            ],
          ),
        );
      } else {
        await SharePlus.instance.share(
          ShareParams(
            text: _getResultsText(context),
            subject: context.l10n.measurementsShareSubject,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing: $e');

      await SharePlus.instance.share(
        ShareParams(
          text: _getResultsText(context),
          subject: context.l10n.measurementsShareSubject,
        ),
      );
    }

    if (context.mounted) Navigator.pop(context);
  }
}
