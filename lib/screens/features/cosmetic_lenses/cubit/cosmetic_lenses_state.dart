import 'dart:ui';

class IrisConfig {
  final String? imagePath;
  final Offset position;
  final double scale;
  final double opacity;
  final bool showEyelid;

  IrisConfig({
    this.imagePath,
    this.position = const Offset(0.5, 0.5), // Center of screen (normalized 0-1)
    this.scale = 1.0,
    this.opacity = 1.0,
    this.showEyelid = false,
  });

  IrisConfig copyWith({
    String? imagePath,
    Offset? position,
    double? scale,
    double? opacity,
    bool? showEyelid,
  }) {
    return IrisConfig(
      imagePath: imagePath ?? this.imagePath,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      opacity: opacity ?? this.opacity,
      showEyelid: showEyelid ?? this.showEyelid,
    );
  }
}

enum EyeSelection { left, right, both }

class CosmeticLensesState {
  final String? cameraPhoto; // File path
  final Map<String, List<String>> availableIris;
  final IrisConfig leftIris;
  final IrisConfig rightIris;
  final List<String> galleryImages; // Paths to images in Sembast
  final EyeSelection activeEye;
  final bool isInitialized;
  final String? statusMessage;
  final bool? isSuccess;

  CosmeticLensesState({
    this.cameraPhoto,
    this.availableIris = const {},
    IrisConfig? leftIris,
    IrisConfig? rightIris,
    this.galleryImages = const [],
    this.activeEye = EyeSelection.both,
    this.isInitialized = false,
    this.statusMessage,
    this.isSuccess,
  }) : leftIris = leftIris ?? IrisConfig(),
       rightIris = rightIris ?? IrisConfig();

  CosmeticLensesState copyWith({
    Object? cameraPhoto = _sentinel,
    Map<String, List<String>>? availableIris,
    IrisConfig? leftIris,
    IrisConfig? rightIris,
    List<String>? galleryImages,
    EyeSelection? activeEye,
    bool? isInitialized,
    Object? statusMessage = _sentinel,
    bool? isSuccess,
  }) {
    return CosmeticLensesState(
      cameraPhoto: cameraPhoto == _sentinel
          ? this.cameraPhoto
          : cameraPhoto as String?,
      availableIris: availableIris ?? this.availableIris,
      leftIris: leftIris ?? this.leftIris,
      rightIris: rightIris ?? this.rightIris,
      galleryImages: galleryImages ?? this.galleryImages,
      activeEye: activeEye ?? this.activeEye,
      isInitialized: isInitialized ?? this.isInitialized,
      statusMessage: statusMessage == _sentinel
          ? this.statusMessage
          : statusMessage as String?,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  static const _sentinel = Object();
}
