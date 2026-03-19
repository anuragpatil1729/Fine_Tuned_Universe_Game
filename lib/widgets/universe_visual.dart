// CHANGES MADE:
// 1. Added `gravity`, `nuclear`, and `em` parameters to receive real-time constant data for reactive rendering.
// 2. Implemented "Warning Shudder": the visual shakes (via Transform.translate) when any constant enters a catastrophic range.
// 3. PILLAR 1: Reactive bigBang - expansion ring speed and particle density now scale with gravity.
// 4. PILLAR 1: Reactive starFormation - star density and pulsing brightness respond to nuclear force.
// 5. PILLAR 1: Reactive planetFormation - orbit stability (wobble) increases as nuclear force deviates from the safe center.
// 6. PILLAR 1: Reactive emergenceOfLife - the intensity of the green "life glow" is mapped to the EM force's proximity to the safe zone.

import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';

class UniverseVisual extends StatefulWidget {
  final UniverseStage stage;
  final double gravity;
  final double nuclear;
  final double em;

  const UniverseVisual({
    super.key,
    required this.stage,
    required this.gravity,
    required this.nuclear,
    required this.em,
  });

  @override
  State<UniverseVisual> createState() => _UniverseVisualState();
}

class _UniverseVisualState extends State<UniverseVisual> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isCatastrophic() {
    if (widget.gravity < 0.2 || widget.gravity > 0.8) return true;
    if (widget.nuclear < 0.3 || widget.nuclear > 0.7) return true;
    if (widget.em < 0.2 || widget.em > 0.8) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Shudder effect for catastrophic values
        double shakeX = 0;
        double shakeY = 0;
        if (_isCatastrophic()) {
          final random = Random();
          shakeX = (random.nextDouble() - 0.5) * 10;
          shakeY = (random.nextDouble() - 0.5) * 10;
        }

        return Transform.translate(
          offset: Offset(shakeX, shakeY),
          child: CustomPaint(
            size: const Size(double.infinity, 350),
            painter: UniversePainter(
              stage: widget.stage,
              animationValue: _controller.value,
              gravity: widget.gravity,
              nuclear: widget.nuclear,
              em: widget.em,
            ),
          ),
        );
      },
    );
  }
}

class UniversePainter extends CustomPainter {
  final UniverseStage stage;
  final double animationValue;
  final double gravity;
  final double nuclear;
  final double em;

  UniversePainter({
    required this.stage,
    required this.animationValue,
    required this.gravity,
    required this.nuclear,
    required this.em,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = Random(42);

    switch (stage) {
      case UniverseStage.bigBang:
        _paintBigBang(canvas, center, size);
        break;
      case UniverseStage.starFormation:
        _paintStars(canvas, size, random);
        break;
      case UniverseStage.planetFormation:
        _paintPlanets(canvas, center, size);
        break;
      case UniverseStage.emergenceOfLife:
        _paintLife(canvas, center, size);
        break;
      default:
        break;
    }
  }

  void _paintBigBang(Canvas canvas, Offset center, Size size) {
    // Expansion speed and ring radius scale with gravity
    double expansion = (animationValue * (0.5 + gravity * 3)) % 1.0;
    double ringRadius = 50 + (expansion * 150);
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 + (gravity * 8)
      ..shader = RadialGradient(
        colors: [Colors.white, GameConstants.cosmicPurple.withOpacity(0.4), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: ringRadius));

    canvas.drawCircle(center, ringRadius, paint);
    
    // Particle density scales with gravity
    final particlePaint = Paint()..color = Colors.white.withOpacity(0.7);
    int pCount = (30 + (gravity * 120)).toInt();
    for (var i = 0; i < pCount; i++) {
      double angle = i * 0.9 + animationValue * (4 - gravity * 2);
      double dist = (i * 2.5) * expansion * (1.1 - gravity * 0.5);
      canvas.drawCircle(
        Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist),
        1 + (gravity * 2),
        particlePaint,
      );
    }
  }

  void _paintStars(Canvas canvas, Size size, Random random) {
    // Star count and brightness pulsing scale with nuclear force
    int starCount = (40 + (nuclear * 180)).toInt();
    double pulse = (sin(animationValue * 25 * nuclear) + 1) / 2;

    for (var i = 0; i < starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = (random.nextDouble() * 0.4) + (pulse * 0.6);
      
      final paint = Paint()..color = GameConstants.starGold.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 0.5 + (nuclear * 2.5), paint);
    }
  }

  void _paintPlanets(Canvas canvas, Offset center, Size size) {
    // Orbit wobble increases as nuclear force deviates from center (0.5)
    double stabilityWobble = (nuclear - 0.5).abs() * 40;
    double angle = animationValue * 2.5 * pi;

    final orbitPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, 65, orbitPaint);
    
    // Main planet with wobble
    double p1Angle = angle + (sin(animationValue * 12) * stabilityWobble * 0.015);
    Offset planetPos = Offset(center.dx + cos(p1Angle) * 65, center.dy + sin(p1Angle) * 65);
    canvas.drawCircle(planetPos, 9, Paint()..color = Colors.blueAccent);

    // Secondary planet with distance wobble
    double p2Dist = 110 + (cos(animationValue * 8) * stabilityWobble);
    Offset p2Pos = Offset(center.dx + cos(angle * 0.4) * p2Dist, center.dy + sin(angle * 0.4) * p2Dist);
    canvas.drawCircle(p2Pos, 13, Paint()..color = Colors.orangeAccent);
  }

  void _paintLife(Canvas canvas, Offset center, Size size) {
    _paintPlanets(canvas, center, size);
    
    // Life glow intensity scales with EM force's proximity to its safe zone (0.35-0.65)
    double emCenter = (GameConstants.emForceMin + GameConstants.emForceMax) / 2;
    double lifeIntensity = (1.0 - (em - emCenter).abs() * 3).clamp(0.0, 1.0);
    double pulse = (sin(animationValue * 18) + 1) / 2 * lifeIntensity;
    
    final lifePaint = Paint()
      ..color = GameConstants.lifeGreen.withOpacity(0.2 + (pulse * 0.5))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + (pulse * 18));
    
    double angle = animationValue * 2.5 * pi;
    Offset planetPos = Offset(center.dx + cos(angle) * 65, center.dy + sin(angle) * 65);
    canvas.drawCircle(planetPos, 22 + (pulse * 25), lifePaint);
  }

  @override
  bool shouldRepaint(covariant UniversePainter oldDelegate) => true;
}
