import 'package:flutter/material.dart';
import 'optical_models.dart';

class OpticalPainter extends CustomPainter {
  final List<DetectionPoint> points;
  final Rect leftLens;
  final Rect rightLens;
  final DetectionPoint? selectedPoint;
  final String? selectedLensSide;
  final Size imageSize;

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
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    // 1. Draw Mask
    _drawMask(canvas, 2.0 / scale);

    // 2. Draw Lenses
    final Paint lensPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 / scale;

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

    // 3. Draw Points
    for (var p in points) {
      bool isSelected = (p.id == selectedPoint?.id);

      Color crossColor = isSelected ? Colors.yellow : Colors.green;
      if (!isSelected &&
          (p.type == DetectionType.pupilLeft ||
              p.type == DetectionType.pupilRight)) {
        crossColor = Colors.redAccent;
      } else if (!isSelected) {
        crossColor = Colors.green;
      }

      Paint crossPaint = Paint()
        ..color = crossColor
        ..strokeWidth = (isSelected ? 3.0 : 2.0) / scale
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      double radius = isSelected ? 15.0 / scale : 10.0 / scale;

      canvas.drawLine(
        p.position - Offset(radius, 0),
        p.position + Offset(radius, 0),
        crossPaint,
      );

      canvas.drawLine(
        p.position - Offset(0, radius),
        p.position + Offset(0, radius),
        crossPaint,
      );
    }

    canvas.restore();
  }

  void _drawMask(Canvas canvas, double strokeWidth) {
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
        oldDelegate.scale != scale ||
        oldDelegate.selectedLensSide != selectedLensSide;
  }
}
