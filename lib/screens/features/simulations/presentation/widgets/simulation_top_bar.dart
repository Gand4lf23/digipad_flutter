import 'package:flutter/material.dart';

import '../../models/simulation_scenario.dart';

class SimulationTopBar extends StatelessWidget {
  final SimulationScenario scenario;
  final SimulationCategory category;
  final Color categoryColor;
  final VoidCallback onBack;

  const SimulationTopBar({
    super.key,
    required this.scenario,
    required this.category,
    required this.categoryColor,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              categoryColor.withOpacity(0.9),
              categoryColor.withOpacity(0.0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: onBack,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scenario.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        category.displayName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2.0,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
