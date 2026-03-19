import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../core/string_utils.dart';
import '../core/universe_dna.dart';
import '../models/universe_state.dart';
import '../services/simulation_service.dart';
import '../widgets/multiverse_observatory.dart';

class ObservatoryScreen extends StatefulWidget {
  const ObservatoryScreen({super.key});

  @override
  State<ObservatoryScreen> createState() => _ObservatoryScreenState();
}

class _ObservatoryScreenState extends State<ObservatoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Offset _getNodePosition(UniverseState state, int index) {
    if (state.dna.isNotEmpty && UniverseDNA.isValid(state.dna)) {
      final parsed = UniverseDNA.parse(state.dna);
      return Offset(
        (parsed['gravity']! * 1100) + 50,
        (parsed['nuclear']! * 1100) + 50,
      );
    }
    // Fallback for history entries without DNA
    final r = Random(index * 7919);
    return Offset(
      r.nextDouble() * 1100 + 50,
      r.nextDouble() * 1100 + 50,
    );
  }

  Color _getOutcomeColor(UniverseOutcome outcome) {
    switch (outcome) {
      case UniverseOutcome.eternalGarden: return GameConstants.lifeGreen;
      case UniverseOutcome.lastLight: return Colors.amber;
      case UniverseOutcome.greatCollapse: return Colors.red;
      case UniverseOutcome.eternalRecurrence: return Colors.purpleAccent;
      default: return Colors.grey;
    }
  }

  IconData _getOutcomeIcon(UniverseOutcome outcome) {
    switch (outcome) {
      case UniverseOutcome.eternalGarden: return Icons.auto_awesome;
      case UniverseOutcome.lastLight: return Icons.wb_sunny_outlined;
      case UniverseOutcome.greatCollapse: return Icons.brightness_3;
      case UniverseOutcome.eternalRecurrence: return Icons.loop;
      default: return Icons.blur_on;
    }
  }

  void _showUniverseDetails(
      BuildContext context, UniverseState state, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 420,
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Text("UNIVERSE #$index",
                style: const TextStyle(
                    color: Colors.white38, letterSpacing: 2)),
            const SizedBox(height: 6),
            Text(
              StringUtils.outcomeLabel(state.outcome.name),
              style: TextStyle(
                color: _getOutcomeColor(state.outcome),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (state.dna.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                state.dna,
                style: GoogleFonts.orbitron(
                  color: Colors.white38,
                  fontSize: 14,
                  letterSpacing: 6,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomPaint(
                      painter: RadarChartPainter(state),
                      size: const Size(150, 150),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _statLabel("G", state.gravity),
                        _statLabel("NF", state.nuclearForce),
                        _statLabel("EM", state.emForce),
                        _statLabel("SR", state.entropyRate),
                        _statLabel("DE", state.darkEnergyPressure),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statLabel(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        "$label: ${val.toStringAsFixed(2)}",
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<SimulationService>().history;

    final collapses = history
        .where((u) => u.outcome == UniverseOutcome.greatCollapse)
        .length;
    final gardens = history
        .where((u) => u.outcome == UniverseOutcome.eternalGarden)
        .length;
    final loops = history
        .where((u) => u.outcome == UniverseOutcome.eternalRecurrence)
        .length;
    final flames =
        history.where((u) => u.outcome == UniverseOutcome.lastLight).length;

    return Scaffold(
      backgroundColor: GameConstants.spaceBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "OBSERVATORY",
              style: GoogleFonts.orbitron(fontSize: 18, letterSpacing: 3),
            ),
            Text(
              "${history.length} universes charted",
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: history.isEmpty
                ? const Center(
              child: Text(
                "No universes charted yet.\nCreate your first universe to begin.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white24, height: 1.6),
              ),
            )
                : InteractiveViewer(
              minScale: 0.3,
              maxScale: 3.0,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(200),
              child: SizedBox(
                width: 1200,
                height: 1200,
                child: Stack(
                  children: [
                    // Starfield background
                    CustomPaint(
                      size: const Size(1200, 1200),
                      painter: StaticStarfieldPainter(200, 42),
                    ),
                    // Constellation lines
                    CustomPaint(
                      size: const Size(1200, 1200),
                      painter: _ObservatoryConstellationPainter(
                        history: history,
                        getPosition: _getNodePosition,
                      ),
                    ),
                    // Universe nodes
                    ...history.asMap().entries.map((entry) {
                      final index = entry.key;
                      final state = entry.value;
                      final pos = _getNodePosition(state, index);
                      final isRecent = index == history.length - 1;
                      final color = _getOutcomeColor(state.outcome);

                      return Positioned(
                        left: pos.dx - 30,
                        top: pos.dy - 30,
                        child: GestureDetector(
                          onTap: () => _showUniverseDetails(
                              context, state, index + 1),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                  color.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: color.withValues(
                                      alpha: isRecent
                                          ? 0.4 +
                                          _pulseController
                                              .value *
                                              0.4
                                          : 0.3,
                                    ),
                                    width: isRecent ? 2 : 1,
                                  ),
                                  boxShadow: isRecent
                                      ? [
                                    BoxShadow(
                                      color: color.withValues(
                                        alpha:
                                        _pulseController
                                            .value *
                                            0.3,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: 5,
                                    ),
                                  ]
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getOutcomeIcon(state.outcome),
                                      size: 18,
                                      color: color,
                                    ),
                                    if (state.dna.isNotEmpty)
                                      Text(
                                        state.dna,
                                        style: TextStyle(
                                          color: color.withValues(
                                              alpha: 0.7),
                                          fontSize: 6,
                                          letterSpacing: 1,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          // Fixed stats bar
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.black54,
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statChip("COLLAPSES", collapses, Colors.red),
                _statChip("GARDENS", gardens, GameConstants.lifeGreen),
                _statChip("LOOPS", loops, Colors.purpleAccent),
                _statChip("FLAMES", flames, Colors.amber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white24,
            fontSize: 9,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ObservatoryConstellationPainter extends CustomPainter {
  final List<UniverseState> history;
  final Offset Function(UniverseState, int) getPosition;

  _ObservatoryConstellationPainter({
    required this.history,
    required this.getPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < history.length - 1; i++) {
      final start = getPosition(history[i], i);
      final end = getPosition(history[i + 1], i + 1);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}