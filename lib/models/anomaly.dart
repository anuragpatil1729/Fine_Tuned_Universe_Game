// CHANGES MADE:
// 1. Defined the `Anomaly` model to represent seeded challenge runs.
// 2. Added `lockedConstants` and `shiftedSafeZones` to override standard game rules.
// 3. Implemented `type` enum to distinguish between different logic modifications.

enum AnomalyType {
  lockedParameter,
  timePressure,
  invertedRules,
  shiftedReality,
}

class Anomaly {
  final String id;
  final String name;
  final String description;
  final String flavorText;
  final AnomalyType type;
  final Map<String, double> lockedConstants;
  final Map<String, List<double>> shiftedSafeZones;
  final bool isCompleted;
  final String badgeLabel;

  Anomaly({
    required this.id,
    required this.name,
    required this.description,
    required this.flavorText,
    required this.type,
    this.lockedConstants = const {},
    this.shiftedSafeZones = const {},
    this.isCompleted = false,
    required this.badgeLabel,
  });

  Anomaly copyWith({bool? isCompleted}) {
    return Anomaly(
      id: id,
      name: name,
      description: description,
      flavorText: flavorText,
      type: type,
      lockedConstants: lockedConstants,
      shiftedSafeZones: shiftedSafeZones,
      isCompleted: isCompleted ?? this.isCompleted,
      badgeLabel: badgeLabel,
    );
  }
}
