import 'package:flutter/material.dart';

/// Represents a visual problem category with its scenes and correction options.
class SimulationCategory {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final List<SimulationScenario> scenarios;

  const SimulationCategory({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.scenarios,
  });
}

/// Represents a single simulation scenario with problem and correction images.
class SimulationScenario {
  final String id;
  final String sceneName;
  final String displayName;
  final String problemImagePath;
  final List<CorrectionLens> correctionLenses;

  const SimulationScenario({
    required this.id,
    required this.sceneName,
    required this.displayName,
    required this.problemImagePath,
    required this.correctionLenses,
  });
}

/// Represents a correction lens option with its corrected image.
class CorrectionLens {
  final String id;
  final String name;
  final String displayName;
  final String correctedImagePath;
  final LensQuality quality;
  final Color? tintColor;

  const CorrectionLens({
    required this.id,
    required this.name,
    required this.displayName,
    required this.correctedImagePath,
    required this.quality,
    this.tintColor,
  });
}

/// Enum representing lens quality levels.
enum LensQuality {
  economy('Economy', 1),
  standard('Standard', 2),
  good('Good', 3),
  premium('Premium', 4);

  final String displayName;
  final int order;

  const LensQuality(this.displayName, this.order);
}
