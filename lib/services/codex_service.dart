// CHANGES MADE:
// 1. Fixed the `Icons.Grain` error (Icons are lowercase by convention in Flutter, e.g., `Icons.grain`).
// 2. Implemented `CodexService` to manage the lifecycle of cosmic lore.
// 3. Added persistence for unlocked entries using `shared_preferences`.
// 4. Implemented `checkAndUnlock` logic to match game state against 12 specific lore triggers.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/codex_entry.dart';
import '../models/universe_state.dart';
import '../core/constants.dart';

class CodexService extends ChangeNotifier {
  final List<CodexEntry> _entries = [
    CodexEntry(
      id: "gravity_collapse",
      title: "The Schwarzschild Limit",
      body: "When gravity overwhelms all other forces, spacetime curves back on itself. Not even light can negotiate with such density. The universe becomes its own tomb.",
      unlockCondition: "Witness a Great Collapse outcome.",
      icon: Icons.brightness_3,
      accentColor: Colors.red,
    ),
    CodexEntry(
      id: "nuclear_burn",
      title: "The Chandrasekhar Paradox",
      body: "Stars are not permanent. They are controlled explosions — a negotiation between gravity and fusion. When nuclear fire burns too hot, stars live brilliant, brutal, short lives.",
      unlockCondition: "Push the Nuclear Force beyond 0.70.",
      icon: Icons.local_fire_department,
      accentColor: Colors.orange,
    ),
    CodexEntry(
      id: "cold_universe",
      title: "The Dark Freeze",
      body: "A universe without fusion is a universe without light. Hydrogen clouds drift forever — vast, cold, patient. Nothing ever catches fire.",
      unlockCondition: "Observe Nuclear Force below 0.30.",
      icon: Icons.ac_unit,
      accentColor: Colors.lightBlue,
    ),
    CodexEntry(
      id: "em_chaos",
      title: "The Ionic Barrier",
      body: "Electromagnetism is the architect of chemistry. Without its precise calibration, electrons refuse to orbit nuclei — atoms remain strangers, chemistry dies unborn.",
      unlockCondition: "Set EM Force above 0.70.",
      icon: Icons.grain,
      accentColor: Colors.cyan,
    ),
    CodexEntry(
      id: "entropy_life",
      title: "The Arrow of Time",
      body: "Life is an entropy machine — it builds order locally by creating disorder everywhere else. The right entropy rate is the thin knife-edge between crystalline stasis and thermal chaos.",
      unlockCondition: "Successfully grow an Eternal Garden.",
      icon: Icons.hourglass_empty,
      accentColor: Colors.green,
    ),
    CodexEntry(
      id: "dark_expansion",
      title: "The Phantom Force",
      body: "Dark energy is the universe's acceleration. It does not push or pull — it stretches the fabric of space itself, separating galaxies beyond any possible reunion.",
      unlockCondition: "Witness Dark Energy exceeding 0.75.",
      icon: Icons.open_in_full,
      accentColor: Colors.blueAccent,
    ),
    CodexEntry(
      id: "knife_edge",
      title: "The Anthropic Razor",
      body: "The probability of all fundamental constants simultaneously landing in life-permitting ranges by chance is vanishingly small. This implies deep underlying order.",
      unlockCondition: "Trigger the Eternal Recurrence loop.",
      icon: Icons.balance,
      accentColor: Colors.purple,
    ),
    CodexEntry(
      id: "last_light_entry",
      title: "The Kardashev Limit",
      body: "A civilization that burns bright consumes faster than it creates. The Last Light universes are the mayflies of the multiverse — brief and blazing.",
      unlockCondition: "Reach the Last Light ending.",
      icon: Icons.wb_incandescent_outlined,
      accentColor: Colors.amber,
    ),
    CodexEntry(
      id: "galaxy_formation",
      title: "The Jeans Instability",
      body: "Galaxies do not assemble randomly. When gas clouds exceed a critical density, gravity wins over pressure and collapse begins — the first act of every spiral arm.",
      unlockCondition: "Reach the Galactic Age.",
      icon: Icons.auto_awesome_motion,
      accentColor: Colors.blueGrey,
    ),
    CodexEntry(
      id: "life_emergence",
      title: "The RNA World",
      body: "The first self-replicating molecule didn't care about meaning. It simply copied itself. From that chemical accident, four billion years of complexity followed.",
      unlockCondition: "Reach the Life Age.",
      icon: Icons.biotech,
      accentColor: Colors.lightGreenAccent,
    ),
    CodexEntry(
      id: "stellar_death",
      title: "We Are Stardust",
      body: "Every atom of carbon in your body was forged in the nuclear furnace of a star that died before your sun was born. Stellar death is the universe's method of writing.",
      unlockCondition: "Reach the Stellar Death stage.",
      icon: Icons.star_half,
      accentColor: Colors.deepPurpleAccent,
    ),
    CodexEntry(
      id: "eternal_garden_entry",
      title: "The Long Burn",
      body: "In universes with just the right constants, red dwarf stars burn for 10 trillion years — a thousand times the age of our cosmos. The story is just beginning.",
      unlockCondition: "Grow an Eternal Garden with all perfect constants.",
      icon: Icons.park,
      accentColor: Colors.teal,
    ),
  ];

