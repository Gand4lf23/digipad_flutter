import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'optical_logic_controller.dart';

const bool kDebugHitboxes = false;

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
  final bool isDragging;

  final double dnpRight;
  final double dnpLeft;
  final double altRight;
  final double altLeft;
  final double aroAnc;
  final bool showChips;

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
    this.isDragging = false,
    this.dnpRight = 0,
    this.dnpLeft = 0,
    this.altRight = 0,
    this.altLeft = 0,
    this.aroAnc = 0,
    this.showChips = false,
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
      if (p1 != null) {
        double refRadiusPxR = (refDiameterMmRight / pixelFactorX) / 2;
        canvas.drawCircle(
          p1,
          refRadiusPxR,
          Paint()
            ..color = Colors.cyanAccent.withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2 / scale,
        );
      }
      if (p2 != null) {
        double refRadiusPxL = (refDiameterMmLeft / pixelFactorX) / 2;
        canvas.drawCircle(
          p2,
          refRadiusPxL,
          Paint()
            ..color = Colors.greenAccent.withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2 / scale,
        );
      }
    }

    // --- 2. POINTS & L CORNERS ---
    for (var p in points) {
      bool isSelected = (p.id == selectedPoint?.id);
      bool isCorner = p.type.index >= DetectionType.lensRightTop.index;
      bool isPupil =
          p.type == DetectionType.pupilLeft ||
          p.type == DetectionType.pupilRight;
      bool isRef =
          p.type == DetectionType.refTL ||
          p.type == DetectionType.refTR ||
          p.type == DetectionType.refBL ||
          p.type == DetectionType.refBR;

      Color color = isPupil
          ? Colors.cyanAccent
          : isRef
          ? Colors.orangeAccent
          : (isCorner ? Colors.white : Colors.redAccent);
      if (isSelected) color = Colors.greenAccent;

      // START UN-ROTATION BLOCK FOR MARKERS
      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(-rotation); // Counter-rotate relative to center of point

      if (isCorner) {
        double armLen = 40.0 / scale;
        final double lStroke = isDragging
            ? (isSelected ? 0.5 : 0.4) / scale
            : (isSelected ? 0.8 : 0.6) / scale;
        Paint lPaint = Paint()
          ..color = Colors.white.withValues(alpha: isSelected ? 0.95 : 0.72)
          ..strokeWidth = lStroke
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.square;
        if (isSelected) lPaint.color = Colors.greenAccent.withValues(alpha: 0.95);

        // --- DEBUG: arm hit bands only (no center circle) ---
        if (kDebugHitboxes) {
          final bandPaint = Paint()
            ..color = Colors.orange.withValues(alpha: 0.28)
            ..strokeWidth = 20.0 / scale
            ..strokeCap = StrokeCap.butt;
          if (p.type == DetectionType.lensRightTop ||
              p.type == DetectionType.lensLeftTop) {
            canvas.drawLine(Offset.zero, Offset(armLen, 0), bandPaint);
            canvas.drawLine(Offset.zero, Offset(0, armLen), bandPaint);
          } else {
            canvas.drawLine(Offset.zero, Offset(-armLen, 0), bandPaint);
            canvas.drawLine(Offset.zero, Offset(0, -armLen), bandPaint);
          }
        }

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
        canvas.drawCircle(Offset.zero, 2.0 / scale, Paint()..color = lPaint.color);
      } else {
        // CROSSES (Stay as "+" regardless of head tilt)
        Paint crossPaint = Paint()
          ..color = color
          ..strokeWidth = (isSelected ? 0.8 : isPupil ? 0.7 : 0.5) / scale
          ..strokeCap = StrokeCap.round;

        double r = isPupil ? 14.0 / scale : 8.0 / scale;
        canvas.drawLine(Offset(-r, 0), Offset(r, 0), crossPaint);
        canvas.drawLine(Offset(0, -r), Offset(0, r), crossPaint);
        if (isPupil) {
          // Ring around pupil marker to make it unmistakable
          canvas.drawCircle(
            Offset.zero,
            r * 0.6,
            Paint()
              ..color = color.withValues(alpha: 0.35)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.6 / scale,
          );
        }
        canvas.drawCircle(
          Offset.zero,
          isPupil ? 2.0 / scale : 1.0 / scale,
          Paint()..color = color,
        );
      }
      canvas.restore(); // END UN-ROTATION BLOCK
    }

    // --- MEASUREMENT LINES + CHIPS (only when showChips is enabled) ---
    if (showChips) {
      _drawMeasurementLines(canvas, scale);

      for (var p in points) {
        final String? chipText = _chipLabel(p.type);
        if (chipText == null) continue;
        canvas.save();
        canvas.translate(p.position.dx, p.position.dy);
        canvas.rotate(-rotation);
        _drawChip(canvas, Offset.zero, chipText, _chipColor(p.type), scale);
        canvas.restore();
      }

      // B-ROW REFERENCE CHIP (130mm)
      final posB1 = _getPos(DetectionType.refBL);
      final posB2 = _getPos(DetectionType.refBR);
      if (posB1 != null && posB2 != null) {
        final midpoint = (posB1 + posB2) / 2;
        canvas.save();
        canvas.translate(midpoint.dx, midpoint.dy);
        canvas.rotate(-rotation);
        _drawChip(canvas, Offset.zero, '130mm', Colors.orangeAccent, scale, yOffset: 20);
        canvas.restore();
      }
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

  String? _chipLabel(DetectionType type) {
    switch (type) {
      case DetectionType.refTL:
      case DetectionType.refTR:
      case DetectionType.refBL:
      case DetectionType.refBR:
        return null; // drawn as inter-pair chip below
      case DetectionType.pupilRight:
        return '${dnpRight.toStringAsFixed(1)}mm';
      case DetectionType.pupilLeft:
        return '${dnpLeft.toStringAsFixed(1)}mm';
      case DetectionType.lensRightTop:
        return '${altRight.toStringAsFixed(1)}mm';
      case DetectionType.lensRightBottom:
        return '${aroAnc.toStringAsFixed(1)}mm';
      case DetectionType.lensLeftTop:
        return '${altLeft.toStringAsFixed(1)}mm';
      case DetectionType.lensLeftBottom:
        return '${aroAnc.toStringAsFixed(1)}mm';
    }
  }

  Color _chipColor(DetectionType type) {
    if (type == DetectionType.pupilRight) return Colors.cyanAccent;
    if (type == DetectionType.pupilLeft) return Colors.greenAccent;
    if (type == DetectionType.refTL ||
        type == DetectionType.refTR ||
        type == DetectionType.refBL ||
        type == DetectionType.refBR) {
      return Colors.orangeAccent;
    }
    return Colors.white70;
  }

  void _drawChip(Canvas canvas, Offset center, String text, Color color, double scale, {double yOffset = -20}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.black, fontSize: 9 / scale, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final px = 4 / scale;
    final py = 2 / scale;
    final chipW = tp.width + px * 2;
    final chipH = tp.height + py * 2;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center + Offset(0, yOffset / scale), width: chipW, height: chipH),
      Radius.circular(chipH / 2),
    );
    canvas.drawRRect(rect, Paint()..color = color.withValues(alpha: 0.85));
    tp.paint(canvas, rect.outerRect.topLeft + Offset(px, py));
  }

  void _drawMeasurementLines(Canvas canvas, double scale) {
    final Paint amberPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.75)
      ..strokeWidth = 0.8 / scale
      ..strokeCap = StrokeCap.round;

    final Offset? p1 = _getPos(DetectionType.pupilRight);
    final Offset? p2 = _getPos(DetectionType.pupilLeft);
    final Offset? rBR = _getPos(DetectionType.lensRightBottom);
    final Offset? lTL = _getPos(DetectionType.lensLeftTop);
    final Offset? rTL = _getPos(DetectionType.lensRightTop);
    final Offset? lBR = _getPos(DetectionType.lensLeftBottom);
    final Offset? b1 = _getPos(DetectionType.refBL);
    final Offset? b2 = _getPos(DetectionType.refBR);

    final double cr = math.cos(rotation), sr = math.sin(rotation);
    final Offset eh = Offset(cr, -sr);
    final Offset ev = Offset(sr, cr);

    double dotP(Offset a, Offset b) => a.dx * b.dx + a.dy * b.dy;

    // B-row (130mm): direct line
    if (b1 != null && b2 != null) {
      canvas.drawLine(b1, b2, amberPaint);
    }

    // DNP: horizontal from each pupil to bridge midpoint (projected along eh)
    if (p1 != null && rBR != null && lTL != null) {
      final Offset bridge = (rBR + lTL) / 2;
      final double dh = dotP(bridge - p1, eh);
      canvas.drawLine(p1, p1 + Offset(eh.dx * dh, eh.dy * dh), amberPaint);
    }
    if (p2 != null && rBR != null && lTL != null) {
      final Offset bridge = (rBR + lTL) / 2;
      final double dh = dotP(bridge - p2, eh);
      canvas.drawLine(p2, p2 + Offset(eh.dx * dh, eh.dy * dh), amberPaint);
    }

    // AltRight: vertical from pupilRight to lensRightBottom (projected along ev)
    if (p1 != null && rBR != null) {
      final double dv = dotP(rBR - p1, ev);
      canvas.drawLine(p1, p1 + Offset(ev.dx * dv, ev.dy * dv), amberPaint);
    }
    // AltLeft: same for left
    if (p2 != null && lBR != null) {
      final double dv = dotP(lBR - p2, ev);
      canvas.drawLine(p2, p2 + Offset(ev.dx * dv, ev.dy * dv), amberPaint);
    }

    // AroAnc right: horizontal at mid-height of right frame
    if (rTL != null && rBR != null) {
      final double vTL = dotP(rTL, ev);
      final double vBR = dotP(rBR, ev);
      final double midV = (vTL + vBR) / 2;
      final Offset leftPt = rTL + Offset(ev.dx * (midV - vTL), ev.dy * (midV - vTL));
      final Offset rightPt = rBR + Offset(ev.dx * (midV - vBR), ev.dy * (midV - vBR));
      canvas.drawLine(leftPt, rightPt, amberPaint);
    }
    // AroAnc left: same for left frame
    if (lTL != null && lBR != null) {
      final double vTL = dotP(lTL, ev);
      final double vBR = dotP(lBR, ev);
      final double midV = (vTL + vBR) / 2;
      final Offset leftPt = lTL + Offset(ev.dx * (midV - vTL), ev.dy * (midV - vTL));
      final Offset rightPt = lBR + Offset(ev.dx * (midV - vBR), ev.dy * (midV - vBR));
      canvas.drawLine(leftPt, rightPt, amberPaint);
    }
  }

  void _drawFrameOutline(Canvas canvas) {
    Offset? rTL = _getPos(DetectionType.lensRightTop);
    Offset? rBR = _getPos(DetectionType.lensRightBottom);
    Offset? lTL = _getPos(DetectionType.lensLeftTop);
    Offset? lBR = _getPos(DetectionType.lensLeftBottom);

    if (rTL == null || rBR == null || lTL == null || lBR == null) return;

    final bool rightActive =
        selectedPoint?.type == DetectionType.lensRightTop ||
        selectedPoint?.type == DetectionType.lensRightBottom;
    final bool leftActive =
        selectedPoint?.type == DetectionType.lensLeftTop ||
        selectedPoint?.type == DetectionType.lensLeftBottom;
    final bool eitherActive = rightActive || leftActive;

    // Screen-axis unit vectors in image-space.
    // After the outer Transform.rotate(rotation) widget:
    //   eh appears as screen-horizontal (+x)
    //   ev appears as screen-vertical  (+y)
    final double cr = math.cos(rotation), sr = math.sin(rotation);
    final Offset eh = Offset(cr, -sr);
    final Offset ev = Offset(sr, cr);

    // Given diagonal corners (origin, opposite), draw a screen-axis-aligned
    // parallelogram in image-space whose corners land exactly on those positions.
    // W = projection of (opposite-origin) onto eh (screen-horizontal span)
    // H = projection of (opposite-origin) onto ev (screen-vertical span)
    void drawLensRect(Offset origin, Offset opposite, bool isActive) {
      final Offset d = opposite - origin;
      final double W = cr * d.dx - sr * d.dy;
      final double H = sr * d.dx + cr * d.dy;
      final Offset p1 = origin + Offset(eh.dx * W, eh.dy * W);
      final Offset p3 = origin + Offset(ev.dx * H, ev.dy * H);
      canvas.drawPath(
        Path()
          ..moveTo(origin.dx, origin.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(opposite.dx, opposite.dy)
          ..lineTo(p3.dx, p3.dy)
          ..close(),
        Paint()
          ..color = Colors.white.withValues(alpha: isActive ? 0.65 : 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (isActive ? 0.8 : 0.5) / scale,
      );
    }

    drawLensRect(rTL, rBR, rightActive);
    drawLensRect(lTL, lBR, leftActive);

    // Bridge: connects the inner side of each frame at mid-height.
    // Right frame inner-top = rTL + W_R * eh; mid = inner-top + H_R/2 * ev
    final Offset dR = rBR - rTL;
    final double wr = cr * dR.dx - sr * dR.dy;
    final double hr = sr * dR.dx + cr * dR.dy;
    final Offset bridgeRight =
        rTL + Offset(eh.dx * wr + ev.dx * (hr / 2), eh.dy * wr + ev.dy * (hr / 2));

    // Left frame inner side is at lTL; mid = lTL + H_L/2 * ev
    final Offset dL = lBR - lTL;
    final double hl = sr * dL.dx + cr * dL.dy;
    final Offset bridgeLeft = lTL + Offset(ev.dx * (hl / 2), ev.dy * (hl / 2));

    canvas.drawLine(
      bridgeRight,
      bridgeLeft,
      Paint()
        ..color = Colors.white.withValues(alpha: eitherActive ? 0.45 : 0.22)
        ..strokeWidth = (eitherActive ? 0.8 : 0.5) / scale,
    );
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
