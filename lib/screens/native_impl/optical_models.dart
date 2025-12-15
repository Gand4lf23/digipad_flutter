import 'dart:ui';

enum DetectionType {
  pupilLeft, // Left Eye Pupil
  pupilRight, // Right Eye Pupil
  maskTopLeft, // Device Marker (Top-Left)
  maskTopRight, // Device Marker (Top-Right)
  maskBottomLeft, // Device Marker (Bottom-Left)
  maskBottomRight, // Device Marker (Bottom-Right)
}

/// Represents a single movable point (Pupil or Marker)
class DetectionPoint {
  final String id;
  final DetectionType type;
  Offset position; // Absolute coordinates on the original image
  String label;

  DetectionPoint({
    required this.id,
    required this.type,
    required this.position,
    required this.label,
  });
}

/// Configuration constants matching 'ExternalParams' from native
class DeviceConfig {
  // Physical dimensions of the reference device (e.g., credit card size or specific tool)
  // ADJUST THESE VALUES TO MATCH YOUR "DIGIPAD" HARDWARE
  final double maskRealWidthMm;
  final double maskRealHeightMm;
  final double adjustmentFactor; // From Preferences.getAdjustmentBack

  DeviceConfig({
    this.maskRealWidthMm = 85.60, // Standard ID-1 card width (Example)
    this.maskRealHeightMm = 53.98, // Standard ID-1 card height (Example)
    this.adjustmentFactor = 1.0,
  });
}

/// Holds the final calculated optical values
class MeasurementResults {
  final double ipd; // DI / Interpupillary Distance
  final double dnpLeft; // Nasopupillary Distance Left
  final double dnpRight; // Nasopupillary Distance Right
  final double heightLeft; // Fitting Height Left
  final double heightRight; // Fitting Height Right
  final double bridge; // Bridge width
  final double lensWidth; // Aro Ancho
  final double lensHeight; // Aro Alto
  final double diameterLeft; // Effective Diameter Left
  final double diameterRight; // Effective Diameter Right
  final bool isValid; // False if barrel correction fails

  MeasurementResults({
    this.ipd = 0,
    this.dnpLeft = 0,
    this.dnpRight = 0,
    this.heightLeft = 0,
    this.heightRight = 0,
    this.bridge = 0,
    this.lensWidth = 0,
    this.lensHeight = 0,
    this.diameterLeft = 0,
    this.diameterRight = 0,
    this.isValid = true,
  });

  Map<String, dynamic> toMap() => {
    'di': ipd,
    'dnp_left': dnpLeft,
    'dnp_right': dnpRight,
    'height_left': heightLeft,
    'height_right': heightRight,
    'bridge': bridge,
    'lens_width': lensWidth,
    'lens_height': lensHeight,
    'diameter_left': diameterLeft,
    'diameter_right': diameterRight,
    'is_valid': isValid,
  };
}
