import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Lenses3DControlPanel extends StatelessWidget {
  const Lenses3DControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<Lenses3DCubit>();

    return Container(
      color: Colors.grey.shade900,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lenses Control',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                // Left Eye Controls
                Expanded(
                  child: _EyeControlColumn(
                    label: 'Left Lens',
                    onGraduationChanged: cubit.updateLeftGraduation,
                    onTintChanged: cubit.updateLeftTint,
                  ),
                ),
                const VerticalDivider(color: Colors.grey),
                // Right Eye Controls
                Expanded(
                  child: _EyeControlColumn(
                    label: 'Right Lens',
                    onGraduationChanged: cubit.updateRightGraduation,
                    onTintChanged: cubit.updateRightTint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Frame Selection (Placeholder)
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FrameOption(
                  label: 'Frame 1',
                  onTap: () => cubit.selectFrame('frame_1'),
                ),
                _FrameOption(
                  label: 'Frame 2',
                  onTap: () => cubit.selectFrame('frame_2'),
                ),
                _FrameOption(
                  label: 'Frame 3',
                  onTap: () => cubit.selectFrame('frame_3'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EyeControlColumn extends StatelessWidget {
  final String label;
  final ValueChanged<double> onGraduationChanged;
  final ValueChanged<Color> onTintChanged;

  const _EyeControlColumn({
    required this.label,
    required this.onGraduationChanged,
    required this.onTintChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 5),
        const Text(
          'Graduation',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        Slider(
          value: 0.5, // TODO: Bind to state
          onChanged: onGraduationChanged,
          activeColor: Colors.blueAccent,
        ),
        const Text(
          'Tint',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ColorDot(
              color: Colors.transparent,
              onTap: () => onTintChanged(Colors.transparent),
            ),
            _ColorDot(
              color: Colors.blue.withValues(alpha: 0.3),
              onTap: () => onTintChanged(Colors.blue.withValues(alpha: 0.3)),
            ),
            _ColorDot(
              color: Colors.brown.withValues(alpha: 0.3),
              onTap: () => onTintChanged(Colors.brown.withValues(alpha: 0.3)),
            ),
            _ColorDot(
              color: Colors.grey.withValues(alpha: 0.3),
              onTap: () => onTintChanged(Colors.grey.withValues(alpha: 0.3)),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _ColorDot({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color == Colors.transparent ? Colors.white : color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white),
        ),
        child: color == Colors.transparent
            ? const Icon(Icons.block, size: 12, color: Colors.black)
            : null,
      ),
    );
  }
}

class _FrameOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FrameOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
