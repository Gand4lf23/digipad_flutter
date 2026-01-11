import 'package:digipad_flutter/common/utils/responsive_utils.dart';
import 'package:digipad_flutter/screens/features/visual_health/cubit/visual_health_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VisualHealthControlPanel extends StatelessWidget {
  const VisualHealthControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VisualHealthCubit>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final responsive = context.responsive(constraints, orientation);

            return Container(
              padding: responsive.padding(
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(responsive.borderRadius(24)),
                ),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade400),
                  left: BorderSide.none,
                  right: BorderSide.none,
                  bottom: BorderSide.none,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // GO BACK
                  _CircleIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => Navigator.of(context).pop(),
                    size: responsive.controlPanelIconSize(32),
                    containerSize: responsive.controlPanelContainerSize(64),
                  ),
                  // PREVIOUS TEST
                  _CircleIconButton(
                    icon: Icons.skip_previous,
                    onPressed: cubit.previousTest,
                    size: responsive.controlPanelIconSize(32),
                    containerSize: responsive.controlPanelContainerSize(64),
                  ),
                  // RESET
                  _CircleIconButton(
                    icon: Icons.refresh,
                    onPressed: cubit.reset,
                    size: responsive.controlPanelIconSize(60),
                    containerSize: responsive.controlPanelContainerSize(96),
                  ),
                  // NEXT TEST
                  _CircleIconButton(
                    icon: Icons.skip_next,
                    onPressed: cubit.nextTest,
                    size: responsive.controlPanelIconSize(32),
                    containerSize: responsive.controlPanelContainerSize(64),
                  ),
                  // HOME
                  _CircleIconButton(
                    icon: Icons.home,
                    onPressed: () => Navigator.of(context).pop(),
                    size: responsive.controlPanelIconSize(32),
                    containerSize: responsive.controlPanelContainerSize(64),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final double containerSize;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    required this.size,
    this.containerSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade800,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}
