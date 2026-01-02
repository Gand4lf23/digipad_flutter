// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Digipad';

  @override
  String get menuVirtualMirror => 'Virtual Mirror';

  @override
  String get menuSimulations => 'Simulations';

  @override
  String get menuLenses3D => 'Lenses 3D';

  @override
  String get menuCosmeticLenses => 'Cosmetic Lenses';

  @override
  String get menuMeasurements => 'Measurements';

  @override
  String get menuVisualHealth => 'Visual Health';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String dialogNavigatingContent(String module) {
    return 'Navigating to the $module module.';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get vmNoImages => 'No images loaded yet.\nCapture one or select from your gallery to get started!';

  @override
  String get vmDragAndDrop => 'Drag and drop photos';

  @override
  String get vmPickOrTake => 'Please pick a photo from your gallery or take a new one';

  @override
  String get vmDropHere => 'Drop image here';

  @override
  String get galleryDeleteTitle => 'Delete image?';

  @override
  String get galleryDeleteContent => 'This will permanently remove the image from storage.';

  @override
  String get vhNoTests => 'No tests loaded yet.';

  @override
  String get vhSelectTest => 'Select a visual health test';

  @override
  String vhTestSummary(int index, int total) {
    return 'Test $index of $total';
  }

  @override
  String get vhSelectAbove => 'Select a test from the gallery above';

  @override
  String get lensThicknessSimulator => 'Lens Thickness Simulator';

  @override
  String get lensConfiguration => 'Lens Configuration';

  @override
  String get materialIndex => 'Material Index';

  @override
  String get higherIndexHint => 'Higher index = thinner lens';

  @override
  String get prescription => 'Prescription';

  @override
  String rangeDiopters(int min, int max) {
    return 'Range: $min-$max diopters';
  }

  @override
  String get frameType => 'Frame Type';

  @override
  String get imageNotAvailable => 'Image not available';

  @override
  String get tryDifferentSettings => 'Try different settings';

  @override
  String get fullView => 'Full View';

  @override
  String get detailView => 'Detail View';

  @override
  String get lensSimulatorTitle => 'Lens Simulator';

  @override
  String get refractiveConditions => 'Refractive conditions';

  @override
  String get lensTreatments => 'Lens Treatments';

  @override
  String get withoutLens => 'Without lens';

  @override
  String scenesCount(int count) {
    return '$count scenes';
  }

  @override
  String lensesAvailable(int count) {
    return '$count lenses available';
  }

  @override
  String get selectLensLabel => 'Select a lens:';

  @override
  String get dividerLabel => 'Divider';

  @override
  String get verticalLabel => 'Vertical';

  @override
  String get horizontalLabel => 'Horizontal';

  @override
  String get dragDivider => 'Drag the divider';

  @override
  String get loadingSimulation => 'Loading simulation...';

  @override
  String get goBack => 'Go Back';

  @override
  String get cameraRequiredTitle => 'Camera Required';

  @override
  String get cameraRequiredContent => 'Camera access has been permanently denied. Please enable it in your system settings to use this feature.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get platformNotSupported => 'Platform not supported';

  @override
  String get placeReferenceHere => 'Place the reference here';

  @override
  String get cameraPermissionRequired => 'Camera Permission Required';

  @override
  String get cameraPermissionExplain => 'We need camera access to detect faces and reference markers.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String detectionIncomplete(int found) {
    return 'Detection incomplete. Found $found/4 circles. Please try a clearer image.';
  }

  @override
  String captureFailed(int found) {
    return 'Capture failed: Found $found circles (4 required). Try adjusting lighting or distance.';
  }

  @override
  String get measureAdjustments => 'Measure Adjustments';

  @override
  String get guides => 'Guides';

  @override
  String referenceShort(int ref) {
    return 'Ref: $ref';
  }

  @override
  String get unitMm => 'mm';

  @override
  String get ipdDi => 'IPD (DI)';

  @override
  String get bridge => 'Bridge';

  @override
  String get frameW => 'Frame W';

  @override
  String get frameH => 'Frame H';

  @override
  String get rightEyeP1 => 'Right Eye (P1)';

  @override
  String get leftEyeP2 => 'Left Eye (P2)';

  @override
  String dnpShort(String value) {
    return 'DNP: $value';
  }

  @override
  String heightShort(String value) {
    return 'Alt: $value';
  }

  @override
  String diamShort(String value) {
    return 'Diam: $value';
  }

  @override
  String get leftEye => 'Left Eye';

  @override
  String get bothEyes => 'Both Eyes';

  @override
  String get rightEye => 'Right Eye';

  @override
  String get size => 'Size';

  @override
  String get opacity => 'Opacity';

  @override
  String get eyelid => 'Eyelid';

  @override
  String get takeOrSelectStart => 'Take a photo or select from Gallery to get started';

  @override
  String get selectBrand => 'Select Brand';

  @override
  String get selectColor => 'Select Color';

  @override
  String get onLabel => 'On';

  @override
  String get offLabel => 'Off';

  @override
  String get detectionLabel => 'Detection';

  @override
  String get overlayLabel => 'Overlay';
}
