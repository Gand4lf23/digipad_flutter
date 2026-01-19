import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Custom painter that draws a split-screen comparison view
/// with a draggable divider line separating the problem and corrected images.
class SimulationPainter extends CustomPainter {
  final ui.Image problemImage;
  final ui.Image? correctedImage;
  final double dividerPosition; // 0.0 to 1.0
  final bool isVerticalDivider;
  final double lensOpacity;
  final Color? tintColor;
  final bool showFullCorrection;
  final BoxFit boxFit;
  
  // Lens dragging mode parameters
  final bool isLensDraggingMode;
  final Offset lensPosition;
  final double lensRadius;

  SimulationPainter({
    required this.problemImage,
    this.correctedImage,
    required this.dividerPosition,
    required this.isVerticalDivider,
    this.tintColor,
    this.lensOpacity = 0.5,
    this.showFullCorrection = false,
    this.boxFit = BoxFit.contain,
    this.isLensDraggingMode = false,
    this.lensPosition = const Offset(200, 200),
    this.lensRadius = 100,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate image positioning
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

    final bool hasCorrection = correctedImage != null || tintColor != null;

    if (showFullCorrection && hasCorrection) {
      // Draw full screen correction (for multifocal category)
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

    if (!hasCorrection) {
      // No correction available - just show problem image
      canvas.drawImageRect(
        problemImage,
        problemSrcRect,
        problemDstRect,
        Paint(),
      );
      _drawNoLensMessage(canvas, size);
      return;
    }

    // Check if we're in lens dragging mode
    if (isLensDraggingMode && correctedImage != null) {
      // Draw lens dragging mode
      _drawLensDraggingMode(canvas, size, problemSrcRect, problemDstRect);
    } else {
      // Draw split-screen comparison (existing behavior)
      if (isVerticalDivider) {
        _drawVerticalSplit(canvas, size, problemSrcRect, problemDstRect);
      } else {
        _drawHorizontalSplit(canvas, size, problemSrcRect, problemDstRect);
      }

      // Draw the divider line
      _drawDividerLine(canvas, size);
    }
  }

  void _drawVerticalSplit(
    Canvas canvas,
    Size size,
    Rect problemSrcRect,
    Rect problemDstRect,
  ) {
    final dividerX = size.width * dividerPosition;

    // Draw problem image on the left side
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, dividerX, size.height));
    canvas.drawImageRect(problemImage, problemSrcRect, problemDstRect, Paint());
    canvas.restore();

    // Draw corrected image on the right side
    if (correctedImage != null) {
      final correctedSrcSize = Size(
        correctedImage!.width.toDouble(),
        correctedImage!.height.toDouble(),
      );
      final correctedFittedSizes = applyBoxFit(boxFit, correctedSrcSize, size);
      final correctedSrcRect = Alignment.center.inscribe(
        correctedFittedSizes.source,
        Offset.zero & correctedSrcSize,
      );
      final correctedDstRect = Alignment.center.inscribe(
        correctedFittedSizes.destination,
        Offset.zero & size,
      );

      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(dividerX, 0, size.width - dividerX, size.height),
      );
      canvas.drawImageRect(
        correctedImage!,
        correctedSrcRect,
        correctedDstRect,
        Paint(),
      );

      // Apply tint overlay if available
      if (tintColor != null) {
        final tintPaint = Paint()
          ..color = tintColor!.withValues(alpha: lensOpacity)
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.srcOver;
        canvas.drawRect(
          Rect.fromLTWH(dividerX, 0, size.width - dividerX, size.height),
          tintPaint,
        );
      }

      canvas.restore();
    }

