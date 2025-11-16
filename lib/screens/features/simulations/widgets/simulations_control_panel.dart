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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Problema:'),
                  const SizedBox(width: 8),
                  DropdownButton<VisionProblem>(
                    value: state.problem,
                    items: VisionProblem.values
                        .map(
                          (p) =>
                              DropdownMenuItem(value: p, child: Text(p.name)),
                        )
                        .toList(),
                    onChanged: (p) => context
                        .read<SimulationsCubit>()
                        .setProblem(p ?? VisionProblem.none),
                  ),
                  const SizedBox(width: 16),
                  const Text('Calidad:'),
                  const SizedBox(width: 8),
                  DropdownButton<SimulationQuality>(
                    value: state.quality,
                    items: SimulationQuality.values
                        .map(
                          (q) =>
                              DropdownMenuItem(value: q, child: Text(q.name)),
                        )
                        .toList(),
                    onChanged: (q) => context
                        .read<SimulationsCubit>()
                        .setQuality(q ?? SimulationQuality.good),
                  ),
                  const Spacer(),
                  const Text('Radio'),
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
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Arrastra con el dedo/cursor para mover el lente',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
