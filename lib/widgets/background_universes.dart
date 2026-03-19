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
      children: history.asMap().entries.map((entry) {
        final index = entry.key;
        final state = entry.value;
        
        // Faded mini-universes positioned randomly or in a subtle grid
        return Positioned(
          left: (index % 3) * 100.0 + 20,
          top: (index / 3).floor() * 100.0 + 50,
          child: Opacity(
            opacity: 0.15,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: _getOutcomeColors(state.outcome),
                ),
              ),
              child: Center(
                child: Icon(
                  _getOutcomeIcon(state.outcome),
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
        return Icons.favorite;
      case UniverseOutcome.collapsed:
        return Icons.brightness_3;
      default:
        return Icons.blur_on;
    }
  }
}
