import 'dart:io';

import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_cubit.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_state.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/widgets/draggable_iris_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digipad_flutter/l10n/l10n.dart';

// Global key for canvas capture
final GlobalKey canvasKey = GlobalKey();

class PhotoCanvasWidget extends StatelessWidget {
  const PhotoCanvasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CosmeticLensesCubit, CosmeticLensesState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey.shade600, width: 2),
          ),
          child: state.cameraPhoto == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt,
                        size: 80,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.l10n.takeOrSelectStart,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                )
              : InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: RepaintBoundary(
                    key: canvasKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background photo
                            Image.file(
                              File(state.cameraPhoto!),
                              fit: BoxFit.contain,
                            ),
                            // Left iris overlay
                            DraggableIrisWidget(
                              isLeftEye: true,
                              canvasWidth: constraints.maxWidth,
                              canvasHeight: constraints.maxHeight,
                            ),
                            // Right iris overlay
                            DraggableIrisWidget(
                              isLeftEye: false,
                              canvasWidth: constraints.maxWidth,
                              canvasHeight: constraints.maxHeight,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
        );
      },
    );
  }
}
