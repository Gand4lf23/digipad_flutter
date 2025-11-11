import 'package:digipad_flutter/screens/features/virtual_mirror/cubit/virtual_mirror_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VirtualMirrorCubit>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
            size: 32,
          ),
          // PICK FROM GALLERY
          _CircleIconButton(
            icon: Icons.photo_library,
            onPressed: () => cubit.pickFromGallery(),
            size: 32,
          ),
          // TAKE PHOTO (bigger)
          _CircleIconButton(
            icon: Icons.camera_alt,
            onPressed: () => cubit.capturePhoto(),
            size: 60,
            containerSize: 96,
          ),
          // TAKE VIDEO
          _CircleIconButton(
            icon: Icons.videocam,
            onPressed: () => cubit.captureVideo(),
            size: 32,
          ),
          // RESET BOTH DROPZONES
          _CircleIconButton(
            icon: Icons.refresh,
            onPressed: cubit.clearImages,
            size: 32,
          ),
        ],
      ),
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
