import 'dart:math';
import 'package:flutter/material.dart';
import 'optical_models.dart';

class OpticalController extends ChangeNotifier {
  // --- State ---
  List<DetectionPoint> points = [];
  Rect leftLensRect = Rect.zero;
  Rect rightLensRect = Rect.zero;
  MeasurementResults results = MeasurementResults();

  // --- Constants from Native Code ---
  static const double ACCEPTABLE_BARREL_ERROR = 0.01;
  static const double UNACCEPTABLE_BARREL_ERROR = (130 / 21) * 0.1;
  static const double DI_CORRECTION_PARAM = 1.035;

  // --- Internal Calculation Variables ---
  double _barrelStrength = 1.0;
  double _correctionRadius = 0.0;
  int _halfWidth = 0;
  int _halfHeight = 0;

  Size? _imageSize;
  final DeviceConfig _config = DeviceConfig();

  // --- Interaction State ---
  DetectionPoint? selectedPoint;
  String? selectedLensSide; // 'left' or 'right'
  bool isEditMode = true;

  // ---------------------------------------------------------------------------
  // 1. Initialization
  // ---------------------------------------------------------------------------

  /// Accepts the new Map structure: {circles: [{x,y}...], eyes: [{x,y}...]}
  void initialize(Map<String, dynamic> detections, Size imageSize) {
    _imageSize = imageSize;
    points.clear();

    debugPrint("--- INITIALIZING CONTROLLER ---");
    debugPrint("Image Size: $imageSize");
    debugPrint("Raw Detections: $detections");

    // Helper to de-normalize: Percentage -> Pixels
    Offset toPixel(dynamic item) {
      double nx = (item['x'] as num).toDouble();
      double ny = (item['y'] as num).toDouble();

      // Safety check for bad data (infinite or NaN)
      if (!nx.isFinite) nx = 0.5;
      if (!ny.isFinite) ny = 0.5;

      return Offset(nx * imageSize.width, ny * imageSize.height);
    }

    // 1. Process Reference Circles
    final List<dynamic> rawCircles = detections['circles'] ?? [];
    if (rawCircles.isNotEmpty) {
      List<Offset> circleOffsets = rawCircles.map((c) => toPixel(c)).toList();

      // Sort by Y to separate Top Pair from Bottom Pair
      circleOffsets.sort((a, b) => a.dy.compareTo(b.dy));

      if (circleOffsets.length >= 4) {
        // Take the top 2 and bottom 2
        var topPair = [circleOffsets[0], circleOffsets[1]];
        var bottomPair = [
          circleOffsets[2],
          circleOffsets[3],
        ]; // Should be 2 & 3

        // Sort pairs by X to distinguish Left from Right
        topPair.sort((a, b) => a.dx.compareTo(b.dx));
        bottomPair.sort((a, b) => a.dx.compareTo(b.dx));

        _addPoint(topPair[0], DetectionType.maskTopLeft, "Ref TL");
        _addPoint(topPair[1], DetectionType.maskTopRight, "Ref TR");

        // FIX: Ensure we use the second pair for bottom
        if (bottomPair.length >= 2) {
          _addPoint(bottomPair[0], DetectionType.maskBottomLeft, "Ref BL");
          _addPoint(bottomPair[1], DetectionType.maskBottomRight, "Ref BR");
        }
      }
    }

    // 2. Process Eyes
    final List<dynamic> rawEyes = detections['eyes'] ?? [];
    if (rawEyes.isNotEmpty) {
      List<Offset> eyeOffsets = rawEyes.map((e) => toPixel(e)).toList();

      // Sort by X. Screen Left = Patient Right Eye.
      eyeOffsets.sort((a, b) => a.dx.compareTo(b.dx));

      if (eyeOffsets.length >= 2) {
        _addPoint(eyeOffsets[0], DetectionType.pupilRight, "Pupila Der");
        _addPoint(eyeOffsets[1], DetectionType.pupilLeft, "Pupila Izq");
      } else if (eyeOffsets.length == 1) {
        if (eyeOffsets[0].dx < imageSize.width / 2) {
          _addPoint(eyeOffsets[0], DetectionType.pupilRight, "Pupila Der");
        } else {
          _addPoint(eyeOffsets[0], DetectionType.pupilLeft, "Pupila Izq");
        }
      }
    }

    _ensurePointsExist(imageSize);
    _initializeLensRects(imageSize);
    calculateMetrics();
  }

