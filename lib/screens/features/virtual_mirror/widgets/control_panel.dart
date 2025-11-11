import 'dart:io';

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
      color: Colors.grey.shade900,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Take photo button
          _CircleIconButton(
            icon: Icons.photo_library,
            onPressed: () =>
                context.read<VirtualMirrorCubit>().pickFromGallery(),
          ),
          _CircleIconButton(
            icon: Icons.camera_alt,
            onPressed: () => context.read<VirtualMirrorCubit>().capturePhoto(),
          ),

          // Take video button
          _CircleIconButton(
            icon: Icons.videocam,
            onPressed: () {
              // TODO: trigger video capture
            },
          ),

          // Reset button
          _CircleIconButton(icon: Icons.refresh, onPressed: cubit.clearImages),
        ],
      ),
    );
  }
}

class _ThumbnailPreview extends StatelessWidget {
  final File file;

  const _ThumbnailPreview({required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(file, fit: BoxFit.cover),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
