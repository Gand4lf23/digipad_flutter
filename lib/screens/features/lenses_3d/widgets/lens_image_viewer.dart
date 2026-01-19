import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_cubit.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digipad_flutter/l10n/l10n.dart';

class LensImageViewer extends StatefulWidget {
  final Lenses3DState state;
  final bool isZoomedOut;

  const LensImageViewer({
    super.key,
    required this.state,
    required this.isZoomedOut,
  });

  @override
  State<LensImageViewer> createState() => _LensImageViewerState();
}

class _LensImageViewerState extends State<LensImageViewer> {
  double _dragStartAngle = 0;
  int _dragStartOrientation = 15;
  bool _showGestureHint = true;

  @override
  void initState() {
    super.initState();
    // Hide gesture hint after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showGestureHint = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<Lenses3DCubit>();

    return GestureDetector(
      onPanStart: (details) {
        _dragStartAngle = 0;
        _dragStartOrientation = widget.state.orientation.angle;
        // Show hint again when user starts dragging
        setState(() => _showGestureHint = true);
      },
      onPanUpdate: (details) {
        // Calculate drag distance
        // Horizontal drag: side to front (1 → 15)
        // Vertical drag (up): front to top (15 → 20)

        final dx = details.delta.dx;
        final dy = details.delta.dy;

        // Combine both gestures with different sensitivities
        final horizontalEffect = dx * 0.15; // Side ↔ Front sensitivity
        final verticalEffect =
            -dy *
            0.08; // Front ↔ Top sensitivity (negative because up is negative dy)

        _dragStartAngle += horizontalEffect + verticalEffect;

        // Get all available angles
        final angles = LensOrientation.values.map((o) => o.angle).toList()
          ..sort();

        // Calculate target angle based on drag
        double targetAngle = _dragStartOrientation + _dragStartAngle;

        // Clamp to valid range
        targetAngle = targetAngle.clamp(
          angles.first.toDouble(),
          angles.last.toDouble(),
        );

        // Find closest valid angle
        final closestAngle = angles.reduce(
          (a, b) => (a - targetAngle).abs() < (b - targetAngle).abs() ? a : b,
        );

        // Update orientation if changed
        if (closestAngle != widget.state.orientation.angle) {
          cubit.updateOrientationByAngle(closestAngle);
        }
      },
      onPanEnd: (details) {
        // Reset for next drag and hide hint after 2 seconds
        _dragStartAngle = 0;
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _showGestureHint = false);
          }
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Lens Image
          ClipRRect(
            child: Transform.scale(
              scale: widget.isZoomedOut ? 1.0 : 1.4,
              child: Image.asset(
                widget.state.currentImagePath,
                fit: widget.isZoomedOut ? BoxFit.contain : BoxFit.cover,
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
            ),
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
                    '${widget.state.materialIndex.displayName} • ${widget.state.prescription}D • ${widget.state.frameType.displayName}',
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
                    widget.isZoomedOut ? Icons.zoom_out : Icons.zoom_in,
                    color: Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.isZoomedOut
                        ? context.l10n.fullView
                        : context.l10n.detailView,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // Gesture hint overlay (only show on detail view when dragging or initially)
          if (!widget.isZoomedOut && _showGestureHint)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _showGestureHint ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swipe,
                          color: Colors.grey.shade900,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Arrastra para rotar',
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_upward,
                          color: Colors.grey.shade900,
                          size: 16,
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.grey.shade900,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Orientation badge - bottom left
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.greenAccent.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getOrientationIcon(),
                  const SizedBox(width: 6),
                  Text(
                    widget.state.orientation.shortName,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getOrientationIcon() {
    final angle = widget.state.orientation.angle;

    if (angle <= 5) {
      return const Icon(Icons.portrait, color: Colors.greenAccent, size: 16);
    } else if (angle >= 20) {
      return const Icon(
        Icons.keyboard_arrow_down,
        color: Colors.greenAccent,
        size: 16,
      );
    } else {
      return const Icon(Icons.face, color: Colors.greenAccent, size: 16);
    }
  }
}
