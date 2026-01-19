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

  final double pixelFactorX; // Horizontal
  final double pixelFactorY; // Vertical
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
    required this.pixelFactorX,
    required this.pixelFactorY,
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

    // --- 1. CIRCLES (Reference & Calculated) - MÁS FINOS ---
    if (showCircles && pixelFactorX > 0) {
      // A. Reference Circle (White/Grey) - Controlled by Slider
      double refRadiusPx = (refDiameterMm / pixelFactorX) / 2;
      Paint refPaint = Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8 / scale; // MÁS FINO

      if (p1 != null) canvas.drawCircle(p1, refRadiusPx, refPaint);
      if (p2 != null) canvas.drawCircle(p2, refRadiusPx, refPaint);

      // B. Calculated Diameter (Cyan) - EXACTO según fórmula
      // El diámetro ya incluye el +1mm, así que mostramos el radio calculado + 0.5mm
      double bufferPx = 0.5 / pixelFactorX;

      Paint calcPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 / scale; // MÁS FINO

      if (p1 != null && calcRadiusPxR > 0) {
        _drawDashedCircle(canvas, p1, calcRadiusPxR + bufferPx, calcPaint);
      }
      if (p2 != null && calcRadiusPxL > 0) {
        _drawDashedCircle(canvas, p2, calcRadiusPxL + bufferPx, calcPaint);
      }
    }

    // --- 2. POINTS & L CORNERS (MEJORADOS) ---
    for (var p in points) {
      bool isSelected = (p.id == selectedPoint?.id);
      bool isCorner = p.type.index >= DetectionType.lensRightTop.index;
      bool isPupil =
          p.type == DetectionType.pupilLeft ||
          p.type == DetectionType.pupilRight;

      // Colors
      Color color = Colors.greenAccent;
      if (isPupil) {
        color = Colors.redAccent;
      } else if (isCorner) {
        color = Colors.yellowAccent; // Las L (bordes ARO INTERNO)
      }

      if (isSelected) color = Colors.white;

      // L SHAPES - MÁS LARGAS Y FINAS
      if (isCorner) {
        double armLen = 60.0 / scale; // MÁS LARGAS (antes 25)
        Paint lPaint = Paint()
          ..color = color
          ..strokeWidth =
              (isSelected ? 2.0 : 1.2) /
              scale // MÁS FINO
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.square;

        if (p.type == DetectionType.lensRightTop ||
            p.type == DetectionType.lensLeftTop) {
          // TOP-LEFT Corner (┌)
          Path path = Path();
          path.moveTo(p.position.dx, p.position.dy + armLen);
          path.lineTo(p.position.dx, p.position.dy);
          path.lineTo(p.position.dx + armLen, p.position.dy);
          canvas.drawPath(path, lPaint);

          // Pequeño círculo en el vértice
          canvas.drawCircle(p.position, 2.0 / scale, Paint()..color = color);
        } else if (p.type == DetectionType.lensRightBottom ||
            p.type == DetectionType.lensLeftBottom) {
          // BOTTOM-RIGHT Corner (┘)
          Path path = Path();
          path.moveTo(p.position.dx - armLen, p.position.dy);
          path.lineTo(p.position.dx, p.position.dy);
          path.lineTo(p.position.dx, p.position.dy - armLen);
          canvas.drawPath(path, lPaint);

          // Pequeño círculo en el vértice
          canvas.drawCircle(p.position, 2.0 / scale, Paint()..color = color);
        }
      } else {
        // CRUCES para Pupils y Calibration - MÁS FINAS
        Paint crossPaint = Paint()
          ..color = color
          ..strokeWidth =
              (isSelected ? 1.5 : 1.0) /
              scale // MÁS FINO
          ..strokeCap = StrokeCap.round;

        double r = isPupil ? 10.0 / scale : 8.0 / scale;

        // Cruz
        canvas.drawLine(
          p.position - Offset(r, 0),
          p.position + Offset(r, 0),
          crossPaint,
        );
        canvas.drawLine(
          p.position - Offset(0, r),
          p.position + Offset(0, r),
          crossPaint,
        );

        // Centro
        canvas.drawCircle(
          p.position,
          isPupil ? 2.0 / scale : 1.5 / scale,
          Paint()..color = color,
        );
      }
    }

    // --- 3. BIFOCAL LINE (MÁS FINA) ---
    if (isBifocal && pixelFactorY > 0) {
      Paint bifocalPaint = Paint()
        ..color = Colors.orangeAccent.withOpacity(0.9)
        ..strokeWidth = 1.5 / scale; // MÁS FINO

      // Calculate Y position: 15mm below pupil + offset
      double drop = (15.0 / pixelFactorY) + (bifocalOffset / scale);

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

    // --- 4. MARCO ARO INTERNO (OPCIONAL - para visualizar) ---
    _drawFrameOutline(canvas);

    canvas.restore();
  }

  void _drawFrameOutline(Canvas canvas) {
    Offset? rTL = _getPos(DetectionType.lensRightTop);
    Offset? rBR = _getPos(DetectionType.lensRightBottom);
    Offset? lTL = _getPos(DetectionType.lensLeftTop);
    Offset? lBR = _getPos(DetectionType.lensLeftBottom);

    if (rTL == null || rBR == null || lTL == null || lBR == null) return;

    Paint framePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 / scale;

    // Right lens box
    canvas.drawRect(Rect.fromPoints(rTL, rBR), framePaint);

    // Left lens box
    canvas.drawRect(Rect.fromPoints(lTL, lBR), framePaint);

    // Bridge line
    canvas.drawLine(
      Offset(rBR.dx, (rTL.dy + rBR.dy) / 2),
      Offset(lTL.dx, (lTL.dy + lBR.dy) / 2),
      framePaint,
    );
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
        double dashLength = 12.0 / scale; // Más cortos
        double gapLength = 18.0 / scale; // Más espaciados
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashLength),
          paint,
        );
        distance += (dashLength + gapLength);
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
