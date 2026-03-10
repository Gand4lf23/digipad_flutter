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
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showFullCorrection && correctedImage != null) {
      // Multifocal mode: show full corrected image
      _drawImage(canvas, size, correctedImage!);
      return;
    }

    if (isLensDraggingMode && correctedImage != null) {
      // LENS DRAGGING MODE: Draw lens effect
      _drawLensMode(canvas, size);
    } else if (correctedImage != null) {
      // DIVIDER MODE: Draw split view
      _drawDividerMode(canvas, size);
    } else {
      // No correction: just show problem image
      _drawImage(canvas, size, problemImage);
    }
  }

  void _drawLensMode(Canvas canvas, Size size) {
    // Draw problem image as background (blurred/affected)
    _drawImage(canvas, size, problemImage);

    // Draw corrected image inside circular lens
    canvas.save();

    // Create circular clip path for lens
    final lensPath = Path()
      ..addOval(Rect.fromCircle(center: lensPosition, radius: lensRadius));
    canvas.clipPath(lensPath);

    // Draw corrected image inside lens
    _drawImage(canvas, size, correctedImage!);

    canvas.restore();

    // Draw lens border
    _drawLensBorder(canvas);
  }

  void _drawDividerMode(Canvas canvas, Size size) {
    if (isVerticalDivider) {
      // Vertical divider: left side shows problem, right side shows correction
      final dividerX = size.width * dividerPosition;

      // Draw problem image on left
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, dividerX, size.height));
      _drawImage(canvas, size, problemImage);
      canvas.restore();

      // Draw corrected image on right
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(dividerX, 0, size.width - dividerX, size.height),
      );
      _drawImage(canvas, size, correctedImage!);
      canvas.restore();

      // Draw vertical divider line
      _drawVerticalDivider(canvas, size, dividerX);
    } else {
      // Horizontal divider: top shows problem, bottom shows correction
      final dividerY = size.height * dividerPosition;

      // Draw problem image on top
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, dividerY));
      _drawImage(canvas, size, problemImage);
      canvas.restore();

      // Draw corrected image on bottom
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(0, dividerY, size.width, size.height - dividerY),
      );
      _drawImage(canvas, size, correctedImage!);
      canvas.restore();

      // Draw horizontal divider line
      _drawHorizontalDivider(canvas, size, dividerY);
    }
  }

  void _drawImage(Canvas canvas, Size size, ui.Image image) {
    final srcSize = Size(image.width.toDouble(), image.height.toDouble());
    final fittedSizes = applyBoxFit(boxFit, srcSize, size);
    final dst = Alignment.center.inscribe(
      fittedSizes.destination,
      Offset.zero & size,
    );

    final paint = Paint();

    // Apply tint if specified
    if (tintColor != null && lensOpacity > 0) {
      paint.colorFilter = ColorFilter.mode(
        tintColor!.withOpacity(lensOpacity),
        BlendMode.srcATop,
      );
    }

    canvas.drawImageRect(image, Offset.zero & srcSize, dst, paint);
  }

  void _drawVerticalDivider(Canvas canvas, Size size, double x) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Draw line
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);

    // Draw handle circle in the middle
    final handleY = size.height / 2;
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, handleY), 20, handlePaint);

    // Draw arrows
    final arrowPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Left arrow
    canvas.drawLine(
      Offset(x - 8, handleY),
      Offset(x - 2, handleY - 6),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(x - 8, handleY),
      Offset(x - 2, handleY + 6),
      arrowPaint,
    );

    // Right arrow
    canvas.drawLine(
      Offset(x + 8, handleY),
      Offset(x + 2, handleY - 6),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(x + 8, handleY),
      Offset(x + 2, handleY + 6),
      arrowPaint,
    );
  }

  void _drawHorizontalDivider(Canvas canvas, Size size, double y) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Draw line
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    // Draw handle circle in the middle
    final handleX = size.width / 2;
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(handleX, y), 20, handlePaint);

    // Draw arrows
    final arrowPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Up arrow
    canvas.drawLine(
      Offset(handleX, y - 8),
      Offset(handleX - 6, y - 2),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(handleX, y - 8),
      Offset(handleX + 6, y - 2),
      arrowPaint,
    );

    // Down arrow
    canvas.drawLine(
      Offset(handleX, y + 8),
      Offset(handleX - 6, y + 2),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(handleX, y + 8),
      Offset(handleX + 6, y + 2),
      arrowPaint,
    );
  }

  void _drawLensBorder(Canvas canvas) {
    // Draw lens border with glow effect
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.white.withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(lensPosition, lensRadius, borderPaint);

    // Draw subtle sheen/reflection
    final sheenPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [Colors.white.withOpacity(0.2), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                lensPosition.dx - lensRadius * 0.3,
                lensPosition.dy - lensRadius * 0.3,
              ),
              radius: lensRadius * 0.5,
            ),
          )
      ..blendMode = BlendMode.plus;

    canvas.drawCircle(
      Offset(
        lensPosition.dx - lensRadius * 0.3,
        lensPosition.dy - lensRadius * 0.3,
      ),
      lensRadius * 0.4,
      sheenPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SimulationPainter oldDelegate) {
    return oldDelegate.dividerPosition != dividerPosition ||
        oldDelegate.isVerticalDivider != isVerticalDivider ||
        oldDelegate.lensOpacity != lensOpacity ||
        oldDelegate.isLensDraggingMode != isLensDraggingMode ||
        oldDelegate.lensPosition != lensPosition ||
        oldDelegate.lensRadius != lensRadius ||
        oldDelegate.correctedImage != correctedImage;
  }
}
