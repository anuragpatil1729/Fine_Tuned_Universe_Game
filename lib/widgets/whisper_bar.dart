// CHANGES MADE:
// 1. Created the `WhisperBar` widget to provide atmospheric narration from the universe.
// 2. Implemented a crossfade transition for new whispers using `AnimatedSwitcher`.
// 3. Added a blinking cursor "|" using a repeating `AnimationController`.
// 4. Styled with `GoogleFonts.exo2` in italic white54 as per the Creative Director's vision.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WhisperBar extends StatefulWidget {
  final String whisper;

  const WhisperBar({super.key, required this.whisper});

  @override
  State<WhisperBar> createState() => _WhisperBarState();
}

class _WhisperBarState extends State<WhisperBar> with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: widget.whisper.isEmpty
            ? const SizedBox.shrink()
            : Row(
                key: ValueKey(widget.whisper),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      widget.whisper,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.exo2(
                        color: Colors.white54,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  FadeTransition(
                    opacity: _cursorController,
                    child: const Text(
                      "|",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
