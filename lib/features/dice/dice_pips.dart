import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable pip renderer using normalized coordinates [-1.0, 1.0].
///
/// Pips are rendered with a tactile recessed depth (inner rim shading and soft
/// radial falloff) rather than flat painted circles.
///
/// Face 1 integrates a subtle PlayMate geometric brand mark (warm bronze spark)
/// in the center of the recessed pip.
class DicePips extends StatelessWidget {
  final int value;
  final double faceSize;
  final Color pipColor;
  final Color accentColor;
  final bool isDarkMode;

  const DicePips({
    super.key,
    required this.value,
    required this.faceSize,
    required this.pipColor,
    this.accentColor = const Color(0xFFC18A42), // PlayMate signature bronze
    this.isDarkMode = false,
  });

  /// Canonical normalized pip coordinates mapped onto [-1.0, 1.0].
  static const Map<int, List<Offset>> normalizedPipOffsets = {
    1: [Offset(0.0, 0.0)],
    2: [Offset(-0.54, -0.54), Offset(0.54, 0.54)],
    3: [Offset(-0.54, -0.54), Offset(0.0, 0.0), Offset(0.54, 0.54)],
    4: [
      Offset(-0.54, -0.54),
      Offset(0.54, -0.54),
      Offset(-0.54, 0.54),
      Offset(0.54, 0.54),
    ],
    5: [
      Offset(-0.54, -0.54),
      Offset(0.54, -0.54),
      Offset(0.0, 0.0),
      Offset(-0.54, 0.54),
      Offset(0.54, 0.54),
    ],
    6: [
      Offset(-0.54, -0.58),
      Offset(0.54, -0.58),
      Offset(-0.54, 0.0),
      Offset(0.54, 0.0),
      Offset(-0.54, 0.58),
      Offset(0.54, 0.58),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(faceSize, faceSize),
      painter: _DicePipsPainter(
        value: value,
        pipColor: pipColor,
        accentColor: accentColor,
        isDarkMode: isDarkMode,
      ),
    );
  }
}

class _DicePipsPainter extends CustomPainter {
  final int value;
  final Color pipColor;
  final Color accentColor;
  final bool isDarkMode;

  const _DicePipsPainter({
    required this.value,
    required this.pipColor,
    required this.accentColor,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (value < 1 || value > 6) return;

    final offsets = DicePips.normalizedPipOffsets[value] ?? [];
    final center = Offset(size.width / 2, size.height / 2);
    // Usable half dimension inside face padding (32% margin)
    final double halfSpan = size.width * 0.28;
    // Pip radius is approximately 9% of face size
    final double pipRadius = size.width * 0.092;

    for (int i = 0; i < offsets.length; i++) {
      final norm = offsets[i];
      final pipCenter = Offset(
        center.dx + norm.dx * halfSpan,
        center.dy + norm.dy * halfSpan,
      );

      final isCenterOnePip = (value == 1 && norm == Offset.zero);
      _drawRecessedPip(canvas, pipCenter, pipRadius, isCenterOnePip);
    }
  }

  void _drawRecessedPip(Canvas canvas, Offset center, double radius, bool isOnePip) {
    // 1. Recessed inner shadow (top-left rim)
    final innerShadowPaint = Paint()
      ..color = isDarkMode
          ? Colors.black.withValues(alpha: 0.6)
          : Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(0.4, 0.6), radius + 0.5, innerShadowPaint);

    // 2. Subtle light reflection on bottom-right rim
    final rimHighlightPaint = Paint()
      ..color = isDarkMode
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, radius, rimHighlightPaint);

    // 3. Pip core gradient fill (darker at top-left, slightly softer at bottom-right)
    final pipGradient = RadialGradient(
      center: const Alignment(-0.25, -0.25),
      radius: 0.9,
      colors: isDarkMode
          ? [
              pipColor,
              pipColor.withValues(alpha: 0.88),
            ]
          : [
              pipColor.withValues(alpha: 0.92),
              pipColor,
            ],
    );

    final pipPaint = Paint()
      ..shader = pipGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, pipPaint);

    // 4. Subtle PlayMate signature geometric mark for Face 1
    if (isOnePip) {
      _drawPlayMateBrandMark(canvas, center, radius);
    }
  }

  void _drawPlayMateBrandMark(Canvas canvas, Offset center, double pipRadius) {
    // Elegant geometric 4-point diamond star / play spark in warm bronze
    final double starRadius = pipRadius * 0.65;
    final double innerRadius = starRadius * 0.26;

    final path = Path();
    for (int i = 0; i < 4; i++) {
      final double outerAngle = i * (math.pi / 2) - (math.pi / 2);
      final double innerAngle = outerAngle + (math.pi / 4);

      final outerX = center.dx + starRadius * math.cos(outerAngle);
      final outerY = center.dy + starRadius * math.sin(outerAngle);

      final innerX = center.dx + innerRadius * math.cos(innerAngle);
      final innerY = center.dy + innerRadius * math.sin(innerAngle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();

    final markPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, markPaint);

    // Micro center point
    final dotPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF17181A) : const Color(0xFFF3F0E8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, pipRadius * 0.14, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DicePipsPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.pipColor != pipColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
