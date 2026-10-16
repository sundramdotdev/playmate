import 'package:flutter/material.dart';

/// Renders the physical fixed pointer mounted at the top frame of the Spin Wheel.
///
/// Features:
/// - Distinct physical arrowhead pointing down into the active sector
/// - Subtle deflection response as perimeter pegs pass underneath
/// - Metallic highlight, warm bronze trim, and contact drop shadow
class WheelPointer extends StatelessWidget {
  final double deflectionAngle;
  final bool isDarkMode;
  final double size;

  const WheelPointer({
    super.key,
    this.deflectionAngle = 0.0,
    this.isDarkMode = false,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: deflectionAngle,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: size,
        height: size * 1.25,
        child: CustomPaint(
          size: Size(size, size * 1.25),
          painter: _PointerPainter(isDarkMode: isDarkMode),
        ),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  final bool isDarkMode;

  const _PointerPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Arrowhead path pointing downwards
    final path = Path()
      ..moveTo(w * 0.18, 0)
      ..lineTo(w * 0.82, 0)
      ..lineTo(w * 0.82, h * 0.38)
      ..lineTo(w * 0.50, h)
      ..lineTo(w * 0.18, h * 0.38)
      ..close();

    // 1. Drop Shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDarkMode ? 0.6 : 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);

    // 2. Base metallic body
    final Color bodyColor = isDarkMode ? const Color(0xFF2E3036) : const Color(0xFFF3F0E8);
    final Paint bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bodyPaint);

    // 3. Warm bronze outer trim
    final Paint trimPaint = Paint()
      ..color = const Color(0xFFC18A42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(path, trimPaint);

    // 4. Center indicator ridge line
    final Paint ridgePaint = Paint()
      ..color = isDarkMode ? Colors.white.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(w * 0.5, 0), Offset(w * 0.5, h * 0.9), ridgePaint);

    // 5. Pivot cap stud at top
    final Paint studPaint = Paint()
      ..color = const Color(0xFFC18A42)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.16), w * 0.12, studPaint);

    final Paint studDotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5 - 0.5, h * 0.16 - 0.5), w * 0.04, studDotPaint);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) {
    return oldDelegate.isDarkMode != isDarkMode;
  }
}

