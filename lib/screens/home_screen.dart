import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../core/universe_dna.dart';
import '../services/simulation_service.dart';
import '../services/codex_service.dart';
import '../services/anomaly_service.dart';
import 'anomaly_selection_screen.dart';
import 'observatory_screen.dart';
import 'simulation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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

    final random = Random(42);
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

  void _showSeedDialog(BuildContext context, SimulationService sim) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          "ENTER UNIVERSE DNA",
          style: GoogleFonts.orbitron(
              color: Colors.white, fontSize: 16, letterSpacing: 2),
        ),
        content: TextField(
          controller: controller,
          maxLength: 6,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 8,
          ),
          decoration: const InputDecoration(
            hintText: "A3F7K2",
            hintStyle: TextStyle(color: Colors.white24),
            border: OutlineInputBorder(),
            counterText: "",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("CANCEL",
                style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              final input = controller.text.trim().toUpperCase();
              if (!UniverseDNA.isValid(input)) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Invalid universe seed"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              final constants = UniverseDNA.parse(input);
              sim.loadFromDNA(constants);
              context.read<AnomalyService>().clearAnomaly();
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const SimulationScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text("LOAD",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SimulationService, CodexService, AnomalyService>(
      builder: (context, sim, codex, anomaly, child) {
        return Scaffold(
          backgroundColor: GameConstants.spaceBlack,
          body: Stack(
            children: [
              // Twinkling starfield
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _starController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: StarfieldPainter(
                        animation: _starController,
                        starPositions: _starPositions,
                        starSizes: _starSizes,
                      ),
                    );
                  },
                ),
              ),

              // Observatory button (top-right, only when history exists)
              if (sim.history.isNotEmpty)
                Positioned(
                  top: 50,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.scatter_plot,
                        color: Colors.white38),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ObservatoryScreen()),
                    ),
                  ),
                ),

              // Main content
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
                          MaterialPageRoute(
                              builder: (_) =>
                              const AnomalySelectionScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        elevation: 10,
                      ),
                      child: const Text(
                        'BEGIN THE ARC',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => _showSeedDialog(context, sim),
                      child: const Text(
                        "LOAD UNIVERSE SEED",
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ProgressIndicator(
                            label: "Badges",
                            value: anomaly.completedCount,
                            total: 5),
                        const SizedBox(width: 30),
                        _ProgressIndicator(
                            label: "Codex",
                            value: codex.unlockedCount,
                            total: 12),
                      ],
                    ),
                    if (sim.history.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        "Universes created: ${sim.history.length} | "
                            "Survived: ${sim.history.where((u) => u.outcome == UniverseOutcome.eternalGarden).length}",
                        style: const TextStyle(
                            color: Colors.white10,
                            fontSize: 10,
                            letterSpacing: 1),
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

  const _ProgressIndicator(
      {required this.label, required this.value, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "$value / $total",
          style: GoogleFonts.orbitron(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              color: Colors.white24, fontSize: 10, letterSpacing: 2),
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
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (int i = 0; i < starPositions.length; i++) {
      double opacity = (sin(animation.value * 2 * pi + i) + 1) / 2;
      paint.color = Colors.white.withValues(alpha: opacity * 0.8);
      canvas.drawCircle(
        Offset(starPositions[i].dx * size.width,
            starPositions[i].dy * size.height),
        starSizes[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) => true;
}