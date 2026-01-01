import 'dart:io';
import 'package:digipad_flutter/screens/features/virtual_mirror/cubit/virtual_mirror_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digipad_flutter/l10n/l10n.dart';

class GallerySection extends StatefulWidget {
  final List<File> gallery;

  const GallerySection({super.key, required this.gallery});

  @override
  State<GallerySection> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<GallerySection> {
  final _controller = ScrollController();

  void scrollLeft() {
    _controller.animateTo(
      _controller.offset - 220,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void scrollRight() {
    _controller.animateTo(
      _controller.offset + 220,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade600, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SizedBox(
          height: 250,
          child: Stack(
            children: [
              // ---- Scrollable gallery ----
              NotificationListener<UserScrollNotification>(
                onNotification: (_) => true,
                child: ListView.separated(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  itemCount: widget.gallery.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final file = widget.gallery[index];
                    return _ScrollableDraggableThumbnail(
                      file: file,
                      onDelete: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(
                              context.l10n.galleryDeleteTitle,
                              style: const TextStyle(color: Colors.white),
                            ),
                            content: Text(
                              context.l10n.galleryDeleteContent,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(
                                  context.l10n.cancel,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  context.l10n.delete,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await context.read<VirtualMirrorCubit>().deleteImage(
                            file,
                          );
                        }
                      },
                    );
                  },
                ),
              ),

              // ---- Scroll arrows ----
              Positioned(
                left: 0,
                top: 100,
                child: _ArrowButton(
                  icon: Icons.arrow_back_ios,
                  onTap: scrollLeft,
                ),
              ),
              Positioned(
                right: 0,
                top: 100,
                child: _ArrowButton(
                  icon: Icons.arrow_forward_ios,
                  onTap: scrollRight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrollableDraggableThumbnail extends StatelessWidget {
  final File file;
  final VoidCallback onDelete;

  const _ScrollableDraggableThumbnail({
    required this.file,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        Scrollable.of(context).position.moveTo(
          Scrollable.of(context).position.pixels - details.delta.dx,
        );
      },

      child: Stack(
        children: [
          LongPressDraggable<File>(
            data: file,
            delay: const Duration(milliseconds: 300),
            feedback: Opacity(
              opacity: 0.7,
              child: _ThumbnailPreview(file: file),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _ThumbnailPreview(file: file),
            ),
            child: _ThumbnailPreview(file: file),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
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
      width: 200,
      height: 250,
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

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey.shade800,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
