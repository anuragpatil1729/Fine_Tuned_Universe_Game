// FEATURE: Session Persistence // WHAT CHANGED: Created PersistenceService to handle JSON serialization of universe history using SharedPreferences. // WHY: To ensure player progress and the Multiverse Observatory persist across app launches.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/universe_state.dart';
import '../core/constants.dart';

class PersistenceService {
  static const String _historyKey = 'universe_history';
  static const int _maxSavedUniverses = 50;

  static Future<void> saveHistory(List<UniverseState> history) async {
    final prefs = await SharedPreferences.getInstance();
    // Save only the most recent N universes to manage storage
    final encoded = history
        .reversed
        .take(_maxSavedUniverses)
        .toList()
        .reversed
        .map((u) => _encodeState(u))
        .toList();
    await prefs.setString(_historyKey, jsonEncode(encoded));
  }

  static Future<List<UniverseState>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => _decodeState(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Map<String, dynamic> _encodeState(UniverseState u) {
    return {
      'gravity': u.gravity,
      'emForce': u.emForce,
      'nuclearForce': u.nuclearForce,
      'entropyRate': u.entropyRate,
      'darkEnergyPressure': u.darkEnergyPressure,
      'cooperationIndex': u.cooperationIndex,
      'energyConsumption': u.energyConsumption,
      'dna': u.dna,
      'outcome': u.outcome.index,
      'stage': u.stage.index,
      'timestamp': u.timestamp.toIso8601String(),
    };
  }

  static UniverseState _decodeState(Map<String, dynamic> map) {
    return UniverseState(
      gravity: (map['gravity'] as num?)?.toDouble() ?? 0.5,
      emForce: (map['emForce'] as num?)?.toDouble() ?? 0.5,
      nuclearForce: (map['nuclearForce'] as num?)?.toDouble() ?? 0.5,
      entropyRate: (map['entropyRate'] as num?)?.toDouble() ?? 0.5,
      darkEnergyPressure: (map['darkEnergyPressure'] as num?)?.toDouble() ?? 0.5,
      cooperationIndex: (map['cooperationIndex'] as num?)?.toDouble() ?? 0.5,
      energyConsumption: (map['energyConsumption'] as num?)?.toDouble() ?? 0.5,
      dna: map['dna'] as String? ?? '',
      outcome: UniverseOutcome.values[(map['outcome'] as int? ?? 0)
          .clamp(0, UniverseOutcome.values.length - 1)],
      stage: UniverseStage.values[(map['stage'] as int? ?? 0)
          .clamp(0, UniverseStage.values.length - 1)],
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
