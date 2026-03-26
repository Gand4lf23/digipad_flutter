import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DetectionType {
  refTL,
  refTR,
  refBL,
  refBR,
  pupilRight,
  pupilLeft,
  lensRightTop,
  lensRightBottom,
  lensLeftTop,
  lensLeftBottom,
}

class DetectionPoint {
  String id;
  DetectionType type;
  Offset position;
  String label;

  DetectionPoint({
    required this.id,
    required this.type,
    required this.position,
    required this.label,
  });
}

class OpticalController extends ChangeNotifier {
  List<DetectionPoint> points = [];

  double ajusteHorizontal = 1.0;
  double ajusteVertical = 1.0;
  double referenceCircleDiameterRight = 60.0;
  double referenceCircleDiameterLeft = 60.0;

  bool showCircles = true;
  bool isBifocal = false;
  double bifocalLineOffset = 0.0;

  double pixelFactorX = 0;
  double pixelFactorY = 0;
  double di = 0;
  double puente = 0;
  double dnpRight = 0;
  double dnpLeft = 0;
  double altRight = 0;
  double altLeft = 0;
  double aroAlt = 0;
  double aroAnc = 0;
  double diametroRight = 0;
  double diametroLeft = 0;
  double calcRadiusPxRight = 0;
  double calcRadiusPxLeft = 0;

  DetectionPoint? selectedPoint;

  OpticalController() {
    _loadCalibration();
  }

  Future<void> _loadCalibration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      ajusteHorizontal =
          prefs.getDouble('ajusteHorizontal')?.clamp(0.0, 2.0) ?? 1.0;
      ajusteVertical =
          prefs.getDouble('ajusteVertical')?.clamp(0.0, 2.0) ?? 1.0;

