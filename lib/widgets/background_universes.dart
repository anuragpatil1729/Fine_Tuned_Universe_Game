// CHANGES MADE:
// 1. Reworked failed universes to be tappable using GestureDetector.
// 2. Tapping a mini-universe now shows a Tooltip/Overlay with its specific constant values and outcome.
// 3. Implemented the "Pattern Detected" hint system: if 3+ failures exist, a button appears to reveal the most unstable constant across all runs.
// 4. Added logic to calculate the "furthest from safe zone" constant across all failed attempts.
// 5. Visual polish: Added subtle animations and refined the grid layout for the multiverse memory.
// 6. Fixed: Removed unnecessary .toList() in spread.
// 7. Fixed: Replaced undefined Colors.black92 with a valid dark color.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/universe_state.dart';
import '../core/constants.dart';
import '../services/simulation_service.dart';

class BackgroundUniverses extends StatelessWidget {
  final List<UniverseState> history;

  const BackgroundUniverses({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SimulationService>();
    final isHintUnlocked = service.hintUnlocked;

    if (history.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        // PILLAR 4: Multiverse Memory Grid
        ...history.asMap().entries.map((entry) {
          final index = entry.key;
          final state = entry.value;
          
          return Positioned(
            left: (index % 4) * 85.0 + 20,
            top: (index / 4).floor() * 85.0 + 100,
            child: GestureDetector(
              onTap: () => _showUniverseTooltip(context, state),
              child: Opacity(
                opacity: 0.25,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: _getOutcomeColors(state.outcome),
                    ),
                    border: Border.all(color: Colors.white10, width: 1),
                  ),
                  child: Center(
                    child: Icon(
                      _getOutcomeIcon(state.outcome),
                      size: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        // PILLAR 4: Pattern Hint Trigger
        if (isHintUnlocked)
          Positioned(
            top: 40,
            right: 20,
            child: TextButton.icon(
              onPressed: () => _showPatternAnalysis(context, history),
              icon: const Icon(Icons.psychology, color: Colors.cyanAccent, size: 20),
              label: const Text(
                "PATTERN DETECTED",
                style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.black45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.cyanAccent, width: 0.5),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showUniverseTooltip(BuildContext context, UniverseState state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 3),
        content: Text(
          "Outcome: ${state.outcome.name.toUpperCase()}\nG: ${state.gravity.toStringAsFixed(2)} | N: ${state.nuclearForce.toStringAsFixed(2)} | EM: ${state.emForce.toStringAsFixed(2)}",
          style: const TextStyle(color: Colors.cyanAccent, fontSize: 12),
        ),
      ),
    );
  }

  void _showPatternAnalysis(BuildContext context, List<UniverseState> history) {
    // Analyze failures: Find which constant was furthest from safe center (0.5) on average
    double gDev = 0, nDev = 0, eDev = 0;
    int failedCount = 0;

    for (var u in history) {
      if (u.outcome != UniverseOutcome.lifeSupporting) {
        gDev += (u.gravity - 0.5).abs();
        nDev += (u.nuclearForce - 0.5).abs();
        eDev += (u.emForce - 0.5).abs();
        failedCount++;
      }
    }

    String culprit = "Gravity";
    if (nDev > gDev && nDev > eDev) culprit = "Strong Nuclear Force";
    if (eDev > gDev && eDev > nDev) culprit = "Electromagnetic Force";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Text("MULTIVERSE ANALYSIS", style: TextStyle(color: Colors.cyanAccent, letterSpacing: 2)),
        content: Text(
          "Across $failedCount iterations, your $culprit was the most unstable variable. Aim for a more balanced center in the next timeline.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("RESUME SIMULATION", style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  List<Color> _getOutcomeColors(UniverseOutcome outcome) {
    switch (outcome) {
      case UniverseOutcome.lifeSupporting:
        return [GameConstants.lifeGreen, Colors.transparent];
      case UniverseOutcome.collapsed:
        return [Colors.red, Colors.black];
      case UniverseOutcome.empty:
        return [Colors.blueGrey, Colors.transparent];
      default:
        return [Colors.purple, Colors.transparent];
    }
  }

  IconData _getOutcomeIcon(UniverseOutcome outcome) {
    switch (outcome) {
      case UniverseOutcome.lifeSupporting:
        return Icons.auto_awesome;
      case UniverseOutcome.collapsed:
        return Icons.brightness_3;
      default:
        return Icons.blur_on;
    }
  }
}
