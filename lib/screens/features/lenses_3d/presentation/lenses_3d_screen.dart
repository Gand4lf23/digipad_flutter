import 'package:digipad_flutter/common/utils/responsive_utils.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_cubit.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_state.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/widgets/lens_image_viewer.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/widgets/lenses_3d_control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Lenses3DScreen extends StatelessWidget {
  const Lenses3DScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Lenses3DCubit(),
      child: Scaffold(
        backgroundColor: Colors.greenAccent.shade100,
        appBar: AppBar(
          title: LayoutBuilder(
            builder: (context, constraints) {
              return OrientationBuilder(
                builder: (context, orientation) {
                  final responsive = context.responsive(
                    constraints,
                    orientation,
                  );
                  return Text(
                    'Lens Thickness Simulator',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.fontSize(20),
                    ),
                  );
                },
              );
            },
          ),
          backgroundColor: Colors.greenAccent.shade200,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<Lenses3DCubit, Lenses3DState>(
          builder: (context, state) {
            return Column(
              children: [
                // Top section: Detail view - zoomed in
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    child: LensImageViewer(state: state, isZoomedOut: false),
                  ),
                ),

                // Middle section: Full view - zoomed out
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade800,
                          width: 1,
                        ),
                      ),
                    ),
                    child: LensImageViewer(state: state, isZoomedOut: true),
                  ),
                ),

                // Bottom section: Control panel (scrollable for small screens)
                Expanded(
                  flex: 3,
                  child: const SingleChildScrollView(
                    child: Lenses3DControlPanel(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
