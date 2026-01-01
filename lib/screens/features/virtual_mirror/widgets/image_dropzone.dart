import 'dart:io';

import 'package:digipad_flutter/screens/features/virtual_mirror/cubit/virtual_mirror_cubit.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/presentation/virtual_mirror_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digipad_flutter/l10n/l10n.dart';

class ImageDropZone extends StatefulWidget {
  final DropSide side;
  final bool showEmptyMessage;

  const ImageDropZone({
    super.key,
    required this.side,
    required this.showEmptyMessage,
  });

  @override
  State<ImageDropZone> createState() => _ImageDropZoneState();
}

class _ImageDropZoneState extends State<ImageDropZone> {
  late TransformationController _controller;
  File? _lastImage;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.side == DropSide.left
        ? context.watch<VirtualMirrorCubit>().state.leftImage
        : context.watch<VirtualMirrorCubit>().state.rightImage;

    final isEmpty = image == null;
    if (image != _lastImage) {
      _lastImage = image;
      _controller.value = Matrix4.identity();
    }

    return DragTarget<File>(
      onAccept: (file) =>
          context.read<VirtualMirrorCubit>().setImage(widget.side, file),
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: isEmpty && widget.showEmptyMessage
                  ? Center(
                      child: Text(
                        context.l10n.vmPickOrTake,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 22,
                        ),
                      ),
                    )
                  : image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: InteractiveViewer(
                        transformationController: _controller,
                        panEnabled: true,
                        scaleEnabled: true,
                        minScale: 1.0,
                        maxScale: 5.0,
                        clipBehavior: Clip.none,
                        child: Image.file(
                          image,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        context.l10n.vmDropHere,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 22,
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
