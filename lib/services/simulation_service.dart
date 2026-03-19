// CHANGES MADE:
// 1. Added `_interventions` counter (max 3) to track player's ability to fix previous stages.
// 2. Implemented `useIntervention()` logic with a 5-second Timer to temporarily unlock constants.
// 3. Added `gravityLocked`, `nuclearLocked`, and `emLocked` flags based on the current stage.
// 4. Implemented Cascading Logic: gravity > 0.7 shrinks nuclear safe zone; nuclear > 0.65 shrinks EM safe zone.
// 5. Added dynamic safe zone getters (`nuclearSafeMin/Max`, `emSafeMin/Max`) for real-time UI rendering.
// 6. Added `hintUnlocked` getter based on multiverse memory (3+ failed runs).
// 7. Added `isFailingTrajectory` to trigger global UI warnings when interventions are exhausted.

import 'dart:async';
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
  int _interventions = 3;
  Timer? _unlockTimer;
  
  // Temporal unlock states
  bool _gravityOverride = false;
  bool _nuclearOverride = false;
  bool _emOverride = false;

  UniverseState get currentUniverse => _currentUniverse;
  List<UniverseState> get history => List.unmodifiable(_history);
  int get interventions => _interventions;

  // PILLAR 2: Locking previous constants
  bool get gravityLocked => _currentUniverse.stage != UniverseStage.bigBang && !_gravityOverride;
  bool get nuclearLocked => (_currentUniverse.stage != UniverseStage.starFormation && _currentUniverse.stage != UniverseStage.planetFormation) && !_nuclearOverride;
  bool get emLocked => _currentUniverse.stage != UniverseStage.emergenceOfLife && !_emOverride;

  // PILLAR 3: Dynamic Safe Zones (Cascading)
  double get nuclearSafeMin => GameConstants.nuclearForceMin + (_currentUniverse.gravity > 0.7 ? 0.05 : 0.0);
  double get nuclearSafeMax => GameConstants.nuclearForceMax - (_currentUniverse.gravity > 0.7 ? 0.05 : 0.0);
  
  double get emSafeMin => GameConstants.emForceMin + (_currentUniverse.nuclearForce > 0.65 ? 0.05 : 0.0);
  double get emSafeMax => GameConstants.emForceMax - (_currentUniverse.nuclearForce > 0.65 ? 0.05 : 0.0);

  bool get isFailingTrajectory {
    final g = _currentUniverse.gravity;
    final n = _currentUniverse.nuclearForce;
    final e = _currentUniverse.emForce;
    
    bool gravityFailed = g < GameConstants.gravityMin || g > GameConstants.gravityMax;
    bool nuclearFailed = n < nuclearSafeMin || n > nuclearSafeMax;
    bool emFailed = e < emSafeMin || e > emSafeMax;
    
    return interventions == 0 && (gravityFailed || nuclearFailed || emFailed);
  }

  // PILLAR 4: Multiverse Memory Hint
  bool get hintUnlocked => _history.where((u) => u.outcome != UniverseOutcome.lifeSupporting && u.outcome != UniverseOutcome.none).length >= 3;

  void updateGravity(double value) {
    if (gravityLocked) return;
    _currentUniverse = _currentUniverse.copyWith(gravity: value);
    notifyListeners();
  }

  void updateEMForce(double value) {
    if (emLocked) return;
    _currentUniverse = _currentUniverse.copyWith(emForce: value);
    notifyListeners();
  }

  void updateNuclearForce(double value) {
    if (nuclearLocked) return;
    _currentUniverse = _currentUniverse.copyWith(nuclearForce: value);
    notifyListeners();
  }

  // PILLAR 2: Intervention Mechanism
  void useIntervention(String constant) {
    if (_interventions <= 0) return;
    
    _interventions--;
    _unlockTimer?.cancel();

    if (constant == 'gravity') _gravityOverride = true;
    if (constant == 'nuclear') _nuclearOverride = true;
    if (constant == 'em') _emOverride = true;

    notifyListeners();

    _unlockTimer = Timer(const Duration(seconds: 5), () {
      _gravityOverride = false;
      _nuclearOverride = false;
      _emOverride = false;
      notifyListeners();
    });
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
    _unlockTimer?.cancel();
    _interventions = 3;
    _gravityOverride = false;
    _nuclearOverride = false;
    _emOverride = false;
    _currentUniverse = UniverseState(
      gravity: 0.5,
      emForce: 0.5,
      nuclearForce: 0.5,
      outcome: UniverseOutcome.none,
      stage: UniverseStage.bigBang,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _unlockTimer?.cancel();
    super.dispose();
  }
}