  List<CodexEntry> get entries => List.unmodifiable(_entries);
  int get unlockedCount => _entries.where((e) => e.isUnlocked).length;
  bool _hasNewEntries = false;
  bool get hasNewEntries => _hasNewEntries;

  CodexService() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < _entries.length; i++) {
      bool unlocked = prefs.getBool('codex_${_entries[i].id}') ?? false;
      bool seen = prefs.getBool('codex_seen_${_entries[i].id}') ?? false;
      _entries[i] = _entries[i].copyWith(isUnlocked: unlocked, isSeen: seen);
    }
    notifyListeners();
  }

  Future<void> markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < _entries.length; i++) {
      if (_entries[i].isUnlocked && !_entries[i].isSeen) {
        _entries[i] = _entries[i].copyWith(isSeen: true);
        await prefs.setBool('codex_seen_${_entries[i].id}', true);
      }
    }
    _hasNewEntries = false;
    notifyListeners();
  }

  void checkAndUnlock(UniverseState state, UniverseStage reachedStage) async {
    final prefs = await SharedPreferences.getInstance();
    bool newlyUnlocked = false;

    void unlock(String id) {
      int index = _entries.indexWhere((e) => e.id == id);
      if (index != -1 && !_entries[index].isUnlocked) {
        _entries[index] = _entries[index].copyWith(isUnlocked: true);
        prefs.setBool('codex_$id', true);
        newlyUnlocked = true;
      }
    }

    // Threshold-based unlocks
    if (state.nuclearForce > 0.70) unlock("nuclear_burn");
    if (state.nuclearForce < 0.30) unlock("cold_universe");
    if (state.emForce > 0.70) unlock("em_chaos");
    if (state.darkEnergyPressure > 0.75) unlock("dark_expansion");

    // Stage-based unlocks
    if (reachedStage.index >= UniverseStage.galacticAge.index) unlock("galaxy_formation");
    if (reachedStage.index >= UniverseStage.lifeAge.index) unlock("life_emergence");
    if (reachedStage.index >= UniverseStage.stellarDeath.index) unlock("stellar_death");

    // Outcome-based unlocks
    if (state.outcome == UniverseOutcome.greatCollapse) unlock("gravity_collapse");
    if (state.outcome == UniverseOutcome.eternalRecurrence) unlock("knife_edge");
    if (state.outcome == UniverseOutcome.lastLight) unlock("last_light_entry");
    if (state.outcome == UniverseOutcome.eternalGarden) {
      unlock("entropy_life");
      bool allSafe = state.gravity >= GameConstants.gravityMin && state.gravity <= GameConstants.gravityMax &&
                     state.nuclearForce >= GameConstants.nuclearForceMin && state.nuclearForce <= GameConstants.nuclearForceMax &&
                     state.emForce >= GameConstants.emForceMin && state.emForce <= GameConstants.emForceMax &&
                     state.entropyRate >= GameConstants.entropyRateMin && state.entropyRate <= GameConstants.entropyRateMax &&
                     state.darkEnergyPressure >= GameConstants.darkEnergyMin && state.darkEnergyPressure <= GameConstants.darkEnergyMax;
      if (allSafe) unlock("eternal_garden_entry");
    }

    if (newlyUnlocked) {
      _hasNewEntries = true;
      notifyListeners();
    }
  }
}
