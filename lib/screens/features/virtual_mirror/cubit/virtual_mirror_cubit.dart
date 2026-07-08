import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:digipad_flutter/data/local/gallery_storage.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/cubit/virtual_mirror_state.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/presentation/virtual_mirror_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class VirtualMirrorCubit extends Cubit<VirtualMirrorState> {
  final ImagePicker _picker = ImagePicker();
  final GalleryStorage storage;
  StreamSubscription<List<File>>? _gallerySub;

  VirtualMirrorCubit(this.storage) : super(VirtualMirrorState()) {
    _gallerySub = storage.watchImages().listen((images) {
      emit(state.copyWith(galleryImages: images));
    });
  }

  /// Still callable from initState — the stream handles the first load.
  Future<void> initGallery() => storage.init();

  Future<void> capturePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      File file = File(photo.path);
      file = await _persistFile(file, 'image');
      await storage.saveImage(file);
      // stream fires → galleryImages auto-updates
    }
  }

  Future<void> captureVideo() async {
    final video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      File file = File(video.path);
      file = await _persistFile(file, 'video');
      await storage.saveVideo(file);
    }
  }

  void setImage(DropSide side, File file) {
    emit(
      side == DropSide.left
          ? state.copyWith(leftImage: file)
          : state.copyWith(rightImage: file),
    );
  }

  void clearImages() {
    emit(state.copyWith(leftImage: null, rightImage: null));
  }

  Future<void> pickFromGallery() async {
    final files = await _picker.pickMultipleMedia();
    if (files.isNotEmpty) {
      for (final xfile in files) {
        final file = await _persistFile(File(xfile.path), 'gallery');
        await storage.saveImage(file);
      }
      // stream fires → galleryImages auto-updates
    }
  }

  Future<File> _persistFile(File file, String prefix) async {
    final docsDir = await getApplicationDocumentsDirectory();
    if (file.path.startsWith(docsDir.path)) return file;

    final galleryDir = Directory(p.join(docsDir.path, 'gallery'));
    if (!await galleryDir.exists()) await galleryDir.create(recursive: true);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = p.extension(file.path);
    final newPath = p.join(galleryDir.path, '${prefix}_$timestamp$ext');
    return await file.copy(newPath);
  }

  Future<void> deleteImage(File file) async {
    await storage.deleteImage(file);
    // stream fires → galleryImages auto-updates
    // also clear drop zones if the deleted file was displayed
    final current = state;
    if (current.leftImage?.path == file.path ||
        current.rightImage?.path == file.path) {
      emit(current.copyWith(
        leftImage: current.leftImage?.path == file.path
            ? null
            : current.leftImage,
        rightImage: current.rightImage?.path == file.path
            ? null
            : current.rightImage,
      ));
    }
  }

  Future<void> deleteMultiple(List<File> files) async {
    for (final f in files) {
      await storage.deleteImage(f);
    }
    final paths = files.map((f) => f.path).toSet();
    final current = state;
    if (paths.contains(current.leftImage?.path) ||
        paths.contains(current.rightImage?.path)) {
      emit(current.copyWith(
        leftImage:
            paths.contains(current.leftImage?.path) ? null : current.leftImage,
        rightImage: paths.contains(current.rightImage?.path)
            ? null
            : current.rightImage,
      ));
    }
  }

  @override
  Future<void> close() async {
    await _gallerySub?.cancel();
    return super.close();
  }
}
