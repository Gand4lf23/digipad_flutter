import 'package:digipad_flutter/screens/activation/cubit/activation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InteractionObserver extends StatelessWidget {
  final Widget child;

  const InteractionObserver({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        context.read<ActivationCubit>().handleInteraction();
      },
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
