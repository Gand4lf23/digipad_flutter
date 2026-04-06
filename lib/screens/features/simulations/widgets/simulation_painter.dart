import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SimulationPainter extends CustomPainter {
  final ui.Image problemImage;
  final ui.Image? correctedImage;
  final double dividerPosition;
  final bool isVerticalDivider;
  final Color? tintColor;
  final double lensOpacity;
  final bool showFullCorrection;
  final BoxFit boxFit;

  // Lens mode parameters
  final bool isLensDraggingMode;
  final Offset lensPosition;
  final double lensRadius;
  final double fontSize;

  /// NEW: velocity input to simulate drag reaction
  final Offset dragVelocity;

  SimulationPainter({
    required this.problemImage,
    this.correctedImage,
    required this.dividerPosition,
    required this.isVerticalDivider,
    this.tintColor,
    required this.lensOpacity,
    required this.showFullCorrection,
    required this.boxFit,
    required this.isLensDraggingMode,
    required this.lensPosition,
    required this.lensRadius,
    required this.fontSize,
    this.dragVelocity = Offset.zero, // 👈 default safe
  });

  @override
  void paint(Canvas canvas, Size size) {
    /// ENTRY POINT
    /// Decides which rendering mode to use

    if (showFullCorrection && correctedImage != null) {
      _drawImage(canvas, size, correctedImage!, applyTint: true);
      return;
    }

    if (isLensDraggingMode && correctedImage != null) {
      _drawLensMode(canvas, size);
    } else if (correctedImage != null) {
      _drawDividerMode(canvas, size);
    } else {
      _drawImage(canvas, size, problemImage);
    }
  }

  /// ------------------------------------------------------------
  /// 🟢 LENS MODE (main feature)
  /// ------------------------------------------------------------
  void _drawLensMode(Canvas canvas, Size size) {
    /// 1. Draw base image
    _drawImage(canvas, size, problemImage);

    /// 2. Build lens shape (reactive)
    final lensPath = _buildLensPath();

    /// 3. Clip to lens
    canvas.save();
    canvas.clipPath(lensPath);

    /// 4. Draw corrected image inside lens
    _drawImage(canvas, size, correctedImage!, applyTint: true);

    /// 5. Add subtle optical vignette (depth realism)
    _drawLensVignette(canvas);

    canvas.restore();

    /// 6. Draw border AFTER restore (so it’s not clipped)
    _drawLensBorder(canvas, lensPath);
  }

  /// ------------------------------------------------------------
  /// 🟣 LENS SHAPE (reacts to drag)
  /// ------------------------------------------------------------
  Path _buildLensPath() {
    final frameWidth = lensRadius * 2.2;
    final frameHeight = lensRadius * 1.5;

    /// 🧠 Velocity-based deformation (subtle!)
    final dx = dragVelocity.dx.clamp(-20, 20) / 20;
    final dy = dragVelocity.dy.clamp(-20, 20) / 20;

    final stretchX = 1 + (dx * 0.05);
    final stretchY = 1 + (dy * 0.05);

    final width = frameWidth * stretchX;
    final height = frameHeight * stretchY;

    final left = lensPosition.dx - width / 2;
    final right = lensPosition.dx + width / 2;
    final top = lensPosition.dy - height / 2;
    final bottom = lensPosition.dy + height / 2;

    return Path()
      ..moveTo(left, top)
      /// Top (almost flat)
      ..quadraticBezierTo(lensPosition.dx, top - lensRadius * 0.1, right, top)
      /// Right
      ..quadraticBezierTo(
        right + lensRadius * 0.2,
        lensPosition.dy,
        right,
        bottom,
      )
      /// Bottom (more curved)
      ..quadraticBezierTo(
        lensPosition.dx,
        bottom + lensRadius * 0.4,
        left,
        bottom,
      )
      /// Left
      ..quadraticBezierTo(left - lensRadius * 0.2, lensPosition.dy, left, top)
      ..close();
  }

  /// ------------------------------------------------------------
  /// 🟡 LENS VIGNETTE (realism, replaces fake shimmer)
  /// ------------------------------------------------------------
  void _drawLensVignette(Canvas canvas) {
    final frameWidth = lensRadius * 2.2;
    final frameHeight = lensRadius * 1.5;

    final rect = Rect.fromCenter(
      center: lensPosition,
      width: frameWidth,
      height: frameHeight,
    );

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.15), // subtle dark edge
        ],
        stops: const [1.7, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  /// ------------------------------------------------------------
  /// 🔵 LENS BORDER (clean, no glow, no shimmer)
  /// ------------------------------------------------------------
  void _drawLensBorder(Canvas canvas, Path lensPath) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.6);

    canvas.drawPath(lensPath, paint);
  }

  /// ------------------------------------------------------------
  /// 🟠 DIVIDER MODE (unchanged)
  /// ------------------------------------------------------------
  void _drawDividerMode(Canvas canvas, Size size) {
    if (isVerticalDivider) {
      final dividerX = size.width * dividerPosition;

      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, dividerX, size.height));
      _drawImage(canvas, size, problemImage);
      canvas.restore();

      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(dividerX, 0, size.width - dividerX, size.height),
      );
      _drawImage(canvas, size, correctedImage!, applyTint: true);
      canvas.restore();

      _drawVerticalDivider(canvas, size, dividerX);
    } else {
      final dividerY = size.height * dividerPosition;

      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, dividerY));
      _drawImage(canvas, size, problemImage);
      canvas.restore();

      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(0, dividerY, size.width, size.height - dividerY),
      );
      _drawImage(canvas, size, correctedImage!, applyTint: true);
      canvas.restore();

      _drawHorizontalDivider(canvas, size, dividerY);
    }
  }

  /// ------------------------------------------------------------
  /// 🖼 IMAGE DRAWING (removed shimmer source)
  /// ------------------------------------------------------------
  void _drawImage(
    Canvas canvas,
    Size size,
    ui.Image image, {
    bool applyTint = false,
  }) {
    final srcSize = Size(image.width.toDouble(), image.height.toDouble());
    final fittedSizes = applyBoxFit(boxFit, srcSize, size);
    final dst = Alignment.center.inscribe(
      fittedSizes.destination,
      Offset.zero & size,
    );

    final paint = Paint();

    /// ✅ ONLY tint (no shimmer, no gradients)
    if (applyTint && tintColor != null && lensOpacity > 0) {
      paint.colorFilter = ColorFilter.mode(
        tintColor!.withValues(alpha: lensOpacity),
        BlendMode.srcATop,
      );
    }

    canvas.drawImageRect(image, Offset.zero & srcSize, dst, paint);
  }

  /// ------------------------------------------------------------
  /// ➗ DIVIDER UI (unchanged)
  /// ------------------------------------------------------------
  void _drawVerticalDivider(Canvas canvas, Size size, double x) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 3;

    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);

    final handleY = size.height / 2;
    canvas.drawCircle(Offset(x, handleY), 20, Paint()..color = Colors.white);
  }

  void _drawHorizontalDivider(Canvas canvas, Size size, double y) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 3;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    final handleX = size.width / 2;
    canvas.drawCircle(Offset(handleX, y), 20, Paint()..color = Colors.white);
  }

  /// ------------------------------------------------------------
  /// 🔁 REPAINT LOGIC
  /// ------------------------------------------------------------
  @override
  bool shouldRepaint(covariant SimulationPainter oldDelegate) {
    return oldDelegate.dividerPosition != dividerPosition ||
        oldDelegate.isVerticalDivider != isVerticalDivider ||
        oldDelegate.lensOpacity != lensOpacity ||
        oldDelegate.isLensDraggingMode != isLensDraggingMode ||
        oldDelegate.lensPosition != lensPosition ||
        oldDelegate.lensRadius != lensRadius ||
        oldDelegate.dragVelocity != dragVelocity || // 👈 NEW
        oldDelegate.correctedImage != correctedImage;
  }
}
