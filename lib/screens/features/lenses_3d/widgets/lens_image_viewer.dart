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
  double _virtualAngle = 15.0;
  bool _showGestureHint = true;

  @override
  void initState() {
    super.initState();
    _virtualAngle = widget.state.orientation.angle.toDouble();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showGestureHint = false);
      }
    });
  }

  @override
  void didUpdateWidget(LensImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.orientation.angle != widget.state.orientation.angle) {
      _virtualAngle = widget.state.orientation.angle.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<Lenses3DCubit>();

    return GestureDetector(
      onPanStart: (details) {
        _virtualAngle = widget.state.orientation.angle.toDouble();
        setState(() => _showGestureHint = true);
      },
      onPanUpdate: (details) {
        final dx = details.delta.dx;
        final dy = details.delta.dy;
        double newAngle = _virtualAngle;

        const double hSensitivity = 0.05;
        const double vSensitivity = 0.05;

        if (_virtualAngle < 14.5) {
          newAngle += dx * hSensitivity;
          if (newAngle > 15.0) newAngle = 15.0;
        } else if (_virtualAngle > 15.5) {
          newAngle -= dy * vSensitivity;
          if (newAngle < 15.0) newAngle = 15.0;
        } else {
          if (dx.abs() > dy.abs()) {
            if (dx < 0) newAngle += dx * hSensitivity;
          } else {
            if (dy < 0) newAngle -= dy * vSensitivity;
          }
        }

        newAngle = newAngle.clamp(1.0, 20.0);
        _virtualAngle = newAngle;

        final int targetAngle = _virtualAngle.round();
        if (targetAngle != widget.state.orientation.angle) {
          cubit.updateOrientationByAngle(targetAngle);
        }
      },
      onPanEnd: (details) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showGestureHint = false);
        });
      },
      child: Container(
        color: Colors.white, // FIX: Background color avoids Green scaffold gaps
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Lens Image
            ClipRect(
              child: Transform.scale(
                // 1. REDUCED SCALE: Since BoxFit.cover already zooms to fill the width,
                // we only need about 1.8x to get a tight crop on the eyes.
                scale: widget.isZoomedOut ? 1.8 : 3,
                // Important: Keep the transform centered to avoid compounding shifts
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: widget.isZoomedOut
                      ? const Offset(0, 0)
                      : const Offset(40, 0),
                  child: Image.asset(
                    widget.state.currentImagePath,
                    fit: widget.isZoomedOut ? BoxFit.contain : BoxFit.cover,
                    // 2. PERFECT FOCUS: -0.35 targets the exact upper-middle section
                    // of the portrait where the eyes and glasses are located.
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 32,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Info overlay - top left
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.state.materialIndex.displayName} • ${widget.state.prescription}D • ${widget.state.frameType.displayName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Zoom indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isZoomedOut ? Icons.zoom_out : Icons.zoom_in,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.isZoomedOut
                          ? context.l10n.fullView
                          : context.l10n.detailView,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Orientation badge
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _getOrientationIcon(),
                    const SizedBox(width: 4),
                    Text(
                      widget.state.orientation.shortName,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getOrientationIcon() {
    final angle = widget.state.orientation.angle;
    if (angle < 15) {
      return const Icon(
        Icons.compare_arrows,
        color: Colors.greenAccent,
        size: 14,
      );
    } else if (angle > 15) {
      return const Icon(Icons.expand_less, color: Colors.greenAccent, size: 14);
    } else {
      return const Icon(Icons.face, color: Colors.greenAccent, size: 14);
    }
  }
}
