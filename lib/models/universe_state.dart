import '../core/constants.dart';

class UniverseState {
  final double gravity;
  final double emForce;
  final double nuclearForce;
  final UniverseOutcome outcome;
  final UniverseStage stage;
  final DateTime timestamp;

  UniverseState({
    required this.gravity,
    required this.emForce,
    required this.nuclearForce,
    required this.outcome,
    required this.stage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  UniverseState copyWith({
    double? gravity,
    double? emForce,
    double? nuclearForce,
    UniverseOutcome? outcome,
    UniverseStage? stage,
  }) {
    return UniverseState(
      gravity: gravity ?? this.gravity,
      emForce: emForce ?? this.emForce,
      nuclearForce: nuclearForce ?? this.nuclearForce,
      outcome: outcome ?? this.outcome,
      stage: stage ?? this.stage,
      timestamp: this.timestamp,
    );
  }
}
