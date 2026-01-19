import 'package:digipad_flutter/common/utils/responsive_utils.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_cubit.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digipad_flutter/l10n/l10n.dart';

class Lenses3DControlPanel extends StatelessWidget {
  const Lenses3DControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final responsive = context.responsive(constraints, orientation);

            // Determine if we have enough width to show the 3 controls in a Row
            // or if we should stack them in a Column (Mobile Portrait)
            final isLandscapeOrWide = constraints.maxWidth > 600;

            return BlocBuilder<Lenses3DCubit, Lenses3DState>(
              builder: (context, state) {
                final cubit = context.read<Lenses3DCubit>();

                return Container(
                  color: Colors.grey.shade900,
                  // Use responsive padding
                  padding: responsive.padding(const EdgeInsets.all(16)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          context.l10n.lensConfiguration,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: responsive.value(
                              mobile: 18,
                              tablet: 22,
                              desktop: 24,
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.spacing(12)),

                        // Main Controls: Material, Prescription, Frame
                        // We use a Flex to switch between Row (Wide) and Column (Narrow)
                        Flex(
                          direction: isLandscapeOrWide
                              ? Axis.horizontal
                              : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Material Index
                            if (isLandscapeOrWide)
                              Expanded(
                                child: _buildMaterialSelector(
                                  context,
                                  state,
                                  cubit,
                                  responsive,
                                ),
                              )
                            else
                              _buildMaterialSelector(
                                context,
                                state,
                                cubit,
                                responsive,
                              ),

                            SizedBox(
                              width: responsive.spacing(12),
                              height: isLandscapeOrWide
                                  ? 0
                                  : responsive.spacing(12),
                            ),

                            // Prescription
                            if (isLandscapeOrWide)
                              Expanded(
                                child: _buildPrescriptionControl(
                                  context,
                                  state,
                                  cubit,
                                  responsive,
                                ),
                              )
                            else
                              _buildPrescriptionControl(
                                context,
                                state,
                                cubit,
                                responsive,
                              ),

                            SizedBox(
                              width: responsive.spacing(12),
                              height: isLandscapeOrWide
                                  ? 0
                                  : responsive.spacing(12),
                            ),

                            // Frame Type
                            if (isLandscapeOrWide)
                              Expanded(
                                child: _buildFrameSelector(
                                  context,
                                  state,
                                  cubit,
                                  responsive,
                                ),
                              )
                            else
                              _buildFrameSelector(
                                context,
                                state,
                                cubit,
                                responsive,
                              ),
                          ],
                        ),

                        SizedBox(height: responsive.spacing(12)),
                        const Divider(color: Colors.white24, height: 1),
                        SizedBox(height: responsive.spacing(12)),

                        // Orientation Control (Full Width)
                        _buildOrientationControl(
                          context,
                          state,
                          cubit,
                          responsive,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMaterialSelector(
    BuildContext context,
    Lenses3DState state,
    Lenses3DCubit cubit,
    ResponsiveUtils responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.materialIndex,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: LensMaterialIndex.values.map((material) {
            final isSelected = state.materialIndex == material;
            return GestureDetector(
              onTap: () => cubit.updateMaterialIndex(material),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blueAccent.shade200
                        : Colors.grey.shade700,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  material.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrescriptionControl(
    BuildContext context,
    Lenses3DState state,
    Lenses3DCubit cubit,
    ResponsiveUtils responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.prescription,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Kept specific centering from HEAD
          children: [
            _buildCircleButton(
              icon: Icons.remove,
              onTap: state.prescription > state.minPrescription
                  ? cubit.decrementPrescription
                  : null,
            ),
            const SizedBox(width: 8),
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blueAccent, width: 1.5),
              ),
              child: Text(
                '${state.prescription}D',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildCircleButton(
              icon: Icons.add,
              onTap: state.prescription < state.maxPrescription
                  ? cubit.incrementPrescription
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.blueAccent,
            inactiveTrackColor: Colors.grey.shade700,
            thumbColor: Colors.blueAccent,
            overlayColor: Colors.blueAccent.withValues(alpha: 0.3),
            trackHeight: 3,
          ),
          child: Slider(
            value: state.prescription.toDouble(),
            min: state.minPrescription.toDouble(),
            max: state.maxPrescription.toDouble(),
            divisions: state.maxPrescription - state.minPrescription,
            onChanged: (value) => cubit.updatePrescription(value.round()),
          ),
        ),
      ],
    );
  }

  Widget _buildFrameSelector(
    BuildContext context,
    Lenses3DState state,
    Lenses3DCubit cubit,
    ResponsiveUtils responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.frameType,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: LensFrameType.values.map((frame) {
            final isSelected = state.frameType == frame;
            return GestureDetector(
              onTap: () => cubit.updateFrameType(frame),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blueAccent.shade200
                        : Colors.grey.shade700,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  frame.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrientationControl(
    BuildContext context,
    Lenses3DState state,
    Lenses3DCubit cubit,
    ResponsiveUtils responsive,
  ) {
    // Note: angles usage logic was removed in HEAD body but existed in definition
    // Keeping logic consistent with HEAD display

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.threesixty, color: Colors.greenAccent, size: 16),
            const SizedBox(width: 6),
            const Text(
              'Orientación',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // Current orientation badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.greenAccent, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getOrientationIcon(state.orientation.angle),
                  const SizedBox(width: 4),
                  Text(
                    state.orientation.shortName,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.greenAccent,
            inactiveTrackColor: Colors.grey.shade700,
            thumbColor: Colors.greenAccent,
            overlayColor: Colors.greenAccent.withOpacity(0.2),
            trackHeight: 3,
            showValueIndicator: ShowValueIndicator.always,
            valueIndicatorColor: Colors.greenAccent,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          child: Slider(
            value: state.orientation.angle.toDouble(),
            min: 1,
            max: 20,
            divisions: 19, // 20 positions (1-20)
            label: state.orientation.angle.toString(),
            onChanged: (value) {
              cubit.updateOrientationByAngle(value.round());
            },
          ),
        ),
        // Labels below slider
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Lateral',
                style: TextStyle(color: Colors.white54, fontSize: 9),
              ),
              Text(
                'Frente',
                style: TextStyle(color: Colors.white54, fontSize: 9),
              ),
              Text(
                'Arriba',
                style: TextStyle(color: Colors.white54, fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getOrientationIcon(int angle) {
    if (angle < 15) {
      // Left side view (1-14)
      return const Icon(Icons.arrow_back, color: Colors.greenAccent, size: 14);
    } else if (angle == 15) {
      // Front view (15)
      return const Icon(Icons.face, color: Colors.greenAccent, size: 14);
    } else {
      // Top view (16-20)
      return const Icon(
        Icons.keyboard_arrow_down,
        color: Colors.greenAccent,
        size: 14,
      );
    }
  }

  Widget _buildCircleButton({required IconData icon, VoidCallback? onTap}) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isEnabled ? Colors.blueAccent : Colors.grey.shade800,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.grey.shade600,
          size: 20,
        ),
      ),
    );
  }
}
