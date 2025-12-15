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
        'assets/images/cosmetic_lenses/acuvue/acuvue2_colors_blue.png',
        'assets/images/cosmetic_lenses/acuvue/acuvue2_colors_gray.png',
        'assets/images/cosmetic_lenses/acuvue/acuvue2_colors_green.png',
        'assets/images/cosmetic_lenses/acuvue/acuvue2_colors_honey.png',
      ],
      'Devlyn': [
        'assets/images/cosmetic_lenses/devlyn/devlyn_color_gray.png',
        'assets/images/cosmetic_lenses/devlyn/devlyn_color_green.png',
        'assets/images/cosmetic_lenses/devlyn/devlyn_color_honey.png',
        'assets/images/cosmetic_lenses/devlyn/devlyn_color_sky_blue.png',
        'assets/images/cosmetic_lenses/devlyn/devlyn2_color_honey.png',
        'assets/images/cosmetic_lenses/devlyn/devlyn3_color_blue.png',
        'assets/images/cosmetic_lenses/devlyn/devlyn3_color_gray.png',
        'assets/images/cosmetic_lenses/devlyn/devlyn3_color_green.png',
      ],
      'Durasoft': [
        'assets/images/cosmetic_lenses/durasoft/durasoft2_colorsblends_blue.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft2_colorsblends_brown.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft2_colorsblends_gray.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft2_colorsblends_green.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_aqua.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_chestnut_brown.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_emerald_green.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_jade_green.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_mist_gray.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_sapphire_blue.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_colors_sky_blue.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_complements_blue.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_complements_brown.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_complements_green.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_complements_shadow_gray.png',
        'assets/images/cosmetic_lenses/durasoft/durasoft3_complements_violet_blue.png',
      ],
      'Fresh Look': [
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_color_blends_amethyst.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_color_blends_blue.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_color_blends_brown.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_color_blends_gray.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_colors_blue.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_colors_green.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_colors_hazel.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_alien.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_black.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_cateye.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_hypnotica.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_icefire.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_jaguar.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_knockout.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_redhot.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_whiteout.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_wildfire.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_zebra.png',
        'assets/images/cosmetic_lenses/fresh_look/fresh_look_wild_zoomin.png',
      ],
      'Normal': [
        'assets/images/cosmetic_lenses/normal/aqua.png',
        'assets/images/cosmetic_lenses/normal/blue.png',
        'assets/images/cosmetic_lenses/normal/brown.png',
        'assets/images/cosmetic_lenses/normal/gray.png',
        'assets/images/cosmetic_lenses/normal/green.png',
        'assets/images/cosmetic_lenses/normal/hazel.png',
        'assets/images/cosmetic_lenses/normal/jade.png',
        'assets/images/cosmetic_lenses/normal/topaz.png',
      ],
      'Optima': [
        'assets/images/cosmetic_lenses/optima/optima_natural_look_blue.png',
        'assets/images/cosmetic_lenses/optima/optima_natural_look_gray.png',
        'assets/images/cosmetic_lenses/optima/optima_natural_look_green.png',
        'assets/images/cosmetic_lenses/optima/optima_natural_look_hazel.png',
        'assets/images/cosmetic_lenses/optima/optima_natural_look_light_green.png',
      ],
      'Star Colors': [
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_blue.png',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_blue_topaz.png',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_dark_green.png',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_green_amazon.png',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_green_turquoise.png',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_grey.png',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_hazel.png',
        'assets/images/cosmetic_lenses/star_colors/star_colors_2_light_green.png',
      ],
      'Tricolor': [
        'assets/images/cosmetic_lenses/tricolor/tricolor_blue.png',
        'assets/images/cosmetic_lenses/tricolor/tricolor_green.png',
        'assets/images/cosmetic_lenses/tricolor/tricolor_grey.png',
        'assets/images/cosmetic_lenses/tricolor/tricolor_honey.png',
        'assets/images/cosmetic_lenses/tricolor/tricolor_purple.png',
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

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/cosmetic_lens_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Save to gallery storage (Sembast DB)
      await _galleryStorage.saveImage(file);

      // Emit success (you can add a success message to state if needed)
      debugPrint('Image saved successfully: $filePath');
    } catch (e) {
      debugPrint('Error saving image: $e');
      rethrow;
    }
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