    // Draw labels
    _drawLabel(canvas, 'Without Lens', Offset(dividerX / 2, 40), size);
    _drawLabel(
      canvas,
      'With Lens',
      Offset(dividerX + (size.width - dividerX) / 2, 40),
      size,
    );
  }

  void _drawHorizontalSplit(
    Canvas canvas,
    Size size,
    Rect problemSrcRect,
    Rect problemDstRect,
  ) {
    final dividerY = size.height * dividerPosition;

    // Draw problem image on the top
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, dividerY));
    canvas.drawImageRect(problemImage, problemSrcRect, problemDstRect, Paint());
    canvas.restore();

    // Draw corrected image on the bottom
    if (correctedImage != null) {
      final correctedSrcSize = Size(
        correctedImage!.width.toDouble(),
        correctedImage!.height.toDouble(),
      );
      final correctedFittedSizes = applyBoxFit(boxFit, correctedSrcSize, size);
      final correctedSrcRect = Alignment.center.inscribe(
        correctedFittedSizes.source,
        Offset.zero & correctedSrcSize,
      );
      final correctedDstRect = Alignment.center.inscribe(
        correctedFittedSizes.destination,
        Offset.zero & size,
      );

      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(0, dividerY, size.width, size.height - dividerY),
      );
      canvas.drawImageRect(
        correctedImage!,
        correctedSrcRect,
        correctedDstRect,
        Paint(),
      );

      // Apply tint overlay if available
      if (tintColor != null) {
        final tintPaint = Paint()
          ..color = tintColor!.withValues(alpha: lensOpacity)
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.srcOver;
        canvas.drawRect(
          Rect.fromLTWH(0, dividerY, size.width, size.height - dividerY),
          tintPaint,
        );
      }

      canvas.restore();
    }

    // Draw labels
    _drawLabel(
      canvas,
      'Without Lens',
      Offset(size.width / 2, dividerY / 2),
      size,
    );
    _drawLabel(
      canvas,
      'With Lens',
      Offset(size.width / 2, dividerY + (size.height - dividerY) / 2),
      size,
    );
  }

  void _drawDividerLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    if (isVerticalDivider) {
      final x = size.width * dividerPosition;
      // Draw shadow
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), shadowPaint);
      // Draw line
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);

      // Draw draggable handle
      _drawHandle(canvas, Offset(x, size.height / 2), true);
    } else {
      final y = size.height * dividerPosition;
      // Draw shadow
      canvas.drawLine(Offset(0, y), Offset(size.width, y), shadowPaint);
      // Draw line
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

      // Draw draggable handle
      _drawHandle(canvas, Offset(size.width / 2, y), false);
    }
  }

  void _drawHandle(Canvas canvas, Offset center, bool isVertical) {
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final handleShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final handleSize = isVertical ? Size(16, 60) : Size(60, 16);
    final handleRect = Rect.fromCenter(
      center: center,
      width: handleSize.width,
      height: handleSize.height,
    );
    final handleRRect = RRect.fromRectAndRadius(
      handleRect,
      const Radius.circular(8),
    );

    // Draw shadow
    canvas.drawRRect(handleRRect.shift(const Offset(0, 2)), handleShadowPaint);
    // Draw handle
    canvas.drawRRect(handleRRect, handlePaint);

    // Draw grip lines
    final gripPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (isVertical) {
      for (int i = -1; i <= 1; i++) {
        final offset = i * 8.0;
        canvas.drawLine(
          Offset(center.dx, center.dy + offset - 12),
          Offset(center.dx, center.dy + offset + 12),
          gripPaint,
        );
      }
    } else {
      for (int i = -1; i <= 1; i++) {
        final offset = i * 8.0;
        canvas.drawLine(
          Offset(center.dx + offset - 12, center.dy),
          Offset(center.dx + offset + 12, center.dy),
          gripPaint,
        );
      }
    }
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset position,
    Size canvasSize,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(blurRadius: 8, color: Colors.black, offset: Offset(0, 2)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawNoLensMessage(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Select a lens to compare',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height / 2 - textPainter.height / 2,
      ),
    );
  }

  void _drawLensDraggingMode(
    Canvas canvas,
    Size size,
    Rect problemSrcRect,
    Rect problemDstRect,
  ) {
    // Draw the full problem image first
    canvas.drawImageRect(problemImage, problemSrcRect, problemDstRect, Paint());

    // Calculate corrected image positioning
    final correctedSrcSize = Size(
      correctedImage!.width.toDouble(),
      correctedImage!.height.toDouble(),
    );
    final correctedFittedSizes = applyBoxFit(boxFit, correctedSrcSize, size);
    final correctedSrcRect = Alignment.center.inscribe(
      correctedFittedSizes.source,
      Offset.zero & correctedSrcSize,
    );
    final correctedDstRect = Alignment.center.inscribe(
      correctedFittedSizes.destination,
      Offset.zero & size,
    );

    // Create circular clip for lens
    final lensPath = Path()
      ..addOval(Rect.fromCircle(
        center: lensPosition,
        radius: lensRadius,
      ));

    // Draw corrected image within the lens circle
    canvas.save();
    canvas.clipPath(lensPath);
    canvas.drawImageRect(
      correctedImage!,
      correctedSrcRect,
      correctedDstRect,
      Paint(),
    );

    // Apply tint overlay if available
    if (tintColor != null) {
      final tintPaint = Paint()
        ..color = tintColor!.withValues(alpha: lensOpacity)
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.srcOver;
      canvas.drawPath(lensPath, tintPaint);
    }

    canvas.restore();

    // Draw lens border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(lensPath, shadowPaint);
    canvas.drawPath(lensPath, borderPaint);

    // Draw lens handle
    _drawLensHandle(canvas);
  }

  void _drawLensHandle(Canvas canvas) {
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final handleShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final handleRect = Rect.fromCircle(
      center: lensPosition,
      radius: 20,
    );
    final handleRRect = RRect.fromRectAndRadius(
      handleRect,
      const Radius.circular(10),
    );

    // Draw shadow
    canvas.drawRRect(handleRRect.shift(const Offset(0, 2)), handleShadowPaint);
    // Draw handle
    canvas.drawRRect(handleRRect, handlePaint);

    // Draw grip icon
    final gripPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw drag icon (four dots)
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        final offset = Offset(i * 4.0, j * 4.0);
        canvas.drawCircle(lensPosition + offset, 1, gripPaint..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SimulationPainter oldDelegate) {
    return oldDelegate.dividerPosition != dividerPosition ||
        oldDelegate.isVerticalDivider != isVerticalDivider ||
        oldDelegate.lensOpacity != lensOpacity ||
        oldDelegate.problemImage != problemImage ||
        oldDelegate.correctedImage != correctedImage ||
        oldDelegate.isLensDraggingMode != isLensDraggingMode ||
        oldDelegate.lensPosition != lensPosition ||
        oldDelegate.lensRadius != lensRadius;
  }
}
