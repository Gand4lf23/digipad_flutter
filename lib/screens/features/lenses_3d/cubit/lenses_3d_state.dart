enum LensFrameType {
  frameA('1', 'Metal 55'),
  frameB('m', 'Acetato'),
  frameC('mp', 'Metal 45');

  final String fileCode;
  final String displayName;
  const LensFrameType(this.fileCode, this.displayName);
}

enum LensMaterialIndex {
  index150('150', '1.50'),
  index160('160', '1.60'),
  index170('170', '1.70'),
  index180('180', '1.80');

  final String fileCode;
  final String displayName;
  const LensMaterialIndex(this.fileCode, this.displayName);
}

enum LensOrientation {
  angle01(1, '1', 'Lateral izquierda'),
  angle02(2, '2', 'Lateral izquierda 2'),
  angle03(3, '3', 'Lateral izquierda 3'),
  angle04(4, '4', 'Lateral izquierda 4'),
  angle05(5, '5', 'Lateral izquierda 5'),
  angle06(6, '6', 'Lateral izquierda 6'),
  angle07(7, '7', 'Lateral izquierda 7'),
  angle08(8, '8', 'Lateral izquierda 8'),
  angle09(9, '9', 'Lateral izquierda 9'),
  angle10(10, '10', 'Lateral izquierda 10'),
  angle11(11, '11', 'Casi frente'),
  angle12(12, '12', 'Casi frente 2'),
  angle13(13, '13', 'Casi frente 3'),
  angle14(14, '14', 'Casi frente 4'),
  angle15(15, 'Frente', 'Vista frontal'),
  angle16(16, '16', 'Arriba 1'),
  angle17(17, '17', 'Arriba 2'),
  angle18(18, '18', 'Arriba 3'),
  angle19(19, '19', 'Arriba 4'),
  angle20(20, 'Arriba', 'Vista superior');

  final int angle;
  final String shortName;
  final String displayName;
  const LensOrientation(this.angle, this.shortName, this.displayName);

  String get fileCode {
    return angle.toString().padLeft(4, '0');
  }
}

class Lenses3DState {
  final LensMaterialIndex materialIndex;
  final int prescription;
  final LensFrameType frameType;
  final LensOrientation orientation;
  final bool isLoading;
  final String? errorMessage;

  const Lenses3DState({
    this.materialIndex = LensMaterialIndex.index160,
    this.prescription = 4,
    this.frameType = LensFrameType.frameA,
    this.orientation = LensOrientation.angle15,
    this.isLoading = false,
    this.errorMessage,
  });

  String get currentImagePath {
    final current =
        'assets/images/lenses_3d/glasses_${materialIndex.fileCode}_$prescription${orientation.fileCode}_${frameType.fileCode}.webp';
    return current;
  }

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

  bool get hasValidImage {
    return prescription >= minPrescription && prescription <= maxPrescription;
  }

  Lenses3DState copyWith({
    LensMaterialIndex? materialIndex,
    int? prescription,
    LensFrameType? frameType,
    LensOrientation? orientation,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return Lenses3DState(
      materialIndex: materialIndex ?? this.materialIndex,
      prescription: prescription ?? this.prescription,
      frameType: frameType ?? this.frameType,
      orientation: orientation ?? this.orientation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  List<Object?> get props => [
    materialIndex,
    prescription,
    frameType,
    orientation,
    isLoading,
    errorMessage,
  ];
}
