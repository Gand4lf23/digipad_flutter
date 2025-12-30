import 'dart:math';
import 'package:flutter/material.dart';

enum DetectionType {
  refTL, // A1 (Arriba Izquierda)
  refTR, // A2 (Arriba Derecha)
  refBL, // Abajo Izquierda
  refBR, // Abajo Derecha
  pupilRight, // P_1 (Ojo Derecho Paciente)
  pupilLeft, // P_2 (Ojo Izquierdo Paciente)
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

  // Usamos Rect para la posición, pero lo dibujaremos como Óvalo
  Rect leftLensRect = Rect.zero;
  Rect rightLensRect = Rect.zero;

  // Configuración
  double ajuste = 1.0;
  double circleDiameterMm = 60.0;
  bool showCircles = false;
  bool isBifocal = false;
  double bifocalLineOffset = 0.0;

  // Resultados
  double pixelFactor = 0;
  double di = 0;
  double puente = 0;
  double medio = 0;
  double dnpRight = 0;
  double dnpLeft = 0;
  double altRight = 0;
  double altLeft = 0;
  double aroAlt = 0;
  double aroAnc = 0;
  double diametroRight = 0;
  double diametroLeft = 0;

  DetectionPoint? selectedPoint;
  String? selectedLensSide;
  Size? _imageSize;

  void initialize(Map<String, dynamic> detections, Size imageSize) {
    _imageSize = imageSize;
    points.clear();

    Offset toPixel(dynamic item) {
      double nx = (item['x'] as num).toDouble();
      double ny = (item['y'] as num).toDouble();
      return Offset(nx * imageSize.width, ny * imageSize.height);
    }

    // 1. Procesar Círculos (Calibración)
    // Esperamos 4 círculos. Los ordenamos espacialmente.
    List<dynamic> rawCircles = detections['circles'] ?? [];
    List<Offset> circleOffsets = rawCircles.map((c) => toPixel(c)).toList();

    // Lógica para asignar TL, TR, BL, BR
    if (circleOffsets.isNotEmpty) {
      // Ordenar por Y primero para separar arriba/abajo
      circleOffsets.sort((a, b) => a.dy.compareTo(b.dy));

      // Si tenemos al menos 2, asumimos que son los de arriba (A1, A2)
      // O si hay 4, tomamos los 2 primeros como arriba y los 2 últimos como abajo
      List<Offset> topRow = [];
      List<Offset> bottomRow = [];

      if (circleOffsets.length >= 4) {
        topRow = [circleOffsets[0], circleOffsets[1]];
        bottomRow = [circleOffsets[2], circleOffsets[3]];
      } else if (circleOffsets.length >= 2) {
        topRow = [circleOffsets[0], circleOffsets[1]];
      } else {
        // Fallback si solo hay 1 o 0
        topRow = circleOffsets;
      }

      // Ordenar filas por X para saber cual es Izq y cual Der
      topRow.sort((a, b) => a.dx.compareTo(b.dx));
      bottomRow.sort((a, b) => a.dx.compareTo(b.dx));

      // Asignar Puntos
      if (topRow.isNotEmpty) _addPoint(topRow.first, DetectionType.refTL, "A1");
      if (topRow.length > 1) _addPoint(topRow.last, DetectionType.refTR, "A2");

      if (bottomRow.isNotEmpty)
        _addPoint(bottomRow.first, DetectionType.refBL, "BL");
      if (bottomRow.length > 1)
        _addPoint(bottomRow.last, DetectionType.refBR, "BR");
    }

    // Si no se detectaron, generar defaults
    _ensureCalibrationPointsExist(imageSize);

    // 2. Procesar Pupilas
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

    _initializeLensRects(imageSize);
    calculateFormulas();
  }

