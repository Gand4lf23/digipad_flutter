import 'dart:ui' as ui;

import 'package:digipad_flutter/screens/features/simulations/widgets/problem_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class SimulationsScreen extends StatefulWidget {
  final String problemName;

  const SimulationsScreen({super.key, required this.problemName});

  @override
  State<SimulationsScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationsScreen> {
  ui.Image? scene;

  // Control panel state
  double quality = 0.5;
  double tintStrength = 0;
  Color tint = Colors.transparent;

  String currentScene = "assets/images/scenes/TintePlaya.jpg";

  @override
  void initState() {
    super.initState();
    _loadScene();
  }

  Future<void> _loadScene() async {
    final data = await rootBundle.load(currentScene);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    setState(() => scene = frame.image);
  }

  Map<String, dynamic> get filterForProblem {
    switch (widget.problemName) {
      case "Miopía":
        return {"blur": 4.0, "aberration": 0.5};
      case "Presbicia":
        return {"blur": 6.0, "aberration": 0.2};
      case "Antirreflejo":
        return {
          "blur": 0,
          "aberration": 0,
          "tint": Colors.blue,
          "tintStrength": 0.15,
        };
      case "Polarizado":
        return {"tint": Colors.blueGrey, "tintStrength": 0.35};
      case "Solar":
        return {"tint": Colors.brown, "tintStrength": 0.4};
      default:
        return {"blur": 0, "aberration": 0};
    }
  }

  final List<String> sceneItems = [
    "assets/images/scenes/TintePlaya.jpg",
    "assets/images/scenes/PresbiciaSuper.jpg",
    "assets/images/scenes/PresbiciaTienda.jpg",
    "assets/images/scenes/solar_con_ar_auto.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    if (scene == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final config = filterForProblem;

    return Scaffold(
      appBar: AppBar(title: Text(widget.problemName)),
      body: Column(
        children: [
          Expanded(
            child: ProblemFilterWidget(
              image: scene!,
              blur: (config["blur"] ?? 0) * quality,
              aberration: (config["aberration"] ?? 0) * quality,
              tint: config["tint"] ?? tint,
              tintStrength: config["tintStrength"] != null
                  ? (config["tintStrength"] * quality)
                  : tintStrength,
            ),
          ),

          // CONTROL PANEL
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black12,
            child: Column(
              children: [
                const Text("Quality"),
                Slider(
                  value: quality,
                  onChanged: (v) => setState(() => quality = v),
                ),

                const SizedBox(height: 8),
                const Text("Tint Strength"),
                Slider(
                  value: tintStrength,
                  onChanged: (v) => setState(() => tintStrength = v),
                ),

                DropdownButton<String>(
                  value: currentScene,
                  items: const [
                    DropdownMenuItem(
                      value: "assets/images/scenes/TintePlaya.jpg",
                      child: Text("Playa"),
                    ),
                    DropdownMenuItem(
                      value: "assets/images/scenes/PresbiciaSuper.jpg",
                      child: Text("Super"),
                    ),
                    DropdownMenuItem(
                      value: "assets/images/scenes/PresbiciaTienda.jpg",
                      child: Text("Tienda"),
                    ),
                    DropdownMenuItem(
                      value: "assets/images/scenes/solar_con_ar_auto.jpg",
                      child: Text("Auto"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => currentScene = value);
                      _loadScene();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
