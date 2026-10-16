import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'coin_orientation.dart';

/// Reusable physical coin face renderer for HEADS and TAILS.
///
/// Features:
/// - Concentric engraved coin rim rings
/// - Physical embossed/engraved tactile relief
/// - Integrated PlayMate branding (Signature Spark on HEADS, Geometric Monogram on TAILS)
/// - Directional metallic lighting and chamfer rim highlights
/// - Premium satin matte finish in light and dark modes
class CoinFace extends StatelessWidget {
  final CoinSide side;
  final double size;
  final bool isDarkMode;
  final double lightIntensity;

  const CoinFace({
    super.key,
    required this.side,
    required this.size,
    this.isDarkMode = false,
    this.lightIntensity = 1.0,
  });

  // Design Tokens (matching Dice system)
  static const Color ivoryBody = Color(0xFFF3F0E8);
  static const Color darkBody = Color(0xFF202124);
  static const Color charcoalBranding = Color(0xFF17181A);
  static const Color pearlBranding = Color(0xFFF5F5F2);
  static const Color bronzeAccent = Color(0xFFC18A42);

  @override
  Widget build(BuildContext context) {
    final Color baseBody = isDarkMode ? darkBody : ivoryBody;
    final Color brandColor = isDarkMode ? pearlBranding : charcoalBranding;

    // Modulate body color by directional lightIntensity
    final Color litBody = Color.lerp(
      isDarkMode ? const Color(0xFF141517) : const Color(0xFFDDD9CF),
      baseBody,
      lightIntensity.clamp(0.0, 1.0),
    )!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: litBody,
        boxShadow: [
          // Outer rim chamfer highlight
          BoxShadow(
            color: (isDarkMode ? Colors.white : Colors.white).withValues(
              alpha: (isDarkMode ? 0.12 : 0.45) * lightIntensity,
            ),
            offset: const Offset(-1.5, -1.5),
            blurRadius: 2.0,
          ),
          BoxShadow(
            color: Colors.black.withValues(
              alpha: (isDarkMode ? 0.65 : 0.22) * lightIntensity,
            ),
            offset: const Offset(1.5, 1.5),
            blurRadius: 3.0,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _CoinFacePainter(
          side: side,
          brandColor: brandColor,
          accentColor: bronzeAccent,
          isDarkMode: isDarkMode,
          lightIntensity: lightIntensity,
        ),
      ),
    );
  }
}

class _CoinFacePainter extends CustomPainter {
  final CoinSide side;
  final Color brandColor;
  final Color accentColor;
  final bool isDarkMode;
  final double lightIntensity;

