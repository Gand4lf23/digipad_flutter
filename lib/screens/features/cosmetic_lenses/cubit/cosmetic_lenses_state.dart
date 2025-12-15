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
  final EyeSelection activeEye;
  final bool isInitialized;

  CosmeticLensesState({
    this.cameraPhoto,
    this.availableIris = const {},
    IrisConfig? leftIris,
    IrisConfig? rightIris,
    this.activeEye = EyeSelection.both,
    this.isInitialized = false,
  }) : leftIris = leftIris ?? IrisConfig(),
       rightIris = rightIris ?? IrisConfig();

  CosmeticLensesState copyWith({
    Object? cameraPhoto = _sentinel,
    Map<String, List<String>>? availableIris,
    IrisConfig? leftIris,
    IrisConfig? rightIris,
    EyeSelection? activeEye,
    bool? isInitialized,
  }) {
    return CosmeticLensesState(
      cameraPhoto: cameraPhoto == _sentinel
          ? this.cameraPhoto
          : cameraPhoto as String?,
      availableIris: availableIris ?? this.availableIris,
      leftIris: leftIris ?? this.leftIris,
      rightIris: rightIris ?? this.rightIris,
      activeEye: activeEye ?? this.activeEye,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  static const _sentinel = Object();
}
