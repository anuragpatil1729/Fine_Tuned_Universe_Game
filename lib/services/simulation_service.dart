// CHANGES MADE:
// 1. Injected `CodexService` and `AnomalyService` for integrated progression and challenge logic.
// 2. Implemented the "Whisper System" logic in `currentWhisper` to provide atmospheric feedback.
// 3. Added Anomaly handling:
//    - "Dark Tide": Timer-based dark energy drift.
//    - Locked constants: Prevention of editing when an anomaly dictates a fixed value.
//    - Completion checking: Calling `anomalyService.checkCompletion` upon finishing.
// 4. Integrated Codex unlocking: Calling `codexService.checkAndUnlock` at every stage advance.
// 5. Added safe zone getters that adapt to active anomalies (Mirror Universe, Silent Bang, etc.).

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../core/simulation_engine.dart';
import '../models/universe_state.dart';
import '../models/anomaly.dart';
import 'codex_service.dart';
import 'anomaly_service.dart';

class SimulationService extends ChangeNotifier {
  final CodexService _codexService;
  final AnomalyService _anomalyService;

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
  Timer? _driftTimer;

  SimulationService(this._codexService, this._anomalyService);

  UniverseState get currentUniverse => _currentUniverse;
  List<UniverseState> get history => List.unmodifiable(_history);

  // PILLAR: Anomaly Safe Zones
  double get gravityMin => _isMirror ? 0.0 : (_isSilentBang ? GameConstants.gravityMin : GameConstants.gravityMin);
  // Prompt says: "Silent Bang: nuclearForce safe zone widens to 0.30–0.70"
  // Prompt says: "Iron Star: Safe zone for gravity narrows by 0.05 on each side"
  double get effectiveGravityMin => _isIronStar ? GameConstants.gravityMin + 0.05 : GameConstants.gravityMin;
  double get effectiveGravityMax => _isIronStar ? GameConstants.gravityMax - 0.05 : GameConstants.gravityMax;
  
  double get effectiveNuclearMin => _isSilentBang ? 0.30 : GameConstants.nuclearForceMin;
  double get effectiveNuclearMax => _isSilentBang ? 0.70 : GameConstants.nuclearForceMax;

  bool get _isMirror => _anomalyService.activeAnomaly?.id == "mirror_universe";
  bool get _isIronStar => _anomalyService.activeAnomaly?.id == "iron_star";
  bool get _isSilentBang => _anomalyService.activeAnomaly?.id == "silent_bang";

  // PILLAR: Whisper System
  String get currentWhisper {
    final u = _currentUniverse;
    if (u.gravity > 0.65) return "I feel myself folding... there is no escape from what I am becoming.";
    if (u.gravity < 0.35) return "I reach for myself but find only silence. Too much space between my thoughts.";
    if (u.nuclearForce > 0.70) return "My stars are screaming. They are burning too bright, too fast. They will not last the night.";
    if (u.nuclearForce < 0.30) return "The hydrogen sits cold and still. Nothing wants to fuse. No light will come.";
    if (u.emForce > 0.70) return "Atoms repel each other like old enemies. Chemistry is dying.";
    if (u.emForce < 0.30) return "Matter passes through matter. Nothing holds. Nothing bonds. Nothing lasts.";
    if (u.entropyRate > 0.70) return "I am unraveling. Complexity burns away faster than it can dream.";
    if (u.entropyRate < 0.30) return "Time has nearly stopped. My worlds are frozen in amber, afraid to change.";
    if (u.darkEnergyPressure > 0.75) return "I am being torn apart by my own expansion. The edge of me is already gone.";
    if (u.darkEnergyPressure < 0.25) return "My own gravity is winning. I am contracting. The end rushes toward the beginning.";

    bool allSafe = u.gravity >= GameConstants.gravityMin && u.gravity <= GameConstants.gravityMax &&
                   u.nuclearForce >= GameConstants.nuclearForceMin && u.nuclearForce <= GameConstants.nuclearForceMax &&
                   u.emForce >= GameConstants.emForceMin && u.emForce <= GameConstants.emForceMax &&
                   u.entropyRate >= GameConstants.entropyRateMin && u.entropyRate <= GameConstants.entropyRateMax &&
                   u.darkEnergyPressure >= GameConstants.darkEnergyMin && u.darkEnergyPressure <= GameConstants.darkEnergyMax;
    
    if (allSafe) return "... I feel it. The quiet hum of something that wants to live.";
    
    return "";
  }

