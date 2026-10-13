import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/sound_service.dart';
import 'spin_wheel_math.dart';
import 'spin_wheel_models.dart';
import 'spin_wheel_motion_config.dart';
import 'wheel_painter.dart';
import 'wheel_pointer.dart';

/// Primary interactive physical PlayMate Spin Wheel component.
///
/// Features:
/// - Mathematically deterministic deceleration landing squarely on [targetWinner]
/// - Physical perimeter peg collisions that deflect the top pointer
/// - Coordinated tactile haptic feedback on peg passage
/// - Subtle idle breathing animation (guarded during automated tests)
/// - Press compression & spring-back feedback
/// - Dynamic contact drop shadow responding to physical elevation
/// - Accessibility semantics with screen reader support
class PlayMateSpinWheel extends StatefulWidget {
  final List<WheelOption> options;
  final WheelOption? targetWinner;
  final bool isSpinning;
  final double size;
  final VoidCallback? onSpinRequested;
  final VoidCallback? onSpinCompleted;

  const PlayMateSpinWheel({
    super.key,
    required this.options,
    this.targetWinner,
    this.isSpinning = false,
    this.size = 280.0,
    this.onSpinRequested,
    this.onSpinCompleted,
  });

  @override
  State<PlayMateSpinWheel> createState() => _PlayMateSpinWheelState();
}