  const _CoinFacePainter({
    required this.side,
    required this.brandColor,
    required this.accentColor,
    required this.isDarkMode,
    required this.lightIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Concentric engraved outer rim rings
    _drawEngravedRims(canvas, center, radius);

    // 2. Face-specific PlayMate branding
    if (side == CoinSide.heads) {
      _drawHeadsBranding(canvas, center, radius);
    } else {
      _drawTailsBranding(canvas, center, radius);
    }
  }

  void _drawEngravedRims(Canvas canvas, Offset center, double radius) {
    // Outer engraved trench rim
    final outerRingPaint = Paint()
      ..color = (isDarkMode ? Colors.black : const Color(0xFFC8C4B8)).withValues(
        alpha: (isDarkMode ? 0.7 : 0.5) * lightIntensity,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.035;
    canvas.drawCircle(center, radius * 0.90, outerRingPaint);

    // Inner bevel highlight ring
    final innerHighlightPaint = Paint()
      ..color = (isDarkMode ? Colors.white : Colors.white).withValues(
        alpha: (isDarkMode ? 0.15 : 0.6) * lightIntensity,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.018;
    canvas.drawCircle(center, radius * 0.88, innerHighlightPaint);

    // Secondary decorative concentric rim with subtle bronze accent
    final decorativeRingPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.28 * lightIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.015;
    canvas.drawCircle(center, radius * 0.76, decorativeRingPaint);
  }

  void _drawHeadsBranding(Canvas canvas, Offset center, double radius) {
    // Central signature PlayMate geometric 4-point diamond star
    final starRadius = radius * 0.42;
    final innerRadius = starRadius * 0.28;

    final starPath = Path();
    for (int i = 0; i < 4; i++) {
      final double outerAngle = i * (math.pi / 2) - (math.pi / 2);
      final double innerAngle = outerAngle + (math.pi / 4);

      final ox = center.dx + starRadius * math.cos(outerAngle);
      final oy = center.dy - (radius * 0.04) + starRadius * math.sin(outerAngle);

      final ix = center.dx + innerRadius * math.cos(innerAngle);
      final iy = center.dy - (radius * 0.04) + innerRadius * math.sin(innerAngle);

      if (i == 0) {
        starPath.moveTo(ox, oy);
      } else {
        starPath.lineTo(ox, oy);
      }
      starPath.lineTo(ix, iy);
    }
    starPath.close();

    // Subtle drop shadow for engraved depth
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDarkMode ? 0.6 : 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawPath(starPath.shift(const Offset(1.0, 1.2)), shadowPaint);

    // Main spark fill
    final sparkPaint = Paint()
      ..color = brandColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(starPath, sparkPaint);

    // Bronze focal center pip
    final bronzePipPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx, center.dy - (radius * 0.04)),
      radius * 0.075,
      bronzePipPaint,
    );

    // Micro text label "HEADS"
    _drawMicroLabel(canvas, 'HEADS', Offset(center.dx, center.dy + radius * 0.48), radius * 0.125);
  }

  void _drawTailsBranding(Canvas canvas, Offset center, double radius) {
    final monogramHeight = radius * 0.60;
    final monogramWidth = radius * 0.44;
    final topLeft = Offset(
      center.dx - monogramWidth / 2,
      center.dy - (radius * 0.08) - monogramHeight / 2,
    );

    // Elegant geometric "P" monogram
    final path = Path();
    final stemWidth = radius * 0.10;
    final loopRadius = monogramWidth - stemWidth;

    // Vertical stem
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(topLeft.dx, topLeft.dy, stemWidth, monogramHeight),
      Radius.circular(stemWidth * 0.4),
    ));

    // Upper semi-circle loop
    final loopRect = Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      monogramWidth,
      monogramHeight * 0.58,
    );
    final loopRRect = RRect.fromRectAndRadius(loopRect, Radius.circular(loopRadius * 0.7));
    final innerLoopRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        topLeft.dx + stemWidth,
        topLeft.dy + stemWidth * 0.7,
        monogramWidth - stemWidth * 1.5,
        (monogramHeight * 0.58) - stemWidth * 1.4,
      ),
      Radius.circular(loopRadius * 0.35),
    );

    final loopPath = Path()
      ..addRRect(loopRRect)
      ..addRRect(innerLoopRRect)
      ..fillType = PathFillType.evenOdd;

    path.addPath(loopPath, Offset.zero);

    // Shadow for tactile depth
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDarkMode ? 0.6 : 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path.shift(const Offset(1.0, 1.2)), shadowPaint);

    // Monogram body fill
    final monogramPaint = Paint()
      ..color = brandColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, monogramPaint);

    // Micro decorative bronze diamond point inside the loop
    final bronzeSparkPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(topLeft.dx + stemWidth + loopRadius * 0.45, topLeft.dy + monogramHeight * 0.29),
      radius * 0.05,
      bronzeSparkPaint,
    );

    // Micro text label "TAILS"
    _drawMicroLabel(canvas, 'TAILS', Offset(center.dx, center.dy + radius * 0.48), radius * 0.125);
  }

  void _drawMicroLabel(Canvas canvas, String text, Offset position, double fontSize) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: brandColor.withValues(alpha: 0.8),
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.5,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CoinFacePainter oldDelegate) {
    return oldDelegate.side != side ||
        oldDelegate.brandColor != brandColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.lightIntensity != lightIntensity;
  }
}
