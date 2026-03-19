// FEATURE: Civilization Layer // WHAT CHANGED: Implemented priority-based outcome calculation for the initial phase and a new calculation method for the civilization phase. Added narrative messages for all 7 possible endings. // WHY: To support the expanded narrative arc from cosmic birth to civilizational transcendence.

import 'constants.dart';

class SimulationEngine {
  static UniverseOutcome calculateOutcome(
    double gravity,
    double nuclear,
    double em,
    double entropy,
    double darkEnergy,
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
    return UniverseOutcome.eternalGarden;
  }

  static UniverseOutcome calculateCivilizationOutcome(
    double cooperation,
    double energy,
  ) {
    // 1. Check EXTINCTION (Immediate failure)
    if (cooperation < 0.35 || energy > 0.70) {
      return UniverseOutcome.extinction;
    }

    // 2. Check TRANSCENDENCE (Optimal)
    if (cooperation > 0.65 && energy >= 0.35 && energy <= 0.55) {
      return UniverseOutcome.transcendence;
    }

    // 3. Mixed results (Probabilistic but deterministic)
    if (cooperation >= 0.40 && cooperation <= 0.65 && energy >= 0.35 && energy <= 0.55) {
      // Deterministic "50% chance" using input values
      if ((cooperation + (1.0 - energy)) > 1.0) {
        return UniverseOutcome.transcendence;
      } else {
        return UniverseOutcome.equilibrium;
      }
    }

    // Fallback
    return UniverseOutcome.extinction;
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
      case UniverseOutcome.transcendence:
        return "The civilization solved cooperation. They left the universe entirely, ascending to dimensions beyond observation. The stars remember them.";
      case UniverseOutcome.extinction:
        return "They had the stars within reach. Internal conflict consumed them before they could grasp it. The universe continues, indifferent.";
      case UniverseOutcome.equilibrium:
        return "They survived. Not transcendent, not extinct — simply enduring. Billions of years of quiet, stable civilization. Perhaps that is enough.";
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
      case UniverseOutcome.transcendence:
        return "Beyond the observable.\nThe next step.";
      case UniverseOutcome.extinction:
        return "So close, and yet.\nThe silence after.";
      case UniverseOutcome.equilibrium:
        return "Not fire, not ice.\nJust time.";
      default:
        return "";
    }
  }
}
