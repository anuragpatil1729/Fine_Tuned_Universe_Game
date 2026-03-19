// FIX: cosmicFate canvas.scale drifts from center.
// FIX: The universe visual must react to slider changes in real time with smooth interpolation.
// CHANGE: Added translate-scale-translate pattern to scale from center.
// CHANGE: Implemented real-time lerp interpolation for display values using a secondary AnimationController.

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants.dart';

class UniverseVisual extends StatefulWidget {
  final UniverseStage stage;
  final double gravity;
  final double nuclear;
  final double em;
  final double entropy;
  final double darkEnergy;

  const UniverseVisual({
    super.key,
    required this.stage,
    required this.gravity,
    required this.nuclear,
    required this.em,
    required this.entropy,
    required this.darkEnergy,
  });

  @override
  State<UniverseVisual> createState() => _UniverseVisualState();
}

class _UniverseVisualState extends State<UniverseVisual> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _reactController;

  double _displayGravity = 0.5;
  double _displayNuclear = 0.5;
  double _displayEm = 0.5;
  double _displayEntropy = 0.5;
  double _displayDarkEnergy = 0.5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _reactController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _displayGravity = widget.gravity;
    _displayNuclear = widget.nuclear;
    _displayEm = widget.em;
    _displayEntropy = widget.entropy;
    _displayDarkEnergy = widget.darkEnergy;
  }

  void _updateDisplayValues() {
    if (!mounted) return;
    final t = _reactController.value;
    final oldG = _displayGravity;
    final oldN = _displayNuclear;
    final oldEm = _displayEm;
    final oldEn = _displayEntropy;
    final oldDe = _displayDarkEnergy;

    setState(() {
      _displayGravity = lerpDouble(oldG, widget.gravity, t) ?? widget.gravity;
      _displayNuclear = lerpDouble(oldN, widget.nuclear, t) ?? widget.nuclear;
      _displayEm = lerpDouble(oldEm, widget.em, t) ?? widget.em;
      _displayEntropy = lerpDouble(oldEn, widget.entropy, t) ?? widget.entropy;
      _displayDarkEnergy = lerpDouble(oldDe, widget.darkEnergy, t) ?? widget.darkEnergy;
    });
  }

  @override
  void didUpdateWidget(UniverseVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.gravity != widget.gravity ||
        oldWidget.nuclear != widget.nuclear ||
        oldWidget.em != widget.em ||
        oldWidget.entropy != widget.entropy ||
        oldWidget.darkEnergy != widget.darkEnergy) {
      
      final startG = _displayGravity;
      final startN = _displayNuclear;
      final startEm = _displayEm;
      final startEn = _displayEntropy;
      final startDe = _displayDarkEnergy;
      
      _reactController.stop();
      _reactController.reset();
      
      void listener() {
        if (!mounted) return;
        final t = _reactController.value;
        setState(() {
          _displayGravity = lerpDouble(startG, widget.gravity, t)!;
          _displayNuclear = lerpDouble(startN, widget.nuclear, t)!;
          _displayEm = lerpDouble(startEm, widget.em, t)!;
          _displayEntropy = lerpDouble(startEn, widget.entropy, t)!;
          _displayDarkEnergy = lerpDouble(startDe, widget.darkEnergy, t)!;
        });
      }

      _reactController.addListener(listener);
      _reactController.forward().then((_) {
        _reactController.removeListener(listener);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _reactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 350),
          painter: UniversePainter(
            stage: widget.stage,
            animationValue: _controller.value,
            gravity: _displayGravity,
            nuclear: _displayNuclear,
            em: _displayEm,
            entropy: _displayEntropy,
            darkEnergy: _displayDarkEnergy,
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
  final double entropy;
  final double darkEnergy;

  UniversePainter({
    required this.stage,
    required this.animationValue,
    required this.gravity,
    required this.nuclear,
    required this.em,
    required this.entropy,
    required this.darkEnergy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = Random(42);

    switch (stage) {
      case UniverseStage.cosmicDawn:
        _paintCosmicDawn(canvas, center, size);
        break;
      case UniverseStage.stellarAge:
        _paintStellarAge(canvas, size, random);
        break;
      case UniverseStage.galacticAge:
        _paintGalacticAge(canvas, center, size, random);
        break;
      case UniverseStage.lifeAge:
        _paintLifeAge(canvas, center, size, random);
        break;
      case UniverseStage.stellarDeath:
        _paintStellarDeath(canvas, center, size, random);
        break;
      case UniverseStage.cosmicFate:
        _paintCosmicFate(canvas, center, size, random);
        break;
    }
  }

  void _paintCosmicDawn(Canvas canvas, Offset center, Size size) {
    double expansion = (animationValue * 5) % 1.0;
    double ringRadius = expansion * (size.width / 2);
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..shader = RadialGradient(
        colors: [Colors.white, GameConstants.cosmicPurple, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: ringRadius));

    canvas.drawCircle(center, ringRadius, paint);

    int pCount = (gravity * 200).toInt();
    final pPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    
    for (int i = 0; i < pCount; i++) {
      double angle = i * 1.5 + animationValue * 2;
      double dist = (i * 2.0) * expansion;
      
      if (gravity > 0.65) {
        dist *= (1.0 - expansion);
        angle += expansion * 10;
      } else if (gravity < 0.35) {
        dist *= (1.0 + expansion);
      }

      canvas.drawCircle(
        Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist),
        1.5,
        pPaint,
      );
    }
  }

  void _paintStellarAge(Canvas canvas, Size size, Random random) {
    for (int i = 0; i < 80; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double flicker = (sin(animationValue * 100 * random.nextDouble()) + 1) / 2;
      double brightness = nuclear * flicker;
      
      Color starColor = GameConstants.starGold;
      if (nuclear < 0.30) {
        starColor = Colors.blue.withValues(alpha: 0.5);
      }
      
      final paint = Paint()..color = starColor.withValues(alpha: brightness.clamp(0.0, 1.0));
      
      if (nuclear > 0.70) {
        double flare = (sin(animationValue * 200) + 1) / 2;
        canvas.drawCircle(Offset(x, y), 2 + flare * 4, paint..color = Colors.white.withValues(alpha: flare));
      } else {
        canvas.drawCircle(Offset(x, y), 1 + random.nextDouble() * 2, paint);
      }
    }

    for (int i = 0; i < 3; i++) {
      Offset pos = Offset(size.width * (0.2 + i * 0.3), size.height * (0.3 + i * 0.2));
      _drawHeroStar(canvas, pos, nuclear);
    }
  }

  void _drawHeroStar(Canvas canvas, Offset pos, double nuclear) {
    final paint = Paint()..color = Colors.white.withValues(alpha: nuclear * 0.5);
    for (double r = 5; r < 40; r += 10) {
      canvas.drawCircle(pos, r, paint..color = Colors.white.withValues(alpha: (1.0 - r / 40) * nuclear * 0.3));
    }
  }

  void _paintGalacticAge(Canvas canvas, Offset center, Size size, Random random) {
    double rotation = animationValue * 2 * pi;
    double density = em * 500;
    
    final paint = Paint()..color = GameConstants.starGold.withValues(alpha: 0.8);
    if (em > 0.7) {
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    }
    
    for (int i = 0; i < density; i++) {
      double t = i / density;
      double angle = t * 4 * pi + rotation;
      double dist = t * 150;
      
      for (int arm = 0; arm < 2; arm++) {
        double currentAngle = angle + (arm * pi);
        if (em < 0.35) {
          currentAngle += random.nextDouble() * 2;
          dist += random.nextDouble() * 50;
        }
        
        Offset p = Offset(center.dx + cos(currentAngle) * dist, center.dy + sin(currentAngle) * dist);
        canvas.drawCircle(p, 1, paint..color = (t < 0.3 ? GameConstants.starGold : Colors.blueAccent).withValues(alpha: 0.6));
      }
    }
  }

  void _paintLifeAge(Canvas canvas, Offset center, Size size, Random random) {
    double pulse = (sin(animationValue * 50 * entropy) + 1) / 2;
    canvas.drawCircle(center, 40, Paint()..color = Colors.blueGrey);
    
    final haloPaint = Paint()
      ..color = GameConstants.lifeGreen.withValues(alpha: 0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + pulse * 10);
    canvas.drawCircle(center, 45 + pulse * 10, haloPaint);

    int cellCount = (entropy > 0.35 && entropy < 0.6) ? 12 : 6;
    for (int i = 0; i < cellCount; i++) {
      double angle = i * (2 * pi / cellCount) + animationValue * 2;
      double dist = 70;
      double radius = 5;
      Color cellColor = GameConstants.lifeGreen;

      if (entropy > 0.6) {
        radius *= (1.0 - (animationValue * 10 % 1.0));
        if (radius < 1) continue;
      } else if (entropy < 0.35) {
        cellColor = Colors.grey;
      }

      canvas.drawCircle(
        Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist),
        radius,
        Paint()..color = cellColor.withValues(alpha: 0.7),
      );
    }
  }

  void _paintStellarDeath(Canvas canvas, Offset center, Size size, Random random) {
    double expansion = 40 + (animationValue * 40);
    canvas.drawCircle(center, expansion, Paint()..color = Colors.red.withValues(alpha: 0.4));
    
    for (int i = 0; i < 10; i++) {
      double scale = 1.0;
      if (darkEnergy > 0.6) {
        scale = 1.0 + animationValue * 5;
      } else if (darkEnergy < 0.4) {
        scale = 1.0 - animationValue;
      }

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * pi / 5 + animationValue);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(50, 0), width: 100 * scale, height: 40),
        Paint()..color = Colors.purple.withValues(alpha: 0.1),
      );
      canvas.restore();
    }

    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(center.dx + i * 10 - 10, center.dy + 5), 2, Paint()..color = Colors.white);
    }
  }

  void _paintCosmicFate(Canvas canvas, Offset center, Size size, Random random) {
    double breath = (sin(animationValue * pi / 2) + 1) / 2;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(0.9 + breath * 0.2);
    canvas.translate(-center.dx, -center.dy);
    
    canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: 0.2));
    _paintCosmicDawn(canvas, center, size);
    _paintStellarAge(canvas, size, random);
    _paintGalacticAge(canvas, center, size, random);
    canvas.restore(); 
    
    canvas.restore(); 
  }

  @override
  bool shouldRepaint(covariant UniversePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.stage != stage ||
           oldDelegate.gravity != gravity ||
           oldDelegate.nuclear != nuclear ||
           oldDelegate.em != em ||
           oldDelegate.entropy != entropy ||
           oldDelegate.darkEnergy != darkEnergy;
  }
}
