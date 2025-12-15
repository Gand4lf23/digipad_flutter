import 'package:flutter/material.dart';
import 'optical_models.dart';

class OpticalPainter extends CustomPainter {
  final List<DetectionPoint> points;
  final Rect leftLens;
  final Rect rightLens;
  final DetectionPoint? selectedPoint;
  final String? selectedLensSide;
  final Size imageSize;

  // Added these to sync with the Gesture Detector in the parent widget
  final double scale;
  final Offset offset;

  OpticalPainter({
    required this.points,
    required this.leftLens,
    required this.rightLens,
    required this.imageSize,
    required this.scale,
    required this.offset,
    this.selectedPoint,
    this.selectedLensSide,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Apply Transformation
    // We use the scale/offset passed from the parent to ensure
    // the visual rendering matches the touch hit-boxes exactly.
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    // 2. Draw "Mask" (Green lines connecting reference markers)
    _drawMask(canvas, 2.0 / scale);

    // 3. Draw Lenses (Rectangles)
    final Paint lensPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 / scale; // Keep stroke constant regardless of zoom

    final Paint selectedLensPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0 / scale;

    canvas.drawRect(
      leftLens,
      selectedLensSide == 'left' ? selectedLensPaint : lensPaint,
    );
    canvas.drawRect(
      rightLens,
      selectedLensSide == 'right' ? selectedLensPaint : lensPaint,
    );

    // 4. Draw Points (Pupils & Markers)
    for (var p in points) {
      bool isSelected =
          (p.id == selectedPoint?.id); // Compare by ID if possible, else Object

      Color color = Colors.green;
      if (p.type == DetectionType.pupilLeft ||
          p.type == DetectionType.pupilRight) {
        color = Colors.redAccent;
      }

      Paint pointPaint = Paint()..color = isSelected ? Colors.yellow : color;

      // Dynamic radius based on zoom
      double radius = isSelected ? 15.0 / scale : 10.0 / scale;

      // Draw outer circle
      canvas.drawCircle(p.position, radius, pointPaint);

      // Draw Crosshair inside point for precision alignment
      Paint crossPaint = Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..strokeWidth = 1.5 / scale
        ..style = PaintingStyle.stroke;

      double crossSize = radius * 0.6;

      canvas.drawLine(
        p.position - Offset(crossSize, 0),
        p.position + Offset(crossSize, 0),
        crossPaint,
      );
      canvas.drawLine(
        p.position - Offset(0, crossSize),
        p.position + Offset(0, crossSize),
        crossPaint,
      );
    }

    canvas.restore();
  }

  void _drawMask(Canvas canvas, double strokeWidth) {
    // Safe lookup helper
    Offset? getPos(DetectionType t) {
      try {
        return points.firstWhere((p) => p.type == t).position;
      } catch (e) {
        return null;
      }
    }

    final tl = getPos(DetectionType.maskTopLeft);
    final tr = getPos(DetectionType.maskTopRight);
    final bl = getPos(DetectionType.maskBottomLeft);
    final br = getPos(DetectionType.maskBottomRight);

    // Only draw if all 4 mask points exist
    if (tl != null && tr != null && bl != null && br != null) {
      final paint = Paint()
        ..color = Colors.greenAccent.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      final path = Path()
        ..moveTo(tl.dx, tl.dy)
        ..lineTo(tr.dx, tr.dy)
        ..lineTo(br.dx, br.dy)
        ..lineTo(bl.dx, bl.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant OpticalPainter oldDelegate) {
    return oldDelegate.selectedPoint != selectedPoint ||
        oldDelegate.points != points ||
        oldDelegate.leftLens != leftLens ||
        oldDelegate.scale != scale || // Repaint if zoom changes
        oldDelegate.selectedLensSide != selectedLensSide;
  }
}
