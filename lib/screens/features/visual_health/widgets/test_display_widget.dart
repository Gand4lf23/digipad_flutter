import 'package:digipad_flutter/screens/features/visual_health/cubit/visual_health_cubit.dart';
import 'package:digipad_flutter/screens/features/visual_health/cubit/visual_health_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestDisplayWidget extends StatefulWidget {
  const TestDisplayWidget({super.key});

  @override
  State<TestDisplayWidget> createState() => _TestDisplayWidgetState();
}

class _TestDisplayWidgetState extends State<TestDisplayWidget> {
  late TransformationController _controller;
  String? _lastImage;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisualHealthCubit, VisualHealthState>(
      builder: (context, state) {
        final currentImage = state.currentTestImage;

        if (currentImage != _lastImage) {
          _lastImage = currentImage;
          _controller.value = Matrix4.identity();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: currentImage == null
                  ? const Center(
                      child: Text(
                        'Select a test from the gallery above',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 22),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: InteractiveViewer(
                        transformationController: _controller,
                        panEnabled: true,
                        scaleEnabled: true,
                        minScale: 1.0,
                        maxScale: 5.0,
                        clipBehavior: Clip.none,
                        child: Image.asset(
                          currentImage,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
