import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'optical_logic_controller.dart';

class OpticalPainter extends CustomPainter {
  final List<DetectionPoint> points;
  final Rect leftLens;
  final Rect rightLens;
  final DetectionPoint? selectedPoint;
  final String? selectedLensSide;
  final Size imageSize;

  final bool showCircles;
  final double circleDiameterMm;
  final double pixelFactor;
  final bool isBifocal;
  final double bifocalOffset;

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
    required this.showCircles,
    required this.circleDiameterMm,
    required this.pixelFactor,
    required this.isBifocal,
    required this.bifocalOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    // 1. Dibujar Lentes como ÓVALOS (Círculos)
    final Paint lensPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 / scale;

    final Paint selectedLensPaint = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 / scale;

    // Aquí cambiamos drawRect por drawOval
    canvas.drawOval(
      rightLens,
      selectedLensSide == 'right' ? selectedLensPaint : lensPaint,
    );
    canvas.drawOval(
      leftLens,
      selectedLensSide == 'left' ? selectedLensPaint : lensPaint,
    );

    for (var p in points) {
      bool isSelected = (p.id == selectedPoint?.id);

      Color color = Colors.greenAccent;
      if (p.type == DetectionType.pupilLeft ||
          p.type == DetectionType.pupilRight) {
        color = Colors.redAccent;
      }
      if (isSelected) color = Colors.yellow;

      Paint pointPaint = Paint()
        ..color = color
        ..strokeWidth = (isSelected ? 1.1 : 1) / scale
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      double radius = isSelected ? 15.0 / scale : 10.0 / scale;

      // Dibujar CRUZ (+)
      canvas.drawLine(
        p.position - Offset(radius, 0),
        p.position + Offset(radius, 0),
        pointPaint,
      );
      canvas.drawLine(
        p.position - Offset(0, radius),
        p.position + Offset(0, radius),
        pointPaint,
      );

      // Pequeño centro
      canvas.drawCircle(p.position, 2.0 / scale, Paint()..color = color);
    }

    // 3. Círculos Punteados (Diámetro Efectivo)
    if (showCircles && pixelFactor > 0) {
      double radiusPx = (circleDiameterMm / pixelFactor) / 2;
      Paint dashedPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 / scale;

      Offset? p1 = _getPos(DetectionType.pupilRight);
      if (p1 != null) _drawDashedCircle(canvas, p1, radiusPx, dashedPaint);

      Offset? p2 = _getPos(DetectionType.pupilLeft);
      if (p2 != null) _drawDashedCircle(canvas, p2, radiusPx, dashedPaint);
    }

    // 4. Línea Bifocal
    if (isBifocal) {
      Paint bifocalPaint = Paint()
        ..color = Colors.orangeAccent
        ..strokeWidth = 2.0 / scale;
      Offset? p1 = _getPos(DetectionType.pupilRight);
      Offset? p2 = _getPos(DetectionType.pupilLeft);
      double drop =
          (15.0 / (pixelFactor > 0 ? pixelFactor : 1)) +
          (bifocalOffset / scale);

      if (p1 != null) {
        canvas.drawLine(
          Offset(rightLens.left, p1.dy + drop),
          Offset(rightLens.right, p1.dy + drop),
          bifocalPaint,
        );
      }
      if (p2 != null) {
        canvas.drawLine(
          Offset(leftLens.left, p2.dy + drop),
          Offset(leftLens.right, p2.dy + drop),
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
          pathMetric.extractPath(distance, distance + (8.0 / scale)),
          paint,
        );
        distance += (16.0 / scale);
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
