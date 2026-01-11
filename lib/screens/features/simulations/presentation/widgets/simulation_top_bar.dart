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
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;

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
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: isPhone ? 24 : 40,
                  ),
                  onPressed: onBack,
                ),
                Expanded(
                  child: Text(
                    'Scene: ${scenario.displayName} - Lens: ${category.displayName}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isPhone ? 16 : 32,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3.0,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
