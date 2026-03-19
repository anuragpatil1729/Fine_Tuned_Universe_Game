// CHANGES MADE:
// 1. Updated the initialization to support the new 5 fundamental constants (including entropy and dark energy).
// 2. Added `updateEntropyRate` and `updateDarkEnergy` methods to allow player intervention in the new stages.
// 3. Updated `nextStage` logic to advance through the expanded 6-stage lifecycle (cosmicDawn to cosmicFate).
// 4. Integrated the new `SimulationEngine.calculateOutcome` call with all 5 parameters.
// 5. Maintained the history of previous universes to support the Home Screen's "Previous universes" readout.

import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../core/simulation_engine.dart';
import '../models/universe_state.dart';

class SimulationService extends ChangeNotifier {
  UniverseState _currentUniverse = UniverseState(
    gravity: 0.5,
    emForce: 0.5,
    nuclearForce: 0.5,
    entropyRate: 0.5,
    darkEnergyPressure: 0.5,
    outcome: UniverseOutcome.none,
    stage: UniverseStage.cosmicDawn,
  );

  final List<UniverseState> _history = [];

  UniverseState get currentUniverse => _currentUniverse;
  List<UniverseState> get history => List.unmodifiable(_history);

  void updateGravity(double value) {
    _currentUniverse = _currentUniverse.copyWith(gravity: value);
    notifyListeners();
  }

  void updateNuclearForce(double value) {
    _currentUniverse = _currentUniverse.copyWith(nuclearForce: value);
    notifyListeners();
  }

  void updateEMForce(double value) {
    _currentUniverse = _currentUniverse.copyWith(emForce: value);
    notifyListeners();
  }

  void updateEntropyRate(double value) {
    _currentUniverse = _currentUniverse.copyWith(entropyRate: value);
    notifyListeners();
  }

  void updateDarkEnergy(double value) {
    _currentUniverse = _currentUniverse.copyWith(darkEnergyPressure: value);
    notifyListeners();
  }

  void nextStage() {
    if (_currentUniverse.stage == UniverseStage.stellarDeath) {
      // Transition to Cosmic Fate
      final outcome = SimulationEngine.calculateOutcome(
        _currentUniverse.gravity,
        _currentUniverse.nuclearForce,
        _currentUniverse.emForce,
        _currentUniverse.entropyRate,
        _currentUniverse.darkEnergyPressure,
      );

      _currentUniverse = _currentUniverse.copyWith(
        outcome: outcome,
        stage: UniverseStage.cosmicFate,
      );
      
      _history.add(_currentUniverse);
    } else if (_currentUniverse.stage != UniverseStage.cosmicFate) {
      final nextIndex = _currentUniverse.stage.index + 1;
      _currentUniverse = _currentUniverse.copyWith(
        stage: UniverseStage.values[nextIndex],
      );
    }
    notifyListeners();
  }

  void reset() {
    _currentUniverse = UniverseState(
      gravity: 0.5,
      emForce: 0.5,
      nuclearForce: 0.5,
      entropyRate: 0.5,
      darkEnergyPressure: 0.5,
      outcome: UniverseOutcome.none,
      stage: UniverseStage.cosmicDawn,
    );
    notifyListeners();
  }
}
