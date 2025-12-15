import 'package:flutter/material.dart';

import '../models/simulation_scenario.dart';

/// Repository of all simulation categories and their scenarios.
///
/// IMPORTANT: For each scenario, the problemImagePath and correctedImagePath
/// must be the SAME SCENE with different visual effects applied.
class SimulationData {
  static const String _basePath = 'assets/images/simulations';

  /// All available simulation categories.
  static final List<SimulationCategory> categories = [
    _myopiaCategory,
    _multifocalCategory,
    //_presbyopiaCategory,
    _bifocalCategory,
    _polarizedCategory,
    _antiReflexCategory,
    _driveCategory,
    _photochromicCategory,
    _solarCategory,
    _tintCategory,
  ];

  // ===================== MYOPIA (with Monofocal lenses) =====================
  // Shows blurred distance vision corrected with monofocal lenses
  static final SimulationCategory _myopiaCategory = SimulationCategory(
    id: 'myopia',
    name: 'myopia',
    displayName: 'Myopia',
    description: 'Difficulty seeing distant objects clearly (nearsightedness)',
    scenarios: [
      // Kitchen scene
      SimulationScenario(
        id: 'myopia_kitchen',
        sceneName: 'kitchen',
        displayName: 'Kitchen',
        problemImagePath: '$_basePath/myopia/myopia_kitchen_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'myopia_kitchen_near',
            name: 'monofocal_near',
            displayName: 'Monofocal Near',
            correctedImagePath: '$_basePath/myopia/myopia_kitchen_close.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'myopia_kitchen_far',
            name: 'monofocal_far',
            displayName: 'Monofocal Far',
            correctedImagePath: '$_basePath/myopia/myopia_kitchen_far.jpg',
            quality: LensQuality.good,
          ),
        ],
      ),
      // Market scene (Store)
      SimulationScenario(
        id: 'myopia_market',
        sceneName: 'market',
        displayName: 'Market',
        problemImagePath: '$_basePath/myopia/myopia_market_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'myopia_market_near',
            name: 'monofocal_near',
            displayName: 'Monofocal Near',
            correctedImagePath: '$_basePath/myopia/myopia_market_close.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'myopia_market_far',
            name: 'monofocal_far',
            displayName: 'Monofocal Far',
            correctedImagePath: '$_basePath/myopia/myopia_market_far.jpg',
            quality: LensQuality.good,
          ),
        ],
      ),
      // Grocery scene (Supermarket)
      SimulationScenario(
        id: 'myopia_grocery',
        sceneName: 'grocery',
        displayName: 'Grocery',
        problemImagePath: '$_basePath/myopia/myopia_grocery_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'myopia_grocery_near',
            name: 'monofocal_near',
            displayName: 'Monofocal Near',
            correctedImagePath: '$_basePath/myopia/myopia_grocery_close.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'myopia_grocery_far',
            name: 'monofocal_far',
            displayName: 'Monofocal Far',
            correctedImagePath: '$_basePath/myopia/myopia_grocery_far.jpg',
            quality: LensQuality.good,
          ),
        ],
      ),
      // Clothing scene
      SimulationScenario(
        id: 'myopia_clothing',
        sceneName: 'clothing',
        displayName: 'Clothing Store',
        problemImagePath: '$_basePath/myopia/myopia_clothing_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'myopia_clothing_near',
            name: 'monofocal_near',
            displayName: 'Monofocal Near',
            correctedImagePath: '$_basePath/myopia/myopia_clothing_close.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'myopia_clothing_far',
            name: 'monofocal_far',
            displayName: 'Monofocal Far',
            correctedImagePath: '$_basePath/myopia/myopia_clothing_far.jpg',
            quality: LensQuality.good,
          ),
        ],
      ),
    ],
  );

  // ===================== MULTIFOCAL =====================
  // Progressive lens quality comparison (Economy, Standard, Good, Premium)
  static final SimulationCategory _multifocalCategory = SimulationCategory(
    id: 'multifocal',
    name: 'multifocal',
    displayName: 'Multifocal',
    description: 'Progressive lens quality comparison',
    scenarios: [
      // Kitchen 2
      SimulationScenario(
        id: 'multifocal_kitchen2',
        sceneName: 'kitchen',
        displayName: 'Kitchen',
        problemImagePath: '$_basePath/multifocal/kitchen2.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'multifocal_kitchen2_economic',
            name: 'economic',
            displayName: 'Economy',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_economic_kitchen2.jpg',
            quality: LensQuality.economy,
          ),
          CorrectionLens(
            id: 'multifocal_kitchen2_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_standard_kitchen2.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'multifocal_kitchen2_good',
            name: 'good',
            displayName: 'Good',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_good_kitchen2.jpg',
            quality: LensQuality.good,
          ),
          CorrectionLens(
            id: 'multifocal_kitchen2_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_premium_kitchen2.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Market
      SimulationScenario(
        id: 'multifocal_market',
        sceneName: 'market',
        displayName: 'Market',
        problemImagePath: '$_basePath/multifocal/market.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'multifocal_market_economic',
            name: 'economic',
            displayName: 'Economy',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_economic_market.jpg',
            quality: LensQuality.economy,
          ),
          CorrectionLens(
            id: 'multifocal_market_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_standard_market.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'multifocal_market_good',
            name: 'good',
            displayName: 'Good',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_good_market.jpg',
            quality: LensQuality.good,
          ),
          CorrectionLens(
            id: 'multifocal_market_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_premium_market.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Clothing
      SimulationScenario(
        id: 'multifocal_clothing',
        sceneName: 'clothing',
        displayName: 'Clothing',
        problemImagePath: '$_basePath/multifocal/clothing.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'multifocal_clothing_economic',
            name: 'economic',
            displayName: 'Economy',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_economic_clothing.jpg',
            quality: LensQuality.economy,
          ),
          CorrectionLens(
            id: 'multifocal_clothing_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_standard_clothing.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'multifocal_clothing_good',
            name: 'good',
            displayName: 'Good',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_good_clothing.jpg',
            quality: LensQuality.good,
          ),
          CorrectionLens(
            id: 'multifocal_clothing_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_premium_clothing.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
    ],
  );

  /*// ===================== PRESBYOPIA =====================
  static final SimulationCategory _presbyopiaCategory = SimulationCategory(
    id: 'presbyopia',
    name: 'presbyopia',
    displayName: 'Presbyopia',
    description:
        'Difficulty focusing on close objects (age-related farsightedness)',
    scenarios: [
      SimulationScenario(
        id: 'presbyopia_kitchen',
        sceneName: 'kitchen',
        displayName: 'Kitchen',
        problemImagePath: '$_basePath/presbicia/PresbiciaCocina.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'presbyopia_kitchen_progressive',
            name: 'progressive',
            displayName: 'Progressive Lens',
            correctedImagePath: '$_basePath/presbicia/presbicia_cocina.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      SimulationScenario(
        id: 'presbyopia_supermarket',
        sceneName: 'supermarket',
        displayName: 'Supermarket',
        problemImagePath: '$_basePath/presbicia/PresbiciaSuper.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'presbyopia_super_progressive',
            name: 'progressive',
            displayName: 'Progressive Lens',
            correctedImagePath: '$_basePath/presbicia/presbicia_almacen.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      SimulationScenario(
        id: 'presbyopia_store',
        sceneName: 'store',
        displayName: 'Store',
        problemImagePath: '$_basePath/presbicia/PresbiciaTienda.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'presbyopia_store_progressive',
            name: 'progressive',
            displayName: 'Progressive Lens',
            correctedImagePath: '$_basePath/presbicia/presbicia_oficina.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
    ],
  );*/

  // ===================== BIFOCAL =====================
  static final SimulationCategory _bifocalCategory = SimulationCategory(
    id: 'bifocal',
    name: 'bifocal',
    displayName: 'Bifocal',
    description: 'Comparison between bifocal and multifocal lenses',
    scenarios: [
      SimulationScenario(
        id: 'bifocal_office',
        sceneName: 'office',
        displayName: 'Office',
        problemImagePath: '$_basePath/bifocal/BifocalOficina.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'bifocal_office_invisible',
            name: 'invisible',
            displayName: 'Invisible Bifocal',
            correctedImagePath:
                '$_basePath/bifocal/BifocalOficinaInvisible.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'bifocal_office_multifocal',
            name: 'multifocal',
            displayName: 'Multifocal',
            correctedImagePath:
                '$_basePath/bifocal/BifocalOficinaMultifocal.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      SimulationScenario(
        id: 'bifocal_driving',
        sceneName: 'driving',
        displayName: 'Driving',
        problemImagePath: '$_basePath/bifocal/BifocalManejando.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'bifocal_driving_multifocal',
            name: 'multifocal',
            displayName: 'Multifocal',
            correctedImagePath:
                '$_basePath/bifocal/BifocalManejandoMultifocal.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
    ],
  );

  // ===================== POLARIZED =====================
  static final SimulationCategory _polarizedCategory = SimulationCategory(
    id: 'polarized',
    name: 'polarized',
    displayName: 'Polarized',
    description: 'Reduction of reflections and glare',
    scenarios: [
      // Golf
      SimulationScenario(
        id: 'polarized_golf',
        sceneName: 'golf',
        displayName: 'Golf',
        problemImagePath: '$_basePath/polarized/polarized_golf_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'polarized_golf_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/polarized/polarized_golf_standard.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'polarized_golf_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/polarized/polarized_golf_premium.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Driving
      SimulationScenario(
        id: 'polarized_driving',
        sceneName: 'driving',
        displayName: 'Driving',
        problemImagePath: '$_basePath/polarized/polarized_driving_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'polarized_driving_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/polarized/polarized_driving_standard.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'polarized_driving_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/polarized/polarized_driving_premium.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Beach
      SimulationScenario(
        id: 'polarized_beach',
        sceneName: 'beach',
        displayName: 'Beach',
        problemImagePath: '$_basePath/polarized/polarized_beach_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'polarized_beach_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/polarized/polarized_beach_standard.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'polarized_beach_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/polarized/polarized_beach_premium.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Tennis
      SimulationScenario(
        id: 'polarized_tennis',
        sceneName: 'tennis',
        displayName: 'Tennis',
        problemImagePath: '$_basePath/polarized/polarized_tennis_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'polarized_tennis_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/polarized/polarized_tennis_standard.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'polarized_tennis_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/polarized/polarized_tennis_premium.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Yacht
      SimulationScenario(
        id: 'polarized_yacht',
        sceneName: 'yacht',
        displayName: 'Yacht',
        problemImagePath: '$_basePath/polarized/polarized_yacht_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'polarized_yacht_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/polarized/polarized_yatch_standard.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'polarized_yacht_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/polarized/polarized_yatch_premium.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Motorcycle
      SimulationScenario(
        id: 'polarized_moto',
        sceneName: 'motorcycle',
        displayName: 'Motorcycle',
        problemImagePath:
            '$_basePath/polarized/polarized_motorcycle_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'polarized_moto_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/polarized/polarized_motorcycle_standard.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'polarized_moto_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/polarized/polarized_motorcycle_premium.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
    ],
  );

  // ===================== ANTI-REFLECTIVE =====================
  static final SimulationCategory _antiReflexCategory = SimulationCategory(
    id: 'anti_reflex',
    name: 'anti_reflective',
    displayName: 'Anti-Reflective',
    description: 'Reduction of lens reflections and better clarity',
    scenarios: [
      // Driving - with AR options
      SimulationScenario(
        id: 'ar_driving',
        sceneName: 'driving',
        displayName: 'Driving',
        problemImagePath:
            '$_basePath/anti_reflex/anti_reflection_driving_noLense.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_driving_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_driving_standard.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_driving_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_driving_premium.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Baseball
      SimulationScenario(
        id: 'ar_baseball',
        sceneName: 'baseball',
        displayName: 'Baseball',
        problemImagePath:
            '$_basePath/anti_reflex/anti_reflection_baseball_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_baseball_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_baseball_standard.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_baseball_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_baseball_premium.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Basketball
      SimulationScenario(
        id: 'ar_basketball',
        sceneName: 'basketball',
        displayName: 'Basketball',
        problemImagePath:
            '$_basePath/anti_reflex/anti_reflection_basket_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_basket_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_basket_standard.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_basket_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_basket_premium.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Soccer
      SimulationScenario(
        id: 'ar_soccer',
        sceneName: 'soccer',
        displayName: 'Soccer',
        problemImagePath:
            '$_basePath/anti_reflex/anti_reflection_soccer_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_soccer_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_soccer_standard.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_soccer_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_soccer_premium.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Tennis
      SimulationScenario(
        id: 'ar_tennis',
        sceneName: 'tennis',
        displayName: 'Tennis',
        problemImagePath:
            '$_basePath/anti_reflex/anti_reflection_tennis_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_tennis_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_tennis_standard.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_tennis_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_tennis_premium.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Concert
      SimulationScenario(
        id: 'ar_concert',
        sceneName: 'concert',
        displayName: 'Concert',
        problemImagePath:
            '$_basePath/anti_reflex/anti_reflection_concert_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_concert_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_concert_standard.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_concert_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_concert_premium.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Bridge
      SimulationScenario(
        id: 'ar_bridge',
        sceneName: 'bridge',
        displayName: 'Bridge',
        problemImagePath:
            '$_basePath/anti_reflex/anti_reflection_bridge_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_bridge_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_bridge_standard.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_bridge_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_bridge_premium.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
    ],
  );

  // ===================== DRIVE =====================
  static final SimulationCategory _driveCategory = SimulationCategory(
    id: 'drive',
    name: 'drive',
    displayName: 'DriveWear',
    description: 'Lenses optimized for driving in different conditions',
    scenarios: [
      // Driving Sunny
      SimulationScenario(
        id: 'drive_driving_sunny',
        sceneName: 'driving_sunny',
        displayName: 'Driving (Sunny)',
        problemImagePath: '$_basePath/drive/DriveManejandoSoleadoSin.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_driving_sunny_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveManejandoSoleado.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Driving Cloudy
      SimulationScenario(
        id: 'drive_driving_cloudy',
        sceneName: 'driving_cloudy',
        displayName: 'Driving (Cloudy)',
        problemImagePath: '$_basePath/drive/DriveManejandoNubladoSin.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_driving_cloudy_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveManejandoNublado.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Golf Sunny
      SimulationScenario(
        id: 'drive_golf_sunny',
        sceneName: 'golf_sunny',
        displayName: 'Golf (Sunny)',
        problemImagePath: '$_basePath/drive/DriveGolfSoleadoSin.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_golf_sunny_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveGolfSoleado.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Golf Cloudy
      SimulationScenario(
        id: 'drive_golf_cloudy',
        sceneName: 'golf_cloudy',
        displayName: 'Golf (Cloudy)',
        problemImagePath: '$_basePath/drive/DriveGolfNubladoSin.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_golf_cloudy_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveGolfNublado.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Beach Sunny
      SimulationScenario(
        id: 'drive_beach_sunny',
        sceneName: 'beach_sunny',
        displayName: 'Beach (Sunny)',
        problemImagePath: '$_basePath/drive/DrivePlayaSoleadoSin.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_beach_sunny_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DrivePlayaSoleado.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Beach Cloudy
      SimulationScenario(
        id: 'drive_beach_cloudy',
        sceneName: 'beach_cloudy',
        displayName: 'Beach (Cloudy)',
        problemImagePath: '$_basePath/drive/DrivePlayaNubladoSin.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_beach_cloudy_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DrivePlayaNublado.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Motorcycle Sunny
      SimulationScenario(
        id: 'drive_moto_sunny',
        sceneName: 'motorcycle_sunny',
        displayName: 'Motorcycle (Sunny)',
        problemImagePath: '$_basePath/drive/DriveMotoSoleadoSin.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_moto_sunny_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveMotoSoleado.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Motorcycle Cloudy
      SimulationScenario(
        id: 'drive_moto_cloudy',
        sceneName: 'motorcycle_cloudy',
        displayName: 'Motorcycle (Cloudy)',
        problemImagePath: '$_basePath/drive/DriveMotoNubladoSin.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_moto_cloudy_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveMotoNublado.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Tennis Sunny
      SimulationScenario(
        id: 'drive_tennis_sunny',
        sceneName: 'tennis_sunny',
        displayName: 'Tennis (Sunny)',
        problemImagePath: '$_basePath/drive/DriveTenisSoleadoSin.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_tennis_sunny_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveTenisSoleado.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Tennis Cloudy
      SimulationScenario(
        id: 'drive_tennis_cloudy',
        sceneName: 'tennis_cloudy',
        displayName: 'Tennis (Cloudy)',
        problemImagePath: '$_basePath/drive/DriveTenisNubladoSin.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_tennis_cloudy_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveTenisNublado.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Yacht Sunny
      SimulationScenario(
        id: 'drive_yacht_sunny',
        sceneName: 'yacht_sunny',
        displayName: 'Yacht (Sunny)',
        problemImagePath: '$_basePath/drive/DriveYateSoleladoSin.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_yacht_sunny_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveYateSolelado.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Yacht Cloudy
      SimulationScenario(
        id: 'drive_yacht_cloudy',
        sceneName: 'yacht_cloudy',
        displayName: 'Yacht (Cloudy)',
        problemImagePath: '$_basePath/drive/DriveYateNubladoSin.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_yacht_cloudy_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveYateNublado.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
    ],
  );

  // ===================== PHOTOCHROMIC =====================
  static final SimulationCategory _photochromicCategory = SimulationCategory(
    id: 'photochromic',
    name: 'photochromic',
    displayName: 'Photochromic',
    description: 'Lenses that adapt to light conditions',
    scenarios: [
      // Indoor (Optic)
      SimulationScenario(
        id: 'photo_optic',
        sceneName: 'optic',
        displayName: 'Optic Store',
        problemImagePath: '$_basePath/photochromic/photochromic_optic_off.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'photo_optic_gray',
            name: 'gray',
            displayName: 'Gray',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_optic_on.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'photo_optic_brown',
            name: 'brown',
            displayName: 'Brown',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_optic_on_brown.jpg',
            quality: LensQuality.good,
          ),
          CorrectionLens(
            id: 'photo_optic_green',
            name: 'green',
            displayName: 'Green',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_optic_on_green.jpg',
            quality: LensQuality.good,
          ),
          CorrectionLens(
            id: 'photo_optic_sunbalance',
            name: 'sunbalance',
            displayName: 'SunBalance',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_optic_on_sunbalance.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Beach
      SimulationScenario(
        id: 'photo_beach',
        sceneName: 'beach',
        displayName: 'Beach',
        problemImagePath: '$_basePath/photochromic/photochromic_beach_off.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'photo_beach_gray',
            name: 'gray',
            displayName: 'Gray',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_beach_on_gray.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'photo_beach_brown',
            name: 'brown',
            displayName: 'Brown',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_beach_on_brown.jpg',
            quality: LensQuality.good,
          ),
          CorrectionLens(
            id: 'photo_beach_green',
            name: 'green',
            displayName: 'Green',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_beach_on_green.jpg',
            quality: LensQuality.good,
          ),
        ],
      ),
      // Driving
      SimulationScenario(
        id: 'photo_driving',
        sceneName: 'driving',
        displayName: 'Driving',
        problemImagePath:
            '$_basePath/photochromic/photochromic_driving_off.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'photo_driving_gray',
            name: 'gray',
            displayName: 'Gray',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_driving_on_gray.jpg',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'photo_driving_brown',
            name: 'brown',
            displayName: 'Brown',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_driving_on_brown.jpg',
            quality: LensQuality.good,
          ),
          CorrectionLens(
            id: 'photo_driving_green',
            name: 'green',
            displayName: 'Green',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_driving_on_green.jpg',
            quality: LensQuality.good,
          ),
        ],
      ),
    ],
  );

  // ===================== SOLAR =====================
  static final SimulationCategory _solarCategory = SimulationCategory(
    id: 'solar',
    name: 'solar',
    displayName: 'Solar',
    description: 'Sun protection with anti-reflective coating',
    scenarios: [
      // Beach
      SimulationScenario(
        id: 'solar_beach',
        sceneName: 'beach',
        displayName: 'Beach',
        problemImagePath: '$_basePath/solar/solar_beach_without.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_beach_ar',
            name: 'anti_reflective',
            displayName: 'With AR',
            correctedImagePath: '$_basePath/solar/solar_beach_withAr.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Beach 2
      SimulationScenario(
        id: 'solar_beach2',
        sceneName: 'beach2',
        displayName: 'Beach 2',
        problemImagePath: '$_basePath/solar/solar_beach2_without.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_beach2_ar',
            name: 'anti_reflective',
            displayName: 'With AR',
            correctedImagePath: '$_basePath/solar/solar_beach2_withAr.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Car
      SimulationScenario(
        id: 'solar_car',
        sceneName: 'car',
        displayName: 'Car',
        problemImagePath: '$_basePath/solar/solar_car_without.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_car_ar',
            name: 'anti_reflective',
            displayName: 'With AR',
            correctedImagePath: '$_basePath/solar/solar_car_withAr.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Driving
      SimulationScenario(
        id: 'solar_driving',
        sceneName: 'driving',
        displayName: 'Driving',
        problemImagePath: '$_basePath/solar/solar_driving_without.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_driving_ar',
            name: 'anti_reflective',
            displayName: 'With AR',
            correctedImagePath: '$_basePath/solar/solar_driving_withAr.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Golf
      SimulationScenario(
        id: 'solar_golf',
        sceneName: 'golf',
        displayName: 'Golf',
        problemImagePath: '$_basePath/solar/solar_golf_without.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_golf_ar',
            name: 'anti_reflective',
            displayName: 'With AR',
            correctedImagePath: '$_basePath/solar/solar_golf_withAr.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Lake
      SimulationScenario(
        id: 'solar_lake',
        sceneName: 'lake',
        displayName: 'Lake',
        problemImagePath: '$_basePath/solar/solar_lake_without.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_lake_ar',
            name: 'anti_reflective',
            displayName: 'With AR',
            correctedImagePath: '$_basePath/solar/solar_lake_withAr.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Motorcycle
      SimulationScenario(
        id: 'solar_moto',
        sceneName: 'motorcycle',
        displayName: 'Motorcycle',
        problemImagePath: '$_basePath/solar/solar_moto_without.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_moto_ar',
            name: 'anti_reflective',
            displayName: 'With AR',
            correctedImagePath: '$_basePath/solar/solar_moto_withAr.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Tennis
      SimulationScenario(
        id: 'solar_tennis',
        sceneName: 'tennis',
        displayName: 'Tennis',
        problemImagePath: '$_basePath/solar/solar_tennis_without.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_tennis_ar',
            name: 'anti_reflective',
            displayName: 'With AR',
            correctedImagePath: '$_basePath/solar/solar_tennis_withAr.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Yacht
      SimulationScenario(
        id: 'solar_yacht',
        sceneName: 'yacht',
        displayName: 'Yacht',
        problemImagePath: '$_basePath/solar/solar_yacht_without.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_yacht_ar',
            name: 'anti_reflective',
            displayName: 'With AR',
            correctedImagePath: '$_basePath/solar/solar_yacht_withAr.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
    ],
  );

  // ===================== TINT =====================
  static final SimulationCategory _tintCategory = SimulationCategory(
    id: 'tint',
    name: 'tint',
    displayName: 'Tint',
    description: 'Customizable lens tints for different environments',
    scenarios: [
      SimulationScenario(
        id: 'tint_beach',
        sceneName: 'beach',
        displayName: 'Beach',
        problemImagePath: '$_basePath/tint/tint_beach.jpg',
        correctionLenses: _getTintLenses(
          'tint_beach',
          '$_basePath/tint/tint_beach.jpg',
        ),
      ),
      SimulationScenario(
        id: 'tint_driving',
        sceneName: 'driving',
        displayName: 'Driving',
        problemImagePath: '$_basePath/tint/tint_driving.jpg',
        correctionLenses: _getTintLenses(
          'tint_driving',
          '$_basePath/tint/tint_driving.jpg',
        ),
      ),
      SimulationScenario(
        id: 'tint_golf',
        sceneName: 'golf',
        displayName: 'Golf',
        problemImagePath: '$_basePath/tint/tint_golf.jpg',
        correctionLenses: _getTintLenses(
          'tint_golf',
          '$_basePath/tint/tint_golf.jpg',
        ),
      ),
      SimulationScenario(
        id: 'tint_lake',
        sceneName: 'lake',
        displayName: 'Lake',
        problemImagePath: '$_basePath/tint/tint_lake.jpg',
        correctionLenses: _getTintLenses(
          'tint_lake',
          '$_basePath/tint/tint_lake.jpg',
        ),
      ),
      SimulationScenario(
        id: 'tint_moto',
        sceneName: 'motorcycle',
        displayName: 'Motorcycle',
        problemImagePath: '$_basePath/tint/tint_motorcycle.jpg',
        correctionLenses: _getTintLenses(
          'tint_moto',
          '$_basePath/tint/tint_motorcycle.jpg',
        ),
      ),
      SimulationScenario(
        id: 'tint_tennis',
        sceneName: 'tennis',
        displayName: 'Tennis',
        problemImagePath: '$_basePath/tint/tint_tennis.jpg',
        correctionLenses: _getTintLenses(
          'tint_tennis',
          '$_basePath/tint/tint_tennis.jpg',
        ),
      ),
      SimulationScenario(
        id: 'tint_yacht',
        sceneName: 'yacht',
        displayName: 'Yacht',
        problemImagePath: '$_basePath/tint/tint_yacht.jpg',
        correctionLenses: _getTintLenses(
          'tint_yacht',
          '$_basePath/tint/tint_yacht.jpg',
        ),
      ),
    ],
  );

  static List<CorrectionLens> _getTintLenses(String prefix, String imagePath) {
    return [
      CorrectionLens(
        id: '${prefix}_gray',
        name: 'gray',
        displayName: 'Gray',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Colors.black.withOpacity(0.6),
      ),
      CorrectionLens(
        id: '${prefix}_brown',
        name: 'brown',
        displayName: 'Brown',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Color(0xFF6D4C41).withOpacity(0.6), // Brown 400
      ),
      CorrectionLens(
        id: '${prefix}_green',
        name: 'green',
        displayName: 'Green',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Colors.green.withOpacity(0.6), // Green 800
      ),
      CorrectionLens(
        id: '${prefix}_yellow',
        name: 'yellow',
        displayName: 'Yellow',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Colors.yellow.withOpacity(0.6),
      ),
      CorrectionLens(
        id: '${prefix}_aqua',
        name: 'aqua',
        displayName: 'Aqua',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Colors.cyanAccent.withOpacity(0.6),
      ),
      CorrectionLens(
        id: '${prefix}_blue',
        name: 'blue',
        displayName: 'Blue',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Colors.blue.withOpacity(0.6),
      ),
      CorrectionLens(
        id: '${prefix}_orange',
        name: 'orange',
        displayName: 'Orange',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Colors.orange.withOpacity(0.6),
      ),
      CorrectionLens(
        id: '${prefix}_red',
        name: 'red',
        displayName: 'Red',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Colors.red.withOpacity(0.6),
      ),
    ];
  }

  /// Get category by ID.
  static SimulationCategory? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get scenario by ID within a category.
  static SimulationScenario? getScenarioById(
    String categoryId,
    String scenarioId,
  ) {
    final category = getCategoryById(categoryId);
    if (category == null) return null;
    try {
      return category.scenarios.firstWhere((s) => s.id == scenarioId);
    } catch (_) {
      return null;
    }
  }
}
