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

  const SimulationCanvas({
    super.key,
    required this.state,
    required this.category,
    required this.problemImage,
    this.correctedImage,
    this.currentLens,
  });

  @override
  State<SimulationCanvas> createState() => _SimulationCanvasState();
}

class _SimulationCanvasState extends State<SimulationCanvas> {
  Offset? _draggingPosition;

  @override
  Widget build(BuildContext context) {
    final lensPos = _draggingPosition ?? widget.state.lensPosition;
    final lensSize = widget.state.lensSize;
    final isMultifocal = widget.category.id == 'multifocal';

    return GestureDetector(
      onPanStart: isMultifocal
          ? null
          : (details) {
              setState(() {
                _draggingPosition = lensPos;
              });
              context.read<SimulationsCubit>().setDragging(true);
            },
      onPanUpdate: isMultifocal
          ? null
          : (details) {
              final size = MediaQuery.of(context).size;
              final currentPos = _draggingPosition ?? lensPos;
              final halfSize = lensSize / 2;
              final dx = (currentPos.dx + details.delta.dx).clamp(
                halfSize,
                size.width - halfSize,
              );
              final dy = (currentPos.dy + details.delta.dy).clamp(
                halfSize,
                size.height - halfSize - 180,
              );
              setState(() {
                _draggingPosition = Offset(dx, dy);
              });
            },
      onPanEnd: isMultifocal
          ? null
          : (_) {
              context.read<SimulationsCubit>().moveLens(_draggingPosition!);
              context.read<SimulationsCubit>().setDragging(false);
              setState(() {
                _draggingPosition = null;
              });
            },
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: SimulationPainter(
            problemImage: widget.problemImage,
            correctedImage: widget.correctedImage,
            lensCenter: lensPos,
            lensSize: lensSize,
            tintColor: widget.currentLens?.tintColor,
            lensOpacity: widget.state.lensOpacity,
            showFullCorrection: isMultifocal,
            boxFit: BoxFit.contain, // Ensuring less zoomed-in
          ),
        ),
      ),
    );
  }
}
