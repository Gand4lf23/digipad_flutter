class VisualHealthState {
  final int currentTestIndex;
  final List<String> testImages;
  final bool isInitialized;

  VisualHealthState({
    this.currentTestIndex = 0,
    this.testImages = const [],
    this.isInitialized = false,
  });

  String? get currentTestImage {
    if (testImages.isEmpty || currentTestIndex >= testImages.length) {
      return null;
    }
    return testImages[currentTestIndex];
  }

  VisualHealthState copyWith({
    int? currentTestIndex,
    List<String>? testImages,
    bool? isInitialized,
  }) {
    return VisualHealthState(
      currentTestIndex: currentTestIndex ?? this.currentTestIndex,
      testImages: testImages ?? this.testImages,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}
