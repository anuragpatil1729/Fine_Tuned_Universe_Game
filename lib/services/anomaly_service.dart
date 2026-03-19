// FEATURE: Civilization Layer // WHAT CHANGED: Added "THE WARRING FACTIONS" anomaly and implemented `resetAll()`. // WHY: To expand challenge runs into the civilization phase and provide a way to clear all progress.

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
    Anomaly(
      id: "warring_factions",
      name: "THE WARRING FACTIONS",
      flavorText: "They never learned to trust each other.",
      description: "Cooperation index locked at 0.20. Achieve Transcendence despite internal conflict.",
      type: AnomalyType.lockedParameter,
      lockedConstants: {"cooperation": 0.20},
      badgeLabel: "Unlikely Savior",
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
    
    if (_activeAnomaly!.id == "frozen_clock") {
      if (outcome == UniverseOutcome.eternalGarden) isSuccess = true;
    } else if (_activeAnomaly!.id == "warring_factions") {
      if (outcome == UniverseOutcome.transcendence) isSuccess = true;
    } else {
      if (outcome == UniverseOutcome.eternalGarden || outcome == UniverseOutcome.transcendence) {
        isSuccess = true;
      }
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

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < _anomalies.length; i++) {
      _anomalies[i] = _anomalies[i].copyWith(isCompleted: false);
      await prefs.remove('anomaly_done_${_anomalies[i].id}');
    }
    notifyListeners();
  }
}
