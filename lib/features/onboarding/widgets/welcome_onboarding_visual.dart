import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../coin/coin_face.dart';
import '../../coin/coin_orientation.dart';
import '../../dice/dice_face.dart';

/// Screen 3 memorable visual composition uniting PlayMate's signature tactile gaming assets.
///
/// Features:
/// - Embossed 3D PlayMate coin alongside a 3D tilted die
/// - Subtle concentric game-night energy arcs
/// - Gentle floating & breathing animation
/// - Full reduced-motion support and lifecycle management
class WelcomeOnboardingVisual extends StatefulWidget {
  final double size;

  const WelcomeOnboardingVisual({super.key, this.size = 230.0});

  @override
  State<WelcomeOnboardingVisual> createState() =>
      _WelcomeOnboardingVisualState();
}

class _WelcomeOnboardingVisualState extends State<WelcomeOnboardingVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    final isTesting =
        !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTesting) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final diceStyle = DiceStyle.fromBrightness(theme.brightness);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Semantics(
      label: 'PlayMate Game Night Welcome Composition',
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final double t = reduceMotion ? 0.5 : _pulseController.value;
          final double floatOffset = math.sin(t * math.pi) * 6.0;

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Concentric Energy Arc Background
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _EnergyArcPainter(
                    arcColor: theme.colorScheme.primary.withValues(
                      alpha: isDark ? 0.12 : 0.07,
                    ),
                    accentColor: const Color(
                      0xFFC18A42,
                    ).withValues(alpha: isDark ? 0.22 : 0.15),
                    phase: reduceMotion ? 0.0 : _pulseController.value,
                  ),
                ),

                // Ground Contact Shadows
                Positioned(
                  bottom: widget.size * 0.14,
                  child: Container(
                    width: widget.size * 0.65,
                    height: 14.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(widget.size * 0.65, 14.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.40 : 0.12,
                          ),
                          blurRadius: 16.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                  ),
                ),

                // PlayMate Minted 3D Coin (Left-anchored)
                Positioned(
                  left: widget.size * 0.12,
                  top: widget.size * 0.24 + floatOffset,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateZ(-0.08)
                      ..rotateY(-0.18),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.55 : 0.18,
                            ),
                            blurRadius: 14.0,
                            offset: const Offset(2, 6),
                          ),
                        ],
                      ),
                      child: const CoinFace(
                        side: CoinSide.heads,
                        size: 88,
                        lightIntensity: 1.0,
                      ),
                    ),
                  ),
                ),

                // PlayMate Tactile Die (Right-anchored)
                Positioned(
                  right: widget.size * 0.12,
                  bottom: widget.size * 0.18 - floatOffset,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateZ(0.12)
                      ..rotateX(0.14)
                      ..rotateY(0.12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(74 * 0.20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.55 : 0.18,
                            ),
                            blurRadius: 16.0,
                            offset: const Offset(4, 8),
                          ),
                        ],
                      ),
                      child: DiceFace(
                        value: 6,
                        size: 74,
                        style: diceStyle,
                        lightIntensity: 1.0,
                        isDarkMode: isDark,
                      ),
                    ),
                  ),
                ),

                // Subtle Top Accent Badge
                Positioned(
                  top: widget.size * 0.08,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC18A42).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFC18A42).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.sports_esports,
                          size: 14,
                          color: Color(0xFFC18A42),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'READY TO PLAY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark
                                ? const Color(0xFFE4AA5A)
                                : const Color(0xFF9E6822),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EnergyArcPainter extends CustomPainter {
  final Color arcColor;
  final Color accentColor;
  final double phase;

  _EnergyArcPainter({
    required this.arcColor,
    required this.accentColor,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint1 = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final paint2 = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final double radius1 = size.width * 0.44;
    final double radius2 = size.width * 0.38;

    canvas.drawCircle(center, radius1, paint1);

    // Accent partial arcs
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius2),
      -math.pi / 4 + (phase * 0.1),
      math.pi / 3,
      false,
      paint2,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius2),
      3 * math.pi / 4 + (phase * 0.1),
      math.pi / 4,
      false,
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant _EnergyArcPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.accentColor != accentColor;
  }
}
