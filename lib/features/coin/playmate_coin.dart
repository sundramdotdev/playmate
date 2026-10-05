import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/sound_service.dart';
import 'coin_face.dart';
import 'coin_motion_config.dart';
import 'coin_orientation.dart';

/// Primary physical 3D PlayMate coin widget.
///
/// Features:
/// - True programmatic 3D transformation using Matrix4 with perspective
/// - Volumetric cylindrical thickness and metallic edge rendering
/// - Distinct HEADS and TAILS faces with embossed PlayMate branding
/// - Deterministic final face orientation matching the logical result
/// - Physical anticipation, launch elevation, multi-flip tumble, and settling
/// - Responsive dynamic contact shadow
/// - Tactile press and spring-back interactions
/// - Full accessibility semantics and reduced-motion graceful fallback
class PlayMateCoin extends StatefulWidget {
  final CoinSide side;
  final double size;
  final bool isFlipping;
  final VoidCallback? onTossRequested;
  final VoidCallback? onTossCompleted;

  const PlayMateCoin({
    super.key,
    required this.side,
    this.size = 150.0,
    this.isFlipping = false,
    this.onTossRequested,
    this.onTossCompleted,
  });

  @override
  State<PlayMateCoin> createState() => _PlayMateCoinState();
}

class _PlayMateCoinState extends State<PlayMateCoin> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _idleController;
  late AnimationController _pressController;

  double _currentRx = CoinOrientation.getBaseAngleForSide(CoinSide.heads);
  double _fromRx = CoinOrientation.getBaseAngleForSide(CoinSide.heads);
  double _targetRx = CoinOrientation.getBaseAngleForSide(CoinSide.heads);

  // Controlled organic variation per toss
  double _secondaryDriftY = 0.0;
  double _secondaryWobbleZ = 0.0;

  bool _hasTriggeredLaunchHaptic = false;
  bool _hasTriggeredMidFlipSound = false;
  bool _hasTriggeredLandingHaptic = false;
  bool _hasTriggeredSettleFeedback = false;

  @override
  void initState() {
    super.initState();
    _currentRx = CoinOrientation.getBaseAngleForSide(widget.side);
    _fromRx = _currentRx;
    _targetRx = _currentRx;

    _flipController = AnimationController(
      vsync: this,
      duration: CoinMotionConfig.flipDuration,
    );

    _idleController = AnimationController(
      vsync: this,
      duration: CoinMotionConfig.idleCycleDuration,
    );

    // Only loop idle animation in production to prevent pumpAndSettle test timeouts
    final isTesting = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTesting) {
      _idleController.repeat();
    }

    _pressController = AnimationController(
      vsync: this,
      duration: CoinMotionConfig.pressDuration,
    );

    _flipController.addListener(_handleFlipTick);
    _flipController.addStatusListener(_handleFlipStatus);

    if (widget.isFlipping) {
      _startFlipSequence();
    }
  }

  @override
  void didUpdateWidget(covariant PlayMateCoin oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.side != oldWidget.side && !widget.isFlipping && !_flipController.isAnimating) {
      setState(() {
        _currentRx = CoinOrientation.getBaseAngleForSide(widget.side);
        _fromRx = _currentRx;
        _targetRx = _currentRx;
      });
    }

    if (widget.isFlipping && !oldWidget.isFlipping && !_flipController.isAnimating) {
      _startFlipSequence();
    }
  }

  void _startFlipSequence() {
    _fromRx = _currentRx;

    // Organic variation: randomize cycles (5 to 6 full 360° flips) and secondary axis drift
    final random = math.Random();
    final int fullCycles = 5 + (random.nextInt(2)); // 5 or 6 complete flips
    _secondaryDriftY = (random.nextDouble() - 0.5) * 0.16; // subtle Y drift
    _secondaryWobbleZ = (random.nextDouble() - 0.5) * 0.12; // subtle Z wobble

    // Deterministically calculate target angle to land squarely on widget.side
    _targetRx = CoinOrientation.calculateTargetFlipAngle(
      currentRx: _fromRx,
      targetSide: widget.side,
      fullCycles: fullCycles,
    );

    _hasTriggeredLaunchHaptic = false;
    _hasTriggeredMidFlipSound = false;
    _hasTriggeredLandingHaptic = false;
    _hasTriggeredSettleFeedback = false;

    _flipController.forward(from: 0.0);
  }

  void _handleFlipTick() {
    final t = _flipController.value;

    // Physical feedback milestones
    if (t >= CoinMotionConfig.anticipationEnd && !_hasTriggeredLaunchHaptic) {
      _hasTriggeredLaunchHaptic = true;
      HapticFeedback.lightImpact();
    }

    if (t >= 0.45 && !_hasTriggeredMidFlipSound) {
      _hasTriggeredMidFlipSound = true;
      SoundService.playTossSound();
    }

    if (t >= CoinMotionConfig.flipEnd && !_hasTriggeredLandingHaptic) {
      _hasTriggeredLandingHaptic = true;
      SoundService.triggerHaptic();
    }

    if (t >= 0.98 && !_hasTriggeredSettleFeedback) {
      _hasTriggeredSettleFeedback = true;
      HapticFeedback.selectionClick();
    }

    // Interpolate rotation progress
    final double rotT = _calculateRotationProgress(t);
    setState(() {
      _currentRx = _fromRx + (_targetRx - _fromRx) * rotT;
    });
  }

  double _calculateRotationProgress(double t) {
    if (t < CoinMotionConfig.anticipationEnd) {
      // Wind-up compression
      final subT = t / CoinMotionConfig.anticipationEnd;
      return -0.01 * CoinMotionConfig.anticipationCurve.transform(subT);
    } else {
      // Fast acceleration into smooth natural deceleration
      final subT = (t - CoinMotionConfig.anticipationEnd) /
          (1.0 - CoinMotionConfig.anticipationEnd);
      return Curves.easeOutCubic.transform(subT.clamp(0.0, 1.0));
    }
  }

  void _handleFlipStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Normalize resting rotation modulo 2pi for mathematical cleanliness
      final baseTarget = CoinOrientation.getBaseAngleForSide(widget.side);
      setState(() {
        _currentRx = baseTarget;
        _fromRx = baseTarget;
        _targetRx = baseTarget;
      });
      widget.onTossCompleted?.call();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _idleController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isFlipping || _flipController.isAnimating) return;
    _pressController.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isFlipping || _flipController.isAnimating) return;
    _pressController.reverse();
    widget.onTossRequested?.call();
  }

  void _onTapCancel() {
    if (widget.isFlipping || _flipController.isAnimating) return;
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Semantics(
      label: widget.isFlipping
          ? 'Coin is flipping'
          : 'Coin showing ${widget.side.displayName}. Double tap to toss',
      button: true,
      enabled: !widget.isFlipping,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: Listenable.merge([_flipController, _idleController, _pressController]),
          builder: (context, _) {
            final double flipT = _flipController.value;
            final double pressT = _pressController.value;

            // 1. Calculate physical scale
            double scale = 1.0 - (pressT * (1.0 - CoinMotionConfig.pressScale));
            if (!reducedMotion && _flipController.isAnimating) {
              if (flipT < CoinMotionConfig.anticipationEnd) {
                final subT = flipT / CoinMotionConfig.anticipationEnd;
                scale = 1.0 - (subT * (1.0 - CoinMotionConfig.pressScale));
              } else if (flipT < CoinMotionConfig.launchEnd) {
                final subT = (flipT - CoinMotionConfig.anticipationEnd) /
                    (CoinMotionConfig.launchEnd - CoinMotionConfig.anticipationEnd);
                scale = CoinMotionConfig.pressScale +
                    subT * (CoinMotionConfig.launchScale - CoinMotionConfig.pressScale);
              } else if (flipT < CoinMotionConfig.flipEnd) {
                final subT = (flipT - CoinMotionConfig.launchEnd) /
                    (CoinMotionConfig.flipEnd - CoinMotionConfig.launchEnd);
                scale = CoinMotionConfig.launchScale - subT * (CoinMotionConfig.launchScale - 1.0);
              } else if (flipT < CoinMotionConfig.landingEnd) {
                final subT = (flipT - CoinMotionConfig.flipEnd) /
                    (CoinMotionConfig.landingEnd - CoinMotionConfig.flipEnd);
                final bouncePhase = math.sin(subT * math.pi * 2);
                scale = 1.0 + (bouncePhase * 0.025);
              } else {
                final subT = (flipT - CoinMotionConfig.landingEnd) /
                    (CoinMotionConfig.settleEnd - CoinMotionConfig.landingEnd);
                final settlePhase = math.sin(subT * math.pi * 2);
                scale = 1.0 + (settlePhase * 0.008);
              }
            }

            // 2. Calculate physical elevation translateY
            double translateY = pressT * CoinMotionConfig.pressTranslateY;
            if (!reducedMotion && _flipController.isAnimating) {
              if (flipT < CoinMotionConfig.anticipationEnd) {
                translateY = CoinMotionConfig.pressTranslateY * (flipT / CoinMotionConfig.anticipationEnd);
              } else if (flipT < CoinMotionConfig.launchEnd) {
                final subT = (flipT - CoinMotionConfig.anticipationEnd) /
                    (CoinMotionConfig.launchEnd - CoinMotionConfig.anticipationEnd);
                translateY = CoinMotionConfig.pressTranslateY +
                    Curves.easeOutQuad.transform(subT) *
                        (CoinMotionConfig.launchPeakElevationY - CoinMotionConfig.pressTranslateY);
              } else if (flipT < CoinMotionConfig.flipEnd) {
                final subT = (flipT - CoinMotionConfig.launchEnd) /
                    (CoinMotionConfig.flipEnd - CoinMotionConfig.launchEnd);
                translateY = CoinMotionConfig.launchPeakElevationY *
                    (1.0 - Curves.easeInQuad.transform(subT));
              } else if (flipT < CoinMotionConfig.landingEnd) {
                final subT = (flipT - CoinMotionConfig.flipEnd) /
                    (CoinMotionConfig.landingEnd - CoinMotionConfig.flipEnd);
                translateY = -4.0 * math.sin(subT * math.pi);
              } else {
                translateY = 0.0;
              }
            } else if (!reducedMotion && !_flipController.isAnimating && pressT == 0) {
              // Idle subtle breathing drift (~1.5px)
              final idlePhase = math.sin(_idleController.value * math.pi * 2);
              translateY = -1.5 * idlePhase;
            }

            // 3. Dynamic contact shadow
            double shadowScale = CoinMotionConfig.shadowIdleScale;
            double shadowOpacity = isDarkMode
                ? CoinMotionConfig.shadowIdleOpacity * 1.5
                : CoinMotionConfig.shadowIdleOpacity;

            if (!reducedMotion && _flipController.isAnimating) {
              if (flipT < CoinMotionConfig.launchEnd) {
                final subT = (flipT / CoinMotionConfig.launchEnd).clamp(0.0, 1.0);
                shadowScale = CoinMotionConfig.shadowIdleScale +
                    subT * (CoinMotionConfig.shadowLaunchScale - CoinMotionConfig.shadowIdleScale);
                shadowOpacity = shadowOpacity +
                    subT * (CoinMotionConfig.shadowLaunchOpacity - shadowOpacity);
              } else if (flipT < CoinMotionConfig.flipEnd) {
                final subT = ((flipT - CoinMotionConfig.launchEnd) /
                        (CoinMotionConfig.flipEnd - CoinMotionConfig.launchEnd))
                    .clamp(0.0, 1.0);
                shadowScale = CoinMotionConfig.shadowLaunchScale +
                    subT * (CoinMotionConfig.shadowLandingScale - CoinMotionConfig.shadowLaunchScale);
                shadowOpacity = CoinMotionConfig.shadowLaunchOpacity +
                    subT * (CoinMotionConfig.shadowLandingOpacity - CoinMotionConfig.shadowLaunchOpacity);
              } else {
                final subT = ((flipT - CoinMotionConfig.flipEnd) /
                        (1.0 - CoinMotionConfig.flipEnd))
                    .clamp(0.0, 1.0);
                shadowScale = CoinMotionConfig.shadowLandingScale +
                    subT * (CoinMotionConfig.shadowIdleScale - CoinMotionConfig.shadowLandingScale);
                shadowOpacity = CoinMotionConfig.shadowLandingOpacity +
                    subT * (CoinMotionConfig.shadowIdleOpacity - CoinMotionConfig.shadowLandingOpacity);
              }
            }

            final double coinSize = widget.size;
            final double thickness = coinSize * CoinOrientation.thicknessRatio;

            // Secondary rotations during tumbling
            final double secondaryY = _flipController.isAnimating
                ? CoinOrientation.restingTiltY + math.sin(flipT * math.pi) * _secondaryDriftY
                : CoinOrientation.restingTiltY;
            final double secondaryZ = _flipController.isAnimating
                ? CoinOrientation.restingTiltZ + math.sin(flipT * math.pi * 2) * _secondaryWobbleZ
                : CoinOrientation.restingTiltZ;

            return RepaintBoundary(
              child: SizedBox(
                width: coinSize * 1.25,
                height: coinSize * 1.45,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Dynamic ground shadow
                    Positioned(
                      bottom: coinSize * 0.10,
                      child: Transform.scale(
                        scale: shadowScale,
                        child: Opacity(
                          opacity: shadowOpacity.clamp(0.0, 1.0),
                          child: Container(
                            width: coinSize * 0.85,
                            height: coinSize * 0.24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(coinSize * 0.42, coinSize * 0.12)),
                              gradient: RadialGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.65),
                                  Colors.black.withValues(alpha: 0.22),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Physical 3D Coin with cylindrical thickness
                    Transform.translate(
                      offset: Offset(0, translateY),
                      child: Transform.scale(
                        scale: scale,
                        child: _build3DCoin(
                          coinSize: coinSize,
                          thickness: thickness,
                          rx: _currentRx + CoinOrientation.restingTiltX,
                          ry: secondaryY,
                          rz: secondaryZ,
                          isDarkMode: isDarkMode,
                        ),
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

  /// Builds volumetric 3D coin with front face, back face, and cylindrical edge
  Widget _build3DCoin({
    required double coinSize,
    required double thickness,
    required double rx,
    required double ry,
    required double rz,
    required bool isDarkMode,
  }) {
    final double halfThickness = thickness / 2;

    // Normal Z component of Front Face (Heads) in rotated camera space
    // Negative = facing camera, Positive = facing away
    final double cosRx = math.cos(rx);
    final bool isHeadsFacing = cosRx >= 0.0;

    // Directional lighting based on orientation relative to light (-0.35, -0.65, -0.67)
    final double lightFront = (0.78 + (0.22 * math.max(0.0, cosRx))).clamp(0.0, 1.0);
    final double lightBack = (0.78 + (0.22 * math.max(0.0, -cosRx))).clamp(0.0, 1.0);

    // 3D rotation transform for the coin container
    final coinTransform = Matrix4.identity()
      ..setEntry(3, 2, 0.0016) // Perspective
      ..rotateX(rx)
      ..rotateY(ry)
      ..rotateZ(rz);

    // Number of cylindrical edge slices
    const int edgeSliceCount = 8;
    final edgeColor = isDarkMode ? const Color(0xFF1E1F23) : const Color(0xFF2B2C31);

    // Edge slices ordered along Z from -halfThickness to +halfThickness
    final List<Widget> children = [];

    // Painter's order:
    // If Heads is facing camera (cosRx >= 0):
    // 1. Tails (Back) disc at +halfThickness
    // 2. Edge slices
    // 3. Heads (Front) disc at -halfThickness
    // If Tails is facing camera (cosRx < 0):
    // 1. Heads (Front) disc at -halfThickness
    // 2. Edge slices
    // 3. Tails (Back) disc at +halfThickness

    final Widget tailsFaceWidget = Transform(
      transform: Matrix4.identity()
        ..rotateY(math.pi)
        ..multiply(Matrix4.translationValues(0.0, 0.0, -halfThickness)),
      alignment: Alignment.center,
      child: CoinFace(
        side: CoinSide.tails,
        size: coinSize,
        isDarkMode: isDarkMode,
        lightIntensity: lightBack,
      ),
    );

    final Widget headsFaceWidget = Transform(
      transform: Matrix4.translationValues(0.0, 0.0, -halfThickness),
      alignment: Alignment.center,
      child: CoinFace(
        side: CoinSide.heads,
        size: coinSize,
        isDarkMode: isDarkMode,
        lightIntensity: lightFront,
      ),
    );

    // Add back face first if Heads is facing, or front face first if Tails is facing
    if (isHeadsFacing) {
      children.add(tailsFaceWidget);
    } else {
      children.add(headsFaceWidget);
    }

    // Cylindrical edge slices along Z creating continuous solid cylindrical thickness
    for (int i = 0; i < edgeSliceCount; i++) {
      final double zSlice = -halfThickness +
          (thickness * (i + 0.5) / edgeSliceCount);

      children.add(
        Transform(
          transform: Matrix4.translationValues(0.0, 0.0, zSlice),
          alignment: Alignment.center,
          child: Container(
            width: coinSize,
            height: coinSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: edgeColor,
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.18),
                width: 0.8,
              ),
            ),
          ),
        ),
      );
    }

    // Add top facing face last in painter's order
    if (isHeadsFacing) {
      children.add(headsFaceWidget);
    } else {
      children.add(tailsFaceWidget);
    }

    return Transform(
      transform: coinTransform,
      alignment: Alignment.center,
      child: SizedBox(
        width: coinSize,
        height: coinSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: children,
        ),
      ),
    );
  }
}
