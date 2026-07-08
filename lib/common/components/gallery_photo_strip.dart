import 'dart:io';

import 'package:flutter/material.dart';

/// Horizontal photo strip with:
/// - X button on each thumbnail for single delete (with confirm dialog)
/// - Long-press to enter multi-select mode
/// - Bulk delete action while in multi-select
/// - Optional [onTap]: called on regular tap (when not in select mode),
///   e.g. to send the photo. A send-icon overlay is shown when provided.
///
/// [onDelete] and [onDeleteMultiple] are called AFTER user confirms the dialog.
/// The caller is responsible for actually deleting from storage.
class GalleryPhotoStrip extends StatefulWidget {
  final List<File> photos;
  final Future<void> Function(File) onDelete;
  final Future<void> Function(List<File>) onDeleteMultiple;

  /// Called on tap when NOT in multi-select mode. If null, tap does nothing.
  final void Function(File)? onTap;

  /// Height of each thumbnail square.
  final double itemSize;

  const GalleryPhotoStrip({
    super.key,
    required this.photos,
    required this.onDelete,
    required this.onDeleteMultiple,
    this.onTap,
    this.itemSize = 100,
  });

  @override
  State<GalleryPhotoStrip> createState() => _GalleryPhotoStripState();
}

class _GalleryPhotoStripState extends State<GalleryPhotoStrip> {
  bool _selecting = false;
  final Set<String> _selected = {};

  void _enterSelect(File file) {
    setState(() {
      _selecting = true;
      _selected.add(file.path);
    });
  }

  void _toggleSelect(File file) {
    setState(() {
      if (_selected.contains(file.path)) {
        _selected.remove(file.path);
        if (_selected.isEmpty) _selecting = false;
      } else {
        _selected.add(file.path);
      }
    });
  }

  void _exitSelect() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  Future<bool> _confirmDelete(BuildContext context, int count) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1C1C1E),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Text(
              count == 1 ? 'Eliminar foto' : 'Eliminar $count fotos',
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              count == 1
                  ? '¿Eliminar esta foto de la galería?'
                  : '¿Eliminar las $count fotos seleccionadas?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Eliminar',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Selection action bar ──────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _selecting
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        '${_selected.length} seleccionada${_selected.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () async {
                          final files = widget.photos
                              .where((f) => _selected.contains(f.path))
                              .toList();
                          if (files.isEmpty) return;
                          final ok =
                              await _confirmDelete(context, files.length);
                          if (ok && context.mounted) {
                            await widget.onDeleteMultiple(files);
                            _exitSelect();
                          }
                        },
                        icon: const Icon(Icons.delete_rounded,
                            size: 16, color: Colors.redAccent),
                        label: const Text('Eliminar',
                            style: TextStyle(color: Colors.redAccent)),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _exitSelect,
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact),
                        child: const Text('Cancelar',
                            style: TextStyle(color: Colors.white38)),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // ── Photo list ────────────────────────────────────────────────────
        SizedBox(
          height: widget.itemSize,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.photos.length,
            separatorBuilder: (_, i) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final file = widget.photos[index];
              final isSelected = _selected.contains(file.path);

              return GestureDetector(
                onLongPress:
                    _selecting ? null : () => _enterSelect(file),
                onTap: _selecting
                    ? () => _toggleSelect(file)
                    : widget.onTap != null
                        ? () => widget.onTap!(file)
                        : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: widget.itemSize,
                  height: widget.itemSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(
                            color: const Color(0xFF6C63FF), width: 2.5)
                        : Border.all(color: Colors.transparent, width: 2.5),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          file,
                          width: widget.itemSize,
                          height: widget.itemSize,
                          fit: BoxFit.cover,
                          cacheWidth: (widget.itemSize * 2).toInt(),
                          errorBuilder: (ctx, err, trace) => Container(
                            color: Colors.white10,
                            child: const Icon(Icons.broken_image,
                                color: Colors.white24),
                          ),
                        ),
                      ),

                      // Checkbox overlay in multi-select mode
                      if (_selecting)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF6C63FF)
                                  : Colors.black54,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white60, width: 1.5),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14)
                                : null,
                          ),
                        ),

                      // Send-icon hint (bottom-right, when onTap provided)
                      if (!_selecting && widget.onTap != null)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send_rounded,
                                color: Colors.white, size: 12),
                          ),
                        ),

                      // X delete button (top-right, only when NOT in select mode)
                      if (!_selecting)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () async {
                              final ok =
                                  await _confirmDelete(context, 1);
                              if (ok && context.mounted) {
                                await widget.onDelete(file);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
