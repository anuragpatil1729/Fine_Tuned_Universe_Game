// FEATURE: Civilization Layer // WHAT CHANGED: Added `cooperation` and `energy` parameters. Implemented `civilizationDawn`, `technologicalAge`, and `cosmicLegacy` painters. Integrated real-time lerp interpolation for all constants. // WHY: To support the visuals for the new civilization phase and ensure smooth transitions during slider adjustments.

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
  final double cooperation;
  final double energy;
  final UniverseOutcome outcome;

  const UniverseVisual({
    super.key,
    required this.stage,
    required this.gravity,
    required this.nuclear,
    required this.em,
    required this.entropy,
    required this.darkEnergy,
    this.cooperation = 0.5,
    this.energy = 0.5,
    this.outcome = UniverseOutcome.none,
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
  double _displayCooperation = 0.5;
  double _displayEnergy = 0.5;

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
    _displayCooperation = widget.cooperation;
    _displayEnergy = widget.energy;
  }

  @override
  void didUpdateWidget(UniverseVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.gravity != widget.gravity ||
        oldWidget.nuclear != widget.nuclear ||
        oldWidget.em != widget.em ||
        oldWidget.entropy != widget.entropy ||
        oldWidget.darkEnergy != widget.darkEnergy ||
        oldWidget.cooperation != widget.cooperation ||
        oldWidget.energy != widget.energy) {
      
      final startG = _displayGravity;
      final startN = _displayNuclear;
      final startEm = _displayEm;
      final startEn = _displayEntropy;
      final startDe = _displayDarkEnergy;
      final startCo = _displayCooperation;
      final startEg = _displayEnergy;
      
      _reactController.stop();
      _reactController.reset();
      
      void updateDisplay() {
        if (!mounted) return;
        final t = _reactController.value;
        setState(() {
          _displayGravity = lerpDouble(startG, widget.gravity, t)!;
          _displayNuclear = lerpDouble(startN, widget.nuclear, t)!;
          _displayEm = lerpDouble(startEm, widget.em, t)!;
          _displayEntropy = lerpDouble(startEn, widget.entropy, t)!;
          _displayDarkEnergy = lerpDouble(startDe, widget.darkEnergy, t)!;
          _displayCooperation = lerpDouble(startCo, widget.cooperation, t)!;
          _displayEnergy = lerpDouble(startEg, widget.energy, t)!;
        });
      }

      _reactController.addListener(updateDisplay);
      _reactController.forward().then((_) {
        _reactController.removeListener(updateDisplay);
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
            cooperation: _displayCooperation,
            energy: _displayEnergy,
            outcome: widget.outcome,
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
  final double cooperation;
  final double energy;
  final UniverseOutcome outcome;

  UniversePainter({
    required this.stage,
    required this.animationValue,
    required this.gravity,
    required this.nuclear,
    required this.em,
    required this.entropy,
    required this.darkEnergy,
    required this.cooperation,
    required this.energy,
    required this.outcome,
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
      case UniverseStage.civilizationDawn:
        _paintCivilizationDawn(canvas, center, size, random);
        break;
      case UniverseStage.technologicalAge:
        _paintTechnologicalAge(canvas, center, size, random);
        break;
      case UniverseStage.cosmicLegacy:
        _paintCosmicLegacy(canvas, center, size, random);
        break;
      case UniverseStage.cosmicFate:
        _paintCosmicFate(canvas, center, size, random);
        break;
    }
  }

  void _paintCosmicDawn(Canvas canvas, Offset center, Size size) {
    double expansion = (animationValue * 5) % 1.0;
    double ringRadius = expansion * (size.width / 2);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 4..shader = RadialGradient(colors: [Colors.white, GameConstants.cosmicPurple, Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: ringRadius));
    canvas.drawCircle(center, ringRadius, paint);
    int pCount = (gravity * 200).toInt();
    final pPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    for (int i = 0; i < pCount; i++) {
      double angle = i * 1.5 + animationValue * 2;
      double dist = (i * 2.0) * expansion;
      if (gravity > 0.65) { dist *= (1.0 - expansion); angle += expansion * 10; }
      else if (gravity < 0.35) { dist *= (1.0 + expansion); }
      canvas.drawCircle(Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist), 1.5, pPaint);
    }
  }

  void _paintStellarAge(Canvas canvas, Size size, Random random) {
    for (int i = 0; i < 80; i++) {
      double flicker = (sin(animationValue * 100 * random.nextDouble()) + 1) / 2;
      double brightness = nuclear * flicker;
      Color starColor = nuclear < 0.30 ? Colors.blue.withValues(alpha: 0.5) : GameConstants.starGold;
      final paint = Paint()..color = starColor.withValues(alpha: brightness.clamp(0.0, 1.0));
      if (nuclear > 0.70) {
        double flare = (sin(animationValue * 200) + 1) / 2;
        canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), 2 + flare * 4, paint..color = Colors.white.withValues(alpha: flare));
      } else {
        canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), 1 + random.nextDouble() * 2, paint);
      }
    }
  }

  void _paintGalacticAge(Canvas canvas, Offset center, Size size, Random random) {
    double rotation = animationValue * 2 * pi;
    double density = em * 500;
    final paint = Paint()..color = GameConstants.starGold.withValues(alpha: 0.8);
    if (em > 0.7) paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    for (int i = 0; i < density; i++) {
      double t = i / density;
      double angle = t * 4 * pi + rotation;
      double dist = t * 150;
      for (int arm = 0; arm < 2; arm++) {
        double curAngle = angle + (arm * pi);
        if (em < 0.35) { curAngle += random.nextDouble() * 2; dist += random.nextDouble() * 50; }
        canvas.drawCircle(Offset(center.dx + cos(curAngle) * dist, center.dy + sin(curAngle) * dist), 1, paint..color = (t < 0.3 ? GameConstants.starGold : Colors.blueAccent).withValues(alpha: 0.6));
      }
    }
  }

  void _paintLifeAge(Canvas canvas, Offset center, Size size, Random random) {
    double pulse = (sin(animationValue * 50 * entropy) + 1) / 2;
    canvas.drawCircle(center, 40, Paint()..color = Colors.blueGrey);
    canvas.drawCircle(center, 45 + pulse * 10, Paint()..color = GameConstants.lifeGreen.withValues(alpha: 0.4)..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + pulse * 10));
    int count = (entropy > 0.35 && entropy < 0.6) ? 12 : 6;
    for (int i = 0; i < count; i++) {
      double angle = i * (2 * pi / count) + animationValue * 2;
      double radius = 5; Color color = GameConstants.lifeGreen;
      if (entropy > 0.6) { radius *= (1.0 - (animationValue * 10 % 1.0)); if (radius < 1) continue; }
      else if (entropy < 0.35) color = Colors.grey;
      canvas.drawCircle(Offset(center.dx + cos(angle) * 70, center.dy + sin(angle) * 70), radius, Paint()..color = color.withValues(alpha: 0.7));
    }
  }

  void _paintStellarDeath(Canvas canvas, Offset center, Size size, Random random) {
    double expansion = 40 + (animationValue * 40);
    canvas.drawCircle(center, expansion, Paint()..color = Colors.red.withValues(alpha: 0.4));
    for (int i = 0; i < 10; i++) {
      double scale = (darkEnergy > 0.6) ? 1.0 + animationValue * 5 : (darkEnergy < 0.4 ? 1.0 - animationValue : 1.0);
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(i * pi / 5 + animationValue);
      canvas.drawOval(Rect.fromCenter(center: const Offset(50, 0), width: 100 * scale, height: 40), Paint()..color = Colors.purple.withValues(alpha: 0.1));
      canvas.restore();
    }
  }

  void _paintCivilizationDawn(Canvas canvas, Offset center, Size size, Random random) {
    canvas.drawCircle(center, 40, Paint()..color = Colors.blue.withValues(alpha: 0.8));
    int count = (cooperation * 20).toInt();
    final lightPaint = Paint()..color = Colors.amberAccent;
    List<Offset> lights = [];
    for (int i = 0; i < count; i++) {
      double angle = random.nextDouble() * 2 * pi;
      double dist = random.nextDouble() * 38;
      Offset p = Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist);
      lights.add(p);
      canvas.drawCircle(p, 1.5, lightPaint);
    }
    if (cooperation >= 0.40 && cooperation <= 0.65) {
      final linePaint = Paint()..color = Colors.amber.withValues(alpha: 0.2)..strokeWidth = 0.5;
      for (int i = 0; i < lights.length - 1; i++) canvas.drawLine(lights[i], lights[i+1], linePaint);
    } else if (cooperation > 0.65) {
      canvas.drawCircle(center, 40, Paint()..color = Colors.amber.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    }
  }

  void _paintTechnologicalAge(Canvas canvas, Offset center, Size size, Random random) {
    canvas.drawCircle(center, 30, Paint()..color = Colors.white.withValues(alpha: (1.0 - energy * 0.5)));
    final ringPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = (energy > 0.7 ? Colors.redAccent : Colors.orangeAccent);
    double arc = energy * 2 * pi;
    canvas.drawArc(Rect.fromCircle(center: center, radius: 50), -pi/2, arc, false, ringPaint);
    for (int i = 0; i < 5; i++) {
      double angle = animationValue * 4 * pi + i;
      canvas.drawCircle(Offset(center.dx + cos(angle) * 60, center.dy + sin(angle) * 60), 1, Paint()..color = Colors.white);
    }
  }

  void _paintCosmicLegacy(Canvas canvas, Offset center, Size size, Random random) {
    if (outcome == UniverseOutcome.transcendence) {
      final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = Colors.white.withValues(alpha: (1.0 - animationValue));
      canvas.drawRect(Rect.fromCenter(center: center, width: animationValue * 200, height: animationValue * 200), paint);
    } else if (outcome == UniverseOutcome.extinction) {
      canvas.drawCircle(center, 20, Paint()..color = Colors.grey);
      for (int i = 0; i < 5; i++) canvas.drawCircle(Offset(center.dx + i * 10, center.dy + i * 5), 2, Paint()..color = Colors.grey);
    } else {
      _paintCivilizationDawn(canvas, center, size, random);
    }
  }

  void _paintCosmicFate(Canvas canvas, Offset center, Size size, Random random) {
    double breath = (sin(animationValue * pi / 2) + 1) / 2;
    canvas.save(); canvas.translate(center.dx, center.dy); canvas.scale(0.9 + breath * 0.2); canvas.translate(-center.dx, -center.dy);
    canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: 0.2));
    _paintCosmicDawn(canvas, center, size); _paintStellarAge(canvas, size, random); _paintGalacticAge(canvas, center, size, random);
    canvas.restore(); canvas.restore();
  }

  @override
  bool shouldRepaint(covariant UniversePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.stage != stage ||
           oldDelegate.gravity != gravity || oldDelegate.nuclear != nuclear ||
           oldDelegate.em != em || oldDelegate.entropy != entropy || oldDelegate.darkEnergy != darkEnergy ||
           oldDelegate.cooperation != cooperation || oldDelegate.energy != energy;
  }
}
