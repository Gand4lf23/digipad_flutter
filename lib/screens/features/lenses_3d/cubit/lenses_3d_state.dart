import 'dart:io';
import 'package:flutter/material.dart';

class Lenses3DState {
  final File? image;
  final double leftGraduation;
  final double rightGraduation;
  final Color leftTint;
  final Color rightTint;
  final String? selectedFrame;
  final bool isLoading;

  const Lenses3DState({
    this.image,
    this.leftGraduation = 0.0,
    this.rightGraduation = 0.0,
    this.leftTint = Colors.transparent,
    this.rightTint = Colors.transparent,
    this.selectedFrame,
    this.isLoading = false,
  });

  Lenses3DState copyWith({
    File? image,
    double? leftGraduation,
    double? rightGraduation,
    Color? leftTint,
    Color? rightTint,
    String? selectedFrame,
    bool? isLoading,
  }) {
    return Lenses3DState(
      image: image ?? this.image,
      leftGraduation: leftGraduation ?? this.leftGraduation,
      rightGraduation: rightGraduation ?? this.rightGraduation,
      leftTint: leftTint ?? this.leftTint,
      rightTint: rightTint ?? this.rightTint,
      selectedFrame: selectedFrame ?? this.selectedFrame,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
