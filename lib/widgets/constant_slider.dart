import 'package:flutter/material.dart';
import '../core/constants.dart';

class ConstantSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const ConstantSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0.0,
          max: 1.0,
          activeColor: GameConstants.cosmicPurple,
          inactiveColor: Colors.white24,
        ),
      ],
    );
  }
}
