import 'package:digipad_flutter/screens/features/simulations/cubit/simulations_state.dart';
import 'package:digipad_flutter/screens/features/simulations/widgets/lens_widget.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;

class ProblemFilterWidget extends StatelessWidget {
  final ui.Image image;
  final VisionProblem problem;
  final double blur;
  final double aberration;
  final Color tint;
  final double tintStrength;
  final Offset lensCenter;
  final double lensRadius;

  const ProblemFilterWidget({
    super.key,
    required this.image,
    required this.problem,
    this.blur = 0,
    this.aberration = 0,
    this.tint = Colors.transparent,
    this.tintStrength = 0,
    required this.lensCenter,
    required this.lensRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: ScenePainter(
        image: image,
        problem: problem,
        blur: blur,
        aberration: aberration,
        tint: tint,
        tintStrength: tintStrength,
        lensCenter: lensCenter,
        lensRadius: lensRadius,
      ),
    );
  }
}

class ScenePainter extends CustomPainter {
  final ui.Image image;
  final VisionProblem problem;
  final double blur;
  final double aberration;
  final Color tint;
  final double tintStrength;
  final Offset lensCenter;
  final double lensRadius;

  ScenePainter({
    required this.image,
    required this.problem,
    required this.blur,
    required this.aberration,
    required this.tint,
    required this.tintStrength,
    required this.lensCenter,
    required this.lensRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final srcSize = Size(image.width.toDouble(), image.height.toDouble());
    final fittedSizes = applyBoxFit(BoxFit.cover, srcSize, size);
    final dst = Alignment.center.inscribe(
      fittedSizes.destination,
      Offset.zero & size,
    );

    // Determine blur amount based on vision problem
    double effectiveBlur = 0.0;
    Color effectiveTint = Colors.transparent;
    double effectiveTintStrength = 0.0;

    switch (problem) {
      case VisionProblem.myopia:
        effectiveBlur = blur;
        break;
      case VisionProblem.presbyopia:
        effectiveBlur = blur * 1.2;
        break;
      case VisionProblem.astigmatism:
        effectiveBlur = blur * 0.8;
        break;
      case VisionProblem.glare:
        effectiveTint = tint;
        effectiveTintStrength = tintStrength;
        break;
      case VisionProblem.none:
        break;
    }

    // Use saveLayer for better performance with blur
    if (effectiveBlur > 0) {
      // Draw blurred background using saveLayer for performance
      final blurPaint = Paint()
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: effectiveBlur,
          sigmaY: effectiveBlur,
          tileMode: TileMode.clamp,
        );

      canvas.saveLayer(Offset.zero & size, blurPaint);
      canvas.drawImageRect(image, Offset.zero & srcSize, dst, Paint());
      canvas.restore();
    } else if (effectiveTintStrength > 0) {
      // Draw tinted background
      final tintPaint = Paint()
        ..colorFilter = ColorFilter.mode(
          Color.lerp(Colors.white, effectiveTint, effectiveTintStrength) ??
              Colors.white,
          BlendMode.modulate,
        );
      canvas.drawImageRect(image, Offset.zero & srcSize, dst, tintPaint);
    } else {
      // No effect
      canvas.drawImageRect(image, Offset.zero & srcSize, dst, Paint());
    }

    // Draw lens: corrected area (sharp, no blur)
    final lensRect = Rect.fromCircle(center: lensCenter, radius: lensRadius);
    canvas.save();
    canvas.clipPath(Path()..addOval(lensRect));

    // Inside lens: show corrected (sharp) scene
    canvas.drawImageRect(image, Offset.zero & srcSize, dst, Paint());

    canvas.restore();

    // Draw lens border
    canvas.save();
    canvas.translate(lensCenter.dx - lensRadius, lensCenter.dy - lensRadius);
    final borderPainter = LensBorderPainter();
    borderPainter.paint(canvas, Size(lensRadius * 2, lensRadius * 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ScenePainter oldDelegate) {
    // Only repaint if something actually changed
    return oldDelegate.lensCenter != lensCenter ||
        oldDelegate.lensRadius != lensRadius ||
        oldDelegate.blur != blur ||
        oldDelegate.aberration != aberration ||
        oldDelegate.tint != tint ||
        oldDelegate.tintStrength != tintStrength ||
        oldDelegate.problem != problem;
  }
}
