// BUG FIXED: Bug 2 - Bubble positions don't match constellation lines.
// BUG FIXED: Bug 4 - Outcome name string has leading space.
// HOW: Implemented a static `getBubbleOffset` method to centralize coordinate calculation based on screen size.
// Integrated `StringUtils.outcomeLabel` for clean outcome titles.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/universe_state.dart';
import '../core/constants.dart';
import '../core/string_utils.dart';

class MultiverseObservatory extends StatefulWidget {
  final List<UniverseState> history;

  const MultiverseObservatory({super.key, required this.history});

  static Offset getBubbleOffset(int index, Size size) {
    final r = Random(index * 7919); // large prime for distribution
    return Offset(
      r.nextDouble() * (size.width - 60) + 30,
      r.nextDouble() * (size.height * 0.6) + 100,
    );
  }

  @override
  State<MultiverseObservatory> createState() => _MultiverseObservatoryState();
}

class _MultiverseObservatoryState extends State<MultiverseObservatory> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  StreamSubscription? _accelerometerSubscription;
  double _tiltX = 0;
  double _tiltY = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _tiltX = (event.x * 2).clamp(-20, 20);
        _tiltY = (event.y * 2).clamp(-20, 20);
      });
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        _buildStarLayer(0.2, 100),
        _buildStarLayer(0.5, 50),

        CustomPaint(
          size: Size.infinite,
          painter: ConstellationPainter(widget.history, _pulseController.value, size),
        ),

        ...widget.history.asMap().entries.map((entry) {
          final index = entry.key;
          final state = entry.value;
          final isRecent = index == widget.history.length - 1;
          final isAncient = widget.history.length - index > 5;
          final pos = MultiverseObservatory.getBubbleOffset(index, size);

          return Positioned(
            left: pos.dx - 20,
            top: pos.dy - 20,
            child: GestureDetector(
              onTap: () => _showUniverseDetails(context, state, index),
              child: Opacity(
                opacity: isAncient ? 0.1 : 0.4,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: isRecent ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3 * _pulseController.value),
                        blurRadius: 10,
                        spreadRadius: 5,
                      )
                    ] : null,
                  ),
                  child: Center(
                    child: Icon(
                      _getOutcomeIcon(state.outcome),
                      size: 14,
                      color: _getOutcomeColor(state.outcome),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStarLayer(double speed, int count) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      left: -20 + (_tiltX * speed),
      top: -20 + (_tiltY * speed),
      right: -20 - (_tiltX * speed),
      bottom: -20 - (_tiltY * speed),
      child: CustomPaint(
        painter: StaticStarfieldPainter(count, speed),
      ),
    );
  }

  void _showUniverseDetails(BuildContext context, UniverseState state, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Text("UNIVERSE #$index", style: const TextStyle(color: Colors.white38, letterSpacing: 2)),
            const SizedBox(height: 10),
            Text(
              StringUtils.outcomeLabel(state.outcome.name),
              style: TextStyle(color: _getOutcomeColor(state.outcome), fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
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
    return Text("$label: ${val.toStringAsFixed(2)}", 
      style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'monospace'));
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
}

class StaticStarfieldPainter extends CustomPainter {
  final int count;
  final double seed;
  StaticStarfieldPainter(this.count, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final r = Random(seed.toInt() + 100);
    final p = Paint()..color = Colors.white;
    for (int i = 0; i < count; i++) {
      p.color = Colors.white.withValues(alpha: r.nextDouble() * 0.5);
      canvas.drawCircle(Offset(r.nextDouble() * size.width, r.nextDouble() * size.height), r.nextDouble() * 1.5, p);
    }
  }
  @override
  bool shouldRepaint(covariant StaticStarfieldPainter oldDelegate) => false;
}

class ConstellationPainter extends CustomPainter {
  final List<UniverseState> history;
  final double pulse;
  final Size size;
  ConstellationPainter(this.history, this.pulse, this.size);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < history.length - 1; i++) {
      final start = MultiverseObservatory.getBubbleOffset(i, this.size);
      final end = MultiverseObservatory.getBubbleOffset(i + 1, this.size);
      canvas.drawLine(start, end, paint);
    }
  }
  @override
  bool shouldRepaint(covariant ConstellationPainter oldDelegate) => oldDelegate.pulse != pulse || oldDelegate.size != size;
}

class RadarChartPainter extends CustomPainter {
  final UniverseState state;
  RadarChartPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final axes = 5;
    final angleStep = (2 * pi) / axes;

    final safePaint = Paint()..color = Colors.green.withValues(alpha: 0.2)..style = PaintingStyle.fill;
    final safePath = Path();
    for (int i = 0; i < axes; i++) {
      double angle = i * angleStep - pi / 2;
      double val = 0.5;
      Offset p = Offset(center.dx + cos(angle) * radius * val, center.dy + sin(angle) * radius * val);
      if (i == 0) safePath.moveTo(p.dx, p.dy); else safePath.lineTo(p.dx, p.dy);
    }
    safePath.close();
    canvas.drawPath(safePath, safePaint);

    final axisPaint = Paint()..color = Colors.white12..strokeWidth = 1;
    for (int i = 0; i < axes; i++) {
      double angle = i * angleStep - pi / 2;
      canvas.drawLine(center, Offset(center.dx + cos(angle) * radius, center.dy + sin(angle) * radius), axisPaint);
    }

    final dataPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
    final dataPath = Path();
    final values = [state.gravity, state.nuclearForce, state.emForce, state.entropyRate, state.darkEnergyPressure];

    for (int i = 0; i < axes; i++) {
      double angle = i * angleStep - pi / 2;
      double val = values[i];
      Offset p = Offset(center.dx + cos(angle) * radius * val, center.dy + sin(angle) * radius * val);
      if (i == 0) dataPath.moveTo(p.dx, p.dy); else dataPath.lineTo(p.dx, p.dy);
      canvas.drawCircle(p, 3, Paint()..color = Colors.white);
    }
    dataPath.close();
    canvas.drawPath(dataPath, dataPaint);
  }
  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) => false;
}
