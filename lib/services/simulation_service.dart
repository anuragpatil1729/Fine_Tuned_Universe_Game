// FEATURE: Session Persistence // WHAT CHANGED: Added `initAsync`, `clearAllHistory`, and integrated `PersistenceService` into the simulation lifecycle. Refactored `nextStage` to support the civilization layer. // WHY: To enable data persistence across app launches and implement the transition to the civilization-specific stages.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../core/simulation_engine.dart';
import '../core/universe_dna.dart';
import '../models/universe_state.dart';
import '../models/anomaly.dart';
import 'codex_service.dart';
import 'anomaly_service.dart';
import 'persistence_service.dart';

class SimulationService extends ChangeNotifier {
  final CodexService _codexService;
  final AnomalyService _anomalyService;

  UniverseState _currentUniverse = UniverseState(
    gravity: 0.5,
    emForce: 0.5,
    nuclearForce: 0.5,
    entropyRate: 0.5,
    darkEnergyPressure: 0.5,
    cooperationIndex: 0.5,
    energyConsumption: 0.5,
    outcome: UniverseOutcome.none,
    stage: UniverseStage.cosmicDawn,
  );

  final List<UniverseState> _history = [];
  bool _persistenceLoaded = false;
  Timer? _driftTimer;

  SimulationService(this._codexService, this._anomalyService);

  UniverseState get currentUniverse => _currentUniverse;
  List<UniverseState> get history => List.unmodifiable(_history);
  bool get civilizationUnlocked => _history.any((u) => u.outcome == UniverseOutcome.eternalGarden);

  Future<void> initAsync() async {
    if (_persistenceLoaded) return;
    _persistenceLoaded = true;
    final saved = await PersistenceService.loadHistory();
    _history.addAll(saved);
    notifyListeners();
  }

  void clearAllHistory() {
    _history.clear();
    PersistenceService.clearHistory();
    notifyListeners();
  }

  bool get _isMirror => _anomalyService.activeAnomaly?.id == "mirror_universe";
  bool get _isIronStar => _anomalyService.activeAnomaly?.id == "iron_star";
  bool get _isSilentBang => _anomalyService.activeAnomaly?.id == "silent_bang";

  // Effective Safe Zones
  double get effectiveGravityMin => _isMirror 
    ? GameConstants.gravityMax + 0.15 
    : (_isIronStar ? GameConstants.gravityMin + 0.05 : GameConstants.gravityMin);
  double get effectiveGravityMax => _isMirror ? 1.0 : GameConstants.gravityMax;

  double get effectiveNuclearMin => _isMirror 
    ? GameConstants.nuclearForceMax + 0.15
    : (_isSilentBang ? 0.30 : GameConstants.nuclearForceMin);
  double get effectiveNuclearMax => _isMirror ? 1.0 : (_isSilentBang ? 0.70 : GameConstants.nuclearForceMax);

  double get effectiveEmMin => _isMirror ? GameConstants.emForceMax + 0.15 : GameConstants.emForceMin;
  double get effectiveEmMax => _isMirror ? 1.0 : GameConstants.emForceMax;

  double get effectiveEntropyMin => _isMirror ? GameConstants.entropyRateMax + 0.15 : GameConstants.entropyRateMin;
  double get effectiveEntropyMax => _isMirror ? 1.0 : GameConstants.entropyRateMax;

  double get effectiveDarkEnergyMin => _isMirror ? GameConstants.darkEnergyMax + 0.15 : GameConstants.darkEnergyMin;
  double get effectiveDarkEnergyMax => _isMirror ? 1.0 : GameConstants.darkEnergyMax;

  double get effectiveCooperationMin => GameConstants.cooperationMin;
  double get effectiveCooperationMax => GameConstants.cooperationMax;
  double get effectiveEnergyMin => GameConstants.energyConsumptionMin;
  double get effectiveEnergyMax => GameConstants.energyConsumptionMax;

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

