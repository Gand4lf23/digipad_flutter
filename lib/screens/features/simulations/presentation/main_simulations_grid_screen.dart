import 'package:digipad_flutter/screens/features/simulations/presentation/simulations_screen.dart';
import 'package:flutter/material.dart';

class MainSimulationsGridScreen extends StatelessWidget {
  const MainSimulationsGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final correction = [
      _Problem("Miopía", Icons.remove_red_eye),
      _Problem("Presbicia", Icons.visibility),
      _Problem("Monofocal", Icons.circle_outlined),
      _Problem("Bifocal", Icons.center_focus_weak),
      _Problem("Progresivos", Icons.view_stream),
      _Problem("Asférico", Icons.blur_circular),
    ];

    final treatments = [
      _Problem("Antirreflejo", Icons.shield),
      _Problem("Polarizado", Icons.filter_hdr),
      _Problem("Fotocromático", Icons.brightness_5),
    ];

    final outdoor = [_Problem("Solar", Icons.wb_sunny)];

    return Scaffold(
      appBar: AppBar(title: const Text("Simulador de lentes")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CategoryTitle("Corrección de la vista"),
          _ProblemGrid(correction, onSelected: _navigateToSim),

          const SizedBox(height: 24),
          _CategoryTitle("Tratamientos del lente"),
          _ProblemGrid(treatments, onSelected: _navigateToSim),

          const SizedBox(height: 24),
          _CategoryTitle("Uso exterior / protección solar"),
          _ProblemGrid(outdoor, onSelected: _navigateToSim),
        ],
      ),
    );
  }

  static void _navigateToSim(BuildContext context, String problemName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimulationsScreen(problemName: problemName),
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
        crossAxisCount: 2,
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
