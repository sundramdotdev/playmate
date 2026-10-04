import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/sound_service.dart';
import 'dice_face.dart';
import 'dice_motion_config.dart';
import 'dice_orientation.dart';
import 'dice_state.dart';

/// Primary physical 3D PlayMate die widget.
///
/// Features:
/// - True programmatic 3D cube transformation using Matrix4 and Euler angles
/// - 6 independently calculated faces with dynamic depth sorting (painter's algorithm)
/// - Directional ambient lighting and chamfer edge reflections
/// - Deterministic final face orientation matching the logical result
/// - Physical anticipation, launch elevation, multi-axis organic tumble, and bounce settling
/// - Responsive dynamic contact shadow
/// - Tactile press and spring-back interactions
/// - Full accessibility semantics and reduced-motion graceful fallback
class PlayMateDice extends StatefulWidget {
  final int value;
  final double size;
  final bool isRolling;
  final VoidCallback? onRollRequested;
  final VoidCallback? onRollCompleted;
  final int diceIndex;
  final int delayMs;
  final DiceType diceType;
  final DiceStyle? style;

  const PlayMateDice({
    super.key,
    required this.value,
    this.size = 150.0,
    this.isRolling = false,
    this.onRollRequested,
    this.onRollCompleted,
    this.diceIndex = 0,
    this.delayMs = 0,
    this.diceType = DiceType.d6,
    this.style,
  });

  @override
  State<PlayMateDice> createState() => _PlayMateDiceState();
}

class _PlayMateDiceState extends State<PlayMateDice> with TickerProviderStateMixin {
  late AnimationController _rollController;
  late AnimationController _idleController;
  late AnimationController _pressController;

  DiceVec3 _currentRotation = DiceFaceOrientation.getRestingEulerForValue(1);
  DiceVec3 _fromRotation = DiceFaceOrientation.getRestingEulerForValue(1);
  DiceVec3 _targetRotation = DiceFaceOrientation.getRestingEulerForValue(1);

  bool _hasTriggeredLaunchHaptic = false;
  bool _hasTriggeredMidRollSound = false;
  bool _hasTriggeredLandingHaptic = false;
  bool _hasTriggeredSettleFeedback = false;

  @override
  void initState() {
    super.initState();
    _currentRotation = DiceFaceOrientation.getRestingEulerForValue(widget.value);
    _fromRotation = _currentRotation;
    _targetRotation = _currentRotation;

    _rollController = AnimationController(
      vsync: this,
      duration: DiceMotionConfig.rollDuration,
    );

    _idleController = AnimationController(
      vsync: this,
      duration: DiceMotionConfig.idleCycleDuration,
    );
    // Do not continuously loop idle animation in tests to prevent pumpAndSettle timeout
    final isTesting = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTesting) {
      _idleController.repeat();
    }

    _pressController = AnimationController(
      vsync: this,
      duration: DiceMotionConfig.pressDuration,
    );

    _rollController.addListener(_handleRollTick);
    _rollController.addStatusListener(_handleRollStatus);

