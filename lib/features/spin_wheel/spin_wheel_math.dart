import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Central mathematical calculation and coordinate system engine for the Spin Wheel.
class SpinWheelMath {
  SpinWheelMath._();

  /// Canonical pointer position is at Top (12 o'clock, -pi / 2 radians).
  static const double pointerAngle = -math.pi / 2;

  /// Angular span of a single segment given total segment count [count].
  static double getSweepAngle(int count) {
    if (count <= 0) return 2 * math.pi;
    return (2 * math.pi) / count;
  }

  /// Starting angle for sector [index] on an unrotated wheel.
  static double getSectorStartAngle(int index, int count) {
    return pointerAngle + (index * getSweepAngle(count));
  }

  /// Center angle for sector [index] on an unrotated wheel.
  static double getSectorCenterAngle(int index, int count) {
    return pointerAngle + ((index + 0.5) * getSweepAngle(count));
  }

  /// Deterministically calculates the target rotation angle to align sector [winningIndex] directly under the pointer.
  ///
  /// [currentRotation] is the continuous rotation angle before the spin.
  /// [winningIndex] is the predetermined winning segment index (0 <= winningIndex < count).
  /// [count] is the total number of segments.
  /// [revolutions] is the number of complete 360° revolutions to perform.
  static double calculateTargetRotation({
    required double currentRotation,
    required int winningIndex,
    required int count,
    int revolutions = 6,
  }) {
    final double sweep = getSweepAngle(count);

    // To bring sector center ((index + 0.5) * sweep) to the pointer:
    // centerAngle + finalRotation = pointerAngle (mod 2pi)
    // finalRotation = - (winningIndex + 0.5) * sweep (mod 2pi)
    final double targetBase = (2 * math.pi - ((winningIndex + 0.5) * sweep) % (2 * math.pi)) % (2 * math.pi);

    final double normalizedCurrent = currentRotation % (2 * math.pi);
    double delta = targetBase - normalizedCurrent;
    if (delta <= 0.00001) {
      delta += 2 * math.pi;
    }

    return currentRotation + (revolutions * 2 * math.pi) + delta;
  }

  /// Calculates the segment index currently aligned under the pointer at a given rotation [rotation].
  static int getIndexUnderPointer({
    required double rotation,
    required int count,
  }) {
    if (count <= 0) return 0;
    final double sweep = getSweepAngle(count);
    // Effective angle on the unrotated wheel that corresponds to pointerAngle
    final double effectiveAngle = (2 * math.pi - (rotation % (2 * math.pi))) % (2 * math.pi);
    final int index = (effectiveAngle / sweep).floor() % count;
    return index;
  }

  // --- Curated Premium Palettes ---

  /// Harmonious game-night segment palette matching PlayMate's warm ivory/charcoal/bronze design tokens.
  static const List<Color> lightSegmentPalette = [
    Color(0xFFF3F0E8), // Warm Ivory
    Color(0xFF2B2C31), // Deep Charcoal
    Color(0xFFE4DFD3), // Muted Sand
    Color(0xFF383A42), // Slate Graphite
    Color(0xFFD6CEBD), // Soft Khaki
    Color(0xFFC18A42), // Warm Bronze Accent
    Color(0xFFECE7DC), // Pearl Ivory
    Color(0xFF484B54), // Dark Slate
  ];

  static const List<Color> darkSegmentPalette = [
    Color(0xFF25272C), // Matte Graphite
    Color(0xFF1B1C20), // Deep Obsidian
    Color(0xFF33353D), // Muted Dark Slate
    Color(0xFF2A2C33), // Dark Neutral
    Color(0xFF3D3F49), // Charcoal Slate
    Color(0xFFC18A42), // Warm Bronze Accent
    Color(0xFF2E3038), // Carbon Grey
    Color(0xFF18191D), // Rich Black
  ];

  /// Resolves the background color for sector [index] in a wheel of [count] options.
  static Color getSegmentColor(int index, int count, bool isDarkMode) {
    final palette = isDarkMode ? darkSegmentPalette : lightSegmentPalette;
    // For odd segment counts like 3 or 5, ensure adjacent segments and first/last don't clash
    if (count % 2 != 0 && index == count - 1) {
      return isDarkMode ? const Color(0xFFC18A42) : const Color(0xFFC18A42);
    }
    return palette[index % palette.length];
  }

  /// Resolves optimal readable text color against segment background.
  static Color getTextColorForSegment(Color segmentColor, bool isDarkMode) {
    final double luminance = segmentColor.computeLuminance();
    // High contrast threshold
    if (luminance > 0.45) {
      return const Color(0xFF17181A); // Deep Charcoal
    } else {
      return const Color(0xFFF5F5F2); // Warm Pearl
    }
  }
}

