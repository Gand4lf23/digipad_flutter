import 'package:digipad_flutter/screens/features/simulations/cubit/simulations_cubit.dart';
import 'package:digipad_flutter/screens/features/simulations/cubit/simulations_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SimulationsControlPanel extends StatelessWidget {
  const SimulationsControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimulationsCubit, SimulationsState>(
      builder: (context, state) {
        return Container(
          color: Colors.black.withOpacity(0.05),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Problem:'),
                  const SizedBox(width: 8),
                  DropdownButton<VisionProblem>(
                    value: state.problem,
                    items: VisionProblem.values
                        .map(
                          (p) =>
                              DropdownMenuItem(value: p, child: Text(p.name)),
                        )
                        .toList(),
                    onChanged: (p) =>
                        context.read<SimulationsCubit>().setProblem(p!),
                  ),
                  const SizedBox(width: 16),
                  const Text('Quality:'),
                  const SizedBox(width: 8),
                  DropdownButton<SimulationQuality>(
                    value: state.quality,
                    items: SimulationQuality.values
                        .map(
                          (q) =>
                              DropdownMenuItem(value: q, child: Text(q.name)),
                        )
                        .toList(),
                    onChanged: (q) =>
                        context.read<SimulationsCubit>().setQuality(q!),
                  ),
                  const Spacer(),
                  const Text('Lens Radius'),
                  Slider(
                    value: state.lensRadius,
                    min: 60,
                    max: 220,
                    onChanged: (v) =>
                        context.read<SimulationsCubit>().setRadius(v),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Drag the lens to see the corrected area'),
            ],
          ),
        );
      },
    );
  }
}
