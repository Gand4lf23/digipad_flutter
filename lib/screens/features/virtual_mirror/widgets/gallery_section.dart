import 'dart:io';

import 'package:digipad_flutter/screens/features/virtual_mirror/cubit/virtual_mirror_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GallerySection extends StatelessWidget {
  const GallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    final gallery = context.watch<VirtualMirrorCubit>().state.galleryImages;

    return Card(
      color: Colors.grey.shade900,
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: gallery.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final file = gallery[index];
              return Draggable<File>(
                data: file,
                feedback: Opacity(
                  opacity: 0.7,
                  child: _ThumbnailPreview(file: file),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _ThumbnailPreview(file: file),
                ),
                child: _ThumbnailPreview(file: file),
              );
            },
          ),
        ),
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
      width: 200,
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
