import 'dart:math';
import 'package:flutter/material.dart';

enum DetectionType {
  refTL, // A1 (Calibration Top-Left)
  refTR, // A2 (Calibration Top-Right)
  refBL, // Calibration Bottom-Left
  refBR, // Calibration Bottom-Right
  pupilRight, // P_1 (Patient Right Eye / Screen Left)
  pupilLeft, // P_2 (Patient Left Eye / Screen Right)
  // CORNERS (The "L" shapes)
  // Right Eye Box (Screen Left)
  lensRightTop, // Defines RE_1 (Temporal) and RS_1 (Top)
  lensRightBottom, // Defines RC_1 (Nasal) and RI_1 (Bottom)
  // Left Eye Box (Screen Right)
  lensLeftTop, // Defines RC_2 (Nasal) and RS_2 (Top)
  lensLeftBottom, // Defines RE_2 (Temporal) and RI_2 (Bottom)
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

  // Configuration
  double ajuste = 1.0;
  double referenceCircleDiameter = 60.0; // Controlled by Slider
  bool showCircles = true;
  bool isBifocal = false;
  double bifocalLineOffset = 0.0;

  // Calculated Results
  double pixelFactor = 0;
  double di = 0; // IPD
  double puente = 0; // Bridge
  double dnpRight = 0;
  double dnpLeft = 0;
  double altRight = 0;
  double altLeft = 0;
  double aroAlt = 0;
  double aroAnc = 0;
  double diametroRight = 0; // Calculated from L position
  double diametroLeft = 0; // Calculated from L position

  // Visual Helpers for Painter
  double calcRadiusPxRight = 0;
  double calcRadiusPxLeft = 0;

  DetectionPoint? selectedPoint;
  Size? _imageSize;

