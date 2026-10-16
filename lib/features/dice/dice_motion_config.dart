import 'package:flutter/animation.dart';

/// Centralized configuration layer for PlayMate dice physics and motion.
class DiceMotionConfig {
  DiceMotionConfig._();

  // --- Animation Durations ---
  /// Total standard roll sequence duration (~1050ms)
  static const Duration rollDuration = Duration(milliseconds: 1050);

  /// Reduced motion quick transition duration (~220ms)
  static const Duration reducedMotionDuration = Duration(milliseconds: 220);

  /// Idle subtle floating breathing cycle
  static const Duration idleCycleDuration = Duration(milliseconds: 3600);

  /// Press interaction spring back duration
  static const Duration pressDuration = Duration(milliseconds: 120);

  // --- Normalized Phase Intervals [0.0, 1.0] ---
  /// Anticipation compression: 0ms to 120ms (0.0 to 0.114)
  static const double anticipationEnd = 0.114;

  /// Launch elevation: 120ms to 280ms (0.114 to 0.266)
  static const double launchEnd = 0.266;

  /// Tumbling spin: 280ms to 800ms (0.266 to 0.762)
  static const double tumbleEnd = 0.762;

  /// Landing and primary bounce: 800ms to 950ms (0.762 to 0.905)
  static const double landingEnd = 0.905;

  /// Settle and micro confirmation: 950ms to 1050ms (0.905 to 1.0)
  static const double settleEnd = 1.0;

  // --- Spatial Scales & Offsets ---
  /// Scale while pressed down by the user
  static const double pressScale = 0.96;

  /// Downward vertical translation while pressed
  static const double pressTranslateY = 4.0;

  /// Elevation peak during launch
  static const double launchPeakElevationY = -34.0;

  /// Scale at peak of throw
  static const double launchScale = 1.04;

  /// Scale during bounce 1 landing
  static const double bounce1ScaleMax = 1.04;
  static const double bounce1ScaleMin = 0.985;

  /// Scale during bounce 2 settle
  static const double bounce2ScaleMax = 1.015;
  static const double bounce2ScaleMin = 0.995;

  // --- Shadow Dynamics ---
  /// Idle shadow scale and opacity
  static const double shadowIdleScale = 1.0;
  static const double shadowIdleOpacity = 0.26;

  /// Shadow at peak launch elevation (smaller & diffused)
  static const double shadowLaunchScale = 0.72;
  static const double shadowLaunchOpacity = 0.14;

  /// Shadow at moment of impact / landing (spreads & darkens)
  static const double shadowLandingScale = 1.08;
  static const double shadowLandingOpacity = 0.35;

  // --- Animation Curves ---
  static const Curve anticipationCurve = Curves.easeInQuad;
  static const Curve launchCurve = Curves.easeOutCubic;
  static const Curve tumbleCurve = Curves.linear;
  static const Curve landingCurve = Curves.bounceOut;
  static const Curve settleCurve = Curves.easeOutCubic;
}
