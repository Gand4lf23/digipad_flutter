import 'dart:io';
import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_state.dart';
import 'package:flutter/material.dart';

class DualImageViewer extends StatelessWidget {
  final Lenses3DState state;
  final bool isZoomedOut;
  final VoidCallback? onPickImage;

  const DualImageViewer({
    super.key,
    required this.state,
    required this.isZoomedOut,
    this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    if (state.image == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: ElevatedButton.icon(
            onPressed: onPickImage,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _SingleLensView(
            image: state.image!,
            graduation: state.leftGraduation,
            tint: state.leftTint,
            isZoomedOut: isZoomedOut,
            label: 'Left',
            selectedFrame: state.selectedFrame,
          ),
        ),
        Container(width: 1, color: Colors.white),
        Expanded(
          child: _SingleLensView(
            image: state.image!,
            graduation: state.rightGraduation,
            tint: state.rightTint,
            isZoomedOut: isZoomedOut,
            label: 'Right',
            selectedFrame: state.selectedFrame,
          ),
        ),
      ],
    );
  }
}

class _SingleLensView extends StatelessWidget {
  final File image;
  final double graduation;
  final Color tint;
  final bool isZoomedOut;
  final String label;
  final String? selectedFrame;

  const _SingleLensView({
    required this.image,
    required this.graduation,
    required this.tint,
    required this.isZoomedOut,
    required this.label,
    this.selectedFrame,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image
        Image.file(
          image,
          fit: isZoomedOut ? BoxFit.contain : BoxFit.cover,
          alignment: Alignment.center,
        ),
        // Lens Effect Overlay
        Container(
          color: tint.withOpacity(
            (tint.opacity * 0.5 + graduation * 0.2).clamp(0.0, 1.0),
          ),
          // Note: using withOpacity on a color that might be transparent or already have alpha.
          // Adjust logic as needed for "Graduation" visualization (maybe blur?).
        ),
        // Graduation Blur effect (using BackdropFilter if heavy?)
        // For now, just a placeholder text or subtle effect.
        if (graduation > 0)
          Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
                shape: BoxShape.circle,
              ),
              width: 50 + (graduation * 50),
              height: 50 + (graduation * 50),
            ),
          ),

        // Frame Overlay
        if (selectedFrame != null)
          Center(
            child: IgnorePointer(
              child: Container(
                width: isZoomedOut ? 200 : 300,
                height: isZoomedOut ? 80 : 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber, width: 3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    selectedFrame!,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Label
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            color: Colors.black54,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
