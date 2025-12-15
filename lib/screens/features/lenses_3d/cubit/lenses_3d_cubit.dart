import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'lenses_3d_state.dart';

class Lenses3DCubit extends Cubit<Lenses3DState> {
  final ImagePicker _picker = ImagePicker();

  Lenses3DCubit() : super(const Lenses3DState());

  Future<void> pickImage(ImageSource source) async {
    try {
      emit(state.copyWith(isLoading: true));
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        emit(state.copyWith(image: File(pickedFile.path), isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      // Handle error
    }
  }

  void updateLeftGraduation(double value) {
    emit(state.copyWith(leftGraduation: value));
  }

  void updateRightGraduation(double value) {
    emit(state.copyWith(rightGraduation: value));
  }

  void updateLeftTint(Color color) {
    emit(state.copyWith(leftTint: color));
  }

  void updateRightTint(Color color) {
    emit(state.copyWith(rightTint: color));
  }

  void selectFrame(String frame) {
    emit(state.copyWith(selectedFrame: frame));
  }
}
