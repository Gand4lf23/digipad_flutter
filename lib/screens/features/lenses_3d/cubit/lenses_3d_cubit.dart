import 'package:flutter_bloc/flutter_bloc.dart';
import 'lenses_3d_state.dart';

class Lenses3DCubit extends Cubit<Lenses3DState> {
  Lenses3DCubit() : super(const Lenses3DState());

  void copySettingsFrom(Lenses3DState otherState) {
    emit(
      state.copyWith(
        materialIndex: otherState.materialIndex,
        prescription: otherState.prescription,
        frameType: otherState.frameType,
        orientation: otherState.orientation,
      ),
    );
  }

  void updateMaterialIndex(LensMaterialIndex materialIndex) {
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

  void updatePrescription(int prescription) {
    final clamped = prescription.clamp(
      state.minPrescription,
      state.maxPrescription,
    );
    emit(state.copyWith(prescription: clamped));
  }

  void incrementPrescription() {
    if (state.prescription < state.maxPrescription) {
      emit(state.copyWith(prescription: state.prescription + 1));
    }
  }

  void decrementPrescription() {
    if (state.prescription > state.minPrescription) {
      emit(state.copyWith(prescription: state.prescription - 1));
    }
  }

  void updateFrameType(LensFrameType frameType) {
    emit(state.copyWith(frameType: frameType));
  }

  void updateOrientation(LensOrientation orientation) {
    emit(state.copyWith(orientation: orientation));
  }

  void updateOrientationByAngle(int angle) {
    final orientation = LensOrientation.values.firstWhere(
      (o) => o.angle == angle,
      orElse: () => LensOrientation.angle15,
    );
    emit(state.copyWith(orientation: orientation));
  }

  void setLoading(bool isLoading) {
    emit(state.copyWith(isLoading: isLoading));
  }

  void setError(String message) {
    emit(state.copyWith(errorMessage: message, isLoading: false));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