  void _addPoint(Offset pos, DetectionType type, String label) {
    points.add(
      DetectionPoint(
        id: "${type.index}_${pos.dx.toInt()}_${pos.dy.toInt()}",
        type: type,
        position: pos,
        label: label,
      ),
    );
  }

  void _ensurePointsExist(Size size) {
    // If detection failed (or < 4 circles / < 2 eyes), create defaults
    // placed roughly in standard positions to prevent crashes.
    final requiredTypes = DetectionType.values;

    // Default positions logic
    final defaults = {
      DetectionType.maskTopLeft: Offset(size.width * 0.3, size.height * 0.3),
      DetectionType.maskTopRight: Offset(size.width * 0.7, size.height * 0.3),
      DetectionType.maskBottomLeft: Offset(size.width * 0.3, size.height * 0.5),
      DetectionType.maskBottomRight: Offset(
        size.width * 0.7,
        size.height * 0.5,
      ),
      DetectionType.pupilRight: Offset(
        size.width * 0.4,
        size.height * 0.4,
      ), // Screen Left
      DetectionType.pupilLeft: Offset(
        size.width * 0.6,
        size.height * 0.4,
      ), // Screen Right
    };

    for (var type in requiredTypes) {
      if (!points.any((p) => p.type == type)) {
        _addPoint(
          defaults[type] ?? Offset(size.width / 2, size.height / 2),
          type,
          type.toString().split('.').last,
        );
      }
    }
  }

  void _initializeLensRects(Size size) {
    // Default Lens Boxes (approx 15% width of image)
    double w = size.width * 0.15;
    double h = size.width * 0.10;

    // We define centers based on the detected (or default) pupils
    Offset pLeft = _pupil(true); // Screen Right
    Offset pRight = _pupil(false); // Screen Left

    leftLensRect = Rect.fromCenter(center: pLeft, width: w, height: h);
    rightLensRect = Rect.fromCenter(center: pRight, width: w, height: h);
  }

  // ---------------------------------------------------------------------------
  // 2. Interaction (Gestures)
  // ---------------------------------------------------------------------------

  void handleTap(Offset localPosition, double scale, Offset translation) {
    if (!isEditMode) return;

    // Convert screen pixel to image pixel
    final imgPos = (localPosition - translation) / scale;
    final hitRadius = 40.0 / scale; // constant physical touch size

    // Priority 1: Points
    // Sort by distance to select the closest one
    points.sort(
      (a, b) => (a.position - imgPos).distance.compareTo(
        (b.position - imgPos).distance,
      ),
    );

    // Check closest point
    if (points.isNotEmpty &&
        (points.first.position - imgPos).distance < hitRadius) {
      selectedPoint = points.first;
      selectedLensSide = null;
      notifyListeners();
      return;
    }

    // Priority 2: Lenses (Check if inside rect)
    if (leftLensRect.contains(imgPos)) {
      selectedLensSide = 'left';
      selectedPoint = null;
    } else if (rightLensRect.contains(imgPos)) {
      selectedLensSide = 'right';
      selectedPoint = null;
    } else {
      selectedPoint = null;
      selectedLensSide = null;
    }
    notifyListeners();
  }

  void handleDrag(Offset delta, double scale) {
    if (!isEditMode) return;
    final imgDelta = delta / scale;

    if (selectedPoint != null) {
      selectedPoint!.position += imgDelta;
      calculateMetrics();
      notifyListeners();
    } else if (selectedLensSide != null) {
      if (selectedLensSide == 'left') {
        leftLensRect = leftLensRect.shift(imgDelta);
      } else {
        rightLensRect = rightLensRect.shift(imgDelta);
      }
      calculateMetrics();
      notifyListeners();
    }
  }

