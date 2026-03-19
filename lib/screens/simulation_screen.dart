// CHANGES MADE:
// 1. Implemented a smooth lifecycle transition system using `AnimatedSwitcher` with combined Fade and Scale transitions.
// 2. Created a `StaggeredTextWidget` to animate stage titles character-by-character for a more dramatic, high-fidelity feel.
// 3. Updated the control layout to show ONLY the active slider for the current stage, reducing cognitive load.
// 4. Integrated the new 6-stage lifecycle, passing all 5 physical constants to the `UniverseVisual`.
// 5. Added a "Cosmic Fate" stage transition that automatically navigates to the result screen after a brief viewing period.
// 6. Refined the UI to be more immersive, focusing the player's attention on the authoring of the universe's arc.

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
        
        if (state.stage == UniverseStage.cosmicFate) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(seconds: 4), () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ResultScreen()),
                );
              }
            });
          });
        }

        return Scaffold(
          backgroundColor: GameConstants.spaceBlack,
          body: Stack(
            children: [
              BackgroundUniverses(history: service.history),
              SafeArea(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (Widget child, Animation<double> animation) {
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
                      const SizedBox(height: 20),
                      StaggeredTextWidget(
                        text: _getStageTitle(state.stage),
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _getStageDescription(state.stage),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
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
                      
                      if (state.stage != UniverseStage.cosmicFate)
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildActiveSlider(service),
                              const SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: () => service.nextStage(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: Text(
                                  state.stage == UniverseStage.stellarDeath ? "WITNESS THE END" : "ADVANCE AEON",
                                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveSlider(SimulationService service) {
    final state = service.currentUniverse;
    switch (state.stage) {
      case UniverseStage.cosmicDawn:
        return ConstantSlider(
          label: "GRAVITATIONAL CONSTANT",
          value: state.gravity,
          safeMin: GameConstants.gravityMin,
          safeMax: GameConstants.gravityMax,
          onChanged: service.updateGravity,
        );
      case UniverseStage.stellarAge:
        return ConstantSlider(
          label: "STRONG NUCLEAR FORCE",
          value: state.nuclearForce,
          safeMin: GameConstants.nuclearForceMin,
          safeMax: GameConstants.nuclearForceMax,
          onChanged: service.updateNuclearForce,
        );
      case UniverseStage.galacticAge:
        return ConstantSlider(
          label: "ELECTROMAGNETIC FORCE",
          value: state.emForce,
          safeMin: GameConstants.emForceMin,
          safeMax: GameConstants.emForceMax,
          onChanged: service.updateEMForce,
        );
      case UniverseStage.lifeAge:
        return ConstantSlider(
          label: "ENTROPY RATE",
          value: state.entropyRate,
          safeMin: GameConstants.entropyRateMin,
          safeMax: GameConstants.entropyRateMax,
          onChanged: service.updateEntropyRate,
        );
      case UniverseStage.stellarDeath:
        return ConstantSlider(
          label: "DARK ENERGY PRESSURE",
          value: state.darkEnergyPressure,
          safeMin: GameConstants.darkEnergyMin,
          safeMax: GameConstants.darkEnergyMax,
          onChanged: service.updateDarkEnergy,
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
      case UniverseStage.cosmicDawn: return "The Big Bang ignites. Tune gravity to prevent immediate collapse or dissipation.";
      case UniverseStage.stellarAge: return "First stars blaze. The nuclear force determines the lifespan and heat of the suns.";
      case UniverseStage.galacticAge: return "Galaxies coalesce. Electromagnetism binds matter into spiral islands of light.";
      case UniverseStage.lifeAge: return "Life emerges. Entropy determines if complexity can survive the arrow of time.";
      case UniverseStage.stellarDeath: return "Stars begin to die. Dark energy determines the final expansion of the void.";
      case UniverseStage.cosmicFate: return "The arc is complete. Observe the final destiny of your creation.";
    }
  }
}

class StaggeredTextWidget extends StatefulWidget {
  final String text;
  final TextStyle style;

  const StaggeredTextWidget({super.key, required this.text, required this.style});

  @override
  State<StaggeredTextWidget> createState() => _StaggeredTextWidgetState();
}

class _StaggeredTextWidgetState extends State<StaggeredTextWidget> with TickerProviderStateMixin {
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
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    _animations = _controllers.map((c) => Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: c, curve: Curves.easeIn),
    )).toList();

    _startStaggeredAnimation();
  }

  void _startStaggeredAnimation() async {
    for (var controller in _controllers) {
      controller.forward();
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  @override
  void didUpdateWidget(StaggeredTextWidget oldWidget) {
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
          child: Text(widget.text[index], style: widget.style),
        );
      }),
    );
  }
}
