import 'dart:ui';

enum VisionProblem { none, miopia, astigmatismo, glare }

enum SimulationQuality { standard, good, premium }

class SimulationsState {
  final VisionProblem problem;
  final SimulationQuality quality;
  final Offset lensPosition;
  final double lensRadius;

  SimulationsState({
    required this.problem,
    required this.quality,
    required this.lensPosition,
    required this.lensRadius,
  });

  SimulationsState copyWith({
    VisionProblem? problem,
    SimulationQuality? quality,
    Offset? lensPosition,
    double? lensRadius,
  }) {
    return SimulationsState(
      problem: problem ?? this.problem,
      quality: quality ?? this.quality,
      lensPosition: lensPosition ?? this.lensPosition,
      lensRadius: lensRadius ?? this.lensRadius,
    );
  }
}
