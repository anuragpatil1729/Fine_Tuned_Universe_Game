import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants.dart';
import '../core/simulation_engine.dart';
import '../core/string_utils.dart';
import '../services/simulation_service.dart';
import '../services/anomaly_service.dart';
import '../services/codex_service.dart';
import '../models/anomaly.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showButtons = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SimulationService, AnomalyService, CodexService>(
      builder: (context, sim, anomaly, codex, child) {
        final state = sim.currentUniverse;
        final outcome = state.outcome;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _getEndingPainter(outcome, _controller.value),
                ),
              ),
              if (outcome == UniverseOutcome.greatCollapse)
                _buildShakeWrapper(
                  child: _buildContent(context, sim, anomaly, codex),
                )
              else
                _buildContent(context, sim, anomaly, codex),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShakeWrapper({required Widget child}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final random = Random();
        double tx = (random.nextDouble() - 0.5) * 4;
        double ty = (random.nextDouble() - 0.5) * 4;
        return Transform.translate(offset: Offset(tx, ty), child: child);
      },
      child: child,
    );
  }

  Widget _buildContent(
      BuildContext context,
      SimulationService sim,
      AnomalyService anomaly,
      CodexService codex,
      ) {
    final state = sim.currentUniverse;
    final outcome = state.outcome;
    final activeAnomaly = anomaly.activeAnomaly;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (activeAnomaly != null) _buildAnomalyBanner(activeAnomaly),

              const SizedBox(height: 20),
              Text(
                StringUtils.outcomeLabel(outcome.name),
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                SimulationEngine.getEndingSubtitle(outcome),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              if (codex.hasNewEntries)
                const Text(
                  "NEW CODEX ENTRIES UNLOCKED",
                  style: TextStyle(
                    color: GameConstants.lifeGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  SimulationEngine.getOutcomeMessage(outcome),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildStatRow("Gravity", state.gravity,
                  GameConstants.gravityMin, GameConstants.gravityMax),
              _buildStatRow("Nuclear", state.nuclearForce,
                  GameConstants.nuclearForceMin, GameConstants.nuclearForceMax),
              _buildStatRow("EM Force", state.emForce,
                  GameConstants.emForceMin, GameConstants.emForceMax),
              _buildStatRow("Entropy", state.entropyRate,
                  GameConstants.entropyRateMin, GameConstants.entropyRateMax),
              _buildStatRow(
                  "Dark Energy",
                  state.darkEnergyPressure,
                  GameConstants.darkEnergyMin,
                  GameConstants.darkEnergyMax),

              // DNA Display Block
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    const Text(
                      "UNIVERSE DNA",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.dna.isEmpty ? "------" : state.dna,
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        color: Colors.white,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Share this seed to recreate your universe",
                      style: TextStyle(color: Colors.white24, fontSize: 10),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),
              AnimatedOpacity(
                opacity: _showButtons ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        sim.reset();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('PLAY AGAIN',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () {
                        final text =
                            "🌌 Universe DNA: ${state.dna}\n"
                            "Outcome: ${StringUtils.outcomeLabel(outcome.name)}\n"
                            "G:${state.gravity.toStringAsFixed(2)} "
                            "N:${state.nuclearForce.toStringAsFixed(2)} "
                            "EM:${state.emForce.toStringAsFixed(2)} "
                            "S:${state.entropyRate.toStringAsFixed(2)} "
                            "DE:${state.darkEnergyPressure.toStringAsFixed(2)}\n"
                            "Fine-Tuned Universe";
                        Share.share(text);
                      },
                      icon: const Icon(Icons.share, color: Colors.white70),
                      label: const Text('SHARE THIS UNIVERSE',
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnomalyBanner(Anomaly anomaly) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            "ANOMALY: ${anomaly.name}",
            style: GoogleFonts.orbitron(
                color: Colors.amber,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          if (anomaly.isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.military_tech, color: Colors.amber, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    "BADGE EARNED: ${anomaly.badgeLabel}",
                    style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
      String label, double value, double min, double max) {
    bool isOk = value >= min && value <= max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Row(
            children: [
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(
                  color: isOk ? Colors.greenAccent : Colors.orangeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                isOk ? Icons.check_circle : Icons.warning,
                size: 12,
                color: isOk ? Colors.greenAccent : Colors.orangeAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  CustomPainter _getEndingPainter(
      UniverseOutcome outcome, double animationValue) {
    switch (outcome) {
      case UniverseOutcome.eternalGarden:
        return EternalGardenPainter(animationValue);
      case UniverseOutcome.lastLight:
        return LastLightPainter(animationValue);
      case UniverseOutcome.greatCollapse:
        return GreatCollapsePainter(animationValue);
      case UniverseOutcome.eternalRecurrence:
        return EternalRecurrencePainter(animationValue);
      default:
        return EternalGardenPainter(animationValue);
    }
  }
}

class EternalGardenPainter extends CustomPainter {
  final double animationValue;
  EternalGardenPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 3; i++) {
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.teal.withValues(alpha: 0.0),
            Colors.green.withValues(alpha: 0.2),
            Colors.teal.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      double offset = (animationValue * 2 * pi + i * 2) % (2 * pi);
      Path path = Path();
      path.moveTo(0, size.height * 0.4 + sin(offset) * 50);
      for (double x = 0; x <= size.width; x += 10) {
        path.lineTo(
            x, size.height * 0.4 + sin(x * 0.01 + offset) * 50 + i * 30);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      canvas.drawPath(path, paint);
    }
    final pPaint = Paint()
      ..color = GameConstants.starGold.withValues(alpha: 0.3);
    for (int i = 0; i < 30; i++) {
      double angle = i * 1.5 + animationValue * 2;
      double dist = (i * 10.0 + animationValue * 100) % 300;
      canvas.drawCircle(
          Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist),
          2,
          pPaint);
    }
    final rPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white10
      ..strokeWidth = 1;
    canvas.drawCircle(center, 100, rPaint);
    canvas.drawCircle(center, 150, rPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LastLightPainter extends CustomPainter {
  final double animationValue;
  LastLightPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    double opacity = (1.0 - (animationValue * 5) % 1.0).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white.withValues(alpha: opacity * 0.5),
    );
    final pPaint = Paint()..color = Colors.orangeAccent.withValues(alpha: 0.4);
    for (int i = 0; i < 20; i++) {
      double x = (i * 20.0 + animationValue * 50) % size.width;
      double y = size.height - (i * 30.0 + animationValue * 200) % size.height;
      canvas.drawCircle(
        Offset(x, y),
        2,
        pPaint
          ..color =
          pPaint.color.withValues(alpha: (y / size.height) * 0.4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant LastLightPainter oldDelegate) => true;
}

class GreatCollapsePainter extends CustomPainter {
  final double animationValue;
  GreatCollapsePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    double pulse = (sin(animationValue * 10) + 1) / 2;
    canvas.drawCircle(
      center,
      200,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.red.withValues(alpha: 0.2 * pulse),
          Colors.black
        ]).createShader(Rect.fromCircle(center: center, radius: 200)),
    );
    final pPaint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.6);
    for (int i = 0; i < 100; i++) {
      double t = (i / 100.0 + animationValue) % 1.0;
      double angle = t * 10 * pi;
      double dist = (1.0 - t) * 200;
      canvas.drawCircle(
        Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist),
        2,
        pPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GreatCollapsePainter oldDelegate) => true;
}

class EternalRecurrencePainter extends CustomPainter {
  final double animationValue;
  EternalRecurrencePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    double cycle = (sin(animationValue * 2 * pi / 3 * 10) + 1) / 2;
    double radius = 10 + cycle * 150;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = GameConstants.cosmicPurple.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    final rPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white24
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, rPaint);
  }

  @override
  bool shouldRepaint(covariant EternalRecurrencePainter oldDelegate) => true;
}