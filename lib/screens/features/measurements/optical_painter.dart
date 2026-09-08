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
  final double altSupRight;
  final double altSupLeft;
  final double aroAnc;
  final double aroAlt;
  final double anchoExtArmazon;
  final double di;
  final double puente;
  final double diametroRight;
  final double diametroLeft;
  final bool showChips;
  final bool isSinAccesorio;

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
    this.altSupRight = 0,
    this.altSupLeft = 0,
    this.aroAnc = 0,
    this.aroAlt = 0,
    this.anchoExtArmazon = 0,
    this.di = 0,
    this.puente = 0,
    this.diametroRight = 0,
    this.diametroLeft = 0,
    this.showChips = false,
    this.isSinAccesorio = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    Offset? p1 = _getPos(DetectionType.pupilRight);
    Offset? p2 = _getPos(DetectionType.pupilLeft);

    // ── PRESENTATION MODE ("vista limpia") ─────────────────────────────
    // Hide every editing marker (crosses, L-corners, reference circles,
    // frame outline) and show ONLY the curated yellow guides + chips.
    if (showChips) {
      _drawPresentationOverlay(canvas);
      canvas.restore();
      return;
    }

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

  // Draws a chip at worldPos in image-space, counter-rotated so it reads upright on screen.
  // xOff/yOff are in screen-space pixels (divided by scale internally).
  void _drawChipAt(Canvas canvas, Offset worldPos, String text, Color color, double scale,
      {double xOff = 0, double yOff = -18}) {
    canvas.save();
    canvas.translate(worldPos.dx, worldPos.dy);
    canvas.rotate(-rotation);
    _drawChip(canvas, Offset(xOff / scale, 0), text, color, scale, yOffset: yOff);
    canvas.restore();
  }

  /// Curated "clean view" overlay: yellow guide lines + white chips only.
  /// Shown when [showChips] is on; every editing marker is hidden by the
  /// caller. Layout mirrors the reference: ancho total, DIP, DNP, alturas
  /// (base y superior), puente y diametro.
  void _drawPresentationOverlay(Canvas canvas) {
    final Offset? p1 = _getPos(DetectionType.pupilRight);
    final Offset? p2 = _getPos(DetectionType.pupilLeft);
    final Offset? rTL = _getPos(DetectionType.lensRightTop);
    final Offset? rBR = _getPos(DetectionType.lensRightBottom);
    final Offset? lTL = _getPos(DetectionType.lensLeftTop);
    final Offset? lBR = _getPos(DetectionType.lensLeftBottom);
    if (p1 == null || p2 == null || rTL == null || rBR == null ||
        lTL == null || lBR == null) {
      return;
    }

    final double cr = math.cos(rotation), sr = math.sin(rotation);
    final Offset eh = Offset(cr, -sr); // screen-horizontal, image space
    final Offset ev = Offset(sr, cr); // screen-vertical, image space

    final Paint guide = Paint()
      ..color = const Color(0xFFFFE100)
      ..strokeWidth = 1.3 / scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Offset shift(Offset p, double h, double v) =>
        p + Offset(eh.dx * h + ev.dx * v, eh.dy * h + ev.dy * v);
    double alongH(Offset from, Offset to) =>
        (to - from).dx * eh.dx + (to - from).dy * eh.dy;
    double alongV(Offset from, Offset to) =>
        (to - from).dx * ev.dx + (to - from).dy * ev.dy;
    // Point on the screen-horizontal line through [anchor], level with [q].
    Offset onHLine(Offset anchor, Offset q) => shift(anchor, alongH(anchor, q), 0);
    // Point on the screen-vertical line through [anchor], level with [q].
    Offset onVLine(Offset anchor, Offset q) => shift(anchor, 0, alongV(anchor, q));

    String mm(double v) => v.toStringAsFixed(2);
    final double tick = 5.0 / scale;

    void hSpan(Offset a, Offset b, String label, {double chipV = -11}) {
      canvas.drawLine(a, b, guide);
      canvas.drawLine(shift(a, 0, -tick), shift(a, 0, tick), guide);
      canvas.drawLine(shift(b, 0, -tick), shift(b, 0, tick), guide);
      _drawChipAt(canvas, Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2),
          label, Colors.white, scale, yOff: chipV);
    }

    void vSpan(Offset a, Offset b, String label, {double chipH = 16}) {
      canvas.drawLine(a, b, guide);
      canvas.drawLine(shift(a, -tick, 0), shift(a, tick, 0), guide);
      canvas.drawLine(shift(b, -tick, 0), shift(b, tick, 0), guide);
      _drawChipAt(canvas, Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2),
          label, Colors.white, scale, xOff: chipH, yOff: 0);
    }

    final Offset bridgeMid = (rBR + lTL) / 2;

    // 1. Ancho total del armazon: bracket above, spanning the outer edges.
    if (anchoExtArmazon > 0) {
      final Offset outerL = onHLine(rTL, lBR);
      final Offset topR = shift(rTL, 0, -70 / scale);
      final Offset topL = shift(outerL, 0, -70 / scale);
      canvas.drawLine(shift(topR, 0, 5 / scale), rTL, guide);
      canvas.drawLine(shift(topL, 0, 5 / scale), outerL, guide);
      hSpan(topR, topL, mm(anchoExtArmazon));
    }

    // 2. DIP (interpupilar).
    if (di > 0) {
      hSpan(shift(p1, 0, -44 / scale), shift(onHLine(p1, p2), 0, -44 / scale),
          mm(di));
    }

    // 3. DNP derecha / izquierda (pupila -> centro del puente).
    if (dnpRight > 0) {
      hSpan(shift(p1, 0, -18 / scale),
          shift(onHLine(p1, bridgeMid), 0, -18 / scale), mm(dnpRight));
    }
    if (dnpLeft > 0) {
      hSpan(shift(p2, 0, -18 / scale),
          shift(onHLine(p2, bridgeMid), 0, -18 / scale), mm(dnpLeft));
    }

    // 4. Altura a la parte superior del aro (pupila -> borde superior).
    if (altSupRight > 0) {
      vSpan(p1, onVLine(p1, rTL), mm(altSupRight), chipH: -20);
    }
    if (altSupLeft > 0) {
      vSpan(p2, onVLine(p2, lTL), mm(altSupLeft), chipH: 20);
    }

    // 5. Altura a la base del aro (pupila -> borde inferior).
    if (altRight > 0) {
      vSpan(p1, onVLine(p1, rBR), mm(altRight), chipH: -20);
    }
    if (altLeft > 0) {
      vSpan(p2, onVLine(p2, lBR), mm(altLeft), chipH: 20);
    }

    // 6. Puente (entre bordes internos de los aros); chip hacia la nariz.
    if (puente > 0) {
      final Offset innerL = onHLine(rBR, lTL);
      final Offset a = shift(rBR, 0, 16 / scale);
      final Offset b = shift(innerL, 0, 16 / scale);
      canvas.drawLine(rBR, a, guide);
      canvas.drawLine(innerL, b, guide);
      hSpan(a, b, mm(puente), chipV: 13);
    }

    // 7. Diametro (diagonal pupila -> esquina externa del aro derecho).
    if (diametroRight > 0) {
      canvas.drawLine(p1, rTL, guide);
      _drawChipAt(canvas, Offset((p1.dx + rTL.dx) / 2, (p1.dy + rTL.dy) / 2),
          'D ${mm(diametroRight)}', Colors.white, scale, yOff: 0);
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
