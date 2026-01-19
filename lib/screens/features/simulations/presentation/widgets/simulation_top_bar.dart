import 'package:digipad_flutter/common/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:digipad_flutter/l10n/l10n.dart';
import '../simulation_strings.dart';

import '../../models/simulation_scenario.dart';

class SimulationTopBar extends StatelessWidget {
  final SimulationScenario scenario;
  final SimulationCategory category;
  final Color categoryColor;
  final VoidCallback onBack;
  final VoidCallback? onToggleMode;
  final bool isLensMode;

  const SimulationTopBar({
    super.key,
    required this.scenario,
    required this.category,
    required this.categoryColor,
    required this.onBack,
    this.onToggleMode,
    this.isLensMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final responsive = context.responsive(constraints, orientation);

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
                    padding: responsive.padding(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: responsive.iconSize(24),
                          ),
                          onPressed: onBack,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                SimulationStrings.scenarioName(
                                  context,
                                  scenario,
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.fontSize(45),
                                  fontWeight: FontWeight.bold,
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3.0,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                SimulationStrings.categoryName(
                                  context,
                                  category,
                                ),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: responsive.fontSize(32),
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
                        if (onToggleMode != null &&
                            scenario.correctionLenses.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              isLensMode
                                  ? Icons.circle_outlined
                                  : Icons.drag_handle,
                              color: Colors.white,
                              size: responsive.iconSize(32),
                            ),
                            onPressed: onToggleMode,
                            tooltip: isLensMode
                                ? 'Switch to divider mode'
                                : 'Switch to lens dragging mode',
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
