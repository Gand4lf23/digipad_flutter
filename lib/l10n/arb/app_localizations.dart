import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Digipad'**
  String get appTitle;

  /// No description provided for @menuVirtualMirror.
  ///
  /// In en, this message translates to:
  /// **'Virtual Mirror'**
  String get menuVirtualMirror;

  /// No description provided for @menuSimulations.
  ///
  /// In en, this message translates to:
  /// **'Simulations'**
  String get menuSimulations;

  /// No description provided for @menuLenses3D.
  ///
  /// In en, this message translates to:
  /// **'Lenses 3D'**
  String get menuLenses3D;

  /// No description provided for @menuCosmeticLenses.
  ///
  /// In en, this message translates to:
  /// **'Cosmetic Lenses'**
  String get menuCosmeticLenses;

  /// No description provided for @menuMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get menuMeasurements;

  /// No description provided for @menuVisualHealth.
  ///
  /// In en, this message translates to:
  /// **'Visual Health'**
  String get menuVisualHealth;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @dialogNavigatingContent.
  ///
  /// In en, this message translates to:
  /// **'Navigating to the {module} module.'**
  String dialogNavigatingContent(String module);

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @vmNoImages.
  ///
  /// In en, this message translates to:
  /// **'No images loaded yet.\nCapture one or select from your gallery to get started!'**
  String get vmNoImages;

  /// No description provided for @vmDragAndDrop.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop photos'**
  String get vmDragAndDrop;

  /// No description provided for @vmPickOrTake.
  ///
  /// In en, this message translates to:
  /// **'Please pick a photo from your gallery or take a new one'**
  String get vmPickOrTake;

  /// No description provided for @vmDropHere.
  ///
  /// In en, this message translates to:
  /// **'Drop image here'**
  String get vmDropHere;

  /// No description provided for @galleryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete image?'**
  String get galleryDeleteTitle;

  /// No description provided for @galleryDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove the image from storage.'**
  String get galleryDeleteContent;

  /// No description provided for @vhNoTests.
  ///
  /// In en, this message translates to:
  /// **'No tests loaded yet.'**
  String get vhNoTests;

  /// No description provided for @vhSelectTest.
  ///
  /// In en, this message translates to:
  /// **'Select a visual health test'**
  String get vhSelectTest;

  /// No description provided for @vhTestSummary.
  ///
  /// In en, this message translates to:
  /// **'Test {index} of {total}'**
  String vhTestSummary(int index, int total);

  /// No description provided for @vhSelectAbove.
  ///
  /// In en, this message translates to:
  /// **'Select a test from the gallery above'**
  String get vhSelectAbove;

  /// No description provided for @lensThicknessSimulator.
  ///
  /// In en, this message translates to:
  /// **'Lens Thickness Simulator'**
  String get lensThicknessSimulator;

  /// No description provided for @lensConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Lens Configuration'**
  String get lensConfiguration;

  /// No description provided for @materialIndex.
  ///
  /// In en, this message translates to:
  /// **'Material Index'**
  String get materialIndex;

  /// No description provided for @higherIndexHint.
  ///
  /// In en, this message translates to:
  /// **'Higher index = thinner lens'**
  String get higherIndexHint;

  /// No description provided for @prescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get prescription;

  /// No description provided for @rangeDiopters.
  ///
  /// In en, this message translates to:
  /// **'Range: {min}-{max} diopters'**
  String rangeDiopters(int min, int max);

  /// No description provided for @frameType.
  ///
  /// In en, this message translates to:
  /// **'Frame Type'**
  String get frameType;

  /// No description provided for @imageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get imageNotAvailable;

  /// No description provided for @tryDifferentSettings.
  ///
  /// In en, this message translates to:
  /// **'Try different settings'**
  String get tryDifferentSettings;

  /// No description provided for @fullView.
  ///
  /// In en, this message translates to:
  /// **'Full View'**
  String get fullView;

  /// No description provided for @detailView.
  ///
  /// In en, this message translates to:
  /// **'Detail View'**
  String get detailView;

  /// No description provided for @lensSimulatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Lens Simulator'**
  String get lensSimulatorTitle;

  /// No description provided for @refractiveConditions.
  ///
  /// In en, this message translates to:
  /// **'Refractive conditions'**
  String get refractiveConditions;

  /// No description provided for @lensTreatments.
  ///
  /// In en, this message translates to:
  /// **'Lens Treatments'**
  String get lensTreatments;

  /// No description provided for @withoutLens.
  ///
  /// In en, this message translates to:
  /// **'Without lens'**
  String get withoutLens;

  /// No description provided for @scenesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} scenes'**
  String scenesCount(int count);

  /// No description provided for @lensesAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} lenses available'**
  String lensesAvailable(int count);

  /// No description provided for @selectLensLabel.
  ///
  /// In en, this message translates to:
  /// **'Select a lens:'**
  String get selectLensLabel;

  /// No description provided for @dividerLabel.
  ///
  /// In en, this message translates to:
  /// **'Divider'**
  String get dividerLabel;

  /// No description provided for @lensLabel.
  ///
  /// In en, this message translates to:
  /// **'Lens'**
  String get lensLabel;

  /// No description provided for @verticalLabel.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get verticalLabel;

  /// No description provided for @horizontalLabel.
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get horizontalLabel;

  /// No description provided for @dragDivider.
  ///
  /// In en, this message translates to:
  /// **'Drag the divider'**
  String get dragDivider;

  /// No description provided for @loadingSimulation.
  ///
  /// In en, this message translates to:
  /// **'Loading simulation...'**
  String get loadingSimulation;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @measurementsModuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurements Module'**
  String get measurementsModuleTitle;

  /// No description provided for @measurementsModuleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Measurement functionality will be implemented here'**
  String get measurementsModuleSubtitle;

  /// No description provided for @cameraRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Required'**
  String get cameraRequiredTitle;

  /// No description provided for @cameraRequiredContent.
  ///
  /// In en, this message translates to:
  /// **'Camera access has been permanently denied. Please enable it in your system settings to use this feature.'**
  String get cameraRequiredContent;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @platformNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Platform not supported'**
  String get platformNotSupported;

  /// No description provided for @placeReferenceHere.
  ///
  /// In en, this message translates to:
  /// **'Place the reference here'**
  String get placeReferenceHere;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get cameraPermissionRequired;

  /// No description provided for @cameraPermissionExplain.
  ///
  /// In en, this message translates to:
  /// **'We need camera access to detect faces and reference markers.'**
  String get cameraPermissionExplain;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @detectionIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Detection incomplete. Found {found}/4 circles. Please try a clearer image.'**
  String detectionIncomplete(int found);

  /// No description provided for @captureFailed.
  ///
  /// In en, this message translates to:
  /// **'Capture failed: Found {found} circles (4 required). Try adjusting lighting or distance.'**
  String captureFailed(int found);

  /// No description provided for @measureAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Measure Adjustments'**
  String get measureAdjustments;

  /// No description provided for @guides.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get guides;

  /// No description provided for @referenceShort.
  ///
  /// In en, this message translates to:
  /// **'Ref: {ref}'**
  String referenceShort(int ref);

  /// No description provided for @unitMm.
  ///
  /// In en, this message translates to:
  /// **'mm'**
  String get unitMm;

  /// No description provided for @ipdDi.
  ///
  /// In en, this message translates to:
  /// **'IPD (DI)'**
  String get ipdDi;

  /// No description provided for @bridge.
  ///
  /// In en, this message translates to:
  /// **'Bridge'**
  String get bridge;

  /// No description provided for @frameW.
  ///
  /// In en, this message translates to:
  /// **'Frame W'**
  String get frameW;

  /// No description provided for @frameH.
  ///
  /// In en, this message translates to:
  /// **'Frame H'**
  String get frameH;

  /// No description provided for @rightEyeP1.
  ///
  /// In en, this message translates to:
  /// **'Right Eye (P1)'**
  String get rightEyeP1;

  /// No description provided for @leftEyeP2.
  ///
  /// In en, this message translates to:
  /// **'Left Eye (P2)'**
  String get leftEyeP2;

  /// No description provided for @dnpShort.
  ///
  /// In en, this message translates to:
  /// **'DNP: {value}'**
  String dnpShort(String value);

  /// No description provided for @heightShort.
  ///
  /// In en, this message translates to:
  /// **'Alt: {value}'**
  String heightShort(String value);

  /// No description provided for @diamShort.
  ///
  /// In en, this message translates to:
  /// **'Diam: {value}'**
  String diamShort(String value);

  /// No description provided for @shareResults.
  ///
  /// In en, this message translates to:
  /// **'Share Results'**
  String get shareResults;

  /// No description provided for @calibration.
  ///
  /// In en, this message translates to:
  /// **'Calibration'**
  String get calibration;

  /// No description provided for @editMode.
  ///
  /// In en, this message translates to:
  /// **'Edit Mode'**
  String get editMode;

  /// No description provided for @zoomMode.
  ///
  /// In en, this message translates to:
  /// **'Zoom Mode'**
  String get zoomMode;

  /// No description provided for @resetZoom.
  ///
  /// In en, this message translates to:
  /// **'Reset Zoom'**
  String get resetZoom;

  /// No description provided for @horizontalAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Horizontal Adjustment'**
  String get horizontalAdjustment;

  /// No description provided for @verticalAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Vertical Adjustment'**
  String get verticalAdjustment;

  /// No description provided for @measurementsResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get measurementsResultsTitle;

  /// No description provided for @copyLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyLabel;

  /// No description provided for @shareLabel.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareLabel;

  /// No description provided for @measurementsShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurementsShareSubject;

  /// No description provided for @leftEye.
  ///
  /// In en, this message translates to:
  /// **'Left Eye'**
  String get leftEye;

  /// No description provided for @bothEyes.
  ///
  /// In en, this message translates to:
  /// **'Both Eyes'**
  String get bothEyes;

  /// No description provided for @rightEye.
  ///
  /// In en, this message translates to:
  /// **'Right Eye'**
  String get rightEye;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @opacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get opacity;

  /// No description provided for @eyelid.
  ///
  /// In en, this message translates to:
  /// **'Eyelid'**
  String get eyelid;

  /// No description provided for @takeOrSelectStart.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or select from Gallery to get started'**
  String get takeOrSelectStart;

  /// No description provided for @selectBrand.
  ///
  /// In en, this message translates to:
  /// **'Select Brand'**
  String get selectBrand;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @onLabel.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get onLabel;

  /// No description provided for @offLabel.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get offLabel;

  /// No description provided for @detectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Detection'**
  String get detectionLabel;

  /// No description provided for @overlayLabel.
  ///
  /// In en, this message translates to:
  /// **'Overlay'**
  String get overlayLabel;

  /// No description provided for @simCatMyopia.
  ///
  /// In en, this message translates to:
  /// **'Myopia'**
  String get simCatMyopia;

  /// No description provided for @simCatMyopiaDesc.
  ///
  /// In en, this message translates to:
  /// **'Difficulty seeing distant objects clearly (nearsightedness)'**
  String get simCatMyopiaDesc;

  /// No description provided for @simSceneKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get simSceneKitchen;

  /// No description provided for @simSceneMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get simSceneMarket;

  /// No description provided for @simSceneGrocery.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get simSceneGrocery;

  /// No description provided for @simSceneClothingStore.
  ///
  /// In en, this message translates to:
  /// **'Clothing Store'**
  String get simSceneClothingStore;

  /// No description provided for @simLensMonofocalNear.
  ///
  /// In en, this message translates to:
  /// **'Monofocal Near'**
  String get simLensMonofocalNear;

  /// No description provided for @simLensMonofocalFar.
  ///
  /// In en, this message translates to:
  /// **'Monofocal Far'**
  String get simLensMonofocalFar;

  /// No description provided for @simCatMultifocal.
  ///
  /// In en, this message translates to:
  /// **'Multifocal'**
  String get simCatMultifocal;

  /// No description provided for @simCatMultifocalDesc.
  ///
  /// In en, this message translates to:
  /// **'Progressive lens quality comparison'**
  String get simCatMultifocalDesc;

  /// No description provided for @simSceneClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get simSceneClothing;

  /// No description provided for @simQualityEconomy.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get simQualityEconomy;

  /// No description provided for @simQualityStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get simQualityStandard;

  /// No description provided for @simQualityGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get simQualityGood;

  /// No description provided for @simQualityPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get simQualityPremium;

  /// No description provided for @simCatBifocal.
  ///
  /// In en, this message translates to:
  /// **'Bifocal'**
  String get simCatBifocal;

  /// No description provided for @simCatBifocalDesc.
  ///
  /// In en, this message translates to:
  /// **'Comparison between bifocal and multifocal lenses'**
  String get simCatBifocalDesc;

  /// No description provided for @simSceneOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get simSceneOffice;

  /// No description provided for @simSceneDriving.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get simSceneDriving;

  /// No description provided for @simLensInvisibleBifocal.
  ///
  /// In en, this message translates to:
  /// **'Invisible Bifocal'**
  String get simLensInvisibleBifocal;

  /// No description provided for @simLensMultifocal.
  ///
  /// In en, this message translates to:
  /// **'Multifocal'**
  String get simLensMultifocal;

  /// No description provided for @simCatPolarized.
  ///
  /// In en, this message translates to:
  /// **'Polarized'**
  String get simCatPolarized;

  /// No description provided for @simCatPolarizedDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduction of reflections and glare'**
  String get simCatPolarizedDesc;

  /// No description provided for @simSceneGolf.
  ///
  /// In en, this message translates to:
  /// **'Golf'**
  String get simSceneGolf;

  /// No description provided for @simSceneBeach.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get simSceneBeach;

  /// No description provided for @simSceneTennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get simSceneTennis;

  /// No description provided for @simSceneYacht.
  ///
  /// In en, this message translates to:
  /// **'Yacht'**
  String get simSceneYacht;

  /// No description provided for @simSceneMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get simSceneMotorcycle;

  /// No description provided for @simCatAntiReflective.
  ///
  /// In en, this message translates to:
  /// **'Anti-Reflective'**
  String get simCatAntiReflective;

  /// No description provided for @simCatAntiReflectiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduction of lens reflections and better clarity'**
  String get simCatAntiReflectiveDesc;

  /// No description provided for @simSceneBaseball.
  ///
  /// In en, this message translates to:
  /// **'Baseball'**
  String get simSceneBaseball;

  /// No description provided for @simSceneBasketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get simSceneBasketball;

  /// No description provided for @simSceneSoccer.
  ///
  /// In en, this message translates to:
  /// **'Soccer'**
  String get simSceneSoccer;

  /// No description provided for @simSceneConcert.
  ///
  /// In en, this message translates to:
  /// **'Concert'**
  String get simSceneConcert;

  /// No description provided for @simSceneBridge.
  ///
  /// In en, this message translates to:
  /// **'Bridge'**
  String get simSceneBridge;

  /// No description provided for @simCatDriveWear.
  ///
  /// In en, this message translates to:
  /// **'DriveWear'**
  String get simCatDriveWear;

  /// No description provided for @simCatDriveWearDesc.
  ///
  /// In en, this message translates to:
  /// **'Lenses optimized for driving in different conditions'**
  String get simCatDriveWearDesc;

  /// No description provided for @simSceneDrivingSunny.
  ///
  /// In en, this message translates to:
  /// **'Driving (Sunny)'**
  String get simSceneDrivingSunny;

  /// No description provided for @simSceneDrivingCloudy.
  ///
  /// In en, this message translates to:
  /// **'Driving (Cloudy)'**
  String get simSceneDrivingCloudy;

  /// No description provided for @simSceneGolfSunny.
  ///
  /// In en, this message translates to:
  /// **'Golf (Sunny)'**
  String get simSceneGolfSunny;

  /// No description provided for @simSceneGolfCloudy.
  ///
  /// In en, this message translates to:
  /// **'Golf (Cloudy)'**
  String get simSceneGolfCloudy;

  /// No description provided for @simSceneBeachSunny.
  ///
  /// In en, this message translates to:
  /// **'Beach (Sunny)'**
  String get simSceneBeachSunny;

  /// No description provided for @simSceneBeachCloudy.
  ///
  /// In en, this message translates to:
  /// **'Beach (Cloudy)'**
  String get simSceneBeachCloudy;

  /// No description provided for @simSceneMotorcycleSunny.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle (Sunny)'**
  String get simSceneMotorcycleSunny;

  /// No description provided for @simSceneMotorcycleCloudy.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle (Cloudy)'**
  String get simSceneMotorcycleCloudy;

  /// No description provided for @simSceneTennisSunny.
  ///
  /// In en, this message translates to:
  /// **'Tennis (Sunny)'**
  String get simSceneTennisSunny;

  /// No description provided for @simSceneTennisCloudy.
  ///
  /// In en, this message translates to:
  /// **'Tennis (Cloudy)'**
  String get simSceneTennisCloudy;

  /// No description provided for @simSceneYachtSunny.
  ///
  /// In en, this message translates to:
  /// **'Yacht (Sunny)'**
  String get simSceneYachtSunny;

  /// No description provided for @simSceneYachtCloudy.
  ///
  /// In en, this message translates to:
  /// **'Yacht (Cloudy)'**
  String get simSceneYachtCloudy;

  /// No description provided for @simCatPhotochromic.
  ///
  /// In en, this message translates to:
  /// **'Photochromic'**
  String get simCatPhotochromic;

  /// No description provided for @simCatPhotochromicDesc.
  ///
  /// In en, this message translates to:
  /// **'Lenses that adapt to light conditions'**
  String get simCatPhotochromicDesc;

  /// No description provided for @simSceneOpticStore.
  ///
  /// In en, this message translates to:
  /// **'Optic Store'**
  String get simSceneOpticStore;

  /// No description provided for @simColorGray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get simColorGray;

  /// No description provided for @simColorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get simColorBrown;

  /// No description provided for @simColorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get simColorGreen;

  /// No description provided for @simColorSunBalance.
  ///
  /// In en, this message translates to:
  /// **'SunBalance'**
  String get simColorSunBalance;

  /// No description provided for @simCatSolar.
  ///
  /// In en, this message translates to:
  /// **'Solar'**
  String get simCatSolar;

  /// No description provided for @simCatSolarDesc.
  ///
  /// In en, this message translates to:
  /// **'Sun protection with anti-reflective coating'**
  String get simCatSolarDesc;

  /// No description provided for @simSceneBeach2.
  ///
  /// In en, this message translates to:
  /// **'Beach 2'**
  String get simSceneBeach2;

  /// No description provided for @simSceneCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get simSceneCar;

  /// No description provided for @simLensWithAR.
  ///
  /// In en, this message translates to:
  /// **'With AR'**
  String get simLensWithAR;

  /// No description provided for @simCatTint.
  ///
  /// In en, this message translates to:
  /// **'Tint'**
  String get simCatTint;

  /// No description provided for @simCatTintDesc.
  ///
  /// In en, this message translates to:
  /// **'Customizable lens tints for different environments'**
  String get simCatTintDesc;

  /// No description provided for @simColorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get simColorYellow;

  /// No description provided for @simColorAqua.
  ///
  /// In en, this message translates to:
  /// **'Aqua'**
  String get simColorAqua;

  /// No description provided for @simColorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get simColorBlue;

  /// No description provided for @simColorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get simColorOrange;

  /// No description provided for @simColorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get simColorRed;

  /// No description provided for @activationTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Activation'**
  String get activationTitle;

  /// No description provided for @activationEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email to request access.'**
  String get activationEnterEmail;

  /// No description provided for @activationEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get activationEmailLabel;

  /// No description provided for @activationRequestAccess.
  ///
  /// In en, this message translates to:
  /// **'Request Access'**
  String get activationRequestAccess;

  /// No description provided for @activationAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Approval'**
  String get activationAwaitingApproval;

  /// No description provided for @activationPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your request for device activation is pending approval.\nEmail: {email}'**
  String activationPendingMessage(String email);

  /// No description provided for @activationRefreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get activationRefreshStatus;

  /// No description provided for @activationConnectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Connection Required'**
  String get activationConnectionRequired;

  /// No description provided for @activationOfflineLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Offline usage limit reached.'**
  String get activationOfflineLimitReached;

  /// No description provided for @activationRetryConnection.
  ///
  /// In en, this message translates to:
  /// **'Retry Connection'**
  String get activationRetryConnection;

  /// No description provided for @activationErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get activationErrorTitle;

  /// No description provided for @activationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get activationEmailInvalid;

  /// No description provided for @activationRequestExists.
  ///
  /// In en, this message translates to:
  /// **'Request already exists for this email.'**
  String get activationRequestExists;

  /// No description provided for @activationNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection and not previously activated.'**
  String get activationNoInternet;

  /// No description provided for @activationConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please check your internet.'**
  String get activationConnectionTimeout;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
