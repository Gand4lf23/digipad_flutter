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

            return BlocBuilder<Lenses3DCubit, Lenses3DState>(
              builder: (context, state) {
                final cubit = context.read<Lenses3DCubit>();

                return Container(
                  color: Colors.grey.shade900,
                  padding: responsive.padding(const EdgeInsets.all(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        context.l10n.lensConfiguration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: responsive.spacing(16)),

                      // Material Index Selection
                      _buildMaterialSelector(context, state, cubit, responsive),
                      SizedBox(height: responsive.spacing(16)),

                      // Prescription Control
                      _buildPrescriptionControl(
                        context,
                        state,
                        cubit,
                        responsive,
                      ),
                      SizedBox(height: responsive.spacing(16)),

                      // Frame Type Selection
                      _buildFrameSelector(context, state, cubit, responsive),
                    ],
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
      children: [
        Text(
          context.l10n.materialIndex,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: LensMaterialIndex.values.map((material) {
            final isSelected = state.materialIndex == material;
            return GestureDetector(
              onTap: () => cubit.updateMaterialIndex(material),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blueAccent.shade200
                        : Colors.grey.shade700,
                    width: 2,
                  ),
                ),
                child: Text(
                  material.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 20,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.higherIndexHint,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
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
      children: [
        Text(
          context.l10n.prescription,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Decrement button
            _buildCircleButton(
              icon: Icons.remove,
              onTap: state.prescription > state.minPrescription
                  ? cubit.decrementPrescription
                  : null,
            ),
            const SizedBox(width: 16),

            // Prescription value display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: SizedBox(
                width: 50,
                child: Text(
                  '${state.prescription} D',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Increment button
            _buildCircleButton(
              icon: Icons.add,
              onTap: state.prescription < state.maxPrescription
                  ? cubit.incrementPrescription
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.rangeDiopters(
            state.minPrescription,
            state.maxPrescription,
          ),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        const SizedBox(height: 12),

        // Slider for quick adjustment
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.blueAccent,
            inactiveTrackColor: Colors.grey.shade700,
            thumbColor: Colors.blueAccent,
            overlayColor: Colors.blueAccent.withValues(alpha: 0.3),
            trackHeight: 6,
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
      children: [
        Text(
          context.l10n.frameType,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: LensFrameType.values.map((frame) {
            final isSelected = state.frameType == frame;
            return GestureDetector(
              onTap: () => cubit.updateFrameType(frame),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blueAccent.shade200
                        : Colors.grey.shade700,
                    width: 2,
                  ),
                ),
                child: Text(
                  frame.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 20,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.lensTreatments,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCircleButton({required IconData icon, VoidCallback? onTap}) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isEnabled ? Colors.blueAccent : Colors.grey.shade800,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.grey.shade600,
          size: 28,
        ),
      ),
    );
  }
}
