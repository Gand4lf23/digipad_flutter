import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'optical_logic_controller.dart';

class OpticalPainter extends CustomPainter {
  final List<DetectionPoint> points;
  final DetectionPoint? selectedPoint;

  final bool showCircles;
  final double refDiameterMmRight;
  final double refDiameterMmLeft;
  final double calcRadiusPxR;
  final double calcRadiusPxL;

  final double pixelFactorX;
  final double pixelFactorY;
  final bool isBifocal;
  final double bifocalOffset;

  final double scale;
  final Offset offset;

  final double rotation; // Radians from parent

  OpticalPainter({
    required this.points,
    required this.scale,
    required this.offset,
    this.selectedPoint,
    required this.showCircles,
    required this.refDiameterMmRight,
    required this.refDiameterMmLeft,
    required this.calcRadiusPxR,
    required this.calcRadiusPxL,
    required this.pixelFactorX,
    required this.pixelFactorY,
    required this.isBifocal,
    required this.bifocalOffset,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    Offset? p1 = _getPos(DetectionType.pupilRight);
    Offset? p2 = _getPos(DetectionType.pupilLeft);

    // --- 1. CIRCLES ---
    if (showCircles && pixelFactorX > 0) {
      Paint circlePaint = Paint()
        ..color = Colors.blueAccent.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 / scale;

      if (p1 != null) {
        double refRadiusPxR = (refDiameterMmRight / pixelFactorX) / 2;
        canvas.drawCircle(p1, refRadiusPxR, circlePaint);
      }
      if (p2 != null) {
        double refRadiusPxL = (refDiameterMmLeft / pixelFactorX) / 2;
        canvas.drawCircle(p2, refRadiusPxL, circlePaint);
      }
    }

    // --- 2. POINTS & L CORNERS ---
    for (var p in points) {
      bool isSelected = (p.id == selectedPoint?.id);
      bool isCorner = p.type.index >= DetectionType.lensRightTop.index;
      bool isPupil =
          p.type == DetectionType.pupilLeft ||
          p.type == DetectionType.pupilRight;

      Color color = isPupil
          ? Colors.redAccent
          : (isCorner ? Colors.white : Colors.redAccent);
      if (isSelected) color = Colors.green;

      // START UN-ROTATION BLOCK FOR MARKERS
      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(-rotation); // Counter-rotate relative to center of point

      if (isCorner) {
        double armLen = 60.0 / scale;
        Paint lPaint = Paint()
          ..color = color
          ..strokeWidth = (isSelected ? 0.7 : 0.5) / scale
          ..style = PaintingStyle.stroke;

        if (p.type == DetectionType.lensRightTop ||
            p.type == DetectionType.lensLeftTop) {
          // Top-Left Corner (┌) - Now always upright relative to screen
          Path path = Path();
          path.moveTo(0, armLen);
          path.lineTo(0, 0);
          path.lineTo(armLen, 0);
          canvas.drawPath(path, lPaint);
        } else if (p.type == DetectionType.lensRightBottom ||
            p.type == DetectionType.lensLeftBottom) {
          // Bottom-Right Corner (┘) - Now always upright relative to screen
          Path path = Path();
          path.moveTo(-armLen, 0);
          path.lineTo(0, 0);
          path.lineTo(0, -armLen);
          canvas.drawPath(path, lPaint);
        }
        canvas.drawCircle(Offset.zero, 1.5 / scale, Paint()..color = color);
      } else {
        // CROSSES (Stay as "+" regardless of head tilt)
        Paint crossPaint = Paint()
          ..color = color
          ..strokeWidth = (isSelected ? 0.7 : 0.5) / scale
          ..strokeCap = StrokeCap.round;

        double r = isPupil ? 10.0 / scale : 8.0 / scale;
        canvas.drawLine(Offset(-r, 0), Offset(r, 0), crossPaint);
        canvas.drawLine(Offset(0, -r), Offset(0, r), crossPaint);
        canvas.drawCircle(
          Offset.zero,
          isPupil ? 1.5 / scale : 1.0 / scale,
          Paint()..color = color,
        );
      }
      canvas.restore(); // END UN-ROTATION BLOCK
    }

    // --- 3. BIFOCAL LINE ---
    if (isBifocal && pixelFactorY > 0) {
      Paint bifocalPaint = Paint()
        ..color = Colors.orangeAccent.withValues(alpha: 0.9)
        ..strokeWidth = 1.0 / scale;

      double drop = (15.0 / pixelFactorY) + (bifocalOffset / scale);

      void drawLeveledBifocal(
        Offset pupil,
        DetectionType t1,
        DetectionType t2,
      ) {
        Offset targetPos = Offset(pupil.dx, pupil.dy + drop);

        canvas.save();
        canvas.translate(targetPos.dx, targetPos.dy);
        canvas.rotate(-rotation); // Make line horizontal to screen

        double xLeft = (_getPos(t1)?.dx ?? pupil.dx - 20) - targetPos.dx;
        double xRight = (_getPos(t2)?.dx ?? pupil.dx + 20) - targetPos.dx;

        canvas.drawLine(Offset(xLeft, 0), Offset(xRight, 0), bifocalPaint);
        canvas.restore();
      }

      if (p1 != null) {
        drawLeveledBifocal(
          p1,
          DetectionType.lensRightTop,
          DetectionType.lensRightBottom,
        );
      }

      if (p2 != null) {
        drawLeveledBifocal(
          p2,
          DetectionType.lensLeftTop,
          DetectionType.lensLeftBottom,
        );
      }
    }

    // --- 4. FRAME OUTLINE ---
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
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3 / scale;

    // Dibujar rectángulos que respeten perfectamente la rotación de la cara
    void drawLeveledRect(Offset p1, Offset p2) {
      Offset center = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

      // Recuperar el ancho y alto real desenrotando el vector de distancia
      double dx = p2.dx - p1.dx;
      double dy = p2.dy - p1.dy;

      double cosR = math.cos(-rotation);
      double sinR = math.sin(-rotation);

      // Proyección sobre los ejes de la pantalla (cara)
      double screenDx = dx * cosR - dy * sinR;
      double screenDy = dx * sinR + dy * cosR;

      double width = screenDx.abs();
      double height = screenDy.abs();

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(-rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: width, height: height),
        framePaint,
      );
      canvas.restore();
    }

    drawLeveledRect(rTL, rBR);
    drawLeveledRect(lTL, lBR);

    // Dibujar la línea del puente visualmente correcta
    Offset rightLensCenter = Offset(
      (rTL.dx + rBR.dx) / 2,
      (rTL.dy + rBR.dy) / 2,
    );
    Offset leftLensCenter = Offset(
      (lTL.dx + lBR.dx) / 2,
      (lTL.dy + lBR.dy) / 2,
    );

    canvas.save();
    Offset bridgeCenter = Offset(
      (rightLensCenter.dx + leftLensCenter.dx) / 2,
      (rightLensCenter.dy + leftLensCenter.dy) / 2,
    );
    canvas.translate(bridgeCenter.dx, bridgeCenter.dy);
    canvas.rotate(-rotation);

    double dxCenters = leftLensCenter.dx - rightLensCenter.dx;
    double dyCenters = leftLensCenter.dy - rightLensCenter.dy;
    double cosR = math.cos(-rotation);
    double sinR = math.sin(-rotation);

    double centerDistX = (dxCenters * cosR - dyCenters * sinR).abs();
    double rWidth = ((rBR.dx - rTL.dx) * cosR - (rBR.dy - rTL.dy) * sinR).abs();
    double lWidth = ((lBR.dx - lTL.dx) * cosR - (lBR.dy - lTL.dy) * sinR).abs();

    double bridgeWidth = centerDistX - (rWidth / 2) - (lWidth / 2);

    if (bridgeWidth > 0) {
      canvas.drawLine(
        Offset(-bridgeWidth / 2, 0),
        Offset(bridgeWidth / 2, 0),
        framePaint,
      );
    }
    canvas.restore();
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
