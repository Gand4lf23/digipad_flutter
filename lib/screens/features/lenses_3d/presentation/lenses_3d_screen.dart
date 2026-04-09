import 'package:digipad_flutter/common/utils/responsive_utils.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_cubit.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/cubit/lenses_3d_state.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/widgets/lens_image_viewer.dart';
import 'package:digipad_flutter/screens/features/lenses_3d/widgets/lenses_3d_control_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digipad_flutter/l10n/l10n.dart';

class Lenses3DScreen extends StatefulWidget {
  const Lenses3DScreen({super.key});

  @override
  State<Lenses3DScreen> createState() => _Lenses3DScreenState();
}

class _Lenses3DScreenState extends State<Lenses3DScreen> {
  late final Lenses3DCubit _leftCubit;
  late final Lenses3DCubit _rightCubit;

  @override
  void initState() {
    super.initState();
    _leftCubit = Lenses3DCubit();
    _rightCubit = Lenses3DCubit();
  }

  @override
  void dispose() {
    _leftCubit.close();
    _rightCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            return OrientationBuilder(
              builder: (context, orientation) {
                final responsive = context.responsive(constraints, orientation);
                return Text(
                  "${context.l10n.lensThicknessSimulator} - Comparador",
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
      body: Column(
        children: [
          // TOP HALF: Images Horizontally wrapped in a Stack for the floating button
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BlocProvider.value(
                        value: _leftCubit,
                        child: const _LensImagesView(label: "Lente A"),
                      ),
                    ),

                    // Optional: A thin visual divider line behind the floating button
                    Container(width: 2, color: Colors.white),

                    Expanded(
                      child: BlocProvider.value(
                        value: _rightCubit,
                        child: const _LensImagesView(label: "Lente B"),
                      ),
                    ),
                  ],
                ),

                // FLOATING EQUAL BUTTON: Dead center between the images
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: FloatingActionButton(
                      heroTag: 'equal_btn',
                      elevation: 4,
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        _rightCubit.copySettingsFrom(_leftCubit.state);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Configuración igualada'),
                            duration: const Duration(milliseconds: 800),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.grey.shade900,
                          ),
                        );
                      },
                      tooltip: 'Igualar Lente B a Lente A',
                      child: const Text('=', style: TextStyle(fontSize: 30)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BOTTOM HALF: Controls Vertically
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.grey.shade900,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    BlocProvider.value(
                      value: _leftCubit,
                      child: const _LensControlsView(label: "Lente A"),
                    ),

                    Container(
                      height: 2,
                      color: Colors.black54,
                    ), // Subtle divider between panels

                    BlocProvider.value(
                      value: _rightCubit,
                      child: const _LensControlsView(label: "Lente B"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget dedicated only to showing the 3D Views and Zoom views
class _LensImagesView extends StatelessWidget {
  final String label;

  const _LensImagesView({required this.label});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Lenses3DCubit, Lenses3DState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              color: Colors.grey.shade300,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
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
            Expanded(
              flex: 2,
              child: LensImageViewer(state: state, isZoomedOut: true),
            ),
          ],
        );
      },
    );
  }
}

// Widget dedicated only to showing collapsible form controls
class _LensControlsView extends StatefulWidget {
  final String label;

  const _LensControlsView({required this.label});

  @override
  State<_LensControlsView> createState() => _LensControlsViewState();
}

class _LensControlsViewState extends State<_LensControlsView> {
  bool _controlsVisible = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _controlsVisible = !_controlsVisible;
            });
          },
          child: Container(
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              border: Border(
                top: BorderSide(color: Colors.grey.shade700, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tune, color: Colors.blueAccent.shade100, size: 14),
                const SizedBox(width: 8),
                Text(
                  _controlsVisible
                      ? "Ocultar Controles ${widget.label}"
                      : "Ajustar ${widget.label}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _controlsVisible
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(
            color: Colors.grey.shade900,
            child: const Lenses3DControlPanel(),
          ),
          secondChild: const SizedBox(width: double.infinity, height: 0),
          crossFadeState: _controlsVisible
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }
}
