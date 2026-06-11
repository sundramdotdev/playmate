import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../shared/responsive_layout.dart';
import 'spin_wheel_provider.dart';

class SpinWheelScreen extends ConsumerStatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  ConsumerState<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends ConsumerState<SpinWheelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _animation;
  final TextEditingController _optionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.decelerate,
    );
  }

  void _spin() {
    final notifier = ref.read(spinWheelProvider.notifier);
    final wheelState = ref.read(spinWheelProvider);
    if (wheelState.isSpinning) return;
    _rotationController.forward(from: 0.0);
    notifier.spin();
  }

  void _addOption() {
    if (_optionController.text.isNotEmpty) {
      ref.read(spinWheelProvider.notifier).addOption(_optionController.text);
      _optionController.clear();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _optionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wheelState = ref.watch(spinWheelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin Wheel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(spinWheelProvider.notifier).resetOptions(),
            tooltip: 'Reset Options',
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Column(
            children: [
              Expanded(
                flex: 4,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSpacing.m),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _animation.value * 2 * pi * 4,
                                  child: Container(
                                    width: 260,
                                    height: 260,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.colorScheme.primary, width: 4),
                                    ),
                                    child: CustomPaint(
                                      painter: WheelPainter(wheelState.options, theme),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Wheel Pointer
                            Positioned(
                              top: 0,
                              child: Icon(
                                Icons.arrow_drop_down,
                                size: 48,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.l),
                        Text(
                          wheelState.isSpinning
                              ? 'Spinning...'
                              : (wheelState.selectedResult ?? 'Ready to Spin!'),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _optionController,
                              decoration: const InputDecoration(
                                hintText: 'Add custom option',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _addOption(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          IconButton.filled(
                            onPressed: _addOption,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: wheelState.options.length,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                        itemBuilder: (context, index) {
                          final option = wheelState.options[index];
                          return ListTile(
                            title: Text(option),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => ref.read(spinWheelProvider.notifier).removeOption(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _spin,
                    child: const Text('SPIN THE WHEEL', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<String> options;
  final ThemeData theme;

  WheelPainter(this.options, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Rect rect = Rect.fromCircle(center: Offset(radius, radius), radius: radius);
    final double sweepAngle = 2 * pi / options.length;

    final List<Color> colors = [
      theme.colorScheme.primary.withValues(alpha: 0.05),
      theme.colorScheme.primary.withValues(alpha: 0.15),
      theme.colorScheme.primary.withValues(alpha: 0.25),
      theme.colorScheme.primary.withValues(alpha: 0.35),
    ];

    for (int i = 0; i < options.length; i++) {
      final Paint paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, i * sweepAngle, sweepAngle, true, paint);

      // Draw text option inside sector
      final double textAngle = i * sweepAngle + sweepAngle / 2;
      canvas.save();
      canvas.translate(radius, radius);
      canvas.rotate(textAngle);

      final textSpan = TextSpan(
        text: options[i].length > 10 ? '${options[i].substring(0, 8)}..' : options[i],
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(radius * 0.4, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
