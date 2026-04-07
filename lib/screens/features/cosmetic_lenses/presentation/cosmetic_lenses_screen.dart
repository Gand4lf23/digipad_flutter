import 'package:digipad_flutter/common/utils/responsive_utils.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_cubit.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_state.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/widgets/cosmetic_control_panel.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/widgets/iris_selector_widget.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/widgets/photo_canvas_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digipad_flutter/l10n/l10n.dart';

class CosmeticLensesScreen extends StatefulWidget {
  const CosmeticLensesScreen({super.key});

  @override
  State<CosmeticLensesScreen> createState() => _CosmeticLensesScreenState();
}

class _CosmeticLensesScreenState extends State<CosmeticLensesScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<CosmeticLensesCubit>();
    cubit.initIrisImages();
    cubit.loadGallery();
  }

  String _translateMessage(BuildContext context, String key) {
    switch (key) {
      case 'cosmeticLensSaved':
        return context.l10n.cosmeticLensSaved;
      case 'cosmeticLensSaveError':
        return context.l10n.cosmeticLensSaveError;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CosmeticLensesCubit, CosmeticLensesState>(
      listenWhen: (previous, current) => current.statusMessage != null,
      listener: (context, state) {
        final message = state.statusMessage;
        if (message != null) {
          final isSuccess = state.isSuccess ?? false;
          final displayMessage = _translateMessage(context, message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                displayMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor:
                  isSuccess ? Colors.green.shade700 : Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.read<CosmeticLensesCubit>().clearStatus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return OrientationBuilder(
                builder: (context, orientation) {
                  final responsive = context.responsive(
                    constraints,
                    orientation,
                  );

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
                                    context.l10n.menuCosmeticLenses,
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
      ),
    );
  }
}
