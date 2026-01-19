import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/simulations_cubit.dart';
import '../../cubit/simulations_state.dart';
import '../../models/simulation_scenario.dart';
import '../../widgets/simulation_painter.dart';

class SimulationCanvas extends StatefulWidget {
  final SimulationsState state;
  final SimulationCategory category;
  final ui.Image problemImage;
  final ui.Image? correctedImage;
  final CorrectionLens? currentLens;
  final Function(Offset)? onLensDragStart;
  final Function(Offset)? onLensDragUpdate;
  final Function()? onLensDragEnd;

  const SimulationCanvas({
    super.key,
    required this.state,
    required this.category,
    required this.problemImage,
    this.correctedImage,
    this.currentLens,
    this.onLensDragStart,
    this.onLensDragUpdate,
    this.onLensDragEnd,
  });

  @override
  State<SimulationCanvas> createState() => _SimulationCanvasState();
}

class _SimulationCanvasState extends State<SimulationCanvas> {
  double? _draggingPosition;

  @override
  Widget build(BuildContext context) {
    final dividerPos = _draggingPosition ?? widget.state.dividerPosition;
    final isMultifocal = widget.category.id == 'multifocal';
    final isLensMode = widget.state.isLensDraggingMode;

    return GestureDetector(
      onPanStart: isMultifocal
          ? null
          : (details) {
              if (isLensMode) {
                // Lens dragging mode
                widget.onLensDragStart?.call(details.localPosition);
              } else {
                // Divider mode
                setState(() {
                  _draggingPosition = _calculateDividerPosition(
                    details.localPosition,
                  );
                });
                context.read<SimulationsCubit>().setDragging(true);
              }
            },
      onPanUpdate: isMultifocal
          ? null
          : (details) {
              if (isLensMode) {
                // Lens dragging mode
                widget.onLensDragUpdate?.call(details.localPosition);
              } else {
                // Divider mode
                setState(() {
                  _draggingPosition = _calculateDividerPosition(
                    details.localPosition,
                  );
                });
              }
            },
      onPanEnd: isMultifocal
          ? null
          : (_) {
              if (isLensMode) {
                // Lens dragging mode
                widget.onLensDragEnd?.call();
              } else {
                // Divider mode
                if (_draggingPosition != null) {
                  context.read<SimulationsCubit>().moveDivider(
                    _draggingPosition!,
                  );
                }
                context.read<SimulationsCubit>().setDragging(false);
                setState(() {
                  _draggingPosition = null;
                });
              }
            },
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: SimulationPainter(
            problemImage: widget.problemImage,
            correctedImage: widget.correctedImage,
            dividerPosition: dividerPos,
            isVerticalDivider: widget.state.isVerticalDivider,
            tintColor: widget.currentLens?.tintColor,
            lensOpacity: widget.state.lensOpacity,
            showFullCorrection: isMultifocal,
            boxFit: BoxFit.contain,
            // Lens dragging specific parameters
            isLensDraggingMode: widget.state.isLensDraggingMode,
            lensPosition: widget.state.lensPosition,
            lensRadius: widget.state.lensRadius,
          ),
        ),
      ),
    );
  }

  double _calculateDividerPosition(Offset localPosition) {
    final size = context.size;
    if (size == null) return widget.state.dividerPosition;

    if (widget.state.isVerticalDivider) {
      // Vertical divider - calculate X position
      return (localPosition.dx / size.width).clamp(0.0, 1.0);
    } else {
      // Horizontal divider - calculate Y position
      return (localPosition.dy / size.height).clamp(0.0, 1.0);
    }
  }
}
