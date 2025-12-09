import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_cubit.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CosmeticControlPanel extends StatelessWidget {
  const CosmeticControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CosmeticLensesCubit>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Colors.grey.shade400),
          left: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide.none,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Eye selection toggle
          BlocBuilder<CosmeticLensesCubit, CosmeticLensesState>(
            builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SegmentedButton<EyeSelection>(
                    segments: const [
                      ButtonSegment(
                        value: EyeSelection.left,
                        label: Text('Left Eye', style: TextStyle(fontSize: 18)),
                        icon: Icon(Icons.visibility, size: 20),
                      ),
                      ButtonSegment(
                        value: EyeSelection.both,
                        label: Text(
                          'Both Eyes',
                          style: TextStyle(fontSize: 20),
                        ),
                        icon: Icon(Icons.remove_red_eye, size: 18),
                      ),
                      ButtonSegment(
                        value: EyeSelection.right,
                        label: Text(
                          'Right Eye',
                          style: TextStyle(fontSize: 20),
                        ),
                        icon: Icon(Icons.visibility, size: 18),
                      ),
                    ],
                    selected: {state.activeEye},
                    onSelectionChanged: (Set<EyeSelection> newSelection) {
                      cubit.setActiveEye(newSelection.first);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.blue.shade700;
                        }
                        return Colors.grey.shade800;
                      }),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          // Vertical sliders in a row
          BlocBuilder<CosmeticLensesCubit, CosmeticLensesState>(
            builder: (context, state) {
              return SizedBox(
                height: 140,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left eye controls
                    if (state.activeEye == EyeSelection.left ||
                        state.activeEye == EyeSelection.both)
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _VerticalSlider(
                                    label: 'Size',
                                    value: state.leftIris.scale,
                                    min: 0.2,
                                    max: 3.0,
                                    onChanged: (value) =>
                                        cubit.updateLeftIrisScale(value),
                                    color: Colors.blue,
                                  ),
                                  _VerticalSlider(
                                    label: 'Opacity',
                                    value: state.leftIris.opacity,
                                    min: 0.0,
                                    max: 1.0,
                                    onChanged: (value) =>
                                        cubit.updateLeftIrisOpacity(value),
                                    color: Colors.blue,
                                    isPercentage: true,
                                  ),
                                  _VerticalToggle(
                                    label: 'Eyelid',
                                    value: state.leftIris.showEyelid,
                                    onChanged: (value) =>
                                        cubit.toggleLeftEyelid(value),
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Divider
                    if (state.activeEye == EyeSelection.both)
                      Container(
                        width: 1,
                        height: 120,
                        color: Colors.grey.shade600,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    // Right eye controls
                    if (state.activeEye == EyeSelection.right ||
                        state.activeEye == EyeSelection.both)
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _VerticalSlider(
                                    label: 'Size',
                                    value: state.rightIris.scale,
                                    min: 0.2,
                                    max: 3.0,
                                    onChanged: (value) =>
                                        cubit.updateRightIrisScale(value),
                                    color: Colors.green,
                                  ),
                                  _VerticalSlider(
                                    label: 'Opacity',
                                    value: state.rightIris.opacity,
                                    min: 0.0,
                                    max: 1.0,
                                    onChanged: (value) =>
                                        cubit.updateRightIrisOpacity(value),
                                    color: Colors.green,
                                    isPercentage: true,
                                  ),
                                  _VerticalToggle(
                                    label: 'Eyelid',
                                    value: state.rightIris.showEyelid,
                                    onChanged: (value) =>
                                        cubit.toggleRightEyelid(value),
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          // Control buttons - always visible at bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () => Navigator.of(context).pop(),
                size: 20,
                containerSize: 44,
              ),
              _CircleIconButton(
                icon: Icons.photo_library,
                onPressed: cubit.pickFromGallery,
                size: 20,
                containerSize: 44,
              ),
              _CircleIconButton(
                icon: Icons.camera_alt,
                onPressed: cubit.capturePhoto,
                size: 28,
                containerSize: 56,
              ),
              _CircleIconButton(
                icon: Icons.save,
                onPressed: cubit.saveComposedImage,
                size: 20,
                containerSize: 44,
              ),
              _CircleIconButton(
                icon: Icons.refresh,
                onPressed: cubit.resetIris,
                size: 20,
                containerSize: 44,
              ),
              _CircleIconButton(
                icon: Icons.delete,
                onPressed: cubit.clearPhoto,
                size: 20,
                containerSize: 44,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerticalSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color color;
  final bool isPercentage;

  const _VerticalSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.color,
    this.isPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6.0,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 12.0,
                ),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                activeColor: color,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isPercentage ? '${(value * 100).toInt()}%' : value.toStringAsFixed(1),
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ],
    );
  }
}

class _VerticalToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  const _VerticalToggle({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Center(
            child: Transform.scale(
              scale: 0.7,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value ? 'On' : 'Off',
          style: const TextStyle(color: Colors.white70, fontSize: 20),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final double containerSize;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    required this.size,
    this.containerSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade800,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}
