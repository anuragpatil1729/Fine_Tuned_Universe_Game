import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../services/simulation_service.dart';
import '../widgets/constant_slider.dart';
import '../widgets/universe_visual.dart';
import '../widgets/background_universes.dart';
import 'result_screen.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulationService>(
      builder: (context, service, child) {
        final state = service.currentUniverse;
        
        return Scaffold(
          backgroundColor: GameConstants.spaceBlack,
          body: Stack(
            children: [
              // Faded background of previous failures
              BackgroundUniverses(history: service.history),
              
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      _getStageTitle(state.stage),
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 24,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _getStageDescription(state.stage),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                    
                    const Expanded(
                      child: Center(
                        child: UniverseVisual(
                          stage: UniverseStage.bigBang, // Keep basic visual for now
                          intensity: 1.0,
                        ),
                      ),
                    ),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstantSlider(
                            label: "Gravitational Constant (G)",
                            value: state.gravity,
                            onChanged: service.updateGravity,
                          ),
                          ConstantSlider(
                            label: "Electromagnetic Force",
                            value: state.emForce,
                            onChanged: service.updateEMForce,
                          ),
                          ConstantSlider(
                            label: "Strong Nuclear Force",
                            value: state.nuclearForce,
                            onChanged: service.updateNuclearForce,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (state.stage == UniverseStage.emergenceOfLife) {
                                service.finishSimulation();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const ResultScreen()),
                                );
                              } else {
                                service.nextStage();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GameConstants.cosmicPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              state.stage == UniverseStage.emergenceOfLife ? "FINALIZE UNIVERSE" : "NEXT STAGE",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStageTitle(UniverseStage stage) {
    switch (stage) {
      case UniverseStage.bigBang: return "BIG BANG";
      case UniverseStage.starFormation: return "STAR FORMATION";
      case UniverseStage.planetFormation: return "PLANET FORMATION";
      case UniverseStage.emergenceOfLife: return "EMERGENCE OF LIFE";
      default: return "";
    }
  }

  String _getStageDescription(UniverseStage stage) {
    switch (stage) {
      case UniverseStage.bigBang: return "Adjust the initial density and expansion.";
      case UniverseStage.starFormation: return "Will gravity overcome entropy to light the first stars?";
      case UniverseStage.planetFormation: return "Heavier elements must clump together into stable orbits.";
      case UniverseStage.emergenceOfLife: return "Complex chemistry requires precise electromagnetic balance.";
      default: return "";
    }
  }
}
