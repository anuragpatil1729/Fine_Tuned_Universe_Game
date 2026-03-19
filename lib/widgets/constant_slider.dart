// CHANGES MADE:
// 1. Re-implemented the slider to match the "Authoring the Arc" redesign.
// 2. Added `safeMin` and `safeMax` parameters to render the visual safe zone band.
// 3. Implemented a dynamic thumb color system (green/orange/red) based on proximity to the safe zone.
// 4. Added a numeric readout next to the label (2 decimal places) for precise tuning.
// 5. Added a "shudder" animation when the value enters the catastrophic zone (±0.15 outside safe).

import 'package:flutter/material.dart';
import '../core/constants.dart';

class ConstantSlider extends StatefulWidget {
  final String label;
  final double value;
  final double safeMin;
  final double safeMax;
  final ValueChanged<double> onChanged;

  const ConstantSlider({
    super.key,
    required this.label,
    required this.value,
    required this.safeMin,
    required this.safeMax,
    required this.onChanged,
  });

  @override
  State<ConstantSlider> createState() => _ConstantSliderState();
}

class _ConstantSliderState extends State<ConstantSlider> with SingleTickerProviderStateMixin {
  late AnimationController _shudderController;
  late Animation<double> _shudderAnimation;

  @override
  void initState() {
    super.initState();
    _shudderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _shudderAnimation = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(parent: _shudderController, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(ConstantSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isCatastrophic(widget.value) && !_isCatastrophic(oldWidget.value)) {
      _shudderController.repeat(reverse: true, period: const Duration(milliseconds: 50));
      Future.delayed(const Duration(milliseconds: 200), () => _shudderController.stop());
    }
  }

  bool _isCatastrophic(double val) {
    return val < (widget.safeMin - 0.15) || val > (widget.safeMax + 0.15);
  }

  bool _isWarning(double val) {
    return (val < widget.safeMin && val >= widget.safeMin - 0.15) || 
           (val > widget.safeMax && val <= widget.safeMax + 0.15);
  }

  Color _getThumbColor(double val) {
    if (_isCatastrophic(val)) return Colors.red;
    if (_isWarning(val)) return Colors.orange;
    return Colors.greenAccent;
  }

  @override
  void dispose() {
    _shudderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shudderAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shudderAnimation.value, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.value.toStringAsFixed(2),
                      style: TextStyle(
                        color: _getThumbColor(widget.value),
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Safe zone band
                  Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Positioned(
                              left: widget.safeMin * constraints.maxWidth,
                              width: (widget.safeMax - widget.safeMin) * constraints.maxWidth,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: _getThumbColor(widget.value),
                      overlayColor: _getThumbColor(widget.value).withOpacity(0.2),
                    ),
                    child: Slider(
                      value: widget.value,
                      onChanged: widget.onChanged,
                      min: 0.0,
                      max: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
