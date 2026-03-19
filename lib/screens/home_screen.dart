// BUG FIXED: Bug 1 - StarfieldPainter regenerates stars every frame.
// HOW: Moved star positions and sizes generation to initState() so they are computed once. 
// Passed them as final lists to the painter to ensure visual stability while animating opacity.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../services/simulation_service.dart';
import '../services/codex_service.dart';
import '../services/anomaly_service.dart';
import 'anomaly_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _starController;
  final List<Offset> _starPositions = [];
  final List<double> _starSizes = [];

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    final random = Random(42); // Fixed seed for consistent star placement
    for (int i = 0; i < 150; i++) {
      _starPositions.add(Offset(random.nextDouble(), random.nextDouble()));
      _starSizes.add(random.nextDouble() * 2);
    }
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SimulationService, CodexService, AnomalyService>(
      builder: (context, sim, codex, anomaly, child) {
        final history = sim.history;
        final survived = history.where((u) => u.outcome == UniverseOutcome.eternalGarden).length;

        return Scaffold(
          backgroundColor: GameConstants.spaceBlack,
          body: Stack(
            children: [
              // Twinkling Starfield
              Positioned.fill(
                child: CustomPaint(
                  painter: StarfieldPainter(
                    animation: _starController,
                    starPositions: _starPositions,
                    starSizes: _starSizes,
                  ),
                ),
              ),
              
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'FINE-TUNED',
                      style: GoogleFonts.orbitron(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 10,
                      ),
                    ),
                    Text(
                      'UNIVERSE',
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        color: Colors.white70,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "From the first spark to the final silence.",
                      style: GoogleFonts.exo2(
                        color: Colors.white38,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 80),
                    ElevatedButton(
                      onPressed: () {
                        sim.reset();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AnomalySelectionScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        elevation: 10,
                      ),
                      child: const Text(
                        'BEGIN THE ARC',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ProgressIndicator(label: "Badges", value: anomaly.completedCount, total: 5),
                        const SizedBox(width: 30),
                        _ProgressIndicator(label: "Codex", value: codex.unlockedCount, total: 12),
                      ],
                    ),
                    if (history.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Universes created: ${history.length} | Survived: $survived",
                        style: const TextStyle(color: Colors.white10, fontSize: 10, letterSpacing: 1),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final String label;
  final int value;
  final int total;

  const _ProgressIndicator({required this.label, required this.value, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "$value / $total",
          style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2),
        ),
      ],
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Offset> starPositions;
  final List<double> starSizes;

  StarfieldPainter({
    required this.animation,
    required this.starPositions,
    required this.starSizes,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (int i = 0; i < starPositions.length; i++) {
      double opacity = (sin(animation.value * 2 * pi + i) + 1) / 2;
      paint.color = Colors.white.withValues(alpha: opacity * 0.8);
      canvas.drawCircle(
        Offset(starPositions[i].dx * size.width, starPositions[i].dy * size.height),
        starSizes[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) => false;
}
