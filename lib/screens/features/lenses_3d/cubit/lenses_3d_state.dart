/// Frame types available for the 3D lens viewer.
enum LensFrameType {
  frameA('1', 'Frame A'),
  frameB('m', 'Frame B'),
  frameC('mp', 'Frame C');

  final String fileCode;
  final String displayName;
  const LensFrameType(this.fileCode, this.displayName);
}

/// Material index options for lenses.
enum LensMaterialIndex {
  index150('150', '1.50'),
  index160('160', '1.60'),
  index170('170', '1.70'),
  index180('180', '1.80');

  final String fileCode;
  final String displayName;
  const LensMaterialIndex(this.fileCode, this.displayName);
}

class Lenses3DState {
  /// Selected material index for the lens.
  final LensMaterialIndex materialIndex;

  /// Prescription in diopters (1-20).
  final int prescription;

  /// Selected frame type.
  final LensFrameType frameType;

  /// Loading state.
  final bool isLoading;

  /// Error message if any.
  final String? errorMessage;

  const Lenses3DState({
    this.materialIndex = LensMaterialIndex.index160,
    this.prescription = 4,
    this.frameType = LensFrameType.frameA,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Generate the asset path for the current lens configuration.
  String get currentImagePath {
    // Format: glasses_[material]_[prescription]0015_[frame].webp
    // Examples: glasses_160_40015_1.webp, glasses_170_100015_mp.webp
    return 'assets/images/lenses_3d/glasses_${materialIndex.fileCode}_${prescription}0015_${frameType.fileCode}.webp';
  }

  /// Get the minimum available prescription for the current material index.
  int get minPrescription {
    switch (materialIndex) {
      case LensMaterialIndex.index150:
        return 1;
      case LensMaterialIndex.index160:
        return 1;
      case LensMaterialIndex.index170:
        return 4;
      case LensMaterialIndex.index180:
        return 4;
    }
  }

  /// Get the maximum available prescription for the current material index.
  int get maxPrescription {
    switch (materialIndex) {
      case LensMaterialIndex.index150:
        return 18;
      case LensMaterialIndex.index160:
        return 20;
      case LensMaterialIndex.index170:
        return 20;
      case LensMaterialIndex.index180:
        return 20;
    }
  }

  /// Check if the current configuration has a valid image.
  bool get hasValidImage {
    return prescription >= minPrescription && prescription <= maxPrescription;
  }

  Lenses3DState copyWith({
    LensMaterialIndex? materialIndex,
    int? prescription,
    LensFrameType? frameType,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return Lenses3DState(
      materialIndex: materialIndex ?? this.materialIndex,
      prescription: prescription ?? this.prescription,
      frameType: frameType ?? this.frameType,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
