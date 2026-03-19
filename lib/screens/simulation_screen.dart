// FEATURE: Civilization Layer & Bug Fixes
// WHAT CHANGED:
// 1. Converted to StatefulWidget to handle Bug 5 (duplicate navigation).
// 2. Added `_navigationScheduled` flag to ensure ResultScreen is pushed exactly once.
// 3. Integrated `ConsequenceTicker` for real-time causal feedback.
// 4. Added "Observatory" button to AppBar.
// 5. Updated "WITNESS DESTINY" button logic to support both phase endings (stellarDeath and technologicalAge).
// 6. Added scale pulse enhancement on slider interaction.

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
import '../widgets/consequence_ticker.dart';
import 'codex_screen.dart';
import 'observatory_screen.dart';
import 'result_screen.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  bool _navigationScheduled = false;
  double _visualScale = 1.0;

  void _maybeNavigateToResult(UniverseStage stage) {
    if ((stage == UniverseStage.cosmicFate || stage == UniverseStage.cosmicLegacy) && !_navigationScheduled) {
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

  void _triggerPulse() {
    setState(() => _visualScale = 1.02);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _visualScale = 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SimulationService, CodexService, AnomalyService>(
      builder: (context, sim, codex, anomaly, child) {
        final state = sim.currentUniverse;
        final activeAnomaly = anomaly.activeAnomaly;

        if (state.stage == UniverseStage.cosmicFate || state.stage == UniverseStage.cosmicLegacy) {
          _maybeNavigateToResult(state.stage);
        }

        return Scaffold(
          backgroundColor: GameConstants.spaceBlack,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.scatter_plot, color: Colors.white38),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ObservatoryScreen()),
                ),
              ),
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
                            const SizedBox(height: 10),
                            ConsequenceTicker(
                              stage: state.stage,
                              gravity: state.gravity,
                              nuclear: state.nuclearForce,
                              em: state.emForce,
                              entropy: state.entropyRate,
                              darkEnergy: state.darkEnergyPressure,
                            ),
                            Expanded(
                              child: Center(
                                child: AnimatedScale(
                                  scale: _visualScale,
                                  duration: const Duration(milliseconds: 150),
                                  curve: Curves.easeOut,
                                  child: UniverseVisual(
                                    stage: state.stage,
                                    gravity: state.gravity,
                                    nuclear: state.nuclearForce,
                                    em: state.emForce,
                                    entropy: state.entropyRate,
                                    darkEnergy: state.darkEnergyPressure,
                                    cooperation: state.cooperationIndex,
                                    energy: state.energyConsumption,
                                    outcome: state.outcome,
                                  ),
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
                          if (state.stage != UniverseStage.cosmicFate && state.stage != UniverseStage.cosmicLegacy) ...[
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
                                (state.stage == UniverseStage.stellarDeath || state.stage == UniverseStage.technologicalAge)
                                    ? "WITNESS DESTINY" : "NEXT ERA",
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
          onChanged: (v) { sim.updateGravity(v); _triggerPulse(); },
          isLocked: sim.isLocked("gravity"),
        );
      case UniverseStage.stellarAge:
        return ConstantSlider(
          label: "NUCLEAR FORCE",
          value: state.nuclearForce,
          safeMin: sim.effectiveNuclearMin,
          safeMax: sim.effectiveNuclearMax,
          onChanged: (v) { sim.updateNuclearForce(v); _triggerPulse(); },
          isLocked: sim.isLocked("nuclear"),
        );
      case UniverseStage.galacticAge:
        return ConstantSlider(
          label: "EM FORCE",
          value: state.emForce,
          safeMin: sim.effectiveEmMin,
          safeMax: sim.effectiveEmMax,
          onChanged: (v) { sim.updateEMForce(v); _triggerPulse(); },
          isLocked: sim.isLocked("em"),
        );
      case UniverseStage.lifeAge:
        return ConstantSlider(
          label: "ENTROPY RATE",
          value: state.entropyRate,
          safeMin: sim.effectiveEntropyMin,
          safeMax: sim.effectiveEntropyMax,
          onChanged: (v) { sim.updateEntropyRate(v); _triggerPulse(); },
          isLocked: sim.isLocked("entropy"),
        );
      case UniverseStage.stellarDeath:
        return ConstantSlider(
          label: "DARK ENERGY",
          value: state.darkEnergyPressure,
          safeMin: sim.effectiveDarkEnergyMin,
          safeMax: sim.effectiveDarkEnergyMax,
          onChanged: (v) { sim.updateDarkEnergy(v); _triggerPulse(); },
          isLocked: sim.isLocked("darkEnergy"),
        );
      case UniverseStage.civilizationDawn:
        return ConstantSlider(
          label: "COOPERATION INDEX",
          value: state.cooperationIndex,
          safeMin: sim.effectiveCooperationMin,
          safeMax: sim.effectiveCooperationMax,
          onChanged: (v) { sim.updateCooperation(v); _triggerPulse(); },
          isLocked: sim.isLocked("cooperation"),
        );
      case UniverseStage.technologicalAge:
        return ConstantSlider(
          label: "ENERGY CONSUMPTION",
          value: state.energyConsumption,
          safeMin: sim.effectiveEnergyMin,
          safeMax: sim.effectiveEnergyMax,
          onChanged: (v) { sim.updateEnergyConsumption(v); _triggerPulse(); },
          isLocked: sim.isLocked("energy"),
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
      case UniverseStage.civilizationDawn: return "CIVILIZATION DAWN";
      case UniverseStage.technologicalAge: return "TECHNOLOGICAL AGE";
      case UniverseStage.cosmicLegacy: return "COSMIC LEGACY";
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
      case UniverseStage.civilizationDawn: return "Intelligence emerges. Cooperation determines if knowledge becomes power or conflict.";
      case UniverseStage.technologicalAge: return "The species reaches for the stars. Energy consumption will define their legacy.";
      case UniverseStage.cosmicLegacy: return "The final chapter. What does this civilization leave behind?";
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
      if (!mounted) return;
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
