import 'dart:ui' as ui;

import 'package:digipad_flutter/screens/features/simulations/cubit/simulations_cubit.dart';
import 'package:digipad_flutter/screens/features/simulations/cubit/simulations_state.dart';
import 'package:digipad_flutter/screens/features/simulations/widgets/problem_filter_widget.dart';
import 'package:digipad_flutter/screens/features/simulations/widgets/simulations_control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';

class SimulationsScreen extends StatefulWidget {
  final String problemName;
  final String sceneAsset;
  const SimulationsScreen({
    super.key,
    required this.problemName,
    required this.sceneAsset,
  });

  @override
  State<SimulationsScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationsScreen> {
  ui.Image? scene;
  String? errorMessage;

  double quality = 0.5;
  double tintStrength = 0.0;
  Color tintColor = Colors.transparent;

  // Lens dragging local state for smoothness
  Offset? draggingPosition;

  @override
  void initState() {
    super.initState();
    _loadScene();
  }

  Future<void> _loadScene() async {
    try {
      final data = await rootBundle.load(widget.sceneAsset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() => scene = frame.image);
      }
    } catch (e) {
      if (mounted) setState(() => errorMessage = e.toString());
    }
  }

  Map<String, dynamic> get filterForProblem {
    switch (widget.problemName.toLowerCase()) {
      case "myopia":
        return {"blur": 4.0, "aberration": 0.5};
      case "presbyopia":
        return {"blur": 6.0, "aberration": 0.2};
      case "anti-reflective":
        return {"tint": Colors.blue, "tintStrength": 0.15};
      case "polarized":
        return {"tint": Colors.blueGrey, "tintStrength": 0.35};
      case "sun":
        return {"tint": Colors.brown, "tintStrength": 0.4};
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.problemName)),
        body: Center(child: Text(errorMessage!)),
      );
    }

    if (scene == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final config = filterForProblem;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(widget.problemName),
      ),

      body: BlocProvider(
        create: (_) => SimulationsCubit(),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<SimulationsCubit, SimulationsState>(
                builder: (context, state) {
                  final lensPos = draggingPosition ?? state.lensPosition;
                  final lensRadius = state.lensRadius;

                  return GestureDetector(
                    onPanStart: (_) {
                      setState(() {
                        draggingPosition = lensPos;
                      });
                    },
                    onPanUpdate: (details) {
                      final size = MediaQuery.of(context).size;
                      final currentPos = draggingPosition ?? lensPos;
                      final dx = (currentPos.dx + details.delta.dx).clamp(
                        lensRadius,
                        size.width - lensRadius,
                      );
                      final dy = (currentPos.dy + details.delta.dy).clamp(
                        lensRadius,
                        size.height - lensRadius,
                      );
                      setState(() {
                        draggingPosition = Offset(dx, dy);
                      });
                    },
                    onPanEnd: (_) {
                      context.read<SimulationsCubit>().moveLens(
                        draggingPosition!,
                      );
                      setState(() {
                        draggingPosition = null;
                      });
                    },
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: ScenePainter(
                          image: scene!,
                          problem: state.problem,
                          blur: (config["blur"] ?? 0) * quality,
                          aberration: (config["aberration"] ?? 0) * quality,
                          tint: config["tint"] ?? tintColor,
                          tintStrength: config["tintStrength"] ?? tintStrength,
                          lensCenter: lensPos,
                          lensRadius: lensRadius,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // CONTROL PANEL
            SimulationsControlPanel(),
          ],
        ),
      ),
    );
  }
}
