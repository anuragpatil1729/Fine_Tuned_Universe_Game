// CHANGES MADE:
// 1. Added `entropyRate` and `darkEnergyPressure` fields to represent the full lifecycle constants.
// 2. Updated `copyWith` to handle the new fields.
// 3. Set default values for new fields to 0.5.
// 4. Maintained compatibility with existing simulation logic while extending for the new narrative.

import '../core/constants.dart';

class UniverseState {
  final double gravity;
  final double emForce;
  final double nuclearForce;
  final double entropyRate;
  final double darkEnergyPressure;
  final UniverseOutcome outcome;
  final UniverseStage stage;
  final DateTime timestamp;

  UniverseState({
    required this.gravity,
    required this.emForce,
    required this.nuclearForce,
    this.entropyRate = 0.5,
    this.darkEnergyPressure = 0.5,
    required this.outcome,
    required this.stage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  UniverseState copyWith({
    double? gravity,
    double? emForce,
    double? nuclearForce,
    double? entropyRate,
    double? darkEnergyPressure,
    UniverseOutcome? outcome,
    UniverseStage? stage,
  }) {
    return UniverseState(
      gravity: gravity ?? this.gravity,
      emForce: emForce ?? this.emForce,
      nuclearForce: nuclearForce ?? this.nuclearForce,
      entropyRate: entropyRate ?? this.entropyRate,
      darkEnergyPressure: darkEnergyPressure ?? this.darkEnergyPressure,
      outcome: outcome ?? this.outcome,
      stage: stage ?? this.stage,
      timestamp: this.timestamp,
    );
  }
}
