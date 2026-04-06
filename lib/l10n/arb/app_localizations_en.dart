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
  String get vmNoImages =>
      'No images loaded yet.\nCapture one or select from your gallery to get started!';

  @override
  String get vmDragAndDrop => 'Drag and drop photos';

  @override
  String get vmPickOrTake =>
      'Please pick a photo from your gallery or take a new one';

  @override
  String get vmDropHere => 'Drop image here';

  @override
  String get galleryDeleteTitle => 'Delete image?';

  @override
  String get galleryDeleteContent =>
      'This will permanently remove the image from storage.';

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
  String get lensLabel => 'Lens';

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
  String get info => 'Info';

  @override
  String get measurementsModuleTitle => 'Measurements Module';

  @override
  String get measurementsModuleSubtitle =>
      'Measurement functionality will be implemented here';

  @override
  String get cameraRequiredTitle => 'Camera Required';

  @override
  String get cameraRequiredContent =>
      'Camera access has been permanently denied. Please enable it in your system settings to use this feature.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get platformNotSupported => 'Platform not supported';

  @override
  String get placeReferenceHere => 'Place the reference here';

  @override
  String get cameraPermissionRequired => 'Camera Permission Required';

  @override
  String get cameraPermissionExplain =>
      'We need camera access to detect faces and reference markers.';

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
  String get shareResults => 'Share Results';

  @override
  String get calibration => 'Calibration';

  @override
  String get editMode => 'Edit Mode';

  @override
  String get zoomMode => 'Zoom Mode';

  @override
  String get resetZoom => 'Reset Zoom';

  @override
  String get horizontalAdjustment => 'Horizontal Adjustment';

  @override
  String get verticalAdjustment => 'Vertical Adjustment';

  @override
  String get measurementsResultsTitle => 'Results';

  @override
  String get copyLabel => 'Copy';

  @override
  String get shareLabel => 'Share';

  @override
  String get measurementsShareSubject => 'Measurements';

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
  String get takeOrSelectStart =>
      'Take a photo or select from Gallery to get started';

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

  @override
  String get simCatMyopia => 'Myopia';

  @override
  String get simCatMyopiaDesc =>
      'Difficulty seeing distant objects clearly (nearsightedness)';

  @override
  String get simCatPresbyopia => 'Presbyopia';

  @override
  String get simCatPresbyopiaDesc =>
      'Difficulty seeing nearby objects clearly (presbyopia)';

  @override
  String get simSceneKitchen => 'Kitchen';

  @override
  String get simSceneMarket => 'Market';

  @override
  String get simSceneGrocery => 'Grocery';

  @override
  String get simSceneClothingStore => 'Clothing Store';

  @override
  String get simLensMonofocalNear => 'Monofocal Near';

  @override
  String get simLensMonofocalFar => 'Monofocal Far';

  @override
  String get simCatMultifocal => 'Multifocal';

  @override
  String get simCatMultifocalDesc => 'Progressive lens quality comparison';

  @override
  String get simSceneClothing => 'Clothing';

  @override
  String get simQualityEconomy => 'Economy';

  @override
  String get simQualityStandard => 'Standard';

  @override
  String get simQualityGood => 'Good';

  @override
  String get simQualityPremium => 'Premium';

  @override
  String get simCatBifocal => 'Bifocal';

  @override
  String get simCatBifocalDesc =>
      'Comparison between bifocal and multifocal lenses';

  @override
  String get simSceneOffice => 'Office';

  @override
  String get simSceneDriving => 'Driving';

  @override
  String get simLensInvisibleBifocal => 'Invisible Bifocal';

  @override
  String get simLensMultifocal => 'Multifocal';

  @override
  String get simCatPolarized => 'Polarized';

  @override
  String get simCatPolarizedDesc => 'Reduction of reflections and glare';

  @override
  String get simSceneGolf => 'Golf';

  @override
  String get simSceneBeach => 'Beach';

  @override
  String get simSceneTennis => 'Tennis';

  @override
  String get simSceneYacht => 'Yacht';

  @override
  String get simSceneMotorcycle => 'Motorcycle';

  @override
  String get simCatAntiReflective => 'Anti-Reflective';

  @override
  String get simCatAntiReflectiveDesc =>
      'Reduction of lens reflections and better clarity';

  @override
  String get simSceneBaseball => 'Baseball';

  @override
  String get simSceneBasketball => 'Basketball';

  @override
  String get simSceneSoccer => 'Soccer';

  @override
  String get simSceneConcert => 'Concert';

  @override
  String get simSceneBridge => 'Bridge';

  @override
  String get simCatDriveWear => 'DriveWear';

  @override
  String get simCatDriveWearDesc =>
      'Lenses optimized for driving in different conditions';

  @override
  String get simSceneDrivingSunny => 'Driving (Sunny)';

  @override
  String get simSceneDrivingCloudy => 'Driving (Cloudy)';

  @override
  String get simSceneGolfSunny => 'Golf (Sunny)';

  @override
  String get simSceneGolfCloudy => 'Golf (Cloudy)';

  @override
  String get simSceneBeachSunny => 'Beach (Sunny)';

  @override
  String get simSceneBeachCloudy => 'Beach (Cloudy)';

  @override
  String get simSceneMotorcycleSunny => 'Motorcycle (Sunny)';

  @override
  String get simSceneMotorcycleCloudy => 'Motorcycle (Cloudy)';

  @override
  String get simSceneTennisSunny => 'Tennis (Sunny)';

  @override
  String get simSceneTennisCloudy => 'Tennis (Cloudy)';

  @override
  String get simSceneYachtSunny => 'Yacht (Sunny)';

  @override
  String get simSceneYachtCloudy => 'Yacht (Cloudy)';

  @override
  String get simCatPhotochromic => 'Photochromic';

  @override
  String get simCatPhotochromicDesc => 'Lenses that adapt to light conditions';

  @override
  String get simSceneOpticStore => 'Optic Store';

  @override
  String get simColorGray => 'Gray';

  @override
  String get simColorBrown => 'Brown';

  @override
  String get simColorGreen => 'Green';

  @override
  String get simColorSunBalance => 'SunBalance';

  @override
  String get simCatSolar => 'Solar';

  @override
  String get simCatSolarDesc => 'Sun protection with anti-reflective coating';

  @override
  String get simSceneBeach2 => 'Beach 2';

  @override
  String get simSceneCar => 'Car';

  @override
  String get simLensWithAR => 'With AR';

  @override
  String get simCatTint => 'Tint';

  @override
  String get simCatTintDesc =>
      'Customizable lens tints for different environments';

  @override
  String get simColorYellow => 'Yellow';

  @override
  String get simColorAqua => 'Aqua';

  @override
  String get simColorBlue => 'Blue';

  @override
  String get simColorOrange => 'Orange';

  @override
  String get simColorRed => 'Red';

  @override
  String get activationTitle => 'Device Activation';

  @override
  String get activationEnterEmail =>
      'Please enter your email to request access.';

  @override
  String get activationEmailLabel => 'Email';

  @override
  String get activationRequestAccess => 'Request Access';

  @override
  String get activationAwaitingApproval => 'Awaiting Approval';

  @override
  String activationPendingMessage(String email) {
    return 'Your request for device activation is pending approval.\nEmail: $email';
  }

  @override
  String get activationRefreshStatus => 'Refresh';

  @override
  String get activationConnectionRequired => 'Connection Required';

  @override
  String get activationOfflineLimitReached => 'Offline usage limit reached.';

  @override
  String get activationRetryConnection => 'Retry Connection';

  @override
  String get activationErrorTitle => 'Error';

  @override
  String get activationEmailInvalid => 'Please enter a valid email';

  @override
  String get activationRequestExists =>
      'Request already exists for this email.';

  @override
  String get activationNoInternet =>
      'No internet connection and not previously activated.';

  @override
  String get activationConnectionTimeout =>
      'Connection timed out. Please check your internet.';

  @override
  String get nativeSplitGalleryOnlyHint =>
      'Tap the bottom button to open the camera\nor select a photo from your gallery';

  @override
  String get nativeSplitModeGallery => 'Gallery';

  @override
  String get nativeSplitModeCamera => 'Camera';

  @override
  String get lensType => 'Lens Type';

  @override
  String get simCatAspheric => 'Aspheric';

  @override
  String get simCatAsphericDesc => 'Slimmer and flatter lens design';

  @override
  String get simCatBlueFilter => 'Blue Filter';

  @override
  String get simCatBlueFilterDesc => 'Protection against blue light';

  @override
  String get simCatMonofocal => 'Monofocal';

  @override
  String get simCatMonofocalDesc =>
      'Vision correction with a single focal point';
}