  void _addPoint(Offset pos, DetectionType type, String label) {
    // Evitar duplicados del mismo tipo
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
    // Si falta alguno, lo ponemos en una posición lógica
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
        "BL",
      );
    }
    if (!points.any((p) => p.type == DetectionType.refBR)) {
      _addPoint(
        Offset(size.width * 0.8, size.height * 0.7),
        DetectionType.refBR,
        "BR",
      );
    }
  }

  void _initializeLensRects(Size size) {
    // Inicializar aros como círculos (ancho = alto)
    double dim = size.width * 0.18;
    Offset p1 = getPoint(DetectionType.pupilRight);
    Offset p2 = getPoint(DetectionType.pupilLeft);
    rightLensRect = Rect.fromCenter(center: p1, width: dim, height: dim);
    leftLensRect = Rect.fromCenter(center: p2, width: dim, height: dim);
  }

  // --- INTERACCIÓN ---

  void handleTap(Offset localPosition, double scale, Offset translation) {
    final imgPos = (localPosition - translation) / scale;
    final hitRadius = 5 / scale;

    // Prioridad: Puntos > Lentes
    try {
      points.sort(
        (a, b) => b.type.index.compareTo(a.type.index),
      ); // Pupilas primero
      final hitPoint = points.firstWhere(
        (p) => (p.position - imgPos).distance < hitRadius,
      );
      selectedPoint = hitPoint;
      selectedLensSide = null;
      notifyListeners();
      return;
    } catch (_) {}

    if (rightLensRect.contains(imgPos)) {
      selectedLensSide = 'right';
      selectedPoint = null;
    } else if (leftLensRect.contains(imgPos)) {
      selectedLensSide = 'left';
      selectedPoint = null;
    } else {
      selectedPoint = null;
      selectedLensSide = null;
    }
    notifyListeners();
  }

  void handleDrag(Offset delta, double scale) {
    final imgDelta = delta / scale;
    if (selectedPoint != null) {
      selectedPoint!.position += imgDelta;
      calculateFormulas();
      notifyListeners();
    } else if (selectedLensSide != null) {
      if (selectedLensSide == 'right') {
        rightLensRect = rightLensRect.shift(imgDelta);
      } else {
        leftLensRect = leftLensRect.shift(imgDelta);
      }
      calculateFormulas();
      notifyListeners();
    }
  }

  void nudgeSelectedPoint(double dx, double dy) {
    if (selectedPoint != null) {
      selectedPoint!.position += Offset(dx, dy);
      calculateFormulas();
      notifyListeners();
    } else if (selectedLensSide != null) {
      Offset d = Offset(dx, dy);
      if (selectedLensSide == 'right')
        rightLensRect = rightLensRect.shift(d);
      else
        leftLensRect = leftLensRect.shift(d);
      calculateFormulas();
      notifyListeners();
    }
  }

  // --- SLIDER LENTE ---
  // Ahora seteamos el ancho explícitamente para que el slider se mueva
  void setLensWidth(double newWidth) {
    if (selectedLensSide == null) return;

    // Mantener proporción (cuadrado/círculo) o solo ancho?
    // Asumiremos círculo: ancho = alto
    double newSize = max(10, newWidth);

    if (selectedLensSide == 'right') {
      rightLensRect = Rect.fromCenter(
        center: rightLensRect.center,
        width: newSize,
        height: newSize,
      );
    } else {
      leftLensRect = Rect.fromCenter(
        center: leftLensRect.center,
        width: newSize,
        height: newSize,
      );
    }
    calculateFormulas();
    notifyListeners();
  }

  double getSelectedLensWidth() {
    if (selectedLensSide == 'right') return rightLensRect.width;
    if (selectedLensSide == 'left') return leftLensRect.width;
    return 0;
  }

  // --- VISUALIZACIÓN ---
  void setCircleDiameter(double val) {
    circleDiameterMm = val;
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

  // --- MATEMÁTICAS ---

  Offset getPoint(DetectionType type) {
    try {
      return points.firstWhere((p) => p.type == type).position;
    } catch (_) {
      return Offset.zero;
    }
  }

  void calculateFormulas() {
    // Variables Puntos
    Offset A1 = getPoint(DetectionType.refTL);
    Offset A2 = getPoint(DetectionType.refTR);
    // Nota: Aunque detectamos 4, la fórmula usa A1 y A2 para el ancho (130)
    // Asumimos que A1 es TL y A2 es TR para el eje X.

    Offset P_1 = getPoint(DetectionType.pupilRight);
    Offset P_2 = getPoint(DetectionType.pupilLeft);

    // Variables Lentes (Bordes)
    double RE_1 = rightLensRect.left;
    double RC_1 = rightLensRect.right;
    double RS_1 = rightLensRect.top;
    double RI_1 = rightLensRect.bottom;

    double RC_2 = leftLensRect.left;
    double RE_2 = leftLensRect.right;
    double RS_2 = leftLensRect.top;
    double RI_2 = leftLensRect.bottom;

    // 1. Pixel = 130 / DeltaX
    double distA = (A2.dx - A1.dx).abs();
    if (distA == 0) distA = 1;
    pixelFactor = (130.0 / distA) * ajuste;

    // 2. Fórmulas Estándar
    di = (P_2.dx - P_1.dx) * pixelFactor;
    puente = (RC_2 - RC_1) * pixelFactor;

    double puentePx = RC_2 - RC_1;
    double medioPx = RC_1 + (puentePx / 2.0);
    medio = medioPx;

    dnpRight = (medioPx - P_1.dx) * pixelFactor;
    dnpLeft = (P_2.dx - medioPx) * pixelFactor;

    altRight = (RI_1 - P_1.dy) * pixelFactor;
    altLeft = (RI_2 - P_2.dy) * pixelFactor;

    aroAlt = ((RI_1 - RS_1 + RI_2 - RS_2) / 2.0) * pixelFactor;
    aroAnc = ((RC_1 - RE_1 + RE_2 - RC_2) / 2.0) * pixelFactor;

    diametroRight = ((P_1.dx - RE_1) * 2.0 * pixelFactor) + 1.0;
    diametroLeft = ((RE_2 - P_2.dx) * 2.0 * pixelFactor) + 1.0;

    notifyListeners();
  }
}
