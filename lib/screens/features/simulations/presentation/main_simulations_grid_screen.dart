import 'package:digipad_flutter/screens/features/simulations/cubit/simulations_cubit.dart';
import 'package:digipad_flutter/screens/features/simulations/presentation/simulations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainSimulationsGridScreen extends StatelessWidget {
  const MainSimulationsGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final corrections = [
      _Problem("Myopia", Icons.remove_red_eye),
      _Problem("Presbyopia", Icons.visibility),
      _Problem("Monofocal", Icons.circle_outlined),
      _Problem("Bifocal", Icons.center_focus_weak),
      _Problem("Progressive", Icons.view_stream),
      _Problem("Aspheric", Icons.blur_circular),
    ];

    final treatments = [
      _Problem("Anti-reflective", Icons.shield),
      _Problem("Polarized", Icons.filter_hdr),
      _Problem("Photochromic", Icons.brightness_5),
    ];

    final outdoor = [_Problem("Sun", Icons.wb_sunny)];

    return Scaffold(
      appBar: AppBar(title: const Text("Lens Simulator")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CategoryTitle("Vision Correction"),
          _ProblemGrid(corrections, onSelected: _navigateToSimulation),

          const SizedBox(height: 24),
          _CategoryTitle("Lens Treatments"),
          _ProblemGrid(treatments, onSelected: _navigateToSimulation),

          const SizedBox(height: 24),
          _CategoryTitle("Outdoor / Sun Protection"),
          _ProblemGrid(outdoor, onSelected: _navigateToSimulation),
        ],
      ),
    );
  }

  static void _navigateToSimulation(BuildContext context, String problemName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => SimulationsCubit(),
          child: SimulationsScreen(
            problemName: problemName,
            sceneAsset: "assets/images/scenes/TintePlaya.jpg",
          ),
        ),
      ),
    );
  }
}

class _CategoryTitle extends StatelessWidget {
  final String title;
  const _CategoryTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ProblemGrid extends StatelessWidget {
  final List<_Problem> problems;
  final void Function(BuildContext, String) onSelected;

  const _ProblemGrid(this.problems, {required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: problems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.05,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        final item = problems[i];
        return GestureDetector(
          onTap: () => onSelected(context, item.label),
          child: Card(
            elevation: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 48),
                const SizedBox(height: 12),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Problem {
  final String label;
  final IconData icon;
  _Problem(this.label, this.icon);
}
