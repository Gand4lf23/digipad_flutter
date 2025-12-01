import 'dart:ui';

import 'package:digipad_flutter/screens/features/simulations/cubit/simulations_state.dart';
import 'package:flutter/material.dart';

class LensWidget extends StatelessWidget {
  final double radius;
  final VisionProblem problem;
  final SimulationQuality quality;
  final String sceneAsset;

  const LensWidget({
    super.key,
    required this.radius,
    required this.problem,
    required this.quality,
    required this.sceneAsset,
  });

  // The lens 'correction' strength depends on quality
  double _correctionFactor() {
    switch (quality) {
      case SimulationQuality.standard:
        return 0.6;
      case SimulationQuality.good:
        return 0.8;
      case SimulationQuality.premium:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final corr = _correctionFactor();

    // The corrected area renders the same scene asset but with inverse effect
    Widget corrected = Image.asset(
      sceneAsset,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
    );

    switch (problem) {
      case VisionProblem.none:
        // no processing, maybe add subtle lens sheen
        return ClipOval(child: corrected);
      case VisionProblem.myopia:
        // inside lens: remove blur (draw original), optionally sharpen
        return ClipOval(child: corrected);
      case VisionProblem.astigmatism:
        // inside lens: remove directional blur
        return ClipOval(child: corrected);
      case VisionProblem.glare:
        // inside lens: reduce bloom — we approximate by overlay
        return ClipOval(
          child: Stack(
            children: [
              corrected,
              ReduceGlareOverlay(strength: corr),
            ],
          ),
        );
      case VisionProblem.presbyopia:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

class ReduceGlareOverlay extends StatelessWidget {
  final double strength;
  const ReduceGlareOverlay({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    // subtle darkening and desaturation to mimic AR coat reducing highlights
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.0),
        // Use a foreground BlendMask by stacking a ColorFiltered child if needed
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.white.withOpacity(0.0 - (0.0)),
          BlendMode.dst,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
          child: Container(),
        ),
      ),
    );
  }
}

// -------------------- Painters --------------------
class LensBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(size.width * 0.5);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.white.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    canvas.drawRRect(RRect.fromRectAndRadius(rect, r), paint);

    // small sheen ellipse
    final sheenPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [Colors.white.withOpacity(0.18), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.35, size.height * 0.25),
              radius: size.width * 0.4,
            ),
          )
      ..blendMode = BlendMode.plus;

    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.25),
      size.width * 0.3,
      sheenPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlarePainter extends CustomPainter {
  final double intensity;
  GlarePainter({this.intensity = 0.4});

  @override
  void paint(Canvas canvas, Size size) {
    // paint large, soft white spots to emulate bloom/highlights
    final center = Offset(size.width * 0.75, size.height * 0.2);
    final paint = Paint()
      ..shader =
          RadialGradient(
            colors: [Colors.white.withOpacity(intensity), Colors.transparent],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.width * 0.25),
          );

    canvas.drawCircle(center, size.width * 0.25, paint);

    // another smaller hotspot
    final center2 = Offset(size.width * 0.2, size.height * 0.6);
    final paint2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withOpacity(intensity * 0.8),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: center2, radius: size.width * 0.12),
          );

    canvas.drawCircle(center2, size.width * 0.12, paint2);
  }

  @override
  bool shouldRepaint(covariant GlarePainter oldDelegate) =>
      oldDelegate.intensity != intensity;
}