      // Si la imagen ya terminó de cargar sus puntos, actualizamos las fórmulas
      if (points.isNotEmpty) {
        calculateFormulas();
      } else {
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error cargando la calibración: $e");
    }
  }

  // Guarda los valores de calibración en memoria persistente
  Future<void> _saveCalibration(String key, double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (key == 'ajusteHorizontal') {
        ajusteHorizontal = value.clamp(0.0, 2.0);
      } else if (key == 'ajusteVertical') {
        ajusteVertical = value.clamp(0.0, 2.0);
      }

      await prefs.setDouble(key, value);
    } catch (e) {
      debugPrint("Error guardando la calibración: $e");
    }
  }

  void initialize(Map<String, dynamic> detections, Size imageSize) {
    points.clear();

    Offset toPixel(dynamic item) {
      double nx = (item['x'] as num).toDouble();
      double ny = (item['y'] as num).toDouble();
      return Offset(nx * imageSize.width, ny * imageSize.height);
    }

    List<dynamic> rawCircles = detections['circles'] ?? [];
    List<Offset> circleOffsets = rawCircles.map((c) => toPixel(c)).toList();

    if (circleOffsets.isNotEmpty) {
      if (circleOffsets.length >= 4) {
        final pts = circleOffsets.take(4).toList();

        double cx = 0, cy = 0;
        for (var p in pts) {
          cx += p.dx;
          cy += p.dy;
        }
        cx /= 4;
        cy /= 4;

        pts.sort((a, b) {
          double angleA = math.atan2(a.dy - cy, a.dx - cx);
          double angleB = math.atan2(b.dy - cy, b.dx - cx);
          return angleA.compareTo(angleB);
        });

        double len1 = (pts[0] - pts[1]).distance + (pts[2] - pts[3]).distance;
        double len2 = (pts[1] - pts[2]).distance + (pts[3] - pts[0]).distance;

        List<Offset> pair1, pair2;
        if (len1 > len2) {
          pair1 = [pts[0], pts[1]];
          pair2 = [pts[2], pts[3]];
        } else {
          pair1 = [pts[1], pts[2]];
          pair2 = [pts[3], pts[0]];
        }

        pair1.sort((a, b) => a.dx.compareTo(b.dx));
        pair2.sort((a, b) => a.dx.compareTo(b.dx));

        final avgY1 = (pair1[0].dy + pair1[1].dy) / 2;
        final avgY2 = (pair2[0].dy + pair2[1].dy) / 2;
        final List<Offset> topRow = avgY1 <= avgY2 ? pair1 : pair2;
        final List<Offset> bottomRow = avgY1 <= avgY2 ? pair2 : pair1;

        _addPoint(topRow[0], DetectionType.refTL, "A1");
        _addPoint(topRow[1], DetectionType.refTR, "A2");
        _addPoint(bottomRow[0], DetectionType.refBL, "B1");
        _addPoint(bottomRow[1], DetectionType.refBR, "B2");
      } else if (circleOffsets.length >= 2) {
        final List<Offset> sorted = circleOffsets
          ..sort((a, b) => a.dx.compareTo(b.dx));
        _addPoint(sorted.first, DetectionType.refTL, "A1");
        _addPoint(sorted.last, DetectionType.refTR, "A2");
      } else if (circleOffsets.length == 1) {
        _addPoint(circleOffsets.first, DetectionType.refTL, "A1");
      }
    }
    _ensureCalibrationPointsExist(imageSize);

    List<dynamic> rawEyes = detections['eyes'] ?? [];
    if (rawEyes.length >= 2) {
      List<Offset> eyes = rawEyes.map((e) => toPixel(e)).toList()
        ..sort((a, b) => a.dx.compareTo(b.dx));
      _addPoint(eyes[0], DetectionType.pupilRight, "P_1");
      _addPoint(eyes[1], DetectionType.pupilLeft, "P_2");
    } else {
      _addPoint(
        Offset(imageSize.width * 0.4, imageSize.height * 0.45),
        DetectionType.pupilRight,
        "P_1",
      );
      _addPoint(
        Offset(imageSize.width * 0.6, imageSize.height * 0.45),
        DetectionType.pupilLeft,
        "P_2",
      );
    }

    _initializeLensCorners(imageSize);
    calculateFormulas();
  }

  void _addPoint(Offset pos, DetectionType type, String label) {
    if (!points.any((p) => p.type == type)) {
      points.add(
        DetectionPoint(
          id: type.toString(),
          type: type,
          position: pos,
          label: label,
        ),
      );
    }
  }

  void _ensureCalibrationPointsExist(Size size) {
    if (!points.any((p) => p.type == DetectionType.refTL)) {
      _addPoint(
        Offset(size.width * 0.2, size.height * 0.3),
        DetectionType.refTL,
        "A1",
      );
    }
    if (!points.any((p) => p.type == DetectionType.refTR)) {
      _addPoint(
        Offset(size.width * 0.8, size.height * 0.3),
        DetectionType.refTR,
        "A2",
      );
    }
    if (!points.any((p) => p.type == DetectionType.refBL)) {
      _addPoint(
        Offset(size.width * 0.2, size.height * 0.7),
        DetectionType.refBL,
        "B1",
      );
    }
    if (!points.any((p) => p.type == DetectionType.refBR)) {
      _addPoint(
        Offset(size.width * 0.8, size.height * 0.7),
        DetectionType.refBR,
        "B2",
      );
    }
  }

  void _initializeLensCorners(Size size) {
    final Offset p1 = getPoint(DetectionType.pupilRight);
    final Offset p2 = getPoint(DetectionType.pupilLeft);

    final Offset B1 = getPoint(DetectionType.refBL);
    final Offset B2 = getPoint(DetectionType.refBR);
    final double barPx = (B2 - B1).distance;
    final double pxPerMm = barPx > 1
        ? (130.0 / barPx)
        : (130.0 / (size.width * 0.6));

    final double halfW = 25.0 / pxPerMm;
    final double halfH = 19.0 / pxPerMm;

    _addPoint(p1 + Offset(-halfW, -halfH), DetectionType.lensRightTop, "R_TL");
    _addPoint(p1 + Offset(halfW, halfH), DetectionType.lensRightBottom, "R_BR");
    _addPoint(p2 + Offset(-halfW, -halfH), DetectionType.lensLeftTop, "L_TL");
    _addPoint(p2 + Offset(halfW, halfH), DetectionType.lensLeftBottom, "L_BR");
  }

  void handleTap(Offset localPosition, double scale, Offset translation) {
    final imgPos = (localPosition - translation) / scale;
    final hitRadius = 45 / scale;

    try {
      final candidates = points
          .where((p) => (p.position - imgPos).distance <= hitRadius)
          .toList();

      if (candidates.isEmpty) {
        if (selectedPoint != null) {
          selectedPoint = null;
          notifyListeners();
        }
        return;
      }

      candidates.sort((a, b) {
        final distA = (a.position - imgPos).distance;
        final distB = (b.position - imgPos).distance;
        return distA.compareTo(distB);
      });

      selectedPoint = candidates.first;
      notifyListeners();
    } catch (_) {
      if (selectedPoint != null) {
        selectedPoint = null;
        notifyListeners();
      }
    }
  }

  void handleDrag(Offset delta, double scale) {
    if (selectedPoint != null) {
      selectedPoint!.position += (delta / scale);
      calculateFormulas();
      notifyListeners();
    }
  }

  void nudgeSelectedPoint(double dx, double dy) {
    if (selectedPoint != null) {
      selectedPoint!.position += Offset(dx, dy);
      calculateFormulas();
      notifyListeners();
    }
  }

  void setReferenceDiameterRight(double val) {
    referenceCircleDiameterRight = val;
    notifyListeners();
  }

  void setReferenceDiameterLeft(double val) {
    referenceCircleDiameterLeft = val;
    notifyListeners();
  }

  void setAjusteHorizontal(double val) {
    ajusteHorizontal = val;
    calculateFormulas();
    // Guardamos el nuevo valor en cuanto se cambia
    _saveCalibration('ajusteHorizontal', val);
  }

  void setAjusteVertical(double val) {
    ajusteVertical = val;
    calculateFormulas();
    // Guardamos el nuevo valor en cuanto se cambia
    _saveCalibration('ajusteVertical', val);
  }

  void toggleCircles(bool val) {
    showCircles = val;
    notifyListeners();
  }

  void toggleBifocal(bool val) {
    isBifocal = val;
    notifyListeners();
  }

  void adjustBifocalLine(double delta) {
    bifocalLineOffset += delta;
    notifyListeners();
  }

  Offset getPoint(DetectionType type) {
    try {
      return points.firstWhere((p) => p.type == type).position;
    } catch (_) {
      return Offset.zero;
    }
  }

  void calculateFormulas() {
    final Offset A1 = getPoint(DetectionType.refTL);
    final Offset A2 = getPoint(DetectionType.refTR);
    final Offset B1 = getPoint(DetectionType.refBL);
    final Offset B2 = getPoint(DetectionType.refBR);
    final Offset P_1 = getPoint(DetectionType.pupilRight);
    final Offset P_2 = getPoint(DetectionType.pupilLeft);
    final Offset rTL = getPoint(DetectionType.lensRightTop);
    final Offset rBR = getPoint(DetectionType.lensRightBottom);
    final Offset lTL = getPoint(DetectionType.lensLeftTop);
    final Offset lBR = getPoint(DetectionType.lensLeftBottom);

    Offset barVec = B2 - B1;
    if (barVec.dx < 0) barVec = Offset(-barVec.dx, -barVec.dy);
    final double barLen = barVec.distance;
    final Offset hUnit = barLen > 1
        ? Offset(barVec.dx / barLen, barVec.dy / barLen)
        : const Offset(1, 0);
    Offset vUnit = Offset(-hUnit.dy, hUnit.dx);
    if (vUnit.dy < 0) vUnit = Offset(hUnit.dy, -hUnit.dx);

    double distHoriz = barLen < 1 ? 1 : barLen;
    double milimetrosPorPixel = 130.0 / distHoriz;

    pixelFactorX = milimetrosPorPixel * ajusteHorizontal;
    pixelFactorY = milimetrosPorPixel * ajusteVertical;

    final Offset midTop = Offset((A1.dx + A2.dx) / 2, (A1.dy + A2.dy) / 2);

    double h(Offset p) {
      final d = p - B1;
      return d.dx * hUnit.dx + d.dy * hUnit.dy;
    }

    double v(Offset p) {
      final d = p - midTop;
      return d.dx * vUnit.dx + d.dy * vUnit.dy;
    }

    final double hP1 = h(P_1);
    final double hP2 = h(P_2);
    final double RE_1 = h(rTL);
    final double RC_1 = h(rBR);
    final double RC_2 = h(lTL);
    final double RE_2 = h(lBR);

    final double vP1 = v(P_1);
    final double vP2 = v(P_2);
    final double RS_1 = v(rTL);
    final double RI_1 = v(rBR);
    final double RS_2 = v(lTL);
    final double RI_2 = v(lBR);

    di = (hP2 - hP1).abs() * pixelFactorX;
    puente = (RC_2 - RC_1).abs() * pixelFactorX;

    final double centroPx = (RC_1 + RC_2) / 2.0;
    dnpRight = (centroPx - hP1).abs() * pixelFactorX;
    dnpLeft = (hP2 - centroPx).abs() * pixelFactorX;

    aroAnc = (((RC_1 - RE_1).abs() + (RE_2 - RC_2).abs()) / 2.0) * pixelFactorX;

    final double radPxR = (hP1 - RE_1).abs();
    diametroRight = (radPxR * 2.0 * pixelFactorX) + 1.0;
    calcRadiusPxRight = radPxR;

    final double radPxL = (RE_2 - hP2).abs();
    diametroLeft = (radPxL * 2.0 * pixelFactorX) + 1.0;
    calcRadiusPxLeft = radPxL;

    altRight = (RI_1 - vP1).abs() * pixelFactorY;
    altLeft = (RI_2 - vP2).abs() * pixelFactorY;
    aroAlt = (((RI_1 - RS_1).abs() + (RI_2 - RS_2).abs()) / 2.0) * pixelFactorY;

    (P_2.dx - P_1.dx).abs();

    notifyListeners();
  }

  String _fmt(Offset o) =>
      "(${o.dx.toStringAsFixed(1)},${o.dy.toStringAsFixed(1)})";
  String _fmtUnit(Offset o) =>
      "(${o.dx.toStringAsFixed(3)},${o.dy.toStringAsFixed(3)})";
}
