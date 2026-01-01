import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_cubit.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DraggableIrisWidget extends StatefulWidget {
  final bool isLeftEye;
  final double canvasWidth;
  final double canvasHeight;

  const DraggableIrisWidget({
    super.key,
    required this.isLeftEye,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  @override
  State<DraggableIrisWidget> createState() => _DraggableIrisWidgetState();
}

class _DraggableIrisWidgetState extends State<DraggableIrisWidget> {
  // We need to store the scale value at the moment the pinch starts
  double _baseScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CosmeticLensesCubit, CosmeticLensesState>(
      builder: (context, state) {
        final irisConfig = widget.isLeftEye ? state.leftIris : state.rightIris;

        // check if this eye is currently editable
        final isActive =
            state.activeEye == EyeSelection.both ||
            (widget.isLeftEye && state.activeEye == EyeSelection.left) ||
            (!widget.isLeftEye && state.activeEye == EyeSelection.right);

        if (irisConfig.imagePath == null) {
          return const SizedBox.shrink();
        }

        final irisSize = 100.0 * irisConfig.scale;

        // Convert normalized position (0-1) to actual pixels
        final left =
            (irisConfig.position.dx * widget.canvasWidth) - (irisSize / 2);
        final top =
            (irisConfig.position.dy * widget.canvasHeight) - (irisSize / 2);

        return Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            // 1. Capture the current scale when the user puts fingers down
            onScaleStart: (details) {
              if (!isActive) return;
              _baseScale = irisConfig.scale;
            },
            // 2. Handle both Dragging (Pan) and Scaling (Pinch) here
            onScaleUpdate: (details) {
              if (!isActive) return;

              final cubit = context.read<CosmeticLensesCubit>();

              // --- HANDLE PANNING (DRAGGING) ---
              // focalPointDelta gives the movement in pixels since the last frame
              if (details.focalPointDelta.dx != 0 ||
                  details.focalPointDelta.dy != 0) {
                // Calculate current center based on the state
                final currentCenterX =
                    (irisConfig.position.dx * widget.canvasWidth);
                final currentCenterY =
                    (irisConfig.position.dy * widget.canvasHeight);

                // Add the movement delta
                final newCenterX = currentCenterX + details.focalPointDelta.dx;
                final newCenterY = currentCenterY + details.focalPointDelta.dy;

                // Normalize back to 0-1
                final normalizedX = (newCenterX / widget.canvasWidth).clamp(
                  0.0,
                  1.0,
                );
                final normalizedY = (newCenterY / widget.canvasHeight).clamp(
                  0.0,
                  1.0,
                );

                final newPosition = Offset(normalizedX, normalizedY);

                if (widget.isLeftEye) {
                  cubit.updateLeftIrisPosition(newPosition);
                } else {
                  cubit.updateRightIrisPosition(newPosition);
                }
              }

              // --- HANDLE SCALING (PINCHING) ---
              // details.scale starts at 1.0 when gesture begins.
              // Multiply base scale by the gesture scale.
              if (details.scale != 1.0) {
                final newScale = (_baseScale * details.scale).clamp(0.2, 3.0);

                if (widget.isLeftEye) {
                  cubit.updateLeftIrisScale(newScale);
                } else {
                  cubit.updateRightIrisScale(newScale);
                }
              }
            },
            child: Container(
              width: irisSize,
              height: irisSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(
                        color: widget.isLeftEye
                            ? Colors.blue.withOpacity(0.3)
                            : Colors.green.withOpacity(0.3),
                        width: 2,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  // Iris image
                  Opacity(
                    opacity: irisConfig.opacity,
                    child: ClipOval(
                      child: Image.asset(
                        irisConfig.imagePath!,
                        fit: BoxFit.cover,
                        height: irisSize,
                        width: irisSize, // Added width to ensure circle
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.red.withOpacity(0.3),
                          child: const Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  // Eyelid overlay
                  if (irisConfig.showEyelid)
                    ClipOval(
                      child: CustomPaint(
                        size: Size(irisSize, irisSize),
                        painter: _EyelidPainter(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom painter remains the same...
class _EyelidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final topGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.center,
      colors: [
        Colors.black.withOpacity(0.6),
        Colors.black.withOpacity(0.3),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.5],
    );

    final topPaint = Paint()..shader = topGradient.createShader(rect);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.5),
      topPaint,
    );

    final bottomGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.center,
      colors: [
        Colors.black.withOpacity(0.4),
        Colors.black.withOpacity(0.2),
        Colors.transparent,
      ],
      stops: const [0.0, 0.2, 0.4],
    );

    final bottomPaint = Paint()..shader = bottomGradient.createShader(rect);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
      bottomPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
