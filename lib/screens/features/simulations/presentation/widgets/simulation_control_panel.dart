import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/simulations_cubit.dart';
import '../../cubit/simulations_state.dart';
import '../../models/simulation_scenario.dart';
import '../../widgets/lens_selector_panel.dart';

class SimulationControlPanel extends StatelessWidget {
  final SimulationsState state;
  final SimulationCategory category;
  final SimulationScenario scenario;
  final CorrectionLens? selectedLens;
  final ValueChanged<CorrectionLens> onLensSelected;

  const SimulationControlPanel({
    super.key,
    required this.state,
    required this.category,
    required this.scenario,
    required this.selectedLens,
    required this.onLensSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isTint = category.id == 'tint';
    final isMultifocal = category.id == 'multifocal';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.95),
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a lens:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Selector and Sizer Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: LensSelectorPanel(
                      lenses: scenario.correctionLenses,
                      selectedLens: selectedLens,
                      onLensSelected: onLensSelected,
                    ),
                  ),

                  // Space around effect
                  if (!isMultifocal) ...[
                    const SizedBox(width: 32),

                    // Vertical separator
                    Container(
                      height: 120,
                      width: 2,
                      color: Colors.white.withOpacity(0.2),
                    ),

                    const SizedBox(width: 32),

                    // Lens controls
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Size Slider
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.crop_free_outlined,
                              color: Colors.white.withOpacity(0.7),
                              size: 32,
                            ),
                            SizedBox(
                              width: 180,
                              height: 60,
                              child: Slider(
                                value: state.lensSize,
                                min: 300,
                                max: 550,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white24,
                                onChanged: (v) {
                                  context.read<SimulationsCubit>().setLensSize(
                                    v,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        // Opacity Slider (Only if tint)
                        if (isTint)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.opacity,
                                color: Colors.white.withOpacity(0.7),
                                size: 32,
                              ),
                              SizedBox(
                                width: 180,
                                height: 60,
                                child: Slider(
                                  value: state.lensOpacity,
                                  min: 0.0,
                                  max: 0.5,
                                  divisions: 13,
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white24,
                                  onChanged: (v) {
                                    context
                                        .read<SimulationsCubit>()
                                        .setLensOpacity(v);
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
