import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_cubit.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_state.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/widgets/dual_image_viewer.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/widgets/lenses_3d_control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class Lenses3DScreen extends StatelessWidget {
  const Lenses3DScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Lenses3DCubit(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Lenses 3D'),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<Lenses3DCubit, Lenses3DState>(
          builder: (context, state) {
            final cubit = context.read<Lenses3DCubit>();
            return Column(
              children: [
                // Top section (1/3 screen): Splitted section with an image
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade800),
                      ),
                    ),
                    child: DualImageViewer(
                      state: state,
                      isZoomedOut: false, // Zoomed In
                      onPickImage: () => cubit.pickImage(ImageSource.gallery),
                    ),
                  ),
                ),
                // Mid section (1/3 screen): Same as above but zoomed out
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade800),
                      ),
                    ),
                    child: DualImageViewer(
                      state: state,
                      isZoomedOut: true, // Zoomed Out
                    ),
                  ),
                ),
                // Bottom section (1/3 screen) Control panel
                const Expanded(flex: 1, child: Lenses3DControlPanel()),
              ],
            );
          },
        ),
      ),
    );
  }
}
