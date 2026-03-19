// CHANGES MADE:
// 1. Implemented a full-screen animated background system driven by CustomPainters for each of the 4 new endings.
// 2. Eternal Garden: Emerald aurora waves and golden particle bloom.
// 3. Last Light: White flash fading to drifting embers.
// 4. Great Collapse: Red/black implosion vortex with screen shake.
// 5. Eternal Recurrence: Ouroboros-style expansion/contraction loop.
// 6. Added a 2-second delay for the "PLAY AGAIN" button's appearance to emphasize the visual conclusion.
// 7. Added "SHARE THIS UNIVERSE" functionality to copy outcome and constants to the clipboard.
// 8. Displayed all 5 lifecycle constants with their safe-zone indicators.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants.dart';
import '../core/simulation_engine.dart';
import '../services/simulation_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
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
    return Consumer<SimulationService>(
      builder: (context, service, child) {
        final state = service.currentUniverse;
        final outcome = state.outcome;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Full screen animated background
              Positioned.fill(
                child: CustomPaint(
                  painter: _getEndingPainter(outcome, _controller.value),
                ),
              ),

              // Shake effect for Great Collapse
              if (outcome == UniverseOutcome.greatCollapse)
                _buildShakeWrapper(
                  child: _buildContent(context, service),
                )
              else
                _buildContent(context, service),
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

  Widget _buildContent(BuildContext context, SimulationService service) {
    final state = service.currentUniverse;
    final outcome = state.outcome;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                outcome.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toUpperCase(),
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
                style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
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
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                ),
              ),
              const SizedBox(height: 40),
              _buildStatRow("Gravity", state.gravity, GameConstants.gravityMin, GameConstants.gravityMax),
              _buildStatRow("Nuclear", state.nuclearForce, GameConstants.nuclearForceMin, GameConstants.nuclearForceMax),
              _buildStatRow("EM Force", state.emForce, GameConstants.emForceMin, GameConstants.emForceMax),
              _buildStatRow("Entropy", state.entropyRate, GameConstants.entropyRateMin, GameConstants.entropyRateMax),
              _statRowDarkEnergy(state.darkEnergyPressure),
              
              const SizedBox(height: 60),
              AnimatedOpacity(
                opacity: _showButtons ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        service.reset();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('PLAY AGAIN', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () {
                        final text = "Universe Outcome: ${outcome.name}\nG: ${state.gravity.toStringAsFixed(2)} | N: ${state.nuclearForce.toStringAsFixed(2)} | EM: ${state.emForce.toStringAsFixed(2)} | S: ${state.entropyRate.toStringAsFixed(2)} | DE: ${state.darkEnergyPressure.toStringAsFixed(2)}";
                        Share.share(text);
                      },
                      icon: const Icon(Icons.share, color: Colors.white70),
                      label: const Text('SHARE THIS UNIVERSE', style: TextStyle(color: Colors.white70)),
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

  Widget _buildStatRow(String label, double value, double min, double max) {
    bool isOk = value >= min && value <= max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Row(
            children: [
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(color: isOk ? Colors.greenAccent : Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 5),
              Icon(isOk ? Icons.check_circle : Icons.warning, size: 12, color: isOk ? Colors.greenAccent : Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statRowDarkEnergy(double value) {
    bool isOk = value >= GameConstants.darkEnergyMin && value <= GameConstants.darkEnergyMax;
    return _buildStatRow("Dark Energy", value, GameConstants.darkEnergyMin, GameConstants.darkEnergyMax);
  }

  CustomPainter _getEndingPainter(UniverseOutcome outcome, double animationValue) {
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
    
    // Aurora waves
    for (int i = 0; i < 3; i++) {
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.teal.withOpacity(0.0), Colors.green.withOpacity(0.2), Colors.teal.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
      double offset = (animationValue * 2 * pi + i * 2) % (2 * pi);
      Path path = Path();
      path.moveTo(0, size.height * 0.4 + sin(offset) * 50);
      for (double x = 0; x <= size.width; x += 10) {
        path.lineTo(x, size.height * 0.4 + sin(x * 0.01 + offset) * 50 + i * 30);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      canvas.drawPath(path, paint);
    }

    // Golden particles
    final pPaint = Paint()..color = GameConstants.starGold.withOpacity(0.3);
    for (int i = 0; i < 30; i++) {
      double angle = i * 1.5 + animationValue * 2;
      double dist = (i * 10.0 + animationValue * 100) % 300;
      canvas.drawCircle(Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist), 2, pPaint);
    }

    // Rings
    final rPaint = Paint()..style = PaintingStyle.stroke..color = Colors.white10..strokeWidth = 1;
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
    // White flash fading
    double opacity = (1.0 - (animationValue * 5) % 1.0).clamp(0.0, 1.0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white.withOpacity(opacity * 0.5));

    // Drifting embers
    final pPaint = Paint()..color = Colors.orangeAccent.withOpacity(0.4);
    for (int i = 0; i < 20; i++) {
      double x = (i * 20.0 + animationValue * 50) % size.width;
      double y = (size.height - (i * 30.0 + animationValue * 200) % size.height);
      canvas.drawCircle(Offset(x, y), 2, pPaint..color = pPaint.color.withOpacity((y / size.height) * 0.4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GreatCollapsePainter extends CustomPainter {
  final double animationValue;
  GreatCollapsePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Pulse
    double pulse = (sin(animationValue * 10) + 1) / 2;
    canvas.drawCircle(center, 200, Paint()..shader = RadialGradient(colors: [Colors.red.withOpacity(0.2 * pulse), Colors.black]).createShader(Rect.fromCircle(center: center, radius: 200)));

    // Spiral particles
    final pPaint = Paint()..color = Colors.redAccent.withOpacity(0.6);
    for (int i = 0; i < 100; i++) {
      double t = (i / 100.0 + animationValue) % 1.0;
      double angle = t * 10 * pi;
      double dist = (1.0 - t) * 200;
      canvas.drawCircle(Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist), 2, pPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EternalRecurrencePainter extends CustomPainter {
  final double animationValue;
  EternalRecurrencePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    double cycle = (sin(animationValue * 2 * pi / 3 * 10) + 1) / 2;
    
    // Expand/Collapse circle
    double radius = 10 + cycle * 150;
    canvas.drawCircle(center, radius, Paint()..color = GameConstants.cosmicPurple.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));
    
    // Ouroboros ring
    final rPaint = Paint()..style = PaintingStyle.stroke..color = Colors.white24..strokeWidth = 2;
    canvas.drawCircle(center, radius, rPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
