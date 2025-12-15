import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/simulation_data.dart';
import '../models/simulation_scenario.dart';
import 'simulations_state.dart';

/// Cubit for managing simulations feature state.
class SimulationsCubit extends Cubit<SimulationsState> {
  SimulationsCubit() : super(SimulationsState.initial());

  /// Get all available categories.
  List<SimulationCategory> get categories => SimulationData.categories;

  /// Select a visual problem category.
  void selectCategory(SimulationCategory category) {
    emit(
      state.copyWith(
        selectedCategory: category,
        clearScenario: true,
        clearLens: true,
      ),
    );
  }

  /// Select a specific scenario within the current category.
  void selectScenario(SimulationScenario scenario) {
    // Auto-select first lens if available
    final firstLens = scenario.correctionLenses.isNotEmpty
        ? scenario.correctionLenses[0]
        : null;
    emit(
      state.copyWith(
        selectedScenario: scenario,
        selectedLens: firstLens,
        clearError: true,
      ),
    );
  }

  /// Select a correction lens for the current scenario.
  void selectLens(CorrectionLens lens) {
    emit(state.copyWith(selectedLens: lens));
  }

  /// Move the draggable lens to a new position.
  void moveLens(Offset position) {
    emit(state.copyWith(lensPosition: position));
  }

  /// Set the lens size.
  void setLensSize(double size) {
    emit(state.copyWith(lensSize: size.clamp(300.0, 550.0)));
  }

  /// Set the lens opacity.
  void setLensOpacity(double opacity) {
    emit(state.copyWith(lensOpacity: opacity.clamp(0.0, 1.0)));
  }

  /// Set dragging state.
  void setDragging(bool isDragging) {
    emit(state.copyWith(isDragging: isDragging));
  }

  /// Set loading state.
  void setLoading(bool isLoading) {
    emit(state.copyWith(isLoading: isLoading));
  }

  /// Set error message.
  void setError(String message) {
    emit(state.copyWith(errorMessage: message, isLoading: false));
  }

  /// Clear error.
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Reset to initial state (category selection).
  void reset() {
    emit(SimulationsState.initial());
  }

  /// Go back to category selection.
  void goToCategories() {
    emit(SimulationsState.initial());
  }

  /// Go back to scenario selection.
  void goToScenarios() {
    emit(state.copyWith(clearLens: true));
  }
}