  void updateGravity(double value) => _updateState(_currentUniverse.copyWith(gravity: value));
  void updateEMForce(double value) => _updateState(_currentUniverse.copyWith(emForce: value));
  void updateNuclearForce(double value) => _updateState(_currentUniverse.copyWith(nuclearForce: value));
  void updateEntropyRate(double value) => _updateState(_currentUniverse.copyWith(entropyRate: value));
  void updateDarkEnergy(double value) => _updateState(_currentUniverse.copyWith(darkEnergyPressure: value));
  void updateCooperation(double value) => _updateState(_currentUniverse.copyWith(cooperationIndex: value));
  void updateEnergyConsumption(double value) => _updateState(_currentUniverse.copyWith(energyConsumption: value));

  void _updateState(UniverseState newState) {
    _currentUniverse = newState;
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
          notifyListeners();
        }
      });
    }
  }

  void nextStage() {
    _codexService.checkAndUnlock(_currentUniverse, _currentUniverse.stage);

    if (_currentUniverse.stage == UniverseStage.stellarDeath) {
      final initialOutcome = SimulationEngine.calculateOutcome(
        _currentUniverse.gravity,
        _currentUniverse.nuclearForce,
        _currentUniverse.emForce,
        _currentUniverse.entropyRate,
        _currentUniverse.darkEnergyPressure,
      );

      if (initialOutcome == UniverseOutcome.eternalGarden && civilizationUnlocked) {
        _currentUniverse = _currentUniverse.copyWith(stage: UniverseStage.civilizationDawn);
      } else {
        _finishSimulation(initialOutcome, UniverseStage.cosmicFate);
      }
    } else if (_currentUniverse.stage == UniverseStage.technologicalAge) {
      final civOutcome = SimulationEngine.calculateCivilizationOutcome(
        _currentUniverse.cooperationIndex,
        _currentUniverse.energyConsumption,
      );
      _finishSimulation(civOutcome, UniverseStage.cosmicLegacy);
    } else if (_currentUniverse.stage == UniverseStage.cosmicLegacy) {
      // Logic for finalizing if needed, though cosmicLegacy is final state.
      // The requirement says cosmicLegacy is READ ONLY - final fate.
    } else {
      final nextIndex = _currentUniverse.stage.index + 1;
      _currentUniverse = _currentUniverse.copyWith(stage: UniverseStage.values[nextIndex]);
    }
    notifyListeners();
  }

  void _finishSimulation(UniverseOutcome outcome, UniverseStage finalStage) {
    _driftTimer?.cancel();
    final dna = UniverseDNA.generate(
      _currentUniverse.gravity,
      _currentUniverse.nuclearForce,
      _currentUniverse.emForce,
      _currentUniverse.entropyRate,
      _currentUniverse.darkEnergyPressure,
    );

    _currentUniverse = _currentUniverse.copyWith(
      outcome: outcome,
      stage: finalStage,
      dna: dna,
    );

    _history.add(_currentUniverse);
    PersistenceService.saveHistory(_history);
    _codexService.checkAndUnlock(_currentUniverse, _currentUniverse.stage);
    _anomalyService.checkCompletion(outcome);
  }

  void loadFromDNA(Map<String, double> constants) {
    _driftTimer?.cancel();
    _currentUniverse = UniverseState(
      gravity: constants['gravity'] ?? 0.5,
      emForce: constants['em'] ?? 0.5,
      nuclearForce: constants['nuclear'] ?? 0.5,
      entropyRate: constants['entropy'] ?? 0.5,
      darkEnergyPressure: constants['darkEnergy'] ?? 0.5,
      outcome: UniverseOutcome.none,
      stage: UniverseStage.cosmicDawn,
    );
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
      cooperationIndex: anomaly?.lockedConstants["cooperation"] ?? 0.5,
      energyConsumption: 0.5,
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
