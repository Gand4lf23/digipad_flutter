import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_state.dart';
import 'package:flutter/material.dart';
import 'package:digipad_flutter/l10n/l10n.dart';

class LensImageViewer extends StatelessWidget {
  final Lenses3DState state;
  final bool isZoomedOut;

  const LensImageViewer({
    super.key,
    required this.state,
    required this.isZoomedOut,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Lens Image
        Image.asset(
          state.currentImagePath,
          fit: isZoomedOut ? BoxFit.contain : BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade900,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.imageNotAvailable,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.tryDifferentSettings,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Info overlay - top left
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.visibility_outlined,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${state.materialIndex.displayName} • ${state.prescription}D • ${state.frameType.displayName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Zoom indicator - top right
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isZoomedOut ? Icons.zoom_out : Icons.zoom_in,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isZoomedOut ? context.l10n.fullView : context.l10n.detailView,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
