import 'dart:math' as math;
import 'package:flutter/material.dart';

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
        // ── Robust rectangle pairing ────────────────────────────────────────
        // Ordenamos los puntos por ángulo alrededor de su centroide para formar
        // el perímetro (ej. TL, TR, BR, BL). Luego comparamos los lados opuestos
        // para identificar cuáles son las filas (los lados más largos).

        final pts = circleOffsets.take(4).toList();

        // 1. Encontrar el centroide
        double cx = 0, cy = 0;
        for (var p in pts) {
          cx += p.dx;
          cy += p.dy;
        }
        cx /= 4;
        cy /= 4;

        // 2. Ordenar cíclicamente por el ángulo
        pts.sort((a, b) {
          double angleA = math.atan2(a.dy - cy, a.dx - cx);
          double angleB = math.atan2(b.dy - cy, b.dx - cx);
          return angleA.compareTo(angleB);
        });

        // 3. Los puntos forman ahora un polígono ordenado (0-1, 1-2, 2-3, 3-0).
        // Comparamos los dos pares de lados opuestos para ver cuáles son las filas.
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

        // 4. Ordenar cada fila de izquierda a derecha (por su componente X)
        pair1.sort((a, b) => a.dx.compareTo(b.dx));
        pair2.sort((a, b) => a.dx.compareTo(b.dx));

        // 5. La fila superior será la que tenga la menor Y promedio
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

    // Estimate a realistic pixel-per-mm factor from the calibration bar so
    // the initial lens corners land close to the actual frame edges.
    // This avoids absurdly large default measurements on first load.
    final Offset B1 = getPoint(DetectionType.refBL);
    final Offset B2 = getPoint(DetectionType.refBR);
    final double barPx = (B2 - B1).distance;
    final double pxPerMm = barPx > 1
        ? (130.0 / barPx)
        : (130.0 / (size.width * 0.6));

    // Typical frame: ~25mm half-width, ~19mm half-height from pupil center
    final double halfW = 25.0 / pxPerMm;
    final double halfH = 19.0 / pxPerMm;

    _addPoint(p1 + Offset(-halfW, -halfH), DetectionType.lensRightTop, "R_TL");
    _addPoint(p1 + Offset(halfW, halfH), DetectionType.lensRightBottom, "R_BR");
    _addPoint(p2 + Offset(-halfW, -halfH), DetectionType.lensLeftTop, "L_TL");
    _addPoint(p2 + Offset(halfW, halfH), DetectionType.lensLeftBottom, "L_BR");
  }

  void handleTap(Offset localPosition, double scale, Offset translation) {
    // Convertir la posición del toque en pantalla a coordenadas de la imagen
    final imgPos = (localPosition - translation) / scale;

    // Aumentamos un poco el radio de "agarre" (45px lógicos) para facilitar el toque,
    // dividido por la escala para que sea consistente al hacer zoom.
    final hitRadius = 45 / scale;

    try {
      // 1. Filtrar TODOS los puntos que están dentro del radio de toque
      final candidates = points
          .where((p) => (p.position - imgPos).distance <= hitRadius)
          .toList();

      if (candidates.isEmpty) {
        // Si tocamos el vacío, deseleccionar
        if (selectedPoint != null) {
          selectedPoint = null;
          notifyListeners();
        }
        return;
      }

      // 2. Ordenar los candidatos por DISTANCIA (el más cercano gana)
      candidates.sort((a, b) {
        final distA = (a.position - imgPos).distance;
        final distB = (b.position - imgPos).distance;
        return distA.compareTo(distB);
      });

      // 3. Seleccionar el primero (el más cercano)
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
    notifyListeners();
  }

  void setAjusteVertical(double val) {
    ajusteVertical = val;
    calculateFormulas();
    notifyListeners();
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

  // ---------------------------------------------------------------------------
  // MEASUREMENT MATH — Rotation-invariant via calibration-bar projection
  //
  // All coordinates are in original IMAGE pixel space (unaffected by UI rotation).
  // The calibration bar (B1→B2) defines the true optical horizontal axis.
  // Every measurement is projected onto that axis and its perpendicular,
  // so results are identical whether the photo is upright or tilted.
  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // MEASUREMENT MATH — Rotation-invariant via calibration-bar projection
  //
  // All coordinates are in original IMAGE pixel space (unaffected by UI rotation).
  // The calibration bar (B1→B2) defines the true optical horizontal axis.
  // Every measurement is projected onto that axis and its perpendicular,
  // so results are identical whether the photo is upright or tilted.
  // ---------------------------------------------------------------------------
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

    // Build calibration-bar coordinate axes.
    // hUnit always points LEFT→RIGHT; vUnit always points DOWNWARD.
    Offset barVec = B2 - B1;
    if (barVec.dx < 0) barVec = Offset(-barVec.dx, -barVec.dy);
    final double barLen = barVec.distance;
    final Offset hUnit = barLen > 1
        ? Offset(barVec.dx / barLen, barVec.dy / barLen)
        : const Offset(1, 0);
    Offset vUnit = Offset(-hUnit.dy, hUnit.dx);
    if (vUnit.dy < 0) vUnit = Offset(hUnit.dy, -hUnit.dx);

    // ─── CÁLCULO DE ESCALA REAL (CORREGIDO) ─────────────────────────────
    // La única medida real que conocemos es el ancho de la barra (130 mm).
    double distHoriz = barLen < 1 ? 1 : barLen;

    // Como los píxeles de una cámara son cuadrados (1:1), 1 píxel equivale a los
    // mismos milímetros tanto en el eje X como en el eje Y.
    double milimetrosPorPixel = 130.0 / distHoriz;

    // Aplicamos la misma escala a ambos ejes, respetando los ajustes manuales del usuario.
    pixelFactorX = milimetrosPorPixel * ajusteHorizontal;
    pixelFactorY = milimetrosPorPixel * ajusteVertical;

    // Calculamos el midTop solo para tener un punto de origen (Y=0) de referencia
    // para las proyecciones verticales.
    final Offset midTop = Offset((A1.dx + A2.dx) / 2, (A1.dy + A2.dy) / 2);

    // ────────────────────────────────────────────────────────────────────

    // Project all points onto the calibration axes (Soporta rotación)
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

    // Measurements
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
  } // Log helpers

  String _fmt(Offset o) =>
      "(${o.dx.toStringAsFixed(1)},${o.dy.toStringAsFixed(1)})";
  String _fmtUnit(Offset o) =>
      "(${o.dx.toStringAsFixed(3)},${o.dy.toStringAsFixed(3)})";
}
