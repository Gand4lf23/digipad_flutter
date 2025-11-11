import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:digipad_flutter/data/local/gallery_storage.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/cubit/virtual_mirror_state.dart';
import 'package:digipad_flutter/screens/features/virtual_mirror/presentation/virtual_mirror_screen.dart';
import 'package:image_picker/image_picker.dart';

class VirtualMirrorCubit extends Cubit<VirtualMirrorState> {
  final ImagePicker _picker = ImagePicker();
  final GalleryStorage storage;

  VirtualMirrorCubit(this.storage) : super(VirtualMirrorState());

  Future<void> initGallery() async {
    await storage.init();
    final files = await storage.loadImages();
    emit(state.copyWith(galleryImages: files));
  }

  Future<void> capturePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final file = File(photo.path);
      await storage.saveImage(file);
      emit(state.copyWith(galleryImages: [...state.galleryImages, file]));
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
    final files = await _picker.pickMultiImage();
    if (files.isNotEmpty) {
      final images = files.map((xfile) => File(xfile.path)).toList();
      emit(state.copyWith(galleryImages: [...state.galleryImages, ...images]));
    }
  }
}
