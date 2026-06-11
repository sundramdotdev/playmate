import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../shared/responsive_layout.dart';
import 'coin_provider.dart';

class CoinScreen extends ConsumerStatefulWidget {
  const CoinScreen({super.key});

  @override
  ConsumerState<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends ConsumerState<CoinScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  void _tossCoin() {
    if (_animationController.isAnimating) return;
    _animationController.forward(from: 0.0);
    ref.read(coinProvider.notifier).toss();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coinState = ref.watch(coinProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Toss'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(coinProvider.notifier).clearHistory(),
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            final double value = _animation.value;
                            final double rotationValue = value * 4 * pi;
                            final double offsetValue = sin(value * pi) * -120;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..translate(0.0, offsetValue, 0.0)
                                ..rotateX(rotationValue),
                              child: _buildCoinWidget(
                                coinState.lastResult,
                                theme,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          coinState.isFlipping
                              ? 'Flipping...'
                              : (coinState.lastResult == null
                                    ? 'Flip the Coin'
                                    : coinState.lastResult!.name.toUpperCase()),
                          style: theme.textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (coinState.tossHistory.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('History', style: theme.textTheme.titleLarge),
                      Text(
                        'Total: ${coinState.tossHistory.length}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.s,
                    ),
                    itemCount: coinState.tossHistory.length,
                    itemBuilder: (context, index) {
                      final item = coinState.tossHistory[index];
                      return Container(
                        margin: const EdgeInsets.only(right: AppSpacing.s),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.primary),
                        ),
                        child: Center(
                          child: Text(
                            item == CoinSide.heads ? 'H' : 'T',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _tossCoin,
                    child: const Text(
                      'TOSS COIN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinWidget(CoinSide? side, ThemeData theme) {
    final text = side == null ? '?' : (side == CoinSide.heads ? 'H' : 'T');
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.primary, width: 4),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
