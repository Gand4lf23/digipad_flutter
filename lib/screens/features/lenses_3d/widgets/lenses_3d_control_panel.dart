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
    final cubit = context.read<Lenses3DCubit>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return BlocBuilder<Lenses3DCubit, Lenses3DState>(
          builder: (context, state) {
            // Reduced padding for compact view
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Material & Frame (Side by side to save vertical space)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildMaterialSelector(context, state, cubit),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFrameSelector(context, state, cubit),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Row 2: Prescription
                  _buildPrescriptionControl(context, state, cubit),

                  const SizedBox(height: 8),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 8),

                  // Row 3: Orientation
                  _buildOrientationControl(context, state, cubit),
                ],
              ),
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.materialIndex,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: LensMaterialIndex.values.map((material) {
            final isSelected = state.materialIndex == material;
            return GestureDetector(
              onTap: () => cubit.updateMaterialIndex(material),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blueAccent.shade200
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Text(
                  material.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 11,
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

  Widget _buildFrameSelector(
    BuildContext context,
    Lenses3DState state,
    Lenses3DCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.frameType,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: LensFrameType.values.map((frame) {
            final isSelected = state.frameType == frame;
            return GestureDetector(
              onTap: () => cubit.updateFrameType(frame),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blueAccent.shade200
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Text(
                  frame.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 11,
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.prescription,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${state.prescription}D',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: state.prescription > state.minPrescription
                  ? cubit.decrementPrescription
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.blueAccent,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              iconSize: 20,
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.grey.shade700,
                  thumbColor: Colors.blueAccent,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  trackHeight: 2,
                ),
                child: Slider(
                  value: state.prescription.toDouble(),
                  min: state.minPrescription.toDouble(),
                  max: state.maxPrescription.toDouble(),
                  divisions: state.maxPrescription - state.minPrescription,
                  onChanged: (value) => cubit.updatePrescription(value.round()),
                ),
              ),
            ),
            IconButton(
              onPressed: state.prescription < state.maxPrescription
                  ? cubit.incrementPrescription
                  : null,
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.blueAccent,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              iconSize: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrientationControl(
    BuildContext context,
    Lenses3DState state,
    Lenses3DCubit cubit,
  ) {
    return Row(
      children: [
        const Icon(Icons.threesixty, color: Colors.greenAccent, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.greenAccent,
              inactiveTrackColor: Colors.grey.shade700,
              thumbColor: Colors.greenAccent,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 2,
            ),
            child: Slider(
              value: state.orientation.angle.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              onChanged: (value) =>
                  cubit.updateOrientationByAngle(value.round()),
            ),
          ),
        ),
      ],
    );
  }
}
