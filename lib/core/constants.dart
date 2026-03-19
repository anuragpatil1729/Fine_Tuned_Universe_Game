// FEATURE: Civilization Layer // WHAT CHANGED: Added civilization stages and outcomes, and new physical constants. // WHY: To support the mid-game expansion that triggers after achieving an Eternal Garden.

import 'package:flutter/material.dart';

class GameConstants {
  static const String appName = 'Fine-Tuned Universe';

  // Core Simulation Thresholds (0.0 to 1.0)
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

  // Civilization Layer Thresholds
  static const double cooperationMin = 0.40;
  static const double cooperationMax = 0.65;
  static const double energyConsumptionMin = 0.35;
  static const double energyConsumptionMax = 0.55;

  // Visual Styling
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
  civilizationDawn,   // Tune: cooperationIndex (Civ Layer)
  technologicalAge,   // Tune: energyConsumption (Civ Layer)
  cosmicLegacy,       // Outcome revealed (Civ Layer)
  cosmicFate         // Outcome revealed (Standard)
}

enum UniverseOutcome {
  none,
  eternalGarden,     // Good ending A
  lastLight,         // Good ending B
  greatCollapse,     // Destruction
  eternalRecurrence, // Infinite loop
  transcendence,     // Civilization leaves the universe
  extinction,        // Civilization destroys itself
  equilibrium        // Civilization survives but stagnates
}
