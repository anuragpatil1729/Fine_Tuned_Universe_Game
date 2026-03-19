// CHANGES MADE:
// 1. Updated the "Pattern Detected" analysis to include all 5 physical constants (Entropy and Dark Energy).
// 2. Updated the outcome visualization logic to handle the new 4-tier ending system.
// 3. Refined the tooltip to display all 5 tuned parameters for each multiverse iteration.
// 4. Adjusted the visual indicators (icons and colors) to reflect the new thematic outcomes.
// 5. Maintained the tappable grid system for exploring previous universe attempts.
// 6. Removed unused imports.

import 'package:flutter/material.dart';
import '../models/universe_state.dart';
import '../core/constants.dart';

class BackgroundUniverses extends StatelessWidget {
  final List<UniverseState> history;

  const BackgroundUniverses({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
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
                  width: 55,
                  height: 55,
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
                      size: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showUniverseTooltip(BuildContext context, UniverseState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          state.outcome.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.5),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statRow("Gravity", state.gravity),
            _statRow("Nuclear", state.nuclearForce),
            _statRow("EM Force", state.emForce),
            _statRow("Entropy", state.entropyRate),
            _statRow("Dark Energy", state.darkEnergyPressure),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text("$label: ${val.toStringAsFixed(2)}", 
          style: const TextStyle(color: Colors.white60, fontSize: 13, fontFamily: 'monospace')),
    );
  }

  List<Color> _getOutcomeColors(UniverseOutcome outcome) {
    switch (outcome) {
      case UniverseOutcome.eternalGarden:
        return [GameConstants.gardenEmerald, Colors.transparent];
      case UniverseOutcome.lastLight:
        return [Colors.amber, Colors.transparent];
      case UniverseOutcome.greatCollapse:
        return [Colors.red, Colors.black];
      case UniverseOutcome.eternalRecurrence:
        return [Colors.purple, Colors.transparent];
      default:
        return [Colors.grey, Colors.transparent];
    }
  }

  IconData _getOutcomeIcon(UniverseOutcome outcome) {
    switch (outcome) {
      case UniverseOutcome.eternalGarden:
        return Icons.auto_awesome;
      case UniverseOutcome.lastLight:
        return Icons.wb_sunny_outlined;
      case UniverseOutcome.greatCollapse:
        return Icons.brightness_3;
      case UniverseOutcome.eternalRecurrence:
        return Icons.loop;
      default:
        return Icons.blur_on;
    }
  }
}
