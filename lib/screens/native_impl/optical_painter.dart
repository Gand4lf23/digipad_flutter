import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'optical_logic_controller.dart';

class OpticalPainter extends CustomPainter {
  final List<DetectionPoint> points;
  final DetectionPoint? selectedPoint;

  // Visual Configuration
  final bool showCircles;
  final double refDiameterMm; // Slider Value (Reference)
  final double calcRadiusPxR; // Calculated from L positions
  final double calcRadiusPxL; // Calculated from L positions

  final double pixelFactor;
  final bool isBifocal;
  final double bifocalOffset;

  final double scale;
  final Offset offset;

  OpticalPainter({
    required this.points,
    required this.scale,
    required this.offset,
    this.selectedPoint,
    required this.showCircles,
    required this.refDiameterMm,
    required this.calcRadiusPxR,
    required this.calcRadiusPxL,
    required this.pixelFactor,
    required this.isBifocal,
    required this.bifocalOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    Offset? p1 = _getPos(DetectionType.pupilRight);
    Offset? p2 = _getPos(DetectionType.pupilLeft);

    // --- 1. CIRCLES (Reference & Calculated) ---
    if (showCircles && pixelFactor > 0) {
      // A. Reference Circle (White/Grey) - Controlled by Slider
      double refRadiusPx = (refDiameterMm / pixelFactor) / 2;
      Paint refPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 / scale;

      if (p1 != null) canvas.drawCircle(p1, refRadiusPx, refPaint);
      if (p2 != null) canvas.drawCircle(p2, refRadiusPx, refPaint);

      // B. Calculated Diameter (Cyan) - Controlled by L position
      // Formula included +1mm, so visually we add that small buffer or draw exactly what math says
      // Visual Radius = (CalculatedDiameter - 1) / 2 / PixelFactor -> This returns us to calcRadiusPx
      // But to represent the FINAL result (+1mm), we add 0.5mm in pixels
      double bufferPx = 0.5 / pixelFactor;

      Paint calcPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 / scale;

      if (p1 != null && calcRadiusPxR > 0) {
        _drawDashedCircle(canvas, p1, calcRadiusPxR + bufferPx, calcPaint);
      }
      if (p2 != null && calcRadiusPxL > 0) {
        _drawDashedCircle(canvas, p2, calcRadiusPxL + bufferPx, calcPaint);
      }
    }

    // --- 2. POINTS & L CORNERS ---
    for (var p in points) {
      bool isSelected = (p.id == selectedPoint?.id);

      // Colors
      Color color = Colors.greenAccent;
      if (p.type == DetectionType.pupilLeft ||
          p.type == DetectionType.pupilRight) {
        color = Colors.redAccent;
      } else if (p.type.index >= DetectionType.lensRightTop.index) {
        color = Colors.yellowAccent; // The Ls
      }

      if (isSelected) color = Colors.white;

      Paint paint = Paint()
        ..color = color
        ..strokeWidth = (isSelected ? 3.0 : 2.0) / scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.square;

      // Draw "L" Shapes
      double armLen = 25.0 / scale;

      if (p.type == DetectionType.lensRightTop ||
          p.type == DetectionType.lensLeftTop) {
        // TOP-LEFT Corner (┌)
        Path path = Path();
        path.moveTo(p.position.dx, p.position.dy + armLen); // Down
        path.lineTo(p.position.dx, p.position.dy); // Corner
        path.lineTo(p.position.dx + armLen, p.position.dy); // Right
        canvas.drawPath(path, paint);
      } else if (p.type == DetectionType.lensRightBottom ||
          p.type == DetectionType.lensLeftBottom) {
        // BOTTOM-RIGHT Corner (┘)
        Path path = Path();
        path.moveTo(p.position.dx - armLen, p.position.dy); // Left
        path.lineTo(p.position.dx, p.position.dy); // Corner
        path.lineTo(p.position.dx, p.position.dy - armLen); // Up
        canvas.drawPath(path, paint);
      } else {
        // Standard Cross for Pupils/Calibration
        double r = 8.0 / scale;
        // Draw cross
        canvas.drawLine(
          p.position - Offset(r, 0),
          p.position + Offset(r, 0),
          paint..strokeWidth = 1.5 / scale,
        );
        canvas.drawLine(
          p.position - Offset(0, r),
          p.position + Offset(0, r),
          paint..strokeWidth = 1.5 / scale,
        );
        // Little dot center
        canvas.drawCircle(p.position, 1.5 / scale, Paint()..color = color);
      }
    }

    // --- 3. BIFOCAL LINE ---
    if (isBifocal) {
      Paint bifocalPaint = Paint()
        ..color = Colors.orangeAccent
        ..strokeWidth = 2.0 / scale;

      // Calculate Y position relative to pupil + offset
      double drop =
          (15.0 / (pixelFactor > 0 ? pixelFactor : 1)) +
          (bifocalOffset / scale);

      // Draw line constrained by the L's width
      if (p1 != null) {
        double x1 = _getPos(DetectionType.lensRightTop)?.dx ?? p1.dx - 20;
        double x2 = _getPos(DetectionType.lensRightBottom)?.dx ?? p1.dx + 20;
        canvas.drawLine(
          Offset(x1, p1.dy + drop),
          Offset(x2, p1.dy + drop),
          bifocalPaint,
        );
      }
      if (p2 != null) {
        double x1 = _getPos(DetectionType.lensLeftTop)?.dx ?? p2.dx - 20;
        double x2 = _getPos(DetectionType.lensLeftBottom)?.dx ?? p2.dx + 20;
        canvas.drawLine(
          Offset(x1, p2.dy + drop),
          Offset(x2, p2.dy + drop),
          bifocalPaint,
        );
      }
    }

    canvas.restore();
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    var path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(
            distance,
            distance + (15.0 / scale),
          ), // Dash length
          paint,
        );
        distance += (25.0 / scale); // Gap length
      }
    }
  }

  Offset? _getPos(DetectionType type) {
    try {
      return points.firstWhere((p) => p.type == type).position;
    } catch (_) {
      return null;
    }
  }

  @override
  bool shouldRepaint(covariant OpticalPainter oldDelegate) => true;
}
