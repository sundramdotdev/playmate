import 'package:flutter/material.dart';
import 'dice_pips.dart';

/// Extensible model for physical dice styles and finishes.
class DiceStyle {
  final Color bodyColor;
  final Color pipColor;
  final Color accentColor;
  final Color highlightColor;
  final Color shadowEdgeColor;

  const DiceStyle({
    required this.bodyColor,
    required this.pipColor,
    required this.accentColor,
    required this.highlightColor,
    required this.shadowEdgeColor,
  });

  /// Default PlayMate warm ivory finish.
  static const DiceStyle warmIvory = DiceStyle(
    bodyColor: Color(0xFFF3F0E8),
    pipColor: Color(0xFF17181A),
    accentColor: Color(0xFFC18A42),
    highlightColor: Color(0x66FFFFFF),
    shadowEdgeColor: Color(0x24000000),
  );

  /// Sleek obsidian graphite dark mode finish.
  static const DiceStyle obsidianDark = DiceStyle(
    bodyColor: Color(0xFF202124),
    pipColor: Color(0xFFF5F5F2),
    accentColor: Color(0xFFC18A42),
    highlightColor: Color(0x26FFFFFF),
    shadowEdgeColor: Color(0x80000000),
  );

  /// Selects the appropriate style based on current brightness.
  static DiceStyle fromBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? obsidianDark : warmIvory;
  }
}

/// A single rendered physical face of the PlayMate die.
class DiceFace extends StatelessWidget {
  final int value;
  final double size;
  final DiceStyle style;
  final double lightIntensity;
  final bool isDarkMode;

  const DiceFace({
    super.key,
    required this.value,
    required this.size,
    required this.style,
    this.lightIntensity = 1.0,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = size * 0.20;

    // Modulate body color by lightIntensity (0.78 to 1.0)
    final Color litBody = Color.lerp(
      isDarkMode ? const Color(0xFF121315) : const Color(0xFFDDD9CF),
      style.bodyColor,
      lightIntensity,
    )!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: litBody,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDarkMode
              ? style.highlightColor.withValues(alpha: 0.15 * lightIntensity)
              : style.shadowEdgeColor.withValues(alpha: 0.12 * lightIntensity),
          width: 1.0,
        ),
        boxShadow: [
          // Subtle inner face bevel and chamfer rim
          BoxShadow(
            color: style.highlightColor.withValues(alpha: 0.35 * lightIntensity),
            offset: const Offset(-1.2, -1.2),
            blurRadius: 1.5,
            spreadRadius: 0.0,
          ),
          BoxShadow(
            color: style.shadowEdgeColor.withValues(alpha: 0.25 * lightIntensity),
            offset: const Offset(1.5, 1.5),
            blurRadius: 2.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Center(
        child: DicePips(
          value: value,
          faceSize: size,
          pipColor: style.pipColor,
          accentColor: style.accentColor,
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }
}
