import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants.dart';

class UniverseVisual extends StatefulWidget {
  final UniverseStage stage;
  final double intensity;

  const UniverseVisual({
    super.key,
    required this.stage,
    required this.intensity,
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
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 300),
          painter: UniversePainter(
            stage: widget.stage,
            animationValue: _controller.value,
            intensity: widget.intensity,
          ),
        );
      },
    );
  }
}

class UniversePainter extends CustomPainter {
  final UniverseStage stage;
  final double animationValue;
  final double intensity;

  UniversePainter({
    required this.stage,
    required this.animationValue,
    required this.intensity,
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
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, GameConstants.cosmicPurple, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: 100 * animationValue));

    canvas.drawCircle(center, 150 * animationValue, paint);
    
    // Particles
    final particlePaint = Paint()..color = Colors.white.withOpacity(0.8);
    for (var i = 0; i < 50; i++) {
      double angle = i * 0.5 + animationValue * 5;
      double dist = (i * 3.0) * animationValue;
      canvas.drawCircle(
        Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist),
        2,
        particlePaint,
      );
    }
  }

  void _paintStars(Canvas canvas, Size size, Random random) {
    for (var i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = (sin(animationValue * 10 + i) + 1) / 2;
      
      final paint = Paint()..color = GameConstants.starGold.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 1 + random.nextDouble() * 2, paint);
    }
  }

  void _paintPlanets(Canvas canvas, Offset center, Size size) {
    final orbitPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, 50, orbitPaint);
    canvas.drawCircle(center, 80, orbitPaint);

    final planetPaint = Paint()..color = Colors.blueAccent;
    double angle = animationValue * 2 * pi;
    canvas.drawCircle(
      Offset(center.dx + cos(angle) * 50, center.dy + sin(angle) * 50),
      8,
      planetPaint,
    );

    canvas.drawCircle(
      Offset(center.dx + cos(angle * 0.6) * 80, center.dy + sin(angle * 0.6) * 80),
      12,
      Paint()..color = Colors.orangeAccent,
    );
  }

  void _paintLife(Canvas canvas, Offset center, Size size) {
    _paintPlanets(canvas, center, size);
    
    final lifePaint = Paint()
      ..color = GameConstants.lifeGreen.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    double angle = animationValue * 2 * pi;
    canvas.drawCircle(
      Offset(center.dx + cos(angle) * 50, center.dy + sin(angle) * 50),
      15,
      lifePaint,
    );
  }

  @override
  bool shouldRepaint(covariant UniversePainter oldDelegate) => true;
}
