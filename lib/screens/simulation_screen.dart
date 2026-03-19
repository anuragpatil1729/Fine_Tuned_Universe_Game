// BUG FIXED: Bug 5 - cosmicFate navigation fires multiple times.
// BUG FIXED: Bug 6 - Mirror Universe safe zones never passed to slider.
// HOW: Converted to StatefulWidget to track `_navigationScheduled` flag. 
// Moved navigation logic to a helper called during stage check.
// Updated `_buildActiveSlider` to use all service getters for safe zones.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../services/simulation_service.dart';
import '../services/codex_service.dart';
import '../services/anomaly_service.dart';
import '../widgets/constant_slider.dart';
import '../widgets/universe_visual.dart';
import '../widgets/multiverse_observatory.dart';
import '../widgets/whisper_bar.dart';
import 'codex_screen.dart';
import 'result_screen.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  bool _navigationScheduled = false;

  void _maybeNavigateToResult(UniverseStage stage) {
    if (stage == UniverseStage.cosmicFate && !_navigationScheduled) {
      _navigationScheduled = true;
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ResultScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SimulationService, CodexService, AnomalyService>(
      builder: (context, sim, codex, anomaly, child) {
        final state = sim.currentUniverse;
        final activeAnomaly = anomaly.activeAnomaly;
        
        if (state.stage == UniverseStage.cosmicFate) {
          _maybeNavigateToResult(state.stage);
        }

        return Scaffold(
          backgroundColor: GameConstants.spaceBlack,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu_book, color: Colors.white70),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CodexScreen()),
                    ),
                  ),
                  if (codex.hasNewEntries)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.cyanAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: Stack(
            children: [
              MultiverseObservatory(history: sim.history),
              SafeArea(
                child: Column(
                  children: [
                    if (activeAnomaly?.id == "dark_tide")
                      _buildPressureBar(state.darkEnergyPressure),
                    
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          key: ValueKey(state.stage),
                          children: [
                            const SizedBox(height: 10),
                            _StaggeredTitle(text: _getStageTitle(state.stage)),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                _getStageDescription(state.stage),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white38, fontSize: 12),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: UniverseVisual(
                                  stage: state.stage,
                                  gravity: state.gravity,
                                  nuclear: state.nuclearForce,
                                  em: state.emForce,
                                  entropy: state.entropyRate,
                                  darkEnergy: state.darkEnergyPressure,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WhisperBar(whisper: sim.currentWhisper),
                          const SizedBox(height: 10),
                          if (state.stage != UniverseStage.cosmicFate) ...[
                            _buildActiveSlider(sim),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => sim.nextStage(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: Text(
                                state.stage == UniverseStage.stellarDeath ? "WITNESS DESTINY" : "NEXT ERA",
                                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                              ),
                            ),
                          ],
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

  Widget _buildPressureBar(double pressure) {
    bool danger = pressure > 0.70;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("DARK TIDE PRESSURE", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
              Text("${(pressure * 100).toInt()}%", style: TextStyle(color: danger ? Colors.red : Colors.white38, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: pressure / 0.8,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(danger ? Colors.red : Colors.cyanAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSlider(SimulationService sim) {
    final state = sim.currentUniverse;
    switch (state.stage) {
      case UniverseStage.cosmicDawn:
        return ConstantSlider(
          label: "GRAVITY",
          value: state.gravity,
          safeMin: sim.effectiveGravityMin,
          safeMax: sim.effectiveGravityMax,
          onChanged: sim.updateGravity,
          isLocked: sim.isLocked("gravity"),
        );
      case UniverseStage.stellarAge:
        return ConstantSlider(
          label: "NUCLEAR FORCE",
          value: state.nuclearForce,
          safeMin: sim.effectiveNuclearMin,
          safeMax: sim.effectiveNuclearMax,
          onChanged: sim.updateNuclearForce,
          isLocked: sim.isLocked("nuclear"),
        );
      case UniverseStage.galacticAge:
        return ConstantSlider(
          label: "EM FORCE",
          value: state.emForce,
          safeMin: sim.effectiveEmMin,
          safeMax: sim.effectiveEmMax,
          onChanged: sim.updateEMForce,
          isLocked: sim.isLocked("em"),
        );
      case UniverseStage.lifeAge:
        return ConstantSlider(
          label: "ENTROPY RATE",
          value: state.entropyRate,
          safeMin: sim.effectiveEntropyMin,
          safeMax: sim.effectiveEntropyMax,
          onChanged: sim.updateEntropyRate,
          isLocked: sim.isLocked("entropy"),
        );
      case UniverseStage.stellarDeath:
        return ConstantSlider(
          label: "DARK ENERGY",
          value: state.darkEnergyPressure,
          safeMin: sim.effectiveDarkEnergyMin,
          safeMax: sim.effectiveDarkEnergyMax,
          onChanged: sim.updateDarkEnergy,
          isLocked: sim.isLocked("darkEnergy"),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _getStageTitle(UniverseStage stage) {
    switch (stage) {
      case UniverseStage.cosmicDawn: return "COSMIC DAWN";
      case UniverseStage.stellarAge: return "STELLAR AGE";
      case UniverseStage.galacticAge: return "GALACTIC AGE";
      case UniverseStage.lifeAge: return "LIFE AGE";
      case UniverseStage.stellarDeath: return "STELLAR DEATH";
      case UniverseStage.cosmicFate: return "COSMIC FATE";
    }
  }

  String _getStageDescription(UniverseStage stage) {
    switch (stage) {
      case UniverseStage.cosmicDawn: return "The singularity expands. Establish the foundation of order.";
      case UniverseStage.stellarAge: return "Hydrogen ignites. The first light negotiates with the dark.";
      case UniverseStage.galacticAge: return "Matter clusters into spiral islands. Atoms seek resonance.";
      case UniverseStage.lifeAge: return "The mirror of consciousness awakens. Complexity fights entropy.";
      case UniverseStage.stellarDeath: return "Fuel runs dry. The final expansion begins its acceleration.";
      case UniverseStage.cosmicFate: return "The arc reaches its conclusion. Observe your handiwork.";
    }
  }
}

class _StaggeredTitle extends StatefulWidget {
  final String text;
  const _StaggeredTitle({required this.text});

  @override
  State<_StaggeredTitle> createState() => _StaggeredTitleState();
}

class _StaggeredTitleState extends State<_StaggeredTitle> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.text.length,
      (index) => AnimationController(vsync: this, duration: const Duration(milliseconds: 300)),
    );
    _animations = _controllers.map((c) => Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: c, curve: Curves.easeIn))).toList();
    _play();
  }

  void _play() async {
    for (var c in _controllers) {
      c.forward();
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  @override
  void didUpdateWidget(_StaggeredTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      for (var c in _controllers) {
        c.dispose();
      }
      _initAnimations();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(widget.text.length, (index) {
        return FadeTransition(
          opacity: _animations[index],
          child: Text(
            widget.text[index],
            style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24, letterSpacing: 4, fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }
}
