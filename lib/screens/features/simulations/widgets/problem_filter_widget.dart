import 'package:flutter/material.dart';

import 'dart:ui' as ui;

class ProblemFilterWidget extends StatelessWidget {
  final ui.Image image;
  final double blur;
  final double aberration;
  final double tintStrength;
  final Color tint;

  const ProblemFilterWidget({
    super.key,
    required this.image,
    this.blur = 0,
    this.aberration = 0,
    this.tintStrength = 0,
    this.tint = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return ui.Gradient.linear(
          Offset(0, 0),
          Offset(rect.width, rect.height),
          [tint.withOpacity(tintStrength), tint.withOpacity(tintStrength)],
        );
      },
      blendMode: BlendMode.modulate,
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: CustomPaint(
          painter: _AberrationPainter(image, aberration),
          size: Size(image.width.toDouble(), image.height.toDouble()),
        ),
      ),
    );
  }
}

/// Chromatic aberration painter
class _AberrationPainter extends CustomPainter {
  final ui.Image image;
  final double aberration;

  _AberrationPainter(this.image, this.aberration);

  @override
  void paint(Canvas canvas, Size size) {
    final paintR = Paint()
      ..colorFilter = const ColorFilter.matrix([
        1, 0, 0, 0, 0, //
        0, 0, 0, 0, 0, //
        0, 0, 0, 0, 0, //
        0, 0, 0, 1, 0,
      ]);

    final paintG = Paint()
      ..colorFilter = const ColorFilter.matrix([
        0,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]);

    final paintB = Paint()
      ..colorFilter = const ColorFilter.matrix([
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]);

    canvas.drawImage(image, Offset.zero, paintR);
    canvas.drawImage(image, Offset(aberration, 0), paintG);
    canvas.drawImage(image, Offset(-aberration, 0), paintB);
  }

  @override
  bool shouldRepaint(covariant _AberrationPainter oldDelegate) {
    return oldDelegate.aberration != aberration || oldDelegate.image != image;
  }
}
