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

            return Container(
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
                              SimulationStrings.scenarioName(context, scenario),
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
                              SimulationStrings.categoryName(context, category),
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
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Divider mode button
                              GestureDetector(
                                onTap: isLensMode ? onToggleMode : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !isLensMode
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.drag_handle,
                                        color: !isLensMode
                                            ? categoryColor
                                            : Colors.white,
                                        size: responsive.iconSize(20),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        context.l10n.dividerLabel,
                                        style: TextStyle(
                                          color: !isLensMode
                                              ? categoryColor
                                              : Colors.white,
                                          fontSize: responsive.fontSize(28),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Lens mode button
                              GestureDetector(
                                onTap: !isLensMode ? onToggleMode : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLensMode
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle_outlined,
                                        color: isLensMode
                                            ? categoryColor
                                            : Colors.white,
                                        size: responsive.iconSize(20),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        context.l10n.lensLabel,
                                        style: TextStyle(
                                          color: isLensMode
                                              ? categoryColor
                                              : Colors.white,
                                          fontSize: responsive.fontSize(28),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
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
