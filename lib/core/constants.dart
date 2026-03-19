import 'package:flutter/material.dart';

class GameConstants {
  static const String appName = 'Fine-Tuned Universe';

  // Thresholds for simulation (0.0 to 1.0)
  static const double gravityMin = 0.4;
  static const double gravityMax = 0.6;
  
  static const double emForceMin = 0.35;
  static const double emForceMax = 0.65;
  
  static const double nuclearForceMin = 0.45;
  static const double nuclearForceMax = 0.55;

  static const Color spaceBlack = Color(0xFF050505);
  static const Color cosmicPurple = Color(0xFF2D004F);
  static const Color cosmicBlue = Color(0xFF001F4F);
  static const Color lifeGreen = Color(0xFF00FF88);
  static const Color starGold = Color(0xFFFFD700);
  static const Color collapseRed = Color(0xFFFF3333);
}

enum UniverseStage {
  bigBang,
  starFormation,
  planetFormation,
  emergenceOfLife,
  finished
}

enum UniverseOutcome {
  none,
  collapsed, // Gravity too high
  empty,     // Gravity too low
  unstableAtoms, // EM too high
  noBonds,    // EM too low
  fastBurn,   // Nuclear too high
  noStars,    // Nuclear too low
  chaotic,    // Mixed issues
  lifeSupporting // Success
}
