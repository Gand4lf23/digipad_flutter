import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Custom painter that draws the problem image as background
/// and overlays the corrected image within the lens area.
class SimulationPainter extends CustomPainter {
  final ui.Image problemImage;
  final ui.Image? correctedImage;
  final Offset lensCenter;
  final double lensSize;
  final double lensOpacity;
  final double lensCornerRadius;
  final Color? tintColor;
  final bool showFullCorrection;
  final BoxFit boxFit;

  SimulationPainter({
    required this.problemImage,
    this.correctedImage,
    required this.lensCenter,
    required this.lensSize,
    this.lensCornerRadius = 20.0,
    this.tintColor,
    this.lensOpacity = 0.5,
    this.showFullCorrection = false,
    this.boxFit = BoxFit.contain, // Default to contain (less zoomed in)
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate image positioning to cover the canvas
    // Using fittedSizes.source ensures we respect the aspect ratio
    // even if BoxFit.cover calculates a crop.
    final problemSrcSize = Size(
      problemImage.width.toDouble(),
      problemImage.height.toDouble(),
    );
    final fittedSizes = applyBoxFit(boxFit, problemSrcSize, size);

    final problemSrcRect = Alignment.center.inscribe(
      fittedSizes.source,
      Offset.zero & problemSrcSize,
    );
    final problemDstRect = Alignment.center.inscribe(
      fittedSizes.destination,
      Offset.zero & size,
    );

    // Draw problem image as background
    canvas.drawImageRect(problemImage, problemSrcRect, problemDstRect, Paint());

    final bool hasCorrection = correctedImage != null || tintColor != null;

    if (showFullCorrection && hasCorrection) {
      // Draw full screen correction
      if (correctedImage != null) {
        final correctedSrcSize = Size(
          correctedImage!.width.toDouble(),
          correctedImage!.height.toDouble(),
        );
        final correctedFittedSizes = applyBoxFit(
          boxFit,
          correctedSrcSize,
          size,
        );
        final correctedSrcRect = Alignment.center.inscribe(
          correctedFittedSizes.source,
          Offset.zero & correctedSrcSize,
        );
        final correctedDstRect = Alignment.center.inscribe(
          correctedFittedSizes.destination,
          Offset.zero & size,
        );

        canvas.drawImageRect(
          correctedImage!,
          correctedSrcRect,
          correctedDstRect,
          Paint(),
        );
      }
      return;
    }

    // Calculate lens RRect (Rectangular shape like glasses frame)
    // lensSize controls width, height is 70% of width
    final lensWidth = lensSize;
    final lensHeight = lensSize * 0.65;

    final lensRect = Rect.fromCenter(
      center: lensCenter,
      width: lensWidth,
      height: lensHeight,
    );
    final rrect = RRect.fromRectAndRadius(
      lensRect,
      Radius.circular(lensCornerRadius),
    );

    if (hasCorrection) {
      if (correctedImage != null) {
        final correctedSrcSize = Size(
          correctedImage!.width.toDouble(),
          correctedImage!.height.toDouble(),
        );
        final correctedFittedSizes = applyBoxFit(
          boxFit,
          correctedSrcSize,
          size,
        );

        final correctedSrcRect = Alignment.center.inscribe(
          correctedFittedSizes.source,
          Offset.zero & correctedSrcSize,
        );
        final correctedDstRect = Alignment.center.inscribe(
          correctedFittedSizes.destination,
          Offset.zero & size,
        );

        final lensPath = Path()..addRRect(rrect);

        // Clip to lens area and draw corrected image
        canvas.save();
        canvas.clipPath(lensPath);
        canvas.drawImageRect(
          correctedImage!,
          correctedSrcRect,
          correctedDstRect,
          Paint(),
        );
        canvas.restore();
      }

      // Draw tint if available
      if (tintColor != null) {
        final tintPaint = Paint()
          ..color = tintColor!.withOpacity(lensOpacity)
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.srcOver; // Simple blending for tint

        canvas.save();
        canvas.clipRRect(rrect);
        canvas.drawPaint(tintPaint);
        canvas.restore();
      }

      // Draw lens border with glass effect
      _drawLensBorder(canvas, rrect);
    } else {
      // No corrected image - just show a placeholder lens
      _drawPlaceholderLens(canvas, rrect, lensCenter);
    }
  }

  void _drawLensBorder(Canvas canvas, RRect rrect) {
    // Outer border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.white.withOpacity(0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    canvas.drawRRect(rrect, borderPaint);

    // Inner subtle border
    final innerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.4);

    // Slightly smaller rrect for inner border
    final innerRRect = rrect.deflate(3);
    canvas.drawRRect(innerRRect, innerBorderPaint);

    // Subtle green tint on lens edge to indicate "corrected"
    final correctionIndicatorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.green.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawRRect(rrect.inflate(2), correctionIndicatorPaint);
  }

  void _drawPlaceholderLens(Canvas canvas, RRect rrect, Offset center) {
    // Draw a semi-transparent shape to show where the lens is
    final placeholderPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, placeholderPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.3);

    canvas.drawRRect(rrect, borderPaint);

    // Draw "No lens selected" text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Select\nLens',
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: rrect.width * 0.8);
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant SimulationPainter oldDelegate) {
    return oldDelegate.lensCenter != lensCenter ||
        oldDelegate.lensSize != lensSize ||
        oldDelegate.lensOpacity != lensOpacity ||
        oldDelegate.lensCornerRadius != lensCornerRadius ||
        oldDelegate.problemImage != problemImage ||
        oldDelegate.correctedImage != correctedImage;
  }
}
