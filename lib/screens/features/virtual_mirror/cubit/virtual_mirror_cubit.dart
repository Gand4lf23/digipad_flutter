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
      File file = File(photo.path);
      //file = await fixImageRotation(file);
      await storage.saveImage(file);
      emit(state.copyWith(galleryImages: [file, ...state.galleryImages]));
    }
  }

  Future<void> captureVideo() async {
    final video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      final file = File(video.path);
      await storage.saveVideo(file);
      emit(state.copyWith(galleryImages: [file, ...state.galleryImages]));
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
      final media = files.map((xfile) => File(xfile.path)).toList();
      emit(state.copyWith(galleryImages: [...media, ...state.galleryImages]));
    }
  }

  Future<void> deleteImage(File file) async {
    await storage.deleteImage(file);
    emit(
      state.copyWith(
        galleryImages: state.galleryImages
            .where((f) => f.path != file.path)
            .toList(),
      ),
    );
  }
}
