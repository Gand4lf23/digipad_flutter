import 'package:digipad_flutter/screens/features/visual_health/cubit/visual_health_cubit.dart';
import 'package:digipad_flutter/screens/features/visual_health/cubit/visual_health_state.dart';
import 'package:digipad_flutter/screens/features/visual_health/widgets/test_display_widget.dart';
import 'package:digipad_flutter/screens/features/visual_health/widgets/test_gallery_widget.dart';
import 'package:digipad_flutter/screens/features/visual_health/widgets/visual_health_control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VisualHealthScreen extends StatefulWidget {
  const VisualHealthScreen({super.key});

  @override
  State<VisualHealthScreen> createState() => _VisualHealthScreenState();
}

class _VisualHealthScreenState extends State<VisualHealthScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VisualHealthCubit>().initTests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Column(
          children: [
            const TestGalleryWidget(),
            BlocBuilder<VisualHealthCubit, VisualHealthState>(
              builder: (context, state) {
                return Text(
                  state.currentTestImage != null
                      ? 'Test ${state.currentTestIndex + 1} of ${state.testImages.length}'
                      : 'Select a visual health test',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 28),
                );
              },
            ),
            const SizedBox(height: 8),
            const Expanded(child: TestDisplayWidget()),
            const VisualHealthControlPanel(),
          ],
        ),
      ),
    );
  }
}
