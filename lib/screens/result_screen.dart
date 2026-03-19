import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../core/simulation_engine.dart';
import '../services/simulation_service.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulationService>(
      builder: (context, service, child) {
        final state = service.currentUniverse;
        final outcome = state.outcome;
        final isSuccess = outcome == UniverseOutcome.lifeSupporting;

        return Scaffold(
          backgroundColor: GameConstants.spaceBlack,
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isSuccess ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  GameConstants.spaceBlack,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSuccess ? Icons.auto_awesome : Icons.error_outline,
                  size: 100,
                  color: isSuccess ? GameConstants.lifeGreen : GameConstants.collapseRed,
                ),
                const SizedBox(height: 30),
                Text(
                  _getOutcomeTitle(outcome),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  SimulationEngine.getOutcomeMessage(outcome),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 50),
                _buildStatRow("Gravity", state.gravity, GameConstants.gravityMin, GameConstants.gravityMax),
                _buildStatRow("EM Force", state.emForce, GameConstants.emForceMin, GameConstants.emForceMax),
                _buildStatRow("Nuclear Force", state.nuclearForce, GameConstants.nuclearForceMin, GameConstants.nuclearForceMax),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () {
                    service.reset();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: GameConstants.cosmicPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'TRY AGAIN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, double value, double min, double max) {
    bool isOk = value >= min && value <= max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Row(
            children: [
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(
                  color: isOk ? GameConstants.lifeGreen : Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isOk ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                size: 16,
                color: isOk ? GameConstants.lifeGreen : Colors.orangeAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getOutcomeTitle(UniverseOutcome outcome) {
    switch (outcome) {
      case UniverseOutcome.collapsed: return "COLLAPSED UNIVERSE";
      case UniverseOutcome.empty: return "EMPTY UNIVERSE";
      case UniverseOutcome.unstableAtoms: return "UNSTABLE ATOMS";
      case UniverseOutcome.noBonds: return "CHEMICALLY INERT";
      case UniverseOutcome.fastBurn: return "BURNT OUT";
      case UniverseOutcome.noStars: return "ETERNAL NIGHT";
      case UniverseOutcome.chaotic: return "CHAOTIC REALM";
      case UniverseOutcome.lifeSupporting: return "A LIVING UNIVERSE";
      default: return "OUTCOME UNKNOWN";
    }
  }
}
