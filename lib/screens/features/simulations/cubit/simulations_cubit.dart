import 'package:digipad_flutter/screens/features/simulations/cubit/simulations_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ------------------ CUBIT & STATE ------------------

class SimulationsCubit extends Cubit<SimulationsState> {
  SimulationsCubit()
    : super(
        SimulationsState(
          problem: VisionProblem.myopia,
          quality: SimulationQuality.good,
          lensPosition: const Offset(150, 300),
          lensRadius: 120,
        ),
      );

  void setProblem(VisionProblem p) => emit(state.copyWith(problem: p));
  void setQuality(SimulationQuality q) => emit(state.copyWith(quality: q));
  void moveLens(Offset pos) => emit(state.copyWith(lensPosition: pos));
  void setRadius(double r) => emit(state.copyWith(lensRadius: r));
}