  void resizeSelectedLens(double widthDelta, double heightDelta) {
    if (selectedLensSide == null) return;

    if (selectedLensSide == 'left') {
      leftLensRect = Rect.fromCenter(
        center: leftLensRect.center,
        width: max(10, leftLensRect.width + widthDelta),
        height: max(10, leftLensRect.height + heightDelta),
      );
    } else {
      rightLensRect = Rect.fromCenter(
        center: rightLensRect.center,
        width: max(10, rightLensRect.width + widthDelta),
        height: max(10, rightLensRect.height + heightDelta),
      );
    }
    calculateMetrics();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 3. Core Math & Barrel Distortion
  // ---------------------------------------------------------------------------

  void calculateMetrics() {
    try {
      _computeBarrelStrength();

      results = MeasurementResults(
        ipd: _getDI(),
        dnpLeft: _getDNP(isLeft: true),
        dnpRight: _getDNP(isLeft: false),
        heightLeft: _getAlt(isLeft: true),
        heightRight: _getAlt(isLeft: false),
        bridge: _getPuente(),
        lensWidth: _getAroAnch(),
        lensHeight: _getAroAlt(),
        diameterLeft: _getDiametro(isLeft: true),
        diameterRight: _getDiametro(isLeft: false),
        isValid: true,
      );
    } catch (e) {
      debugPrint("Calculation Warning: $e");
      // Don't invalidate immediately, allows user to drag points to fix it
      results = MeasurementResults(isValid: false);
    }
    notifyListeners();
  }

  void _computeBarrelStrength() {
    // If missing crucial mask points, we can't compute barrel
    if (!_hasAllMaskPoints()) return;

    final tr = _getPoint(DetectionType.maskTopRight);

    // Native: halfWidth = round(getMask().getTopRightTargetCenter().x * 1.45)
    _halfWidth = (tr.dx * 1.45).round();
    _halfHeight = _halfWidth;

    _correctionRadius = sqrt(pow(_halfWidth, 2) * 4 + pow(_halfHeight, 2) * 4);
    _barrelStrength = _binSearchStrength();

    // Check sanity of barrel correction
    if (_computeError(_barrelStrength) > UNACCEPTABLE_BARREL_ERROR) {
      // Ideally throw error or mark invalid, but we allow partial calculation
    }
  }

  bool _hasAllMaskPoints() {
    return points.any((p) => p.type == DetectionType.maskTopLeft) &&
        points.any((p) => p.type == DetectionType.maskTopRight) &&
        points.any((p) => p.type == DetectionType.maskBottomLeft) &&
        points.any((p) => p.type == DetectionType.maskBottomRight);
  }

  double _binSearchStrength() {
    double minVal = 0.3;
    double maxVal = 2.0;
    double midVal = (minVal + maxVal) / 2;
    double error = double.maxFinite;
    int iterations = 0;

    while (error > ACCEPTABLE_BARREL_ERROR && iterations < 20) {
      double errMin = _computeError(minVal);
      double errMax = _computeError(maxVal);

      if (errMax > errMin) {
        maxVal = midVal;
        midVal = (minVal + maxVal) / 2;
      } else {
        minVal = midVal;
        midVal = (minVal + maxVal) / 2;
      }
      error = _computeError(midVal);
      iterations++;
    }
    return midVal;
  }

  double _computeError(double strength) {
    Offset tl = _getPoint(DetectionType.maskTopLeft);
    Offset tr = _getPoint(DetectionType.maskTopRight);
    Offset bl = _getPoint(DetectionType.maskBottomLeft);
    Offset br = _getPoint(DetectionType.maskBottomRight);

    Offset a = _getSourcePoint(tl, strength);
    Offset b = _getSourcePoint(tr, strength);
    Offset c = _getSourcePoint(bl, strength);
    Offset d = _getSourcePoint(br, strength);

    double d1 = (a - b).distance / (a - c).distance;
    double d2 = (c - d).distance / (b - d).distance;
    double finalDist = (d1 + d2) / 2;

    double targetRatio = _config.maskRealWidthMm / _config.maskRealHeightMm;

    return (finalDist - targetRatio).abs();
  }

  Offset _getSourcePoint(Offset p, double strength) {
    if (_correctionRadius == 0) return p;

    double newX = p.dx - _halfWidth;
    double newY = p.dy - _halfHeight;

    double dist = sqrt(newX * newX + newY * newY);
    double r = dist / _correctionRadius * strength;

    double theta = 1.0;
    if (r != 0) {
      theta = atan(r) / r;
    }

    return Offset(_halfWidth + theta * newX, _halfHeight + theta * newY);
  }

  // ---------------------------------------------------------------------------
  // 4. Optical Formulas
  // ---------------------------------------------------------------------------

  // Java: distanceBetweenPointsDistortionCorrected
  double _distCorrected(Offset p1, Offset p2) {
    Offset a = _getSourcePoint(p1, _barrelStrength);
    Offset b = _getSourcePoint(p2, _barrelStrength);
    return (a - b).distance;
  }

  double _getPixel() {
    Offset tl = _getPoint(DetectionType.maskTopLeft);
    Offset tr = _getPoint(DetectionType.maskTopRight);
    Offset bl = _getPoint(DetectionType.maskBottomLeft);
    Offset br = _getPoint(DetectionType.maskBottomRight);

    // Average top and bottom widths
    double pxDist = (_distCorrected(bl, br) + _distCorrected(tl, tr)) / 2;
    if (pxDist == 0) return 0.1; // avoid div by zero
    return _config.maskRealWidthMm / pxDist; // mm per pixel
  }

  double _getPixelClosest() => _getPixel() * _config.adjustmentFactor;
  double _getPixelFurthest() => _getPixelClosest() * DI_CORRECTION_PARAM;

  // DI (Distance Interpupillary)
  double _getDI() {
    return _distCorrected(_pupil(true), _pupil(false)) * _getPixelFurthest();
  }

  // DNP (Nasopupillary Distance)
  double _getDNP({required bool isLeft}) {
    double centerX = (leftLensRect.center.dx + rightLensRect.center.dx) / 2;
    // We project the center X onto the pupil's Y plane
    Offset center = Offset(centerX, _pupil(isLeft).dy);
    return _distCorrected(_pupil(isLeft), center) * _getPixelFurthest();
  }

  // Alt (Fitting Height)
  double _getAlt({required bool isLeft}) {
    Rect lens = isLeft ? leftLensRect : rightLensRect;
    // Bottom of the lens rect at pupil's X
    Offset bottom = Offset(_pupil(isLeft).dx, lens.bottom);
    return _distCorrected(_pupil(isLeft), bottom) * _getPixelClosest();
  }

  // Puente (Bridge)
  double _getPuente() {
    double neutralY =
        (_getPoint(DetectionType.maskTopLeft).dy +
            _getPoint(DetectionType.maskTopRight).dy) /
        2;
    Offset lRight = Offset(leftLensRect.right, neutralY);
    Offset rLeft = Offset(rightLensRect.left, neutralY);
    return _distCorrected(lRight, rLeft) * _getPixelClosest();
  }

  // Aro (Lens Dimensions)
  double _getAroAnch() {
    double w1 = _distCorrected(
      leftLensRect.bottomLeft,
      leftLensRect.bottomRight,
    );
    double w2 = _distCorrected(
      rightLensRect.bottomLeft,
      rightLensRect.bottomRight,
    );
    return ((w1 + w2) / 2) * _getPixelClosest();
  }

  double _getAroAlt() {
    double h1 = _distCorrected(leftLensRect.topRight, leftLensRect.bottomRight);
    double h2 = _distCorrected(rightLensRect.topLeft, rightLensRect.bottomLeft);
    return ((h1 + h2) / 2) * _getPixelClosest();
  }

  // Effective Diameter
  double _getDiametro({required bool isLeft}) {
    Offset p = _pupil(isLeft);
    Rect lens = isLeft ? leftLensRect : rightLensRect;

    // Calc geometric center of lens
    Offset lensCenter = lens.center;

    // Simplification of finding max distance from pupil to any lens corner/edge
    // Native logic often checks corners to find Effective Diameter (ED)
    List<Offset> corners = [
      lens.topLeft,
      lens.topRight,
      lens.bottomLeft,
      lens.bottomRight,
    ];

    double maxDist = 0;
    for (var c in corners) {
      double d = _distCorrected(p, c);
      if (d > maxDist) maxDist = d;
    }

    // Multiply by 2 for diameter (radius * 2) if using pupil as center,
    // but typically ED is longest dimension of lens * 2 from optical center?
    // Based on provided logic: "distLeft / distRight max"
    // Let's stick to the previous implementation logic:
    double distLeft = (p.dx - lens.left).abs();
    double distRight = (p.dx - lens.right).abs();
    double radiusPx = max(distLeft, distRight);

    Offset pMinus = Offset(p.dx - radiusPx, p.dy);
    Offset pPlus = Offset(p.dx + radiusPx, p.dy);

    return _distCorrected(pMinus, pPlus) * _getPixelClosest() + 1.0;
  }

  // Helpers
  Offset _getPoint(DetectionType type) {
    try {
      return points.firstWhere((p) => p.type == type).position;
    } catch (e) {
      return Offset.zero;
    }
  }

  Offset _pupil(bool isLeft) =>
      _getPoint(isLeft ? DetectionType.pupilLeft : DetectionType.pupilRight);
}
