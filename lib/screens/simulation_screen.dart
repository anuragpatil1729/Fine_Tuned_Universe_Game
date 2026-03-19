// CHANGES MADE:
// 1. Added PILLAR 2: Intervention orbs visualization (glowing cyan orbs) and failing trajectory warning border (pulsing red).
// 2. PILLAR 5: Integrated `AnimatedSwitcher` for smooth 1.5s transitions between stages.
// 3. PILLAR 5: Created `_AnimatedStageTitle` for a staggered, letter-by-letter entrance animation.
// 4. Integrated real-time reactive constants into `UniverseVisual`.
// 5. Updated description texts to reflect the "Intervention" and "Cascading" mechanics.

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
        
        if (state.stage == UniverseStage.finished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ResultScreen()),
              );
            }
          });
        }

        return Scaffold(
          backgroundColor: GameConstants.spaceBlack,
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              border: Border.all(
                color: service.isFailingTrajectory ? Colors.red.withOpacity(0.4) : Colors.transparent,
                width: 4,
              ),
            ),
            child: Stack(
              children: [
                BackgroundUniverses(history: service.history),
                SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(service),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 1500),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: UniverseVisual(
                            key: ValueKey(state.stage),
                            stage: state.stage,
                            gravity: state.gravity,
                            nuclear: state.nuclearForce,
                            em: state.emForce,
                          ),
                        ),
                      ),
                      _buildBottomControls(service),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(SimulationService service) {
    final state = service.currentUniverse;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AnimatedStageTitle(title: _getStageTitle(state.stage)),
              // PILLAR 2: Intervention Orbs
              Row(
                children: List.generate(3, (index) => Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.lens,
                    size: 14,
                    color: index < service.interventions ? Colors.cyanAccent : Colors.white10,
                    shadows: index < service.interventions ? [const BoxShadow(color: Colors.cyanAccent, blurRadius: 8)] : null,
                  ),
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getStageDescription(state.stage),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(SimulationService service) {
    final state = service.currentUniverse;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstantSlider(
            label: "Gravity (Expansion)",
            id: 'gravity',
            value: state.gravity,
            safeMin: GameConstants.gravityMin,
            safeMax: GameConstants.gravityMax,
            isLocked: service.gravityLocked,
            onChanged: service.updateGravity,
          ),
          ConstantSlider(
            label: "Strong Nuclear (Stars)",
            id: 'nuclear',
            value: state.nuclearForce,
            safeMin: service.nuclearSafeMin,
            safeMax: service.nuclearSafeMax,
            isLocked: service.nuclearLocked,
            onChanged: service.updateNuclearForce,
          ),
          ConstantSlider(
            label: "Electromagnetic (Bonds)",
            id: 'em',
            value: state.emForce,
            safeMin: service.emSafeMin,
            safeMax: service.emSafeMax,
            isLocked: service.emLocked,
            onChanged: service.updateEMForce,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => service.nextStage(),
            style: ElevatedButton.styleFrom(
              backgroundColor: GameConstants.cosmicPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 0,
            ),
            child: Text(
              state.stage == UniverseStage.emergenceOfLife ? "ENERGIZE" : "ADVANCE STAGE",
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }

  String _getStageTitle(UniverseStage stage) {
    switch (stage) {
      case UniverseStage.bigBang: return "SINGULARITY";
      case UniverseStage.starFormation: return "STELLAR GENESIS";
      case UniverseStage.planetFormation: return "ACCRETION";
      case UniverseStage.emergenceOfLife: return "ABIOGENESIS";
      default: return "";
    }
  }

  String _getStageDescription(UniverseStage stage) {
    switch (stage) {
      case UniverseStage.bigBang: 
        return "Balance expansion and contraction. High gravity here will tighten the nuclear safe zone.";
      case UniverseStage.starFormation: 
        return "Ignite the first suns. Nuclear force affects future atomic stability.";
      case UniverseStage.planetFormation: 
        return "Cooling matter forms solid ground. Observe the effects of your previous tuning.";
      case UniverseStage.emergenceOfLife: 
        return "Complex chemical pathways require precise harmonic resonance.";
      default: return "";
    }
  }
}

class _AnimatedStageTitle extends StatelessWidget {
  final String title;
  const _AnimatedStageTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      key: ValueKey(title),
      tween: IntTween(begin: 0, end: title.length),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Text(
          title.substring(0, value),
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontSize: 22,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