  void initialize(Map<String, dynamic> detections, Size imageSize) {
    _imageSize = imageSize;
    points.clear();

    Offset toPixel(dynamic item) {
      double nx = (item['x'] as num).toDouble();
      double ny = (item['y'] as num).toDouble();
      return Offset(nx * imageSize.width, ny * imageSize.height);
    }

    // 1. Process Calibration Circles (A1, A2...)
    List<dynamic> rawCircles = detections['circles'] ?? [];
    List<Offset> circleOffsets = rawCircles.map((c) => toPixel(c)).toList();

    if (circleOffsets.isNotEmpty) {
      // Sort Y to find Top vs Bottom rows
      circleOffsets.sort((a, b) => a.dy.compareTo(b.dy));

      List<Offset> topRow = [];
      List<Offset> bottomRow = [];

      if (circleOffsets.length >= 4) {
        topRow = [circleOffsets[0], circleOffsets[1]];
        bottomRow = [circleOffsets[2], circleOffsets[3]];
      } else if (circleOffsets.length >= 2) {
        topRow = [circleOffsets[0], circleOffsets[1]];
      } else {
        topRow = circleOffsets;
      }

      // Sort X to find Left vs Right
      topRow.sort((a, b) => a.dx.compareTo(b.dx));
      bottomRow.sort((a, b) => a.dx.compareTo(b.dx));

      if (topRow.isNotEmpty) _addPoint(topRow.first, DetectionType.refTL, "A1");
      if (topRow.length > 1) _addPoint(topRow.last, DetectionType.refTR, "A2");
      if (bottomRow.isNotEmpty)
        _addPoint(bottomRow.first, DetectionType.refBL, "BL");
      if (bottomRow.length > 1)
        _addPoint(bottomRow.last, DetectionType.refBR, "BR");
    }
    _ensureCalibrationPointsExist(imageSize);

    // 2. Process Pupils (P_1, P_2)
    List<dynamic> rawEyes = detections['eyes'] ?? [];
    if (rawEyes.length >= 2) {
      List<Offset> eyes = rawEyes.map((e) => toPixel(e)).toList()
        ..sort((a, b) => a.dx.compareTo(b.dx));
      _addPoint(eyes[0], DetectionType.pupilRight, "P_1");
      _addPoint(eyes[1], DetectionType.pupilLeft, "P_2");
    } else {
      // Defaults if not found
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

    // 3. Initialize Lens Corners ("L" shapes)
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
    if (!points.any((p) => p.type == DetectionType.refTL))
      _addPoint(
        Offset(size.width * 0.2, size.height * 0.3),
        DetectionType.refTL,
        "A1",
      );
    if (!points.any((p) => p.type == DetectionType.refTR))
      _addPoint(
        Offset(size.width * 0.8, size.height * 0.3),
        DetectionType.refTR,
        "A2",
      );
  }

  void _initializeLensCorners(Size size) {
    Offset p1 = getPoint(DetectionType.pupilRight);
    Offset p2 = getPoint(DetectionType.pupilLeft);

    // Estimate initial box size (e.g., 50mm approx)
    double offsetVal = size.width * 0.08;

    // Right Eye (Screen Left)
    // Top-Left L (Temporal/Top)
    _addPoint(
      p1 + Offset(-offsetVal, -offsetVal),
      DetectionType.lensRightTop,
      "R_TL",
    );
    // Bottom-Right L (Nasal/Bottom)
    _addPoint(
      p1 + Offset(offsetVal, offsetVal),
      DetectionType.lensRightBottom,
      "R_BR",
    );

    // Left Eye (Screen Right)
    // Top-Left L (Nasal/Top)
    _addPoint(
      p2 + Offset(-offsetVal, -offsetVal),
      DetectionType.lensLeftTop,
      "L_TL",
    );
    // Bottom-Right L (Temporal/Bottom)
    _addPoint(
      p2 + Offset(offsetVal, offsetVal),
      DetectionType.lensLeftBottom,
      "L_BR",
    );
  }

  // --- INTERACTION ---

  void handleTap(Offset localPosition, double scale, Offset translation) {
    final imgPos = (localPosition - translation) / scale;
    final hitRadius = 30 / scale; // Larger radius for easier touching of Ls

    try {
      // Priority: Corners > Pupils > Refs
      points.sort((a, b) {
        bool aIsCorner = a.type.index >= DetectionType.lensRightTop.index;
        bool bIsCorner = b.type.index >= DetectionType.lensRightTop.index;
        if (aIsCorner && !bIsCorner) return -1;
        if (!aIsCorner && bIsCorner) return 1;
        return 0;
      });

      final hitPoint = points.firstWhere(
        (p) => (p.position - imgPos).distance < hitRadius,
      );
      selectedPoint = hitPoint;
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

  // --- SLIDER CONTROLS ---

  void setReferenceDiameter(double val) {
    referenceCircleDiameter = val;
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

  // --- MATH FORMULAS ---

  void calculateFormulas() {
    Offset A1 = getPoint(DetectionType.refTL);
    Offset A2 = getPoint(DetectionType.refTR);
    Offset P_1 = getPoint(DetectionType.pupilRight);
    Offset P_2 = getPoint(DetectionType.pupilLeft);

    // Get "L" Corners
    Offset rTL = getPoint(DetectionType.lensRightTop);
    Offset rBR = getPoint(DetectionType.lensRightBottom);
    Offset lTL = getPoint(DetectionType.lensLeftTop);
    Offset lBR = getPoint(DetectionType.lensLeftBottom);

    // Define Edges based on Ls
    // RE (Right Eye - Screen Left)
    double RE_1 = rTL.dx; // Temporal Edge
    double RS_1 = rTL.dy; // Top Edge
    double RC_1 = rBR.dx; // Nasal Edge
    double RI_1 = rBR.dy; // Bottom Edge

    // LE (Left Eye - Screen Right)
    double RC_2 = lTL.dx; // Nasal Edge
    double RS_2 = lTL.dy; // Top Edge
    double RE_2 = lBR.dx; // Temporal Edge
    double RI_2 = lBR.dy; // Bottom Edge

    // 1. Pixel Factor Calculation
    // Formula: Pixel = (130 / (A2.X – A1.X)) * Ajuste
    double distA = (A2.dx - A1.dx).abs();
    if (distA == 0) distA = 1;
    pixelFactor = (130.0 / distA) * ajuste;

    // 2. IPD (DI)
    // Formula: DI = (P_2.X – P_1.X) * Pixel
    di = (P_2.dx - P_1.dx) * pixelFactor;

    // 3. Bridge (Puente)
    // Formula: Puente = (RC_2.X – RC_1.X) * Pixel
    puente = (RC_2 - RC_1) * pixelFactor;

    // 4. Center (Medio) & DNP
    // Formula: Medio = (RC_1.X + (Puente / 2)) -> (RC_1 + RC_2) / 2
    double medioPx = (RC_1 + RC_2) / 2.0;

    // Formula: DNP1 = (Centro - P_1.X) * Pixel
    dnpRight = (medioPx - P_1.dx) * pixelFactor;

    // Formula: DNP2 = (P_2.X - Centro) * Pixel
    dnpLeft = (P_2.dx - medioPx) * pixelFactor;

    // 5. Heights (Alturas)
    // Formula: ALT1 = (RI_1.Y - P_1.Y) * Pixel
    altRight = (RI_1 - P_1.dy) * pixelFactor;
    altLeft = (RI_2 - P_2.dy) * pixelFactor;

    // 6. Box Dimensions (Aro)
    // Formula: Aro Alt. = (((RI_1.Y – RS_1.Y) + (RI_2.Y – RS_2.Y)) / 2) * Pixel
    double h1 = RI_1 - RS_1;
    double h2 = RI_2 - RS_2;
    aroAlt = ((h1 + h2) / 2.0) * pixelFactor;

    // Formula: Aro Anc. = (((RC_1.X – RE_1.X) + (RE_2.X – RC_2.X)) / 2) * Pixel
    double w1 = RC_1 - RE_1;
    double w2 = RE_2 - RC_2;
    aroAnc = ((w1 + w2) / 2.0) * pixelFactor;

    // 7. Calculated Diameters
    // Formula: Diametro1= (((P_1.X – RE_1.X) * 2) * Pixel) + 1
    // Note: We need the pixel radius first to draw it correctly
    double radPxR = (P_1.dx - RE_1).abs();
    diametroRight = (radPxR * 2.0 * pixelFactor) + 1.0;
    calcRadiusPxRight = radPxR; // Store for Painter

    // Formula: Diametro2= (((RE_2.X – P_2.X) * 2) * Pixel) + 1
    double radPxL = (RE_2 - P_2.dx).abs();
    diametroLeft = (radPxL * 2.0 * pixelFactor) + 1.0;
    calcRadiusPxLeft = radPxL; // Store for Painter

    notifyListeners();
  }
}
