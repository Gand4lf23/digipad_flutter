import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_cubit.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DraggableIrisWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocBuilder<CosmeticLensesCubit, CosmeticLensesState>(
      builder: (context, state) {
        final irisConfig = isLeftEye ? state.leftIris : state.rightIris;
        final isActive =
            state.activeEye == EyeSelection.both ||
            (isLeftEye && state.activeEye == EyeSelection.left) ||
            (!isLeftEye && state.activeEye == EyeSelection.right);

        if (irisConfig.imagePath == null) {
          return const SizedBox.shrink();
        }

        final irisSize = 100.0 * irisConfig.scale;

        // Convert normalized position (0-1) to actual pixels
        // Position represents the CENTER of the iris
        final left = (irisConfig.position.dx * canvasWidth) - (irisSize / 2);
        final top = (irisConfig.position.dy * canvasHeight) - (irisSize / 2);

        return Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onPanUpdate: (details) {
              if (!isActive) return;

              // Calculate new center position
              final currentCenterX = left + (irisSize / 2);
              final currentCenterY = top + (irisSize / 2);

              final newCenterX = currentCenterX + details.delta.dx;
              final newCenterY = currentCenterY + details.delta.dy;

              // Convert to normalized coordinates (0-1)
              final normalizedX = (newCenterX / canvasWidth).clamp(0.0, 1.0);
              final normalizedY = (newCenterY / canvasHeight).clamp(0.0, 1.0);

              final newPosition = Offset(normalizedX, normalizedY);

              if (isLeftEye) {
                context.read<CosmeticLensesCubit>().updateLeftIrisPosition(
                  newPosition,
                );
              } else {
                context.read<CosmeticLensesCubit>().updateRightIrisPosition(
                  newPosition,
                );
              }
            },
            child: Container(
              width: irisSize,
              height: irisSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Only show border when active for positioning feedback
                border: isActive
                    ? Border.all(
                        color: isLeftEye
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

// Custom painter for eyelid simulation
class _EyelidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Top eyelid shadow (gradient from top)
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

    // Bottom eyelid shadow (gradient from bottom)
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
