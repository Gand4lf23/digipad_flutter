import 'package:digipad_flutter/common/utils/responsive_utils.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_cubit.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/widgets/cosmetic_control_panel.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/widgets/iris_selector_widget.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/widgets/photo_canvas_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CosmeticLensesScreen extends StatefulWidget {
  const CosmeticLensesScreen({super.key});

  @override
  State<CosmeticLensesScreen> createState() => _CosmeticLensesScreenState();
}

class _CosmeticLensesScreenState extends State<CosmeticLensesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CosmeticLensesCubit>().initIrisImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return OrientationBuilder(
              builder: (context, orientation) {
                final responsive = context.responsive(constraints, orientation);

                return Column(
                  children: [
                    Expanded(flex: 55, child: const PhotoCanvasWidget()),
                    Expanded(
                      flex: 45,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.shade600,
                              width: 2,
                            ),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Title
                              Container(
                                padding: responsive.padding(
                                  const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Cosmetic Lenses',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsive.fontSize(20),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Iris selectors
                              Padding(
                                padding: responsive.padding(
                                  const EdgeInsets.all(12),
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: IrisSelectorWidget(
                                        isLeftEye: true,
                                      ),
                                    ),
                                    SizedBox(width: responsive.spacing(12)),
                                    const Expanded(
                                      child: IrisSelectorWidget(
                                        isLeftEye: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Control panel
                              const CosmeticControlPanel(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
