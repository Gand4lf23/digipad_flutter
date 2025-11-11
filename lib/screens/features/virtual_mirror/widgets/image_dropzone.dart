import 'dart:io';

import 'package:digipad_flutter/screens/features/virtual_mirror/cubit/virtual_mirror_cubit.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/presentation/virtual_mirror_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageDropZone extends StatelessWidget {
  final DropSide side;
  final bool showEmptyMessage;

  const ImageDropZone({
    super.key,
    required this.side,
    required this.showEmptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final image = side == DropSide.left
        ? context.watch<VirtualMirrorCubit>().state.leftImage
        : context.watch<VirtualMirrorCubit>().state.rightImage;

    final isEmpty = image == null;

    return DragTarget<File>(
      onAccept: (file) =>
          context.read<VirtualMirrorCubit>().setImage(side, file),
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black),
          ),
          child: SizedBox(
            width: double.infinity,
            height:
                MediaQuery.of(context).size.height *
                0.5, // Fixed height for consistency
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: isEmpty && showEmptyMessage
                  ? const Center(
                      child: Text(
                        'Please pick a photo from your gallery or take a new one',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    )
                  : image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        image,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Drop image here',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
