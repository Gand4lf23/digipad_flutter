import '../models/simulation_scenario.dart';

/// State for the simulations feature.
class SimulationsState {
  /// Currently selected category.
  final SimulationCategory? selectedCategory;

  /// Currently selected scenario within the category.
  final SimulationScenario? selectedScenario;

  /// Currently selected correction lens (if any).
  final CorrectionLens? selectedLens;

  /// Position of the divider line (0.0 to 1.0).
  /// For vertical divider: 0.0 = left edge, 1.0 = right edge
  /// For horizontal divider: 0.0 = top edge, 1.0 = bottom edge
  final double dividerPosition;

  /// Whether the divider is vertical (true) or horizontal (false).
  final bool isVerticalDivider;

  /// Opacity of the tint (0.0 to 1.0).
  final double lensOpacity;

  /// Whether the user is currently dragging the divider.
  final bool isDragging;

  /// Loading state for images.
  final bool isLoading;

  /// Error message if any.
  final String? errorMessage;

  SimulationsState({
    this.selectedCategory,
    this.selectedScenario,
    this.selectedLens,
    this.dividerPosition = 0.5, // Start in the middle
    this.isVerticalDivider = true, // Default to vertical divider
    this.lensOpacity = 0.5,
    this.isDragging = false,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Initial state with all categories available.
  factory SimulationsState.initial() {
    return SimulationsState(
      selectedCategory: null,
      selectedScenario: null,
      selectedLens: null,
    );
  }

  /// Check if a lens is selected and ready for demonstration.
  bool get hasLensSelected => selectedLens != null;

  /// Check if a scenario is selected.
  bool get hasScenarioSelected => selectedScenario != null;

  /// Get the path to the problem image (how the user sees without correction).
  String? get problemImagePath => selectedScenario?.problemImagePath;

  /// Get the path to the corrected image (how the user sees with the lens).
  String? get correctedImagePath => selectedLens?.correctedImagePath;

  /// Get available lenses for current scenario.
  List<CorrectionLens> get availableLenses =>
      selectedScenario?.correctionLenses ?? [];

  SimulationsState copyWith({
    SimulationCategory? selectedCategory,
    SimulationScenario? selectedScenario,
    CorrectionLens? selectedLens,
    double? dividerPosition,
    bool? isVerticalDivider,
    double? lensOpacity,
    bool? isDragging,
    bool? isLoading,
    String? errorMessage,
    bool clearLens = false,
    bool clearScenario = false,
    bool clearError = false,
  }) {
    return SimulationsState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedScenario: clearScenario
          ? null
          : (selectedScenario ?? this.selectedScenario),
      selectedLens: clearLens ? null : (selectedLens ?? this.selectedLens),
      dividerPosition: dividerPosition ?? this.dividerPosition,
      isVerticalDivider: isVerticalDivider ?? this.isVerticalDivider,
      lensOpacity: lensOpacity ?? this.lensOpacity,
      isDragging: isDragging ?? this.isDragging,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
