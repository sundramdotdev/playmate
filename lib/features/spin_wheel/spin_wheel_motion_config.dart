import 'package:flutter/animation.dart';

/// Centralized motion configuration and physical timing layer for the Spin Wheel.
class SpinWheelMotionConfig {
  SpinWheelMotionConfig._();

  // --- Animation Durations ---
  /// Total standard spin sequence duration (~3800ms)
  static const Duration spinDuration = Duration(milliseconds: 3800);

  /// Reduced motion quick transition duration (~400ms)
  static const Duration reducedMotionDuration = Duration(milliseconds: 400);

  /// Press interaction spring back duration
  static const Duration pressDuration = Duration(milliseconds: 100);

  /// Idle breathing cycle duration
  static const Duration idleCycleDuration = Duration(milliseconds: 3200);

  // --- Normalized Phase Milestones [0.0, 1.0] ---
  /// Anticipation compression: 0 to ~120ms (0.0 to 0.032)
  static const double anticipationEnd = 0.032;

  /// Acceleration: 120ms to 850ms (0.032 to 0.224)
  static const double accelerationEnd = 0.224;

  /// Sustained high speed spin: 850ms to 2400ms (0.224 to 0.632)
  static const double sustainedEnd = 0.632;

  /// Deceleration: 2400ms to 3550ms (0.632 to 0.934)
  static const double decelerationEnd = 0.934;

  /// Settle and micro bounce: 3550ms to 3800ms (0.934 to 1.0)
  static const double settleEnd = 1.0;

  // --- Spatial Scales & Deflections ---
  /// Button/wheel scale when pressed down
  static const double pressScale = 0.97;

  /// Scale during anticipation wind-up
  static const double anticipationScale = 0.985;

  /// Scale during settle micro-bounce
  static const double settleScaleMax = 1.018;

  /// Maximum deflection angle of the pointer in radians (~0.08 rad = ~4.5 degrees)
  static const double pointerMaxDeflection = 0.08;

  // --- Shadow Parameters ---
  static const double shadowIdleScale = 1.0;
  static const double shadowIdleOpacity = 0.25;
  static const double shadowSpinScale = 1.04;
  static const double shadowSpinOpacity = 0.32;

  // --- Animation Curves ---
  /// Smooth physical spin curve: natural build up followed by gradual bearing friction deceleration
  static const Curve spinCurve = Curves.easeOutCubic;
  static const Curve reducedMotionCurve = Curves.easeOutQuad;
}

