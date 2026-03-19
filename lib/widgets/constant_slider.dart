// CHANGES MADE:
// 1. Added `id`, `safeMin`, `safeMax`, and `isLocked` parameters to support the intervention system and cascading constants.
// 2. Implemented a custom safe zone visualization: a colored band behind the slider track.
// 3. Added a dynamic "INTERVENE" button that appears when a constant is locked, allowing players to use their intervention points.
// 4. Integrated visual feedback for "safety": the thumb color changes to orange if outside the safe zone.
// 5. Used a `Stack` and `LayoutBuilder` to accurately position the safe zone band relative to the slider width.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../services/simulation_service.dart';

class ConstantSlider extends StatelessWidget {
  final String label;
  final String id;
  final double value;
  final double safeMin;
  final double safeMax;
  final bool isLocked;
  final ValueChanged<double> onChanged;

  const ConstantSlider({
    super.key,
    required this.label,
    required this.id,
    required this.value,
    required this.safeMin,
    required this.safeMax,
    required this.isLocked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSafe = value >= safeMin && value <= safeMax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isLocked ? Colors.white24 : (isSafe ? Colors.white70 : Colors.orangeAccent),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (isLocked)
                TextButton.icon(
                  onPressed: () => context.read<SimulationService>().useIntervention(id),
                  icon: const Icon(Icons.bolt, size: 14, color: Colors.cyanAccent),
                  label: const Text("INTERVENE", style: TextStyle(fontSize: 10, color: Colors.cyanAccent)),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            // PILLAR 3: Safe Zone Band
            Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(2),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Stack(
                    children: [
                      Positioned(
                        left: safeMin * width,
                        width: (safeMax - safeMin) * width,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: GameConstants.lifeGreen.withOpacity(isLocked ? 0.05 : 0.3),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              if (!isLocked)
                                BoxShadow(
                                  color: GameConstants.lifeGreen.withOpacity(0.1),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                            ],
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
                thumbColor: isLocked ? Colors.grey : (isSafe ? Colors.white : Colors.orangeAccent),
                overlayColor: Colors.cyanAccent.withOpacity(0.1),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                value: value,
                onChanged: isLocked ? null : onChanged,
                min: 0.0,
                max: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