    if (widget.isRolling) {
      _startRollSequence();
    }
  }

  @override
  void didUpdateWidget(covariant PlayMateDice oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value && !widget.isRolling && !_rollController.isAnimating) {
      setState(() {
        _currentRotation = DiceFaceOrientation.getRestingEulerForValue(widget.value);
        _fromRotation = _currentRotation;
        _targetRotation = _currentRotation;
      });
    }

    if (widget.isRolling && !oldWidget.isRolling && !_rollController.isAnimating) {
      _startRollSequence();
    }
  }

  void _startRollSequence() {
    _fromRotation = _currentRotation;

    final baseTarget = DiceFaceOrientation.getRestingEulerForValue(widget.value);

    final int revCountX = 2 + (widget.diceIndex % 2);
    final int revCountY = 3 + ((widget.diceIndex + 1) % 2);
    final double revCountZ = 1.0 + (widget.diceIndex % 3) * 0.5;

    final double extraX = revCountX * 2 * math.pi;
    final double extraY = revCountY * 2 * math.pi;
    final double extraZ = revCountZ * 2 * math.pi;

    _targetRotation = DiceVec3(
      baseTarget.x + extraX,
      baseTarget.y + extraY,
      baseTarget.z + extraZ,
    );

    _hasTriggeredLaunchHaptic = false;
    _hasTriggeredMidRollSound = false;
    _hasTriggeredLandingHaptic = false;
    _hasTriggeredSettleFeedback = false;

    if (widget.delayMs > 0) {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted && widget.isRolling) {
          _rollController.forward(from: 0.0);
        }
      });
    } else {
      _rollController.forward(from: 0.0);
    }
  }

  void _handleRollTick() {
    final t = _rollController.value;

    if (t >= DiceMotionConfig.anticipationEnd && !_hasTriggeredLaunchHaptic) {
      _hasTriggeredLaunchHaptic = true;
      HapticFeedback.lightImpact();
    }

    if (t >= 0.48 && !_hasTriggeredMidRollSound) {
      _hasTriggeredMidRollSound = true;
      SoundService.playRollSound();
    }

    if (t >= DiceMotionConfig.tumbleEnd && !_hasTriggeredLandingHaptic) {
      _hasTriggeredLandingHaptic = true;
      SoundService.triggerHaptic();
    }

    if (t >= 0.98 && !_hasTriggeredSettleFeedback) {
      _hasTriggeredSettleFeedback = true;
      HapticFeedback.selectionClick();
    }

    final double rotT = _calculateRotationProgress(t);
    setState(() {
      _currentRotation = DiceVec3(
        _lerpDouble(_fromRotation.x, _targetRotation.x, rotT),
        _lerpDouble(_fromRotation.y, _targetRotation.y, rotT),
        _lerpDouble(_fromRotation.z, _targetRotation.z, rotT),
      );
    });
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  double _calculateRotationProgress(double t) {
    if (t < DiceMotionConfig.anticipationEnd) {
      final subT = t / DiceMotionConfig.anticipationEnd;
      return -0.015 * DiceMotionConfig.anticipationCurve.transform(subT);
    } else {
      final subT = (t - DiceMotionConfig.anticipationEnd) /
          (1.0 - DiceMotionConfig.anticipationEnd);
      return Curves.easeOutCubic.transform(subT.clamp(0.0, 1.0));
    }
  }

  void _handleRollStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      final baseTarget = DiceFaceOrientation.getRestingEulerForValue(widget.value);
      setState(() {
        _currentRotation = baseTarget;
        _fromRotation = baseTarget;
        _targetRotation = baseTarget;
      });
      widget.onRollCompleted?.call();
    }
  }

  @override
  void dispose() {
    _rollController.dispose();
    _idleController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isRolling || _rollController.isAnimating) return;
    _pressController.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isRolling || _rollController.isAnimating) return;
    _pressController.reverse();
    widget.onRollRequested?.call();
  }

  void _onTapCancel() {
    if (widget.isRolling || _rollController.isAnimating) return;
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final effectiveStyle = widget.style ?? DiceStyle.fromBrightness(theme.brightness);
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Semantics(
      label: widget.isRolling
          ? 'Rolling die'
          : 'Die showing ${widget.value}. Tap or roll to shake',
      button: true,
      enabled: !widget.isRolling,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: Listenable.merge([_rollController, _idleController, _pressController]),
          builder: (context, _) {
            final double rollT = _rollController.value;
            final double pressT = _pressController.value;

            // 1. Calculate physical scale
            double scale = 1.0 - (pressT * (1.0 - DiceMotionConfig.pressScale));
            if (!reducedMotion && _rollController.isAnimating) {
              if (rollT < DiceMotionConfig.anticipationEnd) {
                final subT = rollT / DiceMotionConfig.anticipationEnd;
                scale = _lerpDouble(1.0, DiceMotionConfig.pressScale, subT);
              } else if (rollT < DiceMotionConfig.launchEnd) {
                final subT = (rollT - DiceMotionConfig.anticipationEnd) /
                    (DiceMotionConfig.launchEnd - DiceMotionConfig.anticipationEnd);
                scale = _lerpDouble(DiceMotionConfig.pressScale, DiceMotionConfig.launchScale, subT);
              } else if (rollT < DiceMotionConfig.tumbleEnd) {
                final subT = (rollT - DiceMotionConfig.launchEnd) /
                    (DiceMotionConfig.tumbleEnd - DiceMotionConfig.launchEnd);
                scale = _lerpDouble(DiceMotionConfig.launchScale, 1.0, subT);
              } else if (rollT < DiceMotionConfig.landingEnd) {
                final subT = (rollT - DiceMotionConfig.tumbleEnd) /
                    (DiceMotionConfig.landingEnd - DiceMotionConfig.tumbleEnd);
                final bouncePhase = math.sin(subT * math.pi * 2);
                scale = 1.0 + (bouncePhase * 0.035);
              } else {
                final subT = (rollT - DiceMotionConfig.landingEnd) /
                    (DiceMotionConfig.settleEnd - DiceMotionConfig.landingEnd);
                final settlePhase = math.sin(subT * math.pi * 2);
                scale = 1.0 + (settlePhase * 0.012);
              }
            }

            // 2. Calculate physical elevation translateY
            double translateY = pressT * DiceMotionConfig.pressTranslateY;
            if (!reducedMotion && _rollController.isAnimating) {
              if (rollT < DiceMotionConfig.anticipationEnd) {
                translateY = DiceMotionConfig.pressTranslateY * (rollT / DiceMotionConfig.anticipationEnd);
              } else if (rollT < DiceMotionConfig.launchEnd) {
                final subT = (rollT - DiceMotionConfig.anticipationEnd) /
                    (DiceMotionConfig.launchEnd - DiceMotionConfig.anticipationEnd);
                translateY = _lerpDouble(
                  DiceMotionConfig.pressTranslateY,
                  DiceMotionConfig.launchPeakElevationY,
                  Curves.easeOutQuad.transform(subT),
                );
              } else if (rollT < DiceMotionConfig.tumbleEnd) {
                final subT = (rollT - DiceMotionConfig.launchEnd) /
                    (DiceMotionConfig.tumbleEnd - DiceMotionConfig.launchEnd);
                translateY = _lerpDouble(
                  DiceMotionConfig.launchPeakElevationY,
                  0.0,
                  Curves.easeInQuad.transform(subT),
                );
              } else if (rollT < DiceMotionConfig.landingEnd) {
                final subT = (rollT - DiceMotionConfig.tumbleEnd) /
                    (DiceMotionConfig.landingEnd - DiceMotionConfig.tumbleEnd);
                translateY = -5.0 * math.sin(subT * math.pi);
              } else {
                translateY = 0.0;
              }
            } else if (!reducedMotion && !_rollController.isAnimating && pressT == 0) {
              final idlePhase = math.sin(_idleController.value * math.pi * 2);
              translateY = -1.8 * idlePhase;
            }

            // 3. Dynamic contact shadow
            double shadowScale = DiceMotionConfig.shadowIdleScale;
            double shadowOpacity = isDarkMode
                ? DiceMotionConfig.shadowIdleOpacity * 1.5
                : DiceMotionConfig.shadowIdleOpacity;

            if (!reducedMotion && _rollController.isAnimating) {
              if (rollT < DiceMotionConfig.launchEnd) {
                final subT = (rollT / DiceMotionConfig.launchEnd).clamp(0.0, 1.0);
                shadowScale = _lerpDouble(DiceMotionConfig.shadowIdleScale, DiceMotionConfig.shadowLaunchScale, subT);
                shadowOpacity = _lerpDouble(shadowOpacity, DiceMotionConfig.shadowLaunchOpacity, subT);
              } else if (rollT < DiceMotionConfig.tumbleEnd) {
                final subT = ((rollT - DiceMotionConfig.launchEnd) /
                        (DiceMotionConfig.tumbleEnd - DiceMotionConfig.launchEnd))
                    .clamp(0.0, 1.0);
                shadowScale = _lerpDouble(DiceMotionConfig.shadowLaunchScale, DiceMotionConfig.shadowLandingScale, subT);
                shadowOpacity = _lerpDouble(DiceMotionConfig.shadowLaunchOpacity, DiceMotionConfig.shadowLandingOpacity, subT);
              } else {
                final subT = ((rollT - DiceMotionConfig.tumbleEnd) /
                        (1.0 - DiceMotionConfig.tumbleEnd))
                    .clamp(0.0, 1.0);
                shadowScale = _lerpDouble(DiceMotionConfig.shadowLandingScale, DiceMotionConfig.shadowIdleScale, subT);
                shadowOpacity = _lerpDouble(DiceMotionConfig.shadowLandingOpacity, DiceMotionConfig.shadowIdleOpacity, subT);
              }
            }

            final double dieSize = widget.size;
            final double halfExtent = dieSize / 2;

            return RepaintBoundary(
              child: SizedBox(
                width: dieSize * 1.25,
                height: dieSize * 1.45,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Dynamic ground shadow
                    Positioned(
                      bottom: dieSize * 0.08,
                      child: Transform.scale(
                        scale: shadowScale,
                        child: Opacity(
                          opacity: shadowOpacity.clamp(0.0, 1.0),
                          child: Container(
                            width: dieSize * 0.88,
                            height: dieSize * 0.28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(dieSize * 0.44, dieSize * 0.14)),
                              gradient: RadialGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.65),
                                  Colors.black.withValues(alpha: 0.25),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Physical 3D Cube / Facet body
                    Transform.translate(
                      offset: Offset(0, translateY),
                      child: Transform.scale(
                        scale: scale,
                        child: widget.diceType == DiceType.d6
                            ? _build3DCube(dieSize, halfExtent, effectiveStyle, isDarkMode)
                            : _buildPolyhedralDie(dieSize, effectiveStyle, isDarkMode),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _build3DCube(
    double dieSize,
    double halfExtent,
    DiceStyle style,
    bool isDarkMode,
  ) {
    final visibleFaces = DiceFaceOrientation.computeVisibleFaces(
      cubeRotation: _currentRotation,
      halfExtent: halfExtent,
      perspective: 0.0016,
    );

    return SizedBox(
      width: dieSize,
      height: dieSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: visibleFaces.map((faceData) {
          return Transform(
            alignment: Alignment.center,
            transform: faceData.transform,
            child: DiceFace(
              value: faceData.value,
              size: dieSize,
              style: style,
              lightIntensity: faceData.lightIntensity,
              isDarkMode: isDarkMode,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPolyhedralDie(
    double dieSize,
    DiceStyle style,
    bool isDarkMode,
  ) {
    final double radius = dieSize * 0.22;
    return Container(
      width: dieSize,
      height: dieSize,
      decoration: BoxDecoration(
        color: style.bodyColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDarkMode
              ? style.highlightColor.withValues(alpha: 0.2)
              : style.shadowEdgeColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: style.highlightColor.withValues(alpha: 0.4),
            offset: const Offset(-2, -2),
            blurRadius: 3,
          ),
          BoxShadow(
            color: style.shadowEdgeColor.withValues(alpha: 0.3),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.value}',
              style: TextStyle(
                fontSize: dieSize * 0.38,
                fontWeight: FontWeight.w900,
                color: style.pipColor,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: style.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.diceType.name.toUpperCase(),
                style: TextStyle(
                  fontSize: dieSize * 0.11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: style.accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
