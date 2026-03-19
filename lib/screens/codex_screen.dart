// CHANGES MADE:
// 1. Implemented `CodexScreen` to display the "Cosmic Codex".
// 2. Used a `ListView` with glassmorphism cards for entries.
// 3. Added shimmer-like animation for newly unlocked entries.
// 4. Implemented locked/unlocked visual states with padlocks and grayscale title.
// 5. Added discovery progress header (X/12).
// 6. Integrated with `CodexService` to mark entries as "seen" when the screen is opened.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/codex_service.dart';
import '../models/codex_entry.dart';

class CodexScreen extends StatefulWidget {
  const CodexScreen({super.key});

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> {
  @override
  void initState() {
    super.initState();
    // Mark as seen when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CodexService>().markAsSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "COSMIC CODEX",
          style: GoogleFonts.orbitron(letterSpacing: 2, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Consumer<CodexService>(
        builder: (context, codex, child) {
          final entries = codex.entries;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "${codex.unlockedCount} / ${entries.length} DISCOVERED",
                  style: const TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 2),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    return _CodexCard(entry: entries[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CodexCard extends StatefulWidget {
  final CodexEntry entry;
  const _CodexCard({required this.entry});

  @override
  State<_CodexCard> createState() => _CodexCardState();
}

class _CodexCardState extends State<_CodexCard> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    if (widget.entry.isUnlocked && !widget.entry.isSeen) {
      _shimmerController.forward();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: entry.isUnlocked ? entry.accentColor.withValues(alpha: 0.3) : Colors.white10,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        entry.isUnlocked ? entry.icon : Icons.lock_outline,
                        color: entry.isUnlocked ? entry.accentColor : Colors.white24,
                        size: 24,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          entry.isUnlocked ? entry.title.toUpperCase() : "LOCKED DATA STREAM",
                          style: GoogleFonts.orbitron(
                            color: entry.isUnlocked ? Colors.white : Colors.white24,
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    entry.isUnlocked ? entry.body : "CONDITIONS: ${entry.unlockCondition}",
                    style: TextStyle(
                      color: entry.isUnlocked ? Colors.white70 : Colors.white12,
                      fontSize: 13,
                      height: 1.5,
                      fontStyle: entry.isUnlocked ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (entry.isUnlocked && !entry.isSeen)
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment(_shimmerAnimation.value, 0),
                      widthFactor: 0.3,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              entry.accentColor.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
