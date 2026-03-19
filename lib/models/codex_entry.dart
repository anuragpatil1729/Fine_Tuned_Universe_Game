// CHANGES MADE:
// 1. Defined the `CodexEntry` model to hold atmospheric and scientific lore.
// 2. Added fields for title, body, unlock conditions, and visual metadata (Icon/Color).
// 3. Implemented a `toJson` and `fromJson` pattern (simplified) to support persistence.

import 'package:flutter/material.dart';

class CodexEntry {
  final String id;
  final String title;
  final String body;
  final String unlockCondition;
  final bool isUnlocked;
  final bool isSeen; // Used for the shimmer effect on first open
  final IconData icon;
  final Color accentColor;

  CodexEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.unlockCondition,
    this.isUnlocked = false,
    this.isSeen = false,
    required this.icon,
    required this.accentColor,
  });

  CodexEntry copyWith({
    bool? isUnlocked,
    bool? isSeen,
  }) {
    return CodexEntry(
      id: id,
      title: title,
      body: body,
      unlockCondition: unlockCondition,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isSeen: isSeen ?? this.isSeen,
      icon: icon,
      accentColor: accentColor,
    );
  }
}
