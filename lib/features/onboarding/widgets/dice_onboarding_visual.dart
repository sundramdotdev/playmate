import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../dice/dice_face.dart';

/// Screen 1 custom dice illustration.
///
/// Features:
/// - Reuses PlayMate's authentic dice face rendering (chamfer, realistic pips, embossed shadows)
/// - Paired physical dice composition (primary die + companion accent die)
/// - Subtle, organic floating levitation with dynamic contact shadow
/// - Full reduced-motion awareness and lifecycle disposal
class DiceOnboardingVisual extends StatefulWidget {
  final double size;

  const DiceOnboardingVisual({super.key, this.size = 220.0});

  @override
  State<DiceOnboardingVisual> createState() => _DiceOnboardingVisualState();
}

class _DiceOnboardingVisualState extends State<DiceOnboardingVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    final isTesting =
        !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTesting) {
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final diceStyle = DiceStyle.fromBrightness(theme.brightness);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final primaryDiceSize = widget.size * 0.52;
    final secondaryDiceSize = widget.size * 0.38;

    return Semantics(
      label: 'PlayMate 3D Tabletop Dice Illustration',
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final double t = reduceMotion ? 0.5 : _floatController.value;
          final double floatOffset = math.sin(t * math.pi) * 8.0;
          final double shadowScale = 1.0 - (floatOffset / 40.0).clamp(0.0, 0.3);

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ground Ambient Contact Shadow
                Positioned(
                  bottom: widget.size * 0.12,
                  child: Container(
                    width: widget.size * 0.72 * shadowScale,
                    height: 18.0 * shadowScale,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(widget.size * 0.72, 18.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isDark ? Colors.black : const Color(0xFF1A1A1A))
                                  .withValues(alpha: isDark ? 0.45 : 0.12),
                          blurRadius: 18.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                  ),
                ),

                // Secondary Companion Die (Tilted in background)
                Positioned(
                  right: widget.size * 0.12,
                  top: widget.size * 0.22 - (floatOffset * 0.7),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateZ(0.22)
                      ..rotateX(-0.15)
                      ..rotateY(0.20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          secondaryDiceSize * 0.20,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.50 : 0.16,
                            ),
                            blurRadius: 12.0,
                            offset: const Offset(4, 6),
                          ),
                        ],
                      ),
                      child: DiceFace(
                        value: 5,
                        size: secondaryDiceSize,
                        style: diceStyle,
                        lightIntensity: 0.92,
                        isDarkMode: isDark,
                      ),
                    ),
                  ),
                ),

                // Primary Hero Die (Foreground with signature 6)
                Positioned(
                  left: widget.size * 0.14,
                  bottom: widget.size * 0.20 + floatOffset,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateZ(-0.10)
                      ..rotateX(0.12)
                      ..rotateY(-0.16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          primaryDiceSize * 0.20,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.60 : 0.20,
                            ),
                            blurRadius: 16.0,
                            offset: const Offset(4, 8),
                          ),
                        ],
                      ),
                      child: DiceFace(
                        value: 6,
                        size: primaryDiceSize,
                        style: diceStyle,
                        lightIntensity: 1.0,
                        isDarkMode: isDark,
                      ),
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
