// FEATURE: Observable Consequences Ticker // WHAT CHANGED: Removed unused `_animationController`. Optimized scrolling logic to use only `_scrollController`. // WHY: To reduce unnecessary vsync registrations and simplify the widget.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';

class ConsequenceTicker extends StatefulWidget {
  final UniverseStage stage;
  final double gravity;
  final double nuclear;
  final double em;
  final double entropy;
  final double darkEnergy;

  const ConsequenceTicker({
    super.key,
    required this.stage,
    required this.gravity,
    required this.nuclear,
    required this.em,
    required this.entropy,
    required this.darkEnergy,
  });

  @override
  State<ConsequenceTicker> createState() => _ConsequenceTickerState();
}

class _ConsequenceTickerState extends State<ConsequenceTicker> {
  late ScrollController _scrollController;
  List<String> _currentEvents = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _currentEvents = _generateEvents();
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  @override
  void didUpdateWidget(ConsequenceTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stage != widget.stage ||
        oldWidget.gravity != widget.gravity ||
        oldWidget.nuclear != widget.nuclear ||
        oldWidget.em != widget.em ||
        oldWidget.entropy != widget.entropy ||
        oldWidget.darkEnergy != widget.darkEnergy) {
      setState(() {
        _currentEvents = _generateEvents();
      });
    }
  }

  void _startScrolling() async {
    if (!mounted) return;
    
    while (mounted) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        final remainingDistance = maxScroll - currentScroll;
        
        if (remainingDistance <= 0) {
          _scrollController.jumpTo(0);
          continue;
        }

        final durationMs = (remainingDistance / 30 * 1000).toInt();
        
        await _scrollController.animateTo(
          maxScroll,
          duration: Duration(milliseconds: durationMs),
          curve: Curves.linear,
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  List<String> _generateEvents() {
    List<String> events = [];
    
    switch (widget.stage) {
      case UniverseStage.cosmicDawn:
        events.add("T+0: Singularity expands");
        if (widget.gravity >= 0.35 && widget.gravity <= 0.65) {
          events.add("T+380,000yr: First hydrogen atoms form");
          events.add("T+200Myr: Dark matter halos coalesce");
        }
        if (widget.gravity > 0.65) {
          events.add("WARNING: Spacetime curvature critical");
          events.add("T+1yr: Recollapse imminent");
        }
        if (widget.gravity < 0.35) {
          events.add("WARNING: Matter too diffuse to bind");
          events.add("T+1Gyr: No structure will form");
        }
        break;

      case UniverseStage.stellarAge:
        events.add("T+200Myr: First gas clouds detected");
        if (widget.nuclear >= 0.40 && widget.nuclear <= 0.60) {
          events.add("T+500Myr: First ignition — hydrogen fuses");
          events.add("T+1Gyr: Carbon forged in stellar cores");
          events.add("T+8Gyr: Second generation stars forming");
        }
        if (widget.nuclear > 0.70) {
          events.add("WARNING: Stellar lifetime < 10 million years");
          events.add("T+900Myr: All fuel consumed — total darkness");
        }
        if (widget.nuclear < 0.30) {
          events.add("WARNING: Fusion threshold not reached");
          events.add("T+∞: Hydrogen clouds drift, cold and dark");
        }
        break;

      case UniverseStage.galacticAge:
        events.add("T+1Gyr: Protogalactic clouds detected");
        if (widget.em >= 0.35 && widget.em <= 0.65) {
          events.add("T+2Gyr: Spiral arms forming");
          events.add("T+3Gyr: Heavy element distribution confirmed");
          events.add("T+4Gyr: Rocky planet formation possible");
        }
        if (widget.em > 0.70) {
          events.add("WARNING: Electromagnetic repulsion dominant");
          events.add("Atomic bonds unstable — chemistry impossible");
        }
        if (widget.em < 0.35) {
          events.add("WARNING: Matter passes through matter");
          events.add("No solid structures will form");
        }
        break;

      case UniverseStage.lifeAge:
        events.add("T+4.5Gyr: Planetary oceans detected");
        if (widget.entropy >= 0.35 && widget.entropy <= 0.60) {
          events.add("T+4Gyr: Amino acids in primordial oceans");
          events.add("T+3.8Gyr: First self-replicating molecule");
          events.add("T+540Myr: Cambrian explosion — complexity surges");
          events.add("T+4.5Gyr: Technological civilization detected");
        }
        if (widget.entropy > 0.70) {
          events.add("WARNING: Complexity dissolves faster than it forms");
          events.add("Life cannot maintain order against heat death");
        }
        if (widget.entropy < 0.30) {
          events.add("WARNING: Thermodynamic equilibrium — no gradient");
          events.add("All chemistry frozen in stasis");
        }
        break;

      case UniverseStage.stellarDeath:
        events.add("T+10Gyr: Main sequence stars begin dying");
        if (widget.darkEnergy >= 0.40 && widget.darkEnergy <= 0.60) {
          events.add("T+12Gyr: Planetary nebulae bloom");
          events.add("T+100Gyr: White dwarfs cool slowly");
          events.add("T+10^14yr: Red dwarfs still burning");
        }
        if (widget.darkEnergy > 0.70) {
          events.add("WARNING: Expansion accelerating beyond escape");
          events.add("T+20Gyr: Galaxies beyond light horizon");
          events.add("T+∞: Heat death approaches");
        }
        if (widget.darkEnergy < 0.30) {
          events.add("WARNING: Gravity overcoming expansion");
          events.add("T+50Gyr: Big Crunch sequence begins");
        }
        break;

      case UniverseStage.civilizationDawn:
      case UniverseStage.technologicalAge:
      case UniverseStage.cosmicLegacy:
      case UniverseStage.cosmicFate:
        events.add("Arc complete. Analyzing results...");
        break;
    }

    return events;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentEvents.isEmpty) return const SizedBox(height: 28);
    
    return Container(
      height: 28,
      color: Colors.black26,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.transparent, Colors.white, Colors.white],
            stops: [0.0, 0.1, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final eventIndex = index % _currentEvents.length;
            final event = _currentEvents[eventIndex];
            final isWarning = event.startsWith("WARNING");
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    event,
                    style: GoogleFonts.exo2(
                      fontSize: 11,
                      color: isWarning ? GameConstants.collapseRed : Colors.white38,
                    ),
                  ),
                  const Text("  ·  ", style: TextStyle(color: Colors.white10, fontSize: 11)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
