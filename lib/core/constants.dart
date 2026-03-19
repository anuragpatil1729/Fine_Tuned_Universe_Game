// CHANGES MADE:
// 1. Replaced UniverseStage with the new lifecycle-based stages (cosmicDawn to cosmicFate).
// 2. Replaced UniverseOutcome with the four new thematic endings.
// 3. Added entropyRate and darkEnergy threshold constants.
// 4. Added semantic color mappings for the new endings.

import 'package:flutter/material.dart';

class GameConstants {
  static const String appName = 'Fine-Tuned Universe';

  // Thresholds for simulation (0.0 to 1.0)
  static const double gravityMin = 0.35;
  static const double gravityMax = 0.65;
  
  static const double nuclearForceMin = 0.40;
  static const double nuclearForceMax = 0.60;

  static const double emForceMin = 0.35;
  static const double emForceMax = 0.65;

  static const double entropyRateMin = 0.35;
  static const double entropyRateMax = 0.60;

  static const double darkEnergyMin = 0.40;
  static const double darkEnergyMax = 0.60;

  static const Color spaceBlack = Color(0xFF050505);
  static const Color cosmicPurple = Color(0xFF2D004F);
  static const Color cosmicBlue = Color(0xFF001F4F);
  static const Color lifeGreen = Color(0xFF00FF88);
  static const Color starGold = Color(0xFFFFD700);
  static const Color collapseRed = Color(0xFFFF3333);
  static const Color gardenEmerald = Color(0xFF00A86B);
}

enum UniverseStage {
  cosmicDawn,        // Tune: gravity
  stellarAge,        // Tune: nuclearForce
  galacticAge,       // Tune: emForce
  lifeAge,           // Tune: entropyRate
  stellarDeath,      // Tune: darkEnergyPressure
  cosmicFate         // Outcome revealed
}

enum UniverseOutcome {
  none,
  eternalGarden,     // Good ending A
  lastLight,         // Good ending B (bittersweet)
  greatCollapse,     // Destruction
  eternalRecurrence  // Infinite loop
}
