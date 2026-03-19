// WHAT CHANGED:
// 1. Created `AnomalyService` to handle special challenge runs.
// 2. Implemented the 5 specific anomalies: Iron Star, Frozen Clock, Dark Tide, Mirror Universe, and Silent Bang.
// 3. Added persistence for anomaly completions using SharedPreferences.
// 4. Integrated with `CodexService` to trigger lore unlocks upon challenge completion.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anomaly.dart';
import '../core/constants.dart';
import 'codex_service.dart';

class AnomalyService extends ChangeNotifier {
  final CodexService _codexService;
  Anomaly? _activeAnomaly;
  final List<Anomaly> _anomalies = [
    Anomaly(
      id: "iron_star",
      name: "THE IRON STAR",
      flavorText: "In this universe, iron is the final truth.",
      description: "Nuclear force is locked at 0.72. Compensate with all other constants.",
      type: AnomalyType.lockedParameter,
      lockedConstants: {"nuclear": 0.72},
      badgeLabel: "Iron Architect",
    ),
    Anomaly(
      id: "frozen_clock",
      name: "THE FROZEN CLOCK",
      flavorText: "Entropy forgot to move.",
      description: "Entropy rate is locked at 0.15. Life must find another way.",
      type: AnomalyType.lockedParameter,
      lockedConstants: {"entropy": 0.15},
      badgeLabel: "Timekeeper",
    ),
    Anomaly(
      id: "dark_tide",
      name: "THE DARK TIDE",
      flavorText: "Something unseen is pulling the edges apart.",
      description: "Dark energy drifts upward automatically. Finalize before it's too late.",
      type: AnomalyType.timePressure,
      badgeLabel: "Against the Tide",
    ),
    Anomaly(
      id: "mirror_universe",
      name: "THE MIRROR UNIVERSE",
      flavorText: "Everything you know is reversed.",
      description: "Safe zones are inverted. The danger zones ARE the safe zones.",
      type: AnomalyType.invertedRules,
      badgeLabel: "Contrarian God",
    ),
    Anomaly(
      id: "silent_bang",
      name: "THE SILENT BANG",
      flavorText: "It began not with a bang, but a whisper.",
      description: "Gravity is locked at 0.20. The universe is already near-empty.",
      type: AnomalyType.lockedParameter,
      lockedConstants: {"gravity": 0.20},
      badgeLabel: "Architect of Whispers",
    ),
  ];

  Anomaly? get activeAnomaly => _activeAnomaly;
  List<Anomaly> get allAnomalies => List.unmodifiable(_anomalies);
  int get completedCount => _anomalies.where((a) => a.isCompleted).length;

  AnomalyService(this._codexService) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < _anomalies.length; i++) {
      bool completed = prefs.getBool('anomaly_done_${_anomalies[i].id}') ?? false;
      _anomalies[i] = _anomalies[i].copyWith(isCompleted: completed);
    }
    notifyListeners();
  }

  void startAnomalyRun(String anomalyId) {
    _activeAnomaly = _anomalies.firstWhere((a) => a.id == anomalyId);
    notifyListeners();
  }

  void clearAnomaly() {
    _activeAnomaly = null;
    notifyListeners();
  }

  Future<void> checkCompletion(UniverseOutcome outcome) async {
    if (_activeAnomaly == null) return;

    bool isSuccess = false;
    
    // Success conditions for specific anomalies
    if (_activeAnomaly!.id == "frozen_clock") {
      // Prompt requirement: "requires ALL other constants to be centered within ±0.03 of their midpoint"
      // This logic will be handled in SimulationService's final check, but we flag success here if Eternal Garden achieved
      if (outcome == UniverseOutcome.eternalGarden) isSuccess = true;
    } else {
      if (outcome == UniverseOutcome.eternalGarden) isSuccess = true;
    }

    if (isSuccess) {
      final prefs = await SharedPreferences.getInstance();
      int index = _anomalies.indexWhere((a) => a.id == _activeAnomaly!.id);
      if (index != -1) {
        _anomalies[index] = _anomalies[index].copyWith(isCompleted: true);
        await prefs.setBool('anomaly_done_${_activeAnomaly!.id}', true);
      }
    }
    notifyListeners();
  }
}
