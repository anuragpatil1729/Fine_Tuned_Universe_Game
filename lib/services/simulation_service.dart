import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../core/simulation_engine.dart';
import '../models/universe_state.dart';

class SimulationService extends ChangeNotifier {
  UniverseState _currentUniverse = UniverseState(
    gravity: 0.5,
    emForce: 0.5,
    nuclearForce: 0.5,
    outcome: UniverseOutcome.none,
    stage: UniverseStage.bigBang,
  );

  final List<UniverseState> _history = [];

  UniverseState get currentUniverse => _currentUniverse;
  List<UniverseState> get history => List.unmodifiable(_history);

  void updateGravity(double value) {
    _currentUniverse = _currentUniverse.copyWith(gravity: value);
    notifyListeners();
  }

  void updateEMForce(double value) {
    _currentUniverse = _currentUniverse.copyWith(emForce: value);
    notifyListeners();
  }

  void updateNuclearForce(double value) {
    _currentUniverse = _currentUniverse.copyWith(nuclearForce: value);
    notifyListeners();
  }

  void nextStage() {
    if (_currentUniverse.stage == UniverseStage.emergenceOfLife) {
      finishSimulation();
      return;
    }

    final nextIndex = _currentUniverse.stage.index + 1;
    _currentUniverse = _currentUniverse.copyWith(
      stage: UniverseStage.values[nextIndex],
    );
    notifyListeners();
  }

  void finishSimulation() {
    final outcome = SimulationEngine.calculateOutcome(
      _currentUniverse.gravity,
      _currentUniverse.emForce,
      _currentUniverse.nuclearForce,
    );

    _currentUniverse = _currentUniverse.copyWith(
      outcome: outcome,
      stage: UniverseStage.finished,
    );

    _history.add(_currentUniverse);
    notifyListeners();
  }

  void reset() {
    _currentUniverse = UniverseState(
      gravity: 0.5,
      emForce: 0.5,
      nuclearForce: 0.5,
      outcome: UniverseOutcome.none,
      stage: UniverseStage.bigBang,
    );
    notifyListeners();
  }
}
