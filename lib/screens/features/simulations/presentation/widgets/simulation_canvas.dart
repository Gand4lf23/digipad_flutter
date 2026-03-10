import 'dart:ui' as ui;
import 'package:digipad_flutter/common/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/simulations_cubit.dart';
import '../../cubit/simulations_state.dart';
import '../../models/simulation_scenario.dart';
import '../../widgets/simulation_painter.dart';

class SimulationCanvas extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isMultifocal = category.id == 'multifocal';
    final isLensMode = state.isLensDraggingMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final responsive = context.responsive(constraints, orientation);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: isMultifocal
                  ? null
                  : (details) {
                      if (isLensMode) {
                        onLensDragStart?.call(details.localPosition);
                      } else {
                        context.read<SimulationsCubit>().setDragging(true);
                      }
                    },
              onPanUpdate: isMultifocal
                  ? null
                  : (details) {
                      if (isLensMode) {
                        onLensDragUpdate?.call(details.localPosition);
                      } else {
                        final newPosition = _calculateDividerPosition(
                          details.localPosition,
                          constraints.biggest,
                          state.isVerticalDivider,
                        );
                        context.read<SimulationsCubit>().moveDivider(
                          newPosition,
                        );
                      }
                    },
              onPanEnd: isMultifocal
                  ? null
                  : (_) {
                      if (isLensMode) {
                        onLensDragEnd?.call();
                      } else {
                        context.read<SimulationsCubit>().setDragging(false);
                      }
                    },
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: SimulationPainter(
                    problemImage: problemImage,
                    correctedImage: correctedImage,
                    dividerPosition: state.dividerPosition,
                    isVerticalDivider: state.isVerticalDivider,
                    tintColor: currentLens?.tintColor,
                    lensOpacity: state.lensOpacity,
                    showFullCorrection: isMultifocal,
                    boxFit: BoxFit.contain,
                    // Lens dragging specific parameters
                    isLensDraggingMode: isLensMode,
                    lensPosition: state.lensPosition,
                    lensRadius: state.lensRadius,
                    // Responsive text size
                    fontSize: responsive.fontSize(18),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _calculateDividerPosition(
    Offset localPosition,
    Size canvasSize,
    bool isVertical,
  ) {
    if (isVertical) {
      // Vertical divider - calculate X position (0.0 to 1.0)
      return (localPosition.dx / canvasSize.width).clamp(0.0, 1.0);
    } else {
      // Horizontal divider - calculate Y position (0.0 to 1.0)
      return (localPosition.dy / canvasSize.height).clamp(0.0, 1.0);
    }
  }
}