class _PlayMateSpinWheelState extends State<PlayMateSpinWheel>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _idleController;
  late AnimationController _pressController;

  double _currentRotation = 0.0;
  double _startRotation = 0.0;
  double _targetRotation = 0.0;

  // Peg deflection calculation
  double _pointerDeflection = 0.0;
  int _lastPegSectorIndex = -1;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: SpinWheelMotionConfig.spinDuration,
    );

    _idleController = AnimationController(
      vsync: this,
      duration: SpinWheelMotionConfig.idleCycleDuration,
    );

    // Guard idle animation loop during automated testing to avoid pumpAndSettle timeout
    final isTesting = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTesting) {
      _idleController.repeat();
    }

    _pressController = AnimationController(
      vsync: this,
      duration: SpinWheelMotionConfig.pressDuration,
    );

    _spinController.addListener(_handleSpinTick);
    _spinController.addStatusListener(_handleSpinStatus);

    if (widget.isSpinning) {
      _startSpinSequence();
    }
  }

  @override
  void didUpdateWidget(covariant PlayMateSpinWheel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSpinning && !oldWidget.isSpinning && !_spinController.isAnimating) {
      _startSpinSequence();
    }
  }

  void _startSpinSequence() {
    if (widget.options.isEmpty) return;

    _startRotation = _currentRotation;
    final int count = widget.options.length;

    // Determine target index
    int winningIndex = 0;
    if (widget.targetWinner != null) {
      final found = widget.options.indexWhere((o) => o.id == widget.targetWinner!.id);
      winningIndex = found >= 0 ? found : 0;
    }

    // Deterministically calculate target rotation
    _targetRotation = SpinWheelMath.calculateTargetRotation(
      currentRotation: _startRotation,
      winningIndex: winningIndex,
      count: count,
      revolutions: 6,
    );

    _lastPegSectorIndex = -1;
    _pointerDeflection = 0.0;

    _spinController.forward(from: 0.0);
  }

  void _handleSpinTick() {
    final double t = _spinController.value;
    final double curvedT = SpinWheelMotionConfig.spinCurve.transform(t);

    final double rotation = _startRotation + (_targetRotation - _startRotation) * curvedT;
    final int count = widget.options.length;

    if (count > 0) {
      final double sweep = SpinWheelMath.getSweepAngle(count);
      // Continuous relative angle
      final double normAngle = (rotation % (2 * math.pi));
      final double pegPosition = (normAngle / sweep);
      final double pegFraction = pegPosition - pegPosition.floorToDouble();

      // Check peg passage boundary
      final int currentPegSector = pegPosition.floor();
      if (currentPegSector != _lastPegSectorIndex) {
        _lastPegSectorIndex = currentPegSector;
        // Trigger subtle tick sound and selection haptic
        SoundService.triggerHaptic();
      }

      // Pointer deflection: deflects in rotation direction when near peg boundary (fraction < 0.25)
      if (pegFraction < 0.25) {
        final double factor = math.sin((pegFraction / 0.25) * math.pi);
        _pointerDeflection = factor * SpinWheelMotionConfig.pointerMaxDeflection;
      } else {
        _pointerDeflection = 0.0;
      }
    }

    setState(() {
      _currentRotation = rotation;
    });
  }

  void _handleSpinStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Normalize rotation modulo 2pi for clean continuous future spins
      setState(() {
        _currentRotation = _targetRotation % (2 * math.pi);
        _startRotation = _currentRotation;
        _pointerDeflection = 0.0;
      });
      HapticFeedback.mediumImpact();
      widget.onSpinCompleted?.call();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _idleController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isSpinning || _spinController.isAnimating) return;
    _pressController.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isSpinning || _spinController.isAnimating) return;
    _pressController.reverse();
    widget.onSpinRequested?.call();
  }

  void _onTapCancel() {
    if (widget.isSpinning || _spinController.isAnimating) return;
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final String semanticsLabel = widget.isSpinning
        ? 'Spin wheel is spinning'
        : widget.targetWinner != null
            ? 'Spin wheel winner is ${widget.targetWinner!.label}. Tap to spin again'
            : 'Spin wheel ready with ${widget.options.length} options. Tap to spin';

    return Semantics(
      label: semanticsLabel,
      button: true,
      enabled: !widget.isSpinning,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: Listenable.merge([_spinController, _idleController, _pressController]),
          builder: (context, _) {
            final double pressT = _pressController.value;
            final double spinT = _spinController.value;

            // Physical tactile scale: compression on press, gentle breathing during spin
            double scale = 1.0 - (pressT * (1.0 - SpinWheelMotionConfig.pressScale));
            if (!reducedMotion && _spinController.isAnimating) {
              if (spinT < SpinWheelMotionConfig.accelerationEnd) {
                final subT = spinT / SpinWheelMotionConfig.accelerationEnd;
                scale = 1.0 + (subT * 0.02);
              } else if (spinT > SpinWheelMotionConfig.decelerationEnd) {
                final subT = (spinT - SpinWheelMotionConfig.decelerationEnd) /
                    (1.0 - SpinWheelMotionConfig.decelerationEnd);
                scale = 1.02 - (subT * 0.02);
              } else {
                scale = 1.02;
              }
            }

            // Subtle idle breathing scale
            if (!reducedMotion && !_spinController.isAnimating && pressT == 0) {
              final idlePhase = math.sin(_idleController.value * math.pi * 2);
              scale += idlePhase * 0.006;
            }

            final double wheelSize = widget.size;

            return Transform.scale(
              scale: scale,
              child: SizedBox(
                width: wheelSize,
                height: wheelSize + 24.0, // extra clearance for top pointer & contact shadow
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // 1. Dynamic Contact Shadow
                    Positioned(
                      bottom: 4.0,
                      child: Container(
                        width: wheelSize * SpinWheelMotionConfig.shadowIdleScale,
                        height: wheelSize * 0.14,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.elliptical(wheelSize * 0.5, wheelSize * 0.07)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDarkMode
                                    ? SpinWheelMotionConfig.shadowIdleOpacity * 1.6
                                    : SpinWheelMotionConfig.shadowIdleOpacity,
                              ),
                              blurRadius: _spinController.isAnimating ? 18.0 : 12.0,
                              spreadRadius: _spinController.isAnimating ? 4.0 : 2.0,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Rotating Wheel Body
                    Positioned(
                      top: 14.0,
                      child: Transform.rotate(
                        angle: _currentRotation,
                        child: SizedBox(
                          width: wheelSize,
                          height: wheelSize,
                          child: CustomPaint(
                            painter: WheelPainter(
                              options: widget.options,
                              isDarkMode: isDarkMode,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 3. Fixed Top Physical Pointer (Deflects on Peg Impact)
                    Positioned(
                      top: 4.0,
                      child: WheelPointer(
                        deflectionAngle: _pointerDeflection,
                        isDarkMode: isDarkMode,
                        size: 30.0,
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
}

