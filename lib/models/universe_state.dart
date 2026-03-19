// FEATURE: Civilization Layer // WHAT CHANGED: Added cooperationIndex and energyConsumption fields. // WHY: To track civilization-specific tuning parameters in the second phase of the game.

import '../core/constants.dart';

class UniverseState {
  final double gravity;
  final double emForce;
  final double nuclearForce;
  final double entropyRate;
  final double darkEnergyPressure;
  final double cooperationIndex;
  final double energyConsumption;
  final String dna;
  final UniverseOutcome outcome;
  final UniverseStage stage;
  final DateTime timestamp;

  UniverseState({
    required this.gravity,
    required this.emForce,
    required this.nuclearForce,
    this.entropyRate = 0.5,
    this.darkEnergyPressure = 0.5,
    this.cooperationIndex = 0.5,
    this.energyConsumption = 0.5,
    this.dna = '',
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
    double? cooperationIndex,
    double? energyConsumption,
    String? dna,
    UniverseOutcome? outcome,
    UniverseStage? stage,
  }) {
    return UniverseState(
      gravity: gravity ?? this.gravity,
      emForce: emForce ?? this.emForce,
      nuclearForce: nuclearForce ?? this.nuclearForce,
      entropyRate: entropyRate ?? this.entropyRate,
      darkEnergyPressure: darkEnergyPressure ?? this.darkEnergyPressure,
      cooperationIndex: cooperationIndex ?? this.cooperationIndex,
      energyConsumption: energyConsumption ?? this.energyConsumption,
      dna: dna ?? this.dna,
      outcome: outcome ?? this.outcome,
      stage: stage ?? this.stage,
      timestamp: this.timestamp,
    );
  }
}
