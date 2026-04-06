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
    _monofocalCategory,
    _multifocalCategory,
    _presbyopiaCategory,
    _bifocalCategory,
    _polarizedCategory,
    _antiReflexCategory,
    _driveCategory,
    _photochromicCategory,
    _solarCategory,
    _tintCategory,
    _blueFilterCategory,
    _asphericCategory,
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
        problemImagePath: '$_basePath/myopia/myopia_kitchen_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'myopia_kitchen_near',
            name: 'monofocal_near',
            displayName: 'Monofocal Near',
            correctedImagePath: '$_basePath/myopia/myopia_kitchen_close.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'myopia_kitchen_far',
            name: 'monofocal_far',
            displayName: 'Monofocal Far',
            correctedImagePath: '$_basePath/myopia/myopia_kitchen_far.webp',
            quality: LensQuality.good,
          ),
        ],
      ),
      // Market scene (Store)
      SimulationScenario(
        id: 'myopia_market',
        sceneName: 'market',
        displayName: 'Market',
        problemImagePath: '$_basePath/myopia/myopia_market_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'myopia_market_near',
            name: 'monofocal_near',
            displayName: 'Monofocal Near',
            correctedImagePath: '$_basePath/myopia/myopia_market_close.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'myopia_market_far',
            name: 'monofocal_far',
            displayName: 'Monofocal Far',
            correctedImagePath: '$_basePath/myopia/myopia_market_far.webp',
            quality: LensQuality.good,
          ),
        ],
      ),
      // Grocery scene (Supermarket)
      SimulationScenario(
        id: 'myopia_grocery',
        sceneName: 'grocery',
        displayName: 'Grocery',
        problemImagePath: '$_basePath/myopia/myopia_grocery_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'myopia_grocery_near',
            name: 'monofocal_near',
            displayName: 'Monofocal Near',
            correctedImagePath: '$_basePath/myopia/myopia_grocery_close.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'myopia_grocery_far',
            name: 'monofocal_far',
            displayName: 'Monofocal Far',
            correctedImagePath: '$_basePath/myopia/myopia_grocery_far.webp',
            quality: LensQuality.good,
          ),
        ],
      ),
      // Clothing scene
      SimulationScenario(
        id: 'myopia_clothing',
        sceneName: 'clothing',
        displayName: 'Clothing Store',
        problemImagePath: '$_basePath/myopia/myopia_clothing_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'myopia_clothing_near',
            name: 'monofocal_near',
            displayName: 'Monofocal Near',
            correctedImagePath: '$_basePath/myopia/myopia_clothing_close.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'myopia_clothing_far',
            name: 'monofocal_far',
            displayName: 'Monofocal Far',
            correctedImagePath: '$_basePath/myopia/myopia_clothing_far.webp',
            quality: LensQuality.good,
          ),
        ],
      ),
    ],
  );

  // ===================== MONOFOCAL =====================
  static final SimulationCategory _monofocalCategory = SimulationCategory(
    id: 'monofocal',
    name: 'monofocal',
    displayName: 'Monofocal',
    description: 'Vision correction with a single focal point',
    scenarios: _myopiaCategory.scenarios,
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
        problemImagePath: '$_basePath/multifocal/kitchen2.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'multifocal_kitchen2_economic',
            name: 'economic',
            displayName: 'Economy',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_economic_kitchen2.webp',
            quality: LensQuality.economy,
          ),
          CorrectionLens(
            id: 'multifocal_kitchen2_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_standard_kitchen2.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'multifocal_kitchen2_good',
            name: 'good',
            displayName: 'Good',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_good_kitchen2.webp',
            quality: LensQuality.good,
          ),
          CorrectionLens(
            id: 'multifocal_kitchen2_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_premium_kitchen2.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Market
      SimulationScenario(
        id: 'multifocal_market',
        sceneName: 'market',
        displayName: 'Market',
        problemImagePath: '$_basePath/multifocal/market.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'multifocal_market_economic',
            name: 'economic',
            displayName: 'Economy',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_economic_market.webp',
            quality: LensQuality.economy,
          ),
          CorrectionLens(
            id: 'multifocal_market_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_standard_market.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'multifocal_market_good',
            name: 'good',
            displayName: 'Good',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_good_market.webp',
            quality: LensQuality.good,
          ),
          CorrectionLens(
            id: 'multifocal_market_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_premium_market.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Clothing
      SimulationScenario(
        id: 'multifocal_clothing',
        sceneName: 'clothing',
        displayName: 'Clothing',
        problemImagePath: '$_basePath/multifocal/clothing.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'multifocal_clothing_economic',
            name: 'economic',
            displayName: 'Economy',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_economic_clothing.webp',
            quality: LensQuality.economy,
          ),
          CorrectionLens(
            id: 'multifocal_clothing_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_standard_clothing.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'multifocal_clothing_good',
            name: 'good',
            displayName: 'Good',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_good_clothing.webp',
            quality: LensQuality.good,
          ),
          CorrectionLens(
            id: 'multifocal_clothing_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/multifocal/multifocal_premium_clothing.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
    ],
  );

  // ===================== PRESBYOPIA =====================
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
        problemImagePath: '$_basePath/presbicia/PresbiciaCocina.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'presbyopia_kitchen_progressive',
            name: 'progressive',
            displayName: 'Progressive Lens',
            correctedImagePath: '$_basePath/presbicia/presbicia_cocina.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      SimulationScenario(
        id: 'presbyopia_supermarket',
        sceneName: 'supermarket',
        displayName: 'Supermarket',
        problemImagePath: '$_basePath/presbicia/PresbiciaSuper.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'presbyopia_super_progressive',
            name: 'progressive',
            displayName: 'Progressive Lens',
            correctedImagePath: '$_basePath/presbicia/presbicia_almacen.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      SimulationScenario(
        id: 'presbyopia_store',
        sceneName: 'store',
        displayName: 'Store',
        problemImagePath: '$_basePath/presbicia/PresbiciaTienda.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'presbyopia_store_progressive',
            name: 'progressive',
            displayName: 'Progressive Lens',
            correctedImagePath: '$_basePath/presbicia/presbicia_oficina.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
    ],
  );

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
        problemImagePath: '$_basePath/bifocal/BifocalOficina.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'bifocal_office_invisible',
            name: 'invisible',
            displayName: 'Invisible Bifocal',
            correctedImagePath:
                '$_basePath/bifocal/BifocalOficinaInvisible.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'bifocal_office_multifocal',
            name: 'multifocal',
            displayName: 'Multifocal',
            correctedImagePath:
                '$_basePath/bifocal/BifocalOficinaMultifocal.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      SimulationScenario(
        id: 'bifocal_driving',
        sceneName: 'driving',
        displayName: 'Driving',
        problemImagePath: '$_basePath/bifocal/BifocalManejando.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'bifocal_driving_multifocal',
            name: 'multifocal',
            displayName: 'Multifocal',
            correctedImagePath:
                '$_basePath/bifocal/BifocalManejandoMultifocal.webp',
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
        problemImagePath: '$_basePath/polarized/polarized_golf_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'polarized_golf_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/polarized/polarized_golf_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'polarized_golf_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/polarized/polarized_golf_premium.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Driving
      SimulationScenario(
        id: 'polarized_driving',
        sceneName: 'driving',
        displayName: 'Driving',
        problemImagePath: '$_basePath/polarized/polarized_driving_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'polarized_driving_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/polarized/polarized_driving_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'polarized_driving_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/polarized/polarized_driving_premium.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Beach
      SimulationScenario(
        id: 'polarized_beach',
        sceneName: 'beach',
        displayName: 'Beach',
        problemImagePath: '$_basePath/polarized/polarized_beach_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'polarized_beach_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/polarized/polarized_beach_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'polarized_beach_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/polarized/polarized_beach_premium.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Tennis
      SimulationScenario(
        id: 'polarized_tennis',
        sceneName: 'tennis',
        displayName: 'Tennis',
        problemImagePath: '$_basePath/polarized/polarized_tennis_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'polarized_tennis_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/polarized/polarized_tennis_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'polarized_tennis_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/polarized/polarized_tennis_premium.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Yacht
      SimulationScenario(
        id: 'polarized_yacht',
        sceneName: 'yacht',
        displayName: 'Yacht',
        problemImagePath: '$_basePath/polarized/polarized_yacht_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'polarized_yacht_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/polarized/polarized_yatch_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'polarized_yacht_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/polarized/polarized_yatch_premium.webp',
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
            '$_basePath/polarized/polarized_motorcycle_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'polarized_moto_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/polarized/polarized_motorcycle_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'polarized_moto_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/polarized/polarized_motorcycle_premium.webp',
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
            '$_basePath/anti_reflex/anti_reflection_driving_noLense.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_driving_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_driving_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_driving_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_driving_premium.webp',
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
            '$_basePath/anti_reflex/anti_reflection_baseball_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_baseball_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_baseball_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_baseball_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_baseball_premium.webp',
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
            '$_basePath/anti_reflex/anti_reflection_basket_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_basket_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_basket_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_basket_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_basket_premium.webp',
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
            '$_basePath/anti_reflex/anti_reflection_soccer_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_soccer_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_soccer_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_soccer_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_soccer_premium.webp',
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
            '$_basePath/anti_reflex/anti_reflection_tennis_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_tennis_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_tennis_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_tennis_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_tennis_premium.webp',
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
            '$_basePath/anti_reflex/anti_reflection_concert_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_concert_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_concert_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_concert_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_concert_premium.webp',
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
            '$_basePath/anti_reflex/anti_reflection_bridge_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'ar_bridge_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_bridge_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'ar_bridge_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath:
                '$_basePath/anti_reflex/anti_reflection_bridge_premium.webp',
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
        problemImagePath: '$_basePath/drive/DriveManejandoSoleadoSin.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_driving_sunny_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveManejandoSoleado.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Driving Cloudy
      SimulationScenario(
        id: 'drive_driving_cloudy',
        sceneName: 'driving_cloudy',
        displayName: 'Driving (Cloudy)',
        problemImagePath: '$_basePath/drive/DriveManejandoNubladoSin.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_driving_cloudy_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveManejandoNublado.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Golf Sunny
      SimulationScenario(
        id: 'drive_golf_sunny',
        sceneName: 'golf_sunny',
        displayName: 'Golf (Sunny)',
        problemImagePath: '$_basePath/drive/DriveGolfSoleadoSin.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_golf_sunny_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveGolfSoleado.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Golf Cloudy
      SimulationScenario(
        id: 'drive_golf_cloudy',
        sceneName: 'golf_cloudy',
        displayName: 'Golf (Cloudy)',
        problemImagePath: '$_basePath/drive/DriveGolfNubladoSin.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_golf_cloudy_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveGolfNublado.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Beach Sunny
      SimulationScenario(
        id: 'drive_beach_sunny',
        sceneName: 'beach_sunny',
        displayName: 'Beach (Sunny)',
        problemImagePath: '$_basePath/drive/DrivePlayaSoleadoSin.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_beach_sunny_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DrivePlayaSoleado.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Beach Cloudy
      SimulationScenario(
        id: 'drive_beach_cloudy',
        sceneName: 'beach_cloudy',
        displayName: 'Beach (Cloudy)',
        problemImagePath: '$_basePath/drive/DrivePlayaNubladoSin.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_beach_cloudy_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DrivePlayaNublado.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Motorcycle Sunny
      SimulationScenario(
        id: 'drive_moto_sunny',
        sceneName: 'motorcycle_sunny',
        displayName: 'Motorcycle (Sunny)',
        problemImagePath: '$_basePath/drive/DriveMotoSoleadoSin.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_moto_sunny_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveMotoSoleado.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Motorcycle Cloudy
      SimulationScenario(
        id: 'drive_moto_cloudy',
        sceneName: 'motorcycle_cloudy',
        displayName: 'Motorcycle (Cloudy)',
        problemImagePath: '$_basePath/drive/DriveMotoNubladoSin.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_moto_cloudy_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveMotoNublado.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Tennis Sunny
      SimulationScenario(
        id: 'drive_tennis_sunny',
        sceneName: 'tennis_sunny',
        displayName: 'Tennis (Sunny)',
        problemImagePath: '$_basePath/drive/DriveTenisSoleadoSin.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_tennis_sunny_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveTenisSoleado.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Tennis Cloudy
      SimulationScenario(
        id: 'drive_tennis_cloudy',
        sceneName: 'tennis_cloudy',
        displayName: 'Tennis (Cloudy)',
        problemImagePath: '$_basePath/drive/DriveTenisNubladoSin.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_tennis_cloudy_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveTenisNublado.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Yacht Sunny
      SimulationScenario(
        id: 'drive_yacht_sunny',
        sceneName: 'yacht_sunny',
        displayName: 'Yacht (Sunny)',
        problemImagePath: '$_basePath/drive/DriveYateSoleladoSin.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_yacht_sunny_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveYateSolelado.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Yacht Cloudy
      SimulationScenario(
        id: 'drive_yacht_cloudy',
        sceneName: 'yacht_cloudy',
        displayName: 'Yacht (Cloudy)',
        problemImagePath: '$_basePath/drive/DriveYateNubladoSin.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'drive_yacht_cloudy_lens',
            name: 'drivewear',
            displayName: 'DriveWear',
            correctedImagePath: '$_basePath/drive/DriveYateNublado.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
    ],
  );

  // ===================== PHOTOCHROMIC (FOTOCROMÁTICO) =====================
  static final SimulationCategory _photochromicCategory = SimulationCategory(
    id: 'photochromic',
    name: 'fotocromático',
    displayName: 'Fotocromático',
    description: 'Lentes que se adaptan a las condiciones de luz',
    scenarios: [
      // Indoor (Optic)
      SimulationScenario(
        id: 'photo_optic',
        sceneName: 'optic',
        displayName: 'Optic Store',
        problemImagePath: '$_basePath/photochromic/photochromic_optic_off.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'photo_optic_gray',
            name: 'gray',
            displayName: 'Gray',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_optic_on.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'photo_optic_brown',
            name: 'brown',
            displayName: 'Brown',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_optic_on_brown.webp',
            quality: LensQuality.good,
          ),
          CorrectionLens(
            id: 'photo_optic_green',
            name: 'green',
            displayName: 'Green',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_optic_on_green.webp',
            quality: LensQuality.good,
          ),
        ],
      ),
      // Beach
      SimulationScenario(
        id: 'photo_beach',
        sceneName: 'beach',
        displayName: 'Beach',
        problemImagePath: '$_basePath/photochromic/photochromic_beach_off.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'photo_beach_gray',
            name: 'gray',
            displayName: 'Gray',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_beach_on_gray.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'photo_beach_brown',
            name: 'brown',
            displayName: 'Brown',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_beach_on_brown.webp',
            quality: LensQuality.good,
          ),
          CorrectionLens(
            id: 'photo_beach_green',
            name: 'green',
            displayName: 'Green',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_beach_on_green.webp',
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
            '$_basePath/photochromic/photochromic_driving_off.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'photo_driving_gray',
            name: 'gray',
            displayName: 'Gray',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_driving_on_gray.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'photo_driving_brown',
            name: 'brown',
            displayName: 'Brown',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_driving_on_brown.webp',
            quality: LensQuality.good,
          ),
          CorrectionLens(
            id: 'photo_driving_green',
            name: 'green',
            displayName: 'Green',
            correctedImagePath:
                '$_basePath/photochromic/photochromic_driving_on_green.webp',
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
    description:
        'Sun protection lenses with and without anti-reflective coating',
    scenarios: [
      // Driving - Without Solar vs With Solar
      SimulationScenario(
        id: 'solar_driving_no_ar',
        sceneName: 'driving',
        displayName: 'Driving',
        problemImagePath: '$_basePath/solar/solar_driving_without.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_driving_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath: '$_basePath/solar/solar_driving_withAr.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'solar_driving_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath: '$_basePath/solar/solar_driving_withAr.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Golf - Without Solar vs With Solar
      SimulationScenario(
        id: 'solar_golf_no_ar',
        sceneName: 'golf',
        displayName: 'Golf',
        problemImagePath: '$_basePath/solar/solar_golf_without.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_golf_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath: '$_basePath/solar/solar_golf_withAr.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'solar_golf_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath: '$_basePath/solar/solar_golf_withAr.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Motorcycle - Without Solar vs With Solar
      SimulationScenario(
        id: 'solar_moto_no_ar',
        sceneName: 'motorcycle',
        displayName: 'Motorcycle',
        problemImagePath: '$_basePath/solar/solar_moto_without.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_moto_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath: '$_basePath/solar/solar_moto_withAr.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'solar_moto_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath: '$_basePath/solar/solar_moto_withAr.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Tennis - Without Solar vs With Solar
      SimulationScenario(
        id: 'solar_tennis_no_ar',
        sceneName: 'tennis',
        displayName: 'Tennis',
        problemImagePath: '$_basePath/solar/solar_tennis_without.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_tennis_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath: '$_basePath/solar/solar_tennis_withAr.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'solar_tennis_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath: '$_basePath/solar/solar_tennis_withAr.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      // Yacht - Without Solar vs With Solar
      SimulationScenario(
        id: 'solar_yacht_no_ar',
        sceneName: 'yacht',
        displayName: 'Yacht',
        problemImagePath: '$_basePath/solar/solar_yacht_without.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'solar_yacht_standard',
            name: 'standard',
            displayName: 'Standard',
            correctedImagePath: '$_basePath/solar/solar_yacht_withAr.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'solar_yacht_premium',
            name: 'premium',
            displayName: 'Premium',
            correctedImagePath: '$_basePath/solar/solar_yacht_withAr.webp',
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
        problemImagePath: '$_basePath/tint/tint_beach.webp',
        correctionLenses: _getTintLenses(
          'tint_beach',
          '$_basePath/tint/tint_beach.webp',
        ),
      ),
      SimulationScenario(
        id: 'tint_driving',
        sceneName: 'driving',
        displayName: 'Driving',
        problemImagePath: '$_basePath/tint/tint_driving.webp',
        correctionLenses: _getTintLenses(
          'tint_driving',
          '$_basePath/tint/tint_driving.webp',
        ),
      ),
      SimulationScenario(
        id: 'tint_golf',
        sceneName: 'golf',
        displayName: 'Golf',
        problemImagePath: '$_basePath/tint/tint_golf.webp',
        correctionLenses: _getTintLenses(
          'tint_golf',
          '$_basePath/tint/tint_golf.webp',
        ),
      ),
      SimulationScenario(
        id: 'tint_lake',
        sceneName: 'lake',
        displayName: 'Lake',
        problemImagePath: '$_basePath/tint/tint_lake.webp',
        correctionLenses: _getTintLenses(
          'tint_lake',
          '$_basePath/tint/tint_lake.webp',
        ),
      ),
      SimulationScenario(
        id: 'tint_moto',
        sceneName: 'motorcycle',
        displayName: 'Motorcycle',
        problemImagePath: '$_basePath/tint/tint_motorcycle.webp',
        correctionLenses: _getTintLenses(
          'tint_moto',
          '$_basePath/tint/tint_motorcycle.webp',
        ),
      ),
      SimulationScenario(
        id: 'tint_tennis',
        sceneName: 'tennis',
        displayName: 'Tennis',
        problemImagePath: '$_basePath/tint/tint_tennis.webp',
        correctionLenses: _getTintLenses(
          'tint_tennis',
          '$_basePath/tint/tint_tennis.webp',
        ),
      ),
      SimulationScenario(
        id: 'tint_yacht',
        sceneName: 'yacht',
        displayName: 'Yacht',
        problemImagePath: '$_basePath/tint/tint_yacht.webp',
        correctionLenses: _getTintLenses(
          'tint_yacht',
          '$_basePath/tint/tint_yacht.webp',
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
        tintColor: Colors.black.withValues(alpha: 0.6),
      ),
      CorrectionLens(
        id: '${prefix}_brown',
        name: 'brown',
        displayName: 'Brown',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Color(0xFF6D4C41).withValues(alpha: 0.6), // Brown 400
      ),
      CorrectionLens(
        id: '${prefix}_green',
        name: 'green',
        displayName: 'Green',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Colors.green.withValues(alpha: 0.6), // Green 800
      ),
      CorrectionLens(
        id: '${prefix}_yellow',
        name: 'yellow',
        displayName: 'Yellow',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Colors.yellow.withValues(alpha: 0.6),
      ),
      CorrectionLens(
        id: '${prefix}_aqua',
        name: 'aqua',
        displayName: 'Aqua',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Colors.cyanAccent.withValues(alpha: 0.6),
      ),
      CorrectionLens(
        id: '${prefix}_blue',
        name: 'blue',
        displayName: 'Blue',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Colors.blue.withValues(alpha: 0.6),
      ),
      CorrectionLens(
        id: '${prefix}_orange',
        name: 'orange',
        displayName: 'Orange',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Colors.orange.withValues(alpha: 0.6),
      ),
      CorrectionLens(
        id: '${prefix}_red',
        name: 'red',
        displayName: 'Red',
        correctedImagePath: imagePath,
        quality: LensQuality.standard,
        tintColor: Colors.red.withValues(alpha: 0.6),
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

  // ===================== BLUE FILTER =====================
  static final SimulationCategory _blueFilterCategory = SimulationCategory(
    id: 'blue_filter',
    name: 'blue_filter',
    displayName: 'Blue Filter',
    description: 'Protection against blue light from digital screens',
    scenarios: [
      SimulationScenario(
        id: 'blue_filter_notebook',
        sceneName: 'notebook',
        displayName: 'Notebook',
        problemImagePath: '$_basePath/blue_filter/blue_notebook_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'blue_filter_notebook_premium',
            name: 'premium',
            displayName: 'Premium Blue Filter',
            correctedImagePath: '$_basePath/blue_filter/blue_notebook.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      SimulationScenario(
        id: 'blue_filter_office',
        sceneName: 'office',
        displayName: 'Office',
        problemImagePath: '$_basePath/blue_filter/blue_office_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'blue_filter_office_premium',
            name: 'premium',
            displayName: 'Premium Blue Filter',
            correctedImagePath: '$_basePath/blue_filter/blue_office.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      SimulationScenario(
        id: 'blue_filter_mobile',
        sceneName: 'smartphone',
        displayName: 'Smartphone',
        problemImagePath: '$_basePath/blue_filter/blue_smartphone_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'blue_filter_mobile_premium',
            name: 'premium',
            displayName: 'Premium Blue Filter',
            correctedImagePath: '$_basePath/blue_filter/blue_smartphone.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
      SimulationScenario(
        id: 'blue_filter_store',
        sceneName: 'store',
        displayName: 'Electronic Store',
        problemImagePath: '$_basePath/blue_filter/blue_store_noLens.jpg',
        correctionLenses: [
          CorrectionLens(
            id: 'blue_filter_store_premium',
            name: 'premium',
            displayName: 'Premium Blue Filter',
            correctedImagePath: '$_basePath/blue_filter/blue_store.jpg',
            quality: LensQuality.premium,
          ),
        ],
      ),
    ],
  );

  // ===================== ASPHERIC =====================
  static final SimulationCategory _asphericCategory = SimulationCategory(
    id: 'aspheric',
    name: 'aspheric',
    displayName: 'Aspheric',
    description: 'Slimmer and flatter lens design for better aesthetics',
    scenarios: [
      SimulationScenario(
        id: 'aspheric_strong_prescription',
        sceneName: 'strong_prescription',
        displayName: 'Strong Prescription',
        problemImagePath: '$_basePath/aspheric/aspheric_strong_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'aspheric_strong_standard',
            name: 'standard',
            displayName: 'Standard Lens',
            correctedImagePath:
                '$_basePath/aspheric/aspheric_strong_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'aspheric_strong_aspheric',
            name: 'aspheric',
            displayName: 'Aspheric Lens',
            correctedImagePath:
                '$_basePath/aspheric/aspheric_strong_aspheric.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      SimulationScenario(
        id: 'aspheric_moderate_prescription',
        sceneName: 'moderate_prescription',
        displayName: 'Moderate Prescription',
        problemImagePath: '$_basePath/aspheric/aspheric_moderate_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'aspheric_moderate_standard',
            name: 'standard',
            displayName: 'Standard Lens',
            correctedImagePath:
                '$_basePath/aspheric/aspheric_moderate_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'aspheric_moderate_aspheric',
            name: 'aspheric',
            displayName: 'Aspheric Lens',
            correctedImagePath:
                '$_basePath/aspheric/aspheric_moderate_aspheric.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
      SimulationScenario(
        id: 'aspheric_daily_wear',
        sceneName: 'daily_wear',
        displayName: 'Daily Wear',
        problemImagePath: '$_basePath/aspheric/aspheric_daily_noLens.webp',
        correctionLenses: [
          CorrectionLens(
            id: 'aspheric_daily_standard',
            name: 'standard',
            displayName: 'Standard Lens',
            correctedImagePath:
                '$_basePath/aspheric/aspheric_daily_standard.webp',
            quality: LensQuality.standard,
          ),
          CorrectionLens(
            id: 'aspheric_daily_aspheric',
            name: 'aspheric',
            displayName: 'Aspheric Lens',
            correctedImagePath:
                '$_basePath/aspheric/aspheric_daily_aspheric.webp',
            quality: LensQuality.premium,
          ),
        ],
      ),
    ],
  );
}