  bool isLocked(String id) {
    return _anomalyService.activeAnomaly?.lockedConstants.containsKey(id) ?? false;
  }

  void updateGravity(double value) {
    if (isLocked("gravity")) return;
    _currentUniverse = _currentUniverse.copyWith(gravity: value);
    notifyListeners();
  }

  void updateNuclearForce(double value) {
    if (isLocked("nuclear")) return;
    _currentUniverse = _currentUniverse.copyWith(nuclearForce: value);
    notifyListeners();
  }

  void updateEMForce(double value) {
    if (isLocked("em")) return;
    _currentUniverse = _currentUniverse.copyWith(emForce: value);
    notifyListeners();
  }

  void updateEntropyRate(double value) {
    if (isLocked("entropy")) return;
    _currentUniverse = _currentUniverse.copyWith(entropyRate: value);
    notifyListeners();
  }

  void updateDarkEnergy(double value) {
    if (isLocked("darkEnergy")) return;
    _currentUniverse = _currentUniverse.copyWith(darkEnergyPressure: value);
    notifyListeners();
  }

  void _startDriftTimer() {
    _driftTimer?.cancel();
    if (_anomalyService.activeAnomaly?.id == "dark_tide") {
      _driftTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_currentUniverse.darkEnergyPressure < 1.0) {
          _currentUniverse = _currentUniverse.copyWith(
            darkEnergyPressure: (_currentUniverse.darkEnergyPressure + 0.002).clamp(0.0, 1.0),
          );
          if (_currentUniverse.darkEnergyPressure > 0.80) {
             // Dark energy exceeds threshold in Dark Tide
          }
          notifyListeners();
        }
      });
    }
  }

  void nextStage() {
    _codexService.checkAndUnlock(_currentUniverse, _currentUniverse.stage);

    if (_currentUniverse.stage == UniverseStage.stellarDeath) {
      finishSimulation();
    } else if (_currentUniverse.stage != UniverseStage.cosmicFate) {
      final nextIndex = _currentUniverse.stage.index + 1;
      _currentUniverse = _currentUniverse.copyWith(
        stage: UniverseStage.values[nextIndex],
      );
    }
    notifyListeners();
  }

  void finishSimulation() {
    _driftTimer?.cancel();
    
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
    _codexService.checkAndUnlock(_currentUniverse, _currentUniverse.stage);
    _anomalyService.checkCompletion(outcome);
    notifyListeners();
  }

  void reset() {
    _driftTimer?.cancel();
    final anomaly = _anomalyService.activeAnomaly;
    
    _currentUniverse = UniverseState(
      gravity: anomaly?.lockedConstants["gravity"] ?? 0.5,
      emForce: anomaly?.lockedConstants["em"] ?? 0.5,
      nuclearForce: anomaly?.lockedConstants["nuclear"] ?? 0.5,
      entropyRate: anomaly?.lockedConstants["entropy"] ?? 0.5,
      darkEnergyPressure: anomaly?.lockedConstants["darkEnergy"] ?? 0.5,
      outcome: UniverseOutcome.none,
      stage: UniverseStage.cosmicDawn,
    );

    if (anomaly?.id == "dark_tide") _startDriftTimer();
    
    notifyListeners();
  }

  @override
  void dispose() {
    _driftTimer?.cancel();
    super.dispose();
  }
}
