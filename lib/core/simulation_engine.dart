import 'constants.dart';

class SimulationEngine {
  static UniverseOutcome calculateOutcome(double gravity, double emForce, double nuclearForce) {
    // Gravity checks
    if (gravity > GameConstants.gravityMax + 0.2) return UniverseOutcome.collapsed;
    if (gravity < GameConstants.gravityMin - 0.2) return UniverseOutcome.empty;

    // Nuclear checks (Stars)
    if (nuclearForce > GameConstants.nuclearForceMax + 0.15) return UniverseOutcome.fastBurn;
    if (nuclearForce < GameConstants.nuclearForceMin - 0.15) return UniverseOutcome.noStars;

    // EM checks (Atoms/Chemistry)
    if (emForce > GameConstants.emForceMax + 0.15) return UniverseOutcome.unstableAtoms;
    if (emForce < GameConstants.emForceMin - 0.15) return UniverseOutcome.noBonds;

    // Narrow success window
    bool gravityOk = gravity >= GameConstants.gravityMin && gravity <= GameConstants.gravityMax;
    bool emOk = emForce >= GameConstants.emForceMin && emForce <= GameConstants.emForceMax;
    bool nuclearOk = nuclearForce >= GameConstants.nuclearForceMin && nuclearForce <= GameConstants.nuclearForceMax;

    if (gravityOk && emOk && nuclearOk) {
      return UniverseOutcome.lifeSupporting;
    }

    return UniverseOutcome.chaotic;
  }

  static String getOutcomeMessage(UniverseOutcome outcome) {
    switch (outcome) {
      case UniverseOutcome.collapsed:
        return "The universe collapsed into a singularity immediately.";
      case UniverseOutcome.empty:
        return "Matter is too sparse. A cold, dark, and empty void.";
      case UniverseOutcome.unstableAtoms:
        return "Electromagnetic repulsion prevents atoms from forming.";
      case UniverseOutcome.noBonds:
        return "Chemistry is impossible. No molecules can form.";
      case UniverseOutcome.fastBurn:
        return "Stars consumed their fuel in an instant. Total darkness remains.";
      case UniverseOutcome.noStars:
        return "Hydrogen never fused. The universe is a cold gas cloud.";
      case UniverseOutcome.chaotic:
        return "The laws of physics are too unbalanced for stability.";
      case UniverseOutcome.lifeSupporting:
        return "Perfect balance. Life flourishes across the cosmos.";
      default:
        return "The void awaits your touch.";
    }
  }
}
