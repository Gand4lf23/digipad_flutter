import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:digipad_flutter/data/local/gallery_storage.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/cubit/cosmetic_lenses_state.dart';
import 'package:digipad_flutter/screens/features/cosmetic_lenses/widgets/photo_canvas_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CosmeticLensesCubit extends Cubit<CosmeticLensesState> {
  final ImagePicker _picker = ImagePicker();
  final GalleryStorage _galleryStorage;

  CosmeticLensesCubit(this._galleryStorage) : super(CosmeticLensesState());

  void initIrisImages() {
    final irisMap = <String, List<String>>{
      'Acuvue': [
        'assets/images/cosmetic_lenses/acuvue/acuvue2_colors_blue.webp',
        'assets/images/cosmetic_lenses/acuvue/acuvue2_colors_gray.webp',
        'assets/images/cosmetic_lenses/acuvue/acuvue2_colors_green.webp',
        'assets/images/cosmetic_lenses/acuvue/acuvue2_colors_honey.webp',
      ],
      'Devlyn': [
        'assets/images/cosmetic_lenses/devlyn/devlyn_color_gray.webp',
        'assets/images/cosmetic_lenses/devlyn/devlyn_color_green.webp',
        'assets/images/cosmetic_lenses/devlyn/devlyn_color_honey.webp',
        'assets/images/cosmetic_lenses/devlyn/devlyn_color_sky_blue.webp',
        'assets/images/cosmetic_lenses/devlyn/devlyn2_color_honey.webp',
        'assets/images/cosmetic_lenses/devlyn/devlyn3_color_blue.webp',
        'assets/images/cosmetic_lenses/devlyn/devlyn3_color_gray.webp',
        'assets/images/cosmetic_lenses/devlyn/devlyn3_color_green.webp',
      ],
      'Durasoft': [
        'assets/images/cosmetic_lenses/durasoft/durasoft2_colorsblends_blue.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft2_colorsblends_brown.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft2_colorsblends_gray.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft2_colorsblends_green.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_aqua.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_chestnut_brown.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_emerald_green.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_jade_green.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_mist_gray.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_sapphire_blue.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_sky_blue.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_complements_blue.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_complements_brown.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_complements_green.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_complements_shadow_gray.webp',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_complements_violet_blue.webp',
      ],
      'Fresh Look': [
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_color_blends_amethyst.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_color_blends_blue.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_color_blends_brown.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_color_blends_gray.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_colors_blue.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_colors_green.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_colors_hazel.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_alien.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_black.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_cateye.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_hypnotica.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_icefire.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_jaguar.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_knockout.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_redhot.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_whiteout.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_wildfire.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_zebra.webp',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_zoomin.webp',
      ],
      'Normal': [
        'assets/images/cosmetic_lenses/normal/aqua.webp',
        'assets/images/cosmetic_lenses/normal/blue.webp',
        'assets/images/cosmetic_lenses/normal/brown.webp',
        'assets/images/cosmetic_lenses/normal/gray.webp',
        'assets/images/cosmetic_lenses/normal/green.webp',
        'assets/images/cosmetic_lenses/normal/hazel.webp',
        'assets/images/cosmetic_lenses/normal/jade.webp',
        'assets/images/cosmetic_lenses/normal/topaz.webp',
      ],
      'Optima': [
        'assets/images/cosmetic_lenses/optima/optima_natural_look_blue.webp',
        'assets/images/cosmetic_lenses/optima/optima_natural_look_gray.webp',
        'assets/images/cosmetic_lenses/optima/optima_natural_look_green.webp',
        'assets/images/cosmetic_lenses/optima/optima_natural_look_hazel.webp',
        'assets/images/cosmetic_lenses/optima/optima_natural_look_light_green.webp',
      ],
      'Star Colors': [
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_blue.webp',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_blue_topaz.webp',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_dark_green.webp',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_green_amazon.webp',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_green_turquoise.webp',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_grey.webp',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_hazel.webp',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_light_green.webp',
      ],
      'Tricolor': [
        'assets/images/cosmetic_lenses/tricolor/tricolor_blue.webp',
        'assets/images/cosmetic_lenses/tricolor/tricolor_green.webp',
        'assets/images/cosmetic_lenses/tricolor/tricolor_grey.webp',
        'assets/images/cosmetic_lenses/tricolor/tricolor_honey.webp',
        'assets/images/cosmetic_lenses/tricolor/tricolor_purple.webp',
      ],
    };

    emit(state.copyWith(availableIris: irisMap, isInitialized: true));
  }

  Future<void> capturePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      emit(state.copyWith(cameraPhoto: photo.path));
    }
  }

  Future<void> pickFromGallery() async {
    final photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      emit(state.copyWith(cameraPhoto: photo.path));
    }
  }

  Future<void> saveComposedImage() async {
    try {
      // Check if there's a photo loaded
      if (state.cameraPhoto == null) {
        throw Exception(
          'No photo loaded. Please take or select a photo first.',
        );
      }

      // Get the RenderRepaintBoundary from the canvas key
      final boundary =
          canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Unable to capture canvas. Please try again.');
      }

      // Capture the canvas as an image
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to bytes.');
      }

      // Save to application documents directory
      final dir = await getApplicationDocumentsDirectory();
      final syncDir = Directory('${dir.path}/gallery');
      if (!await syncDir.exists()) {
        await syncDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${syncDir.path}/cosmetic_lens_$timestamp.webp';
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Save to gallery storage (Sembast DB)
      await _galleryStorage.saveImage(file);

      // Emit success state for UI feedback
      emit(
        state.copyWith(
          statusMessage: 'cosmeticLensSaved',
          isSuccess: true,
        ),
      );

      debugPrint('Image saved successfully: $filePath');
      // Refresh local gallery images in state
      loadGallery();
    } catch (e) {
      debugPrint('Error saving image: $e');
      emit(
        state.copyWith(
          statusMessage: 'cosmeticLensSaveError',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> loadGallery() async {
    try {
      final files = await _galleryStorage.loadImages();
      emit(state.copyWith(galleryImages: files.map((f) => f.path).toList()));
    } catch (e) {
      debugPrint('Error loading gallery: $e');
    }
  }

  void pickFromInternalGallery(String imagePath) {
    emit(state.copyWith(cameraPhoto: imagePath));
  }

  void clearStatus() {
    emit(state.copyWith(statusMessage: null, isSuccess: null));
  }

  void selectLeftIris(String imagePath) {
    // Spawn on right side of screen (0.75 normalized position)
    emit(
      state.copyWith(
        leftIris: state.leftIris.copyWith(
          imagePath: imagePath,
          position: const Offset(0.75, 0.5),
        ),
      ),
    );
  }

  void selectRightIris(String imagePath) {
    // Spawn on left side of screen (0.25 normalized position)
    emit(
      state.copyWith(
        rightIris: state.rightIris.copyWith(
          imagePath: imagePath,
          position: const Offset(0.25, 0.5),
        ),
      ),
    );
  }

  void updateLeftIrisPosition(Offset position) {
    emit(state.copyWith(leftIris: state.leftIris.copyWith(position: position)));
  }

  void updateRightIrisPosition(Offset position) {
    emit(
      state.copyWith(rightIris: state.rightIris.copyWith(position: position)),
    );
  }

  void updateLeftIrisScale(double scale) {
    emit(state.copyWith(leftIris: state.leftIris.copyWith(scale: scale)));
  }

  void updateRightIrisScale(double scale) {
    emit(state.copyWith(rightIris: state.rightIris.copyWith(scale: scale)));
  }

  void updateLeftIrisOpacity(double opacity) {
    emit(state.copyWith(leftIris: state.leftIris.copyWith(opacity: opacity)));
  }

  void updateRightIrisOpacity(double opacity) {
    emit(state.copyWith(rightIris: state.rightIris.copyWith(opacity: opacity)));
  }

  void toggleLeftEyelid(bool show) {
    emit(state.copyWith(leftIris: state.leftIris.copyWith(showEyelid: show)));
  }

  void toggleRightEyelid(bool show) {
    emit(state.copyWith(rightIris: state.rightIris.copyWith(showEyelid: show)));
  }

  void setActiveEye(EyeSelection eye) {
    emit(state.copyWith(activeEye: eye));
  }

  void resetIris() {
    emit(state.copyWith(leftIris: IrisConfig(), rightIris: IrisConfig()));
  }

  void clearPhoto() {
    emit(state.copyWith(cameraPhoto: null));
  }
}
