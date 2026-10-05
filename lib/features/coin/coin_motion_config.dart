import 'package:flutter/animation.dart';

/// Centralized configuration layer for PlayMate coin physics and motion.
class CoinMotionConfig {
  CoinMotionConfig._();

  // --- Animation Durations ---
  /// Total standard flip sequence duration (~1050ms)
  static const Duration flipDuration = Duration(milliseconds: 1050);

  /// Reduced motion quick transition duration (~220ms)
  static const Duration reducedMotionDuration = Duration(milliseconds: 220);

  /// Idle subtle floating breathing cycle
  static const Duration idleCycleDuration = Duration(milliseconds: 3600);

  /// Press interaction spring back duration
  static const Duration pressDuration = Duration(milliseconds: 100);

  // --- Normalized Phase Intervals [0.0, 1.0] ---
  /// Anticipation compression: 0ms to 100ms (0.0 to 0.095)
  static const double anticipationEnd = 0.095;

  /// Launch elevation: 100ms to 240ms (0.095 to 0.228)
  static const double launchEnd = 0.228;

  /// Rapid flipping: 240ms to 780ms (0.228 to 0.742)
  static const double flipEnd = 0.742;

  /// Landing and primary impact: 780ms to 920ms (0.742 to 0.876)
  static const double landingEnd = 0.876;

  /// Settle and micro bounce: 920ms to 1050ms (0.876 to 1.0)
  static const double settleEnd = 1.0;

  // --- Spatial Scales & Offsets ---
  /// Scale while pressed down by the user
  static const double pressScale = 0.96;

  /// Downward vertical translation while pressed
  static const double pressTranslateY = 3.5;

  /// Elevation peak during launch throw
  static const double launchPeakElevationY = -42.0;

  /// Scale at peak of throw
  static const double launchScale = 1.03;

  /// Scale during bounce 1 landing
  static const double bounceScaleMax = 1.025;
  static const double bounceScaleMin = 0.992;

  // --- Shadow Dynamics ---
  /// Idle shadow scale and opacity
  static const double shadowIdleScale = 1.0;
  static const double shadowIdleOpacity = 0.22;

  /// Shadow at peak launch elevation (smaller & diffused)
  static const double shadowLaunchScale = 0.68;
  static const double shadowLaunchOpacity = 0.12;

  /// Shadow at moment of impact / landing (spreads & darkens)
  static const double shadowLandingScale = 1.10;
  static const double shadowLandingOpacity = 0.32;

  // --- Animation Curves ---
  static const Curve anticipationCurve = Curves.easeInQuad;
  static const Curve launchCurve = Curves.easeOutCubic;
  static const Curve flipCurve = Curves.linear;
  static const Curve landingCurve = Curves.easeOutQuad;
  static const Curve settleCurve = Curves.easeOutCubic;
}
