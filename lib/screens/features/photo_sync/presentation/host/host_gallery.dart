import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/photo_sync_host_cubit.dart';

/// Gallery grid showing received photos on the HOST.
/// Supports tapping to view full-screen and long-press to delete.
/// Images are persisted in Sembast, so they survive app restarts.
class HostGallery extends StatelessWidget {
  final List<File> images;

  const HostGallery({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return _buildImageTile(context, images[index], index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_rounded,
            color: Colors.white12,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Las fotos aparecerán aquí',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando un celular envíe una foto,\nse mostrará automáticamente',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white24,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTile(BuildContext context, File imageFile, int index) {
    return GestureDetector(
      onTap: () => _showFullImage(context, imageFile),
      onLongPress: () => _confirmDelete(context, imageFile),
      child: Hero(
        tag: 'photo_sync_$index',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.white10,
                child: const Icon(Icons.broken_image_rounded,
                    color: Colors.white24, size: 32),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Eliminar foto?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Se eliminará permanentemente del dispositivo.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PhotoSyncHostCubit>().deleteImage(imageFile);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, File imageFile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullImageScreen(imageFile: imageFile),
      ),
    );
  }
}

class _FullImageScreen extends StatelessWidget {
  final File imageFile;

  const _FullImageScreen({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            imageFile,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
