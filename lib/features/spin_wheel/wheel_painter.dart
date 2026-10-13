import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'spin_wheel_math.dart';
import 'spin_wheel_models.dart';

/// Renders the physical segmented PlayMate wheel with outer metallic rim, perimeter pegs,
/// radial labels, and central embossed hub.
class WheelPainter extends CustomPainter {
  final List<WheelOption> options;
  final bool isDarkMode;

  const WheelPainter({
    required this.options,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final int count = options.length;
    final double sweepAngle = SpinWheelMath.getSweepAngle(count);

    // Rim dimensions
    final double rimThickness = radius * 0.065;
    final double innerRadius = radius - rimThickness;
    final Rect innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    // 1. Draw Sector Bodies
    for (int i = 0; i < count; i++) {
      final double startAngle = SpinWheelMath.getSectorStartAngle(i, count);
      final Color sectorColor = options[i].customColor ??
          SpinWheelMath.getSegmentColor(i, count, isDarkMode);

      final Paint sectorPaint = Paint()
        ..color = sectorColor
        ..style = PaintingStyle.fill;

      canvas.drawArc(innerRect, startAngle, sweepAngle, true, sectorPaint);
    }

    // 2. Draw Sector Divider Lines
    final Paint dividerPaint = Paint()
      ..color = isDarkMode
          ? Colors.white.withValues(alpha: 0.18)
          : Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < count; i++) {
      final double startAngle = SpinWheelMath.getSectorStartAngle(i, count);
      final double dx = center.dx + innerRadius * math.cos(startAngle);
      final double dy = center.dy + innerRadius * math.sin(startAngle);
      canvas.drawLine(center, Offset(dx, dy), dividerPaint);
    }

    // 3. Draw Radial Segment Labels
    _drawLabels(canvas, center, innerRadius, count, sweepAngle);

    // 4. Draw Outer Metallic Rim with Chamfer Bevel
    _drawOuterRim(canvas, center, radius, innerRadius);

    // 5. Draw Perimeter Pegs / Studs at Sector Boundaries
    _drawPerimeterPegs(canvas, center, radius, innerRadius, count);

    // 6. Draw Center Metallic Hub
    _drawCenterHub(canvas, center, radius);
  }

  void _drawLabels(
    Canvas canvas,
    Offset center,
    double innerRadius,
    int count,
    double sweepAngle,
  ) {
    // Dynamic typography scaling based on segment density
    final double fontSize = count <= 4
        ? 14.0
        : count <= 8
            ? 12.0
            : count <= 12
                ? 10.5
                : 9.0;

    final double maxLabelWidth = innerRadius * 0.48;

    for (int i = 0; i < count; i++) {
      final double centerAngle = SpinWheelMath.getSectorCenterAngle(i, count);
      final Color sectorColor = options[i].customColor ??
          SpinWheelMath.getSegmentColor(i, count, isDarkMode);
      final Color textColor = SpinWheelMath.getTextColorForSegment(sectorColor, isDarkMode);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(centerAngle);

      final String rawLabel = options[i].label;
      final textSpan = TextSpan(
        text: rawLabel,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '..',
      );

      textPainter.layout(maxWidth: maxLabelWidth);

      // Position text along the radial arm (between center hub and outer rim)
      final double radialOffset = innerRadius * 0.42;
      textPainter.paint(
        canvas,
        Offset(radialOffset, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  void _drawOuterRim(Canvas canvas, Offset center, double radius, double innerRadius) {
    // Rim background stroke
    final rimColor = isDarkMode ? const Color(0xFF1E1F24) : const Color(0xFF2C2D33);
    final Paint rimPaint = Paint()
      ..color = rimColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = (radius - innerRadius);

    canvas.drawCircle(center, (radius + innerRadius) / 2, rimPaint);

    // Subtle outer highlight ring
    final Paint highlightPaint = Paint()
      ..color = (isDarkMode ? Colors.white : Colors.white).withValues(alpha: isDarkMode ? 0.12 : 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 0.5, highlightPaint);

    // Inner rim trench line
    final Paint trenchPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDarkMode ? 0.6 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, innerRadius, trenchPaint);
  }

  void _drawPerimeterPegs(
    Canvas canvas,
    Offset center,
    double radius,
    double innerRadius,
    int count,
  ) {
    final double pegRadius = (radius - innerRadius) * 0.26;
    final double pegDistance = (radius + innerRadius) / 2;

    final Paint pegBodyPaint = Paint()
      ..color = const Color(0xFFC18A42) // Warm bronze stud
      ..style = PaintingStyle.fill;

    final Paint pegHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final double boundaryAngle = SpinWheelMath.getSectorStartAngle(i, count);
      final Offset pegCenter = Offset(
        center.dx + pegDistance * math.cos(boundaryAngle),
        center.dy + pegDistance * math.sin(boundaryAngle),
      );

      // Peg body
      canvas.drawCircle(pegCenter, pegRadius, pegBodyPaint);
      // Subtle top-left highlight point
      canvas.drawCircle(
        pegCenter - const Offset(0.5, 0.5),
        pegRadius * 0.45,
        pegHighlightPaint,
      );
    }
  }

  void _drawCenterHub(Canvas canvas, Offset center, double radius) {
    final double hubRadius = radius * 0.21;

    // 1. Hub Drop Shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDarkMode ? 0.7 : 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(center + const Offset(0, 2), hubRadius, shadowPaint);

    // 2. Hub Metallic Body
    final hubBodyColor = isDarkMode ? const Color(0xFF22242A) : const Color(0xFFF3F0E8);
    final Paint hubPaint = Paint()
      ..color = hubBodyColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, hubRadius, hubPaint);

    // 3. Hub Concentric Engraved Ring
    final Paint engravedRingPaint = Paint()
      ..color = (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, hubRadius * 0.85, engravedRingPaint);

    // 4. Hub Outer Chamfer Rim
    final Paint bevelPaint = Paint()
      ..color = (isDarkMode ? Colors.white : Colors.white).withValues(alpha: isDarkMode ? 0.15 : 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, hubRadius - 0.75, bevelPaint);

    // 5. PlayMate Signature Diamond Spark in Hub Center
    _drawHubBrandMark(canvas, center, hubRadius * 0.44);
  }

  void _drawHubBrandMark(Canvas canvas, Offset center, double markRadius) {
    final double innerRadius = markRadius * 0.28;
    final path = Path();

    for (int i = 0; i < 4; i++) {
      final double outerAngle = i * (math.pi / 2) - (math.pi / 2);
      final double innerAngle = outerAngle + (math.pi / 4);

      final ox = center.dx + markRadius * math.cos(outerAngle);
      final oy = center.dy + markRadius * math.sin(outerAngle);

      final ix = center.dx + innerRadius * math.cos(innerAngle);
      final iy = center.dy + innerRadius * math.sin(innerAngle);

      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();

    final Paint markPaint = Paint()
      ..color = const Color(0xFFC18A42) // Warm Bronze Accent
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, markPaint);

    // Micro center point
    final Paint dotPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF141518) : const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, markRadius * 0.18, dotPaint);
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) {
    if (oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.options.length != options.length) {
      return true;
    }
    for (int i = 0; i < options.length; i++) {
      if (oldDelegate.options[i] != options[i]) return true;
    }
    return false;
  }
}

