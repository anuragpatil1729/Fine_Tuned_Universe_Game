// CHANGES MADE:
// 1. Replaced old outcome calculation with the new 4-tier thematic ending system.
// 2. Implemented priority-based evaluation: Collapse -> Recurrence -> Last Light -> Garden.
// 3. Added narrative strings for each ending to be displayed on the ResultScreen.
// 4. Integrated the new `entropyRate` and `darkEnergyPressure` constants into the logic.
// 5. Added a "knife-edge" balance check for the Eternal Recurrence ending.

import 'constants.dart';

class SimulationEngine {
  static UniverseOutcome calculateOutcome(
    double gravity, 
    double nuclear, 
    double em, 
    double entropy, 
    double darkEnergy
  ) {
    // 1. Check GREAT COLLAPSE (Priority 1)
    if (gravity > 0.65 || darkEnergy < 0.30) {
      return UniverseOutcome.greatCollapse;
    }

    // 2. Check ETERNAL RECURRENCE (Priority 2)
    bool isKnifeEdge = (gravity - 0.5).abs() <= 0.02 &&
                       (nuclear - 0.5).abs() <= 0.02 &&
                       (em - 0.5).abs() <= 0.02 &&
                       (entropy - 0.5).abs() <= 0.02 &&
                       (darkEnergy - 0.5).abs() <= 0.02;

    if ((darkEnergy > 0.70 && entropy < 0.35) || isKnifeEdge) {
      return UniverseOutcome.eternalRecurrence;
    }

    // 3. Check LAST LIGHT (Priority 3)
    bool gravityOk = gravity >= GameConstants.gravityMin && gravity <= GameConstants.gravityMax;
    bool nuclearOk = nuclear >= GameConstants.nuclearForceMin && nuclear <= GameConstants.nuclearForceMax;
    bool emOk = em >= GameConstants.emForceMin && em <= GameConstants.emForceMax;
    bool darkEnergyOk = darkEnergy >= GameConstants.darkEnergyMin && darkEnergy <= GameConstants.darkEnergyMax;

    if (gravityOk && nuclearOk && emOk && darkEnergyOk && (entropy > 0.60 && entropy <= 0.75)) {
      return UniverseOutcome.lastLight;
    }

    // 4. Default / ETERNAL GARDEN
    bool entropyOk = entropy >= GameConstants.entropyRateMin && entropy <= GameConstants.entropyRateMax;
    if (gravityOk && nuclearOk && emOk && entropyOk && darkEnergyOk) {
      return UniverseOutcome.eternalGarden;
    }

    // Fallback if none of the above match exactly
    return (darkEnergy > 0.6) ? UniverseOutcome.eternalRecurrence : UniverseOutcome.greatCollapse;
  }

  static String getOutcomeMessage(UniverseOutcome outcome) {
    switch (outcome) {
      case UniverseOutcome.eternalGarden:
        return "Stars burn for a trillion years. Life spreads between galaxies. The universe hums with the quiet music of consciousness.";
      case UniverseOutcome.lastLight:
        return "Life flourishes briefly — a bright, beautiful flame. The universe burns fast and dies young. It was glorious.";
      case UniverseOutcome.greatCollapse:
        return "Gravity wins. Everything — every star, every world, every thought — crushed back into a single, silent point.";
      case UniverseOutcome.eternalRecurrence:
        return "The universe neither lives nor dies. It expands, contracts, and is born again. You are trapped in the loop.";
      default:
        return "The void remains silent.";
    }
  }

  static String getEndingSubtitle(UniverseOutcome outcome) {
    switch (outcome) {
      case UniverseOutcome.eternalGarden:
        return "A legacy of light and infinite peace.\nThe cradle of infinity.";
      case UniverseOutcome.lastLight:
        return "A short-lived masterpiece of heat and hope.\nThe candle in the dark.";
      case UniverseOutcome.greatCollapse:
        return "The weight of existence becomes too heavy.\nThe crushing end.";
      case UniverseOutcome.eternalRecurrence:
        return "Time is a circle, and you are its architect.\nThe snake eats its tail.";
      default:
        return "";
    }
  }
}
