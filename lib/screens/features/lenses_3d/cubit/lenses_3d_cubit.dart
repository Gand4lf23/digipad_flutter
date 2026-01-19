import 'package:flutter_bloc/flutter_bloc.dart';
import 'lenses_3d_state.dart';

class Lenses3DCubit extends Cubit<Lenses3DState> {
  Lenses3DCubit() : super(const Lenses3DState());

  /// Update the material index.
  void updateMaterialIndex(LensMaterialIndex materialIndex) {
    // Adjust prescription if out of range for new material
    int newPrescription = state.prescription;
    final newState = state.copyWith(materialIndex: materialIndex);

    if (newPrescription < newState.minPrescription) {
      newPrescription = newState.minPrescription;
    } else if (newPrescription > newState.maxPrescription) {
      newPrescription = newState.maxPrescription;
    }

    emit(
      state.copyWith(
        materialIndex: materialIndex,
        prescription: newPrescription,
      ),
    );
  }

  /// Update the prescription (diopters).
  void updatePrescription(int prescription) {
    final clamped = prescription.clamp(
      state.minPrescription,
      state.maxPrescription,
    );
    emit(state.copyWith(prescription: clamped));
  }

  /// Increment prescription by 1.
  void incrementPrescription() {
    if (state.prescription < state.maxPrescription) {
      emit(state.copyWith(prescription: state.prescription + 1));
    }
  }

  /// Decrement prescription by 1.
  void decrementPrescription() {
    if (state.prescription > state.minPrescription) {
      emit(state.copyWith(prescription: state.prescription - 1));
    }
  }

  /// Update the frame type.
  void updateFrameType(LensFrameType frameType) {
    emit(state.copyWith(frameType: frameType));
  }

  /// Update the orientation/angle.
  void updateOrientation(LensOrientation orientation) {
    emit(state.copyWith(orientation: orientation));
  }

  /// Update orientation by angle value (for slider).
  void updateOrientationByAngle(int angle) {
    final orientation = LensOrientation.values.firstWhere(
      (o) => o.angle == angle,
      orElse: () => LensOrientation.angle15, // Default to front
    );
    emit(state.copyWith(orientation: orientation));
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
}
