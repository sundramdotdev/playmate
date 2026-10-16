import 'dart:math' as math;

/// The two logical sides of the PlayMate coin.
enum CoinSide {
  heads,
  tails;

  String get displayName => name.toUpperCase();
}

/// Centralized 3D geometry proportions and orientation mapping for the PlayMate coin.
class CoinOrientation {
  CoinOrientation._();

  /// Normalized thickness ratio relative to diameter (0.12 = 1:8.3 ratio).
  static const double thicknessRatio = 0.12;

  /// Normalized rim bevel ratio (0.04 = 4% of diameter).
  static const double bevelRatio = 0.04;

  /// Subtle canonical resting 3D perspective tilt.
  /// Reveals the coin's physical thickness and top-edge chamfer even when idle.
  static const double restingTiltX = -0.16;
  static const double restingTiltY = 0.18;
  static const double restingTiltZ = 0.0;

  /// Canonical base rotation around X for each side.
  /// Heads: rx = 0 (outward normal pointing at camera)
  /// Tails: rx = pi (outward normal pointing at camera after 180° flip)
  static double getBaseAngleForSide(CoinSide side) {
    switch (side) {
      case CoinSide.heads:
        return 0.0;
      case CoinSide.tails:
        return math.pi;
    }
  }

  /// Calculates whether the front face (Heads) is facing the camera.
  /// Camera looks along -Z. cos(rx) > 0 means Heads is visible; cos(rx) < 0 means Tails is visible.
  static bool isHeadsFacing(double rx) {
    return math.cos(rx) >= 0.0;
  }

  /// Calculates the normalized edge visibility factor in [0.0, 1.0].
  /// 0.0 = completely face-on (0° or 180°)
  /// 1.0 = completely edge-on (90° or 270°)
  static double getEdgeVisibility(double rx) {
    return (math.sin(rx)).abs().clamp(0.0, 1.0);
  }

  /// Calculates the deterministic target rotation for a flip sequence.
  ///
  /// [currentRx] is the current continuous rotation angle.
  /// [targetSide] is the logical result that MUST be displayed at rest.
  /// [fullCycles] is the number of complete 360° revolutions (e.g. 4, 5, or 6).
  static double calculateTargetFlipAngle({
    required double currentRx,
    required CoinSide targetSide,
    required int fullCycles,
  }) {
    // Current base angle normalized to [0, 2pi)
    final double normalizedCurrent = currentRx % (2 * math.pi);
    final double targetBase = getBaseAngleForSide(targetSide);

    // Additional delta needed to reach targetBase from current position
    double delta = targetBase - normalizedCurrent;
    if (delta <= 0) {
      delta += 2 * math.pi;
    }

    // Add requested full 360° flip revolutions
    final double totalAddition = (fullCycles * 2 * math.pi) + delta;
    return currentRx + totalAddition;
  }
}
