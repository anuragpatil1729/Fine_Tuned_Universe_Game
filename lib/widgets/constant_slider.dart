// CHANGES MADE:
// 1. Integrated the `isLocked` logic to support the Anomaly Engine:
//    - Locked sliders show a lock icon instead of the numeric readout.
//    - Non-interactive state (onChanged: null) when locked.
//    - Track renders in a "ghost" white10 state when locked.
// 2. Added support for inverted safe zones (Mirror Universe Anomaly):
//    - If safeMin > safeMax, the band renders as a "danger zone" instead.
// 3. Preserved the "shudder" animation and dynamic thumb coloring.

import 'package:flutter/material.dart';

class ConstantSlider extends StatefulWidget {
  final String label;
  final double value;
  final double safeMin;
  final double safeMax;
  final ValueChanged<double>? onChanged;
  final bool isLocked;

  const ConstantSlider({
    super.key,
    required this.label,
    required this.value,
    required this.safeMin,
    required this.safeMax,
    this.onChanged,
    this.isLocked = false,
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
    if (!widget.isLocked && _isCatastrophic(widget.value) && !_isCatastrophic(oldWidget.value)) {
      _shudderController.repeat(reverse: true, period: const Duration(milliseconds: 50));
      Future.delayed(const Duration(milliseconds: 200), () => _shudderController.stop());
    }
  }

  bool _isCatastrophic(double val) {
    // Inverted logic for Mirror Universe
    if (widget.safeMin > widget.safeMax) {
      return val >= widget.safeMax && val <= widget.safeMin;
    }
    return val < (widget.safeMin - 0.15) || val > (widget.safeMax + 0.15);
  }

  bool _isWarning(double val) {
    if (widget.safeMin > widget.safeMax) return false;
    return (val < widget.safeMin && val >= widget.safeMin - 0.15) || 
           (val > widget.safeMax && val <= widget.safeMax + 0.15);
  }

  Color _getThumbColor(double val) {
    if (widget.isLocked) return Colors.white24;
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
          child: Opacity(
            opacity: widget.isLocked ? 0.5 : 1.0,
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
                      widget.isLocked 
                        ? const Icon(Icons.lock_outline, size: 14, color: Colors.white30)
                        : Text(
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
                          bool inverted = widget.safeMin > widget.safeMax;
                          double start = inverted ? widget.safeMax : widget.safeMin;
                          double width = inverted ? (widget.safeMin - widget.safeMax) : (widget.safeMax - widget.safeMin);

                          return Stack(
                            children: [
                              Positioned(
                                left: start * constraints.maxWidth,
                                width: width * constraints.maxWidth,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: inverted ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3),
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
                        overlayColor: _getThumbColor(widget.value).withValues(alpha: 0.2),
                        disabledThumbColor: Colors.white24,
                      ),
                      child: Slider(
                        value: widget.value,
                        onChanged: widget.isLocked ? null : widget.onChanged,
                        min: 0.0,
                        max: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
