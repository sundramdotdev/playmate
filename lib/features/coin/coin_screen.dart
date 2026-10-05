import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/responsive_layout.dart';
import 'coin_provider.dart';
import 'playmate_coin.dart';

class CoinScreen extends ConsumerStatefulWidget {
  const CoinScreen({super.key});

  @override
  ConsumerState<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends ConsumerState<CoinScreen> {
  void _triggerToss() {
    final coinState = ref.read(coinProvider);
    if (coinState.isFlipping) return;
    ref.read(coinProvider.notifier).toss();
  }

  @override
  Widget build(BuildContext context) {
    final coinState = ref.watch(coinProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final currentSide = coinState.lastResult ?? CoinSide.heads;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Toss'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: coinState.isFlipping
                ? null
                : () => ref.read(coinProvider.notifier).resetCoin(),
            tooltip: 'Reset Coin',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: (coinState.tossHistory.isEmpty || coinState.isFlipping)
                ? null
                : () => ref.read(coinProvider.notifier).clearHistory(),
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Column(
            children: [
              // Main hero area with tactile 3D coin
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),

                      // Responsive Hero 3D Physical Coin (interactive press & toss)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double availableWidth = constraints.maxWidth;
                          final double coinSize = _calculateResponsiveCoinSize(availableWidth);

                          return Center(
                            child: PlayMateCoin(
                              side: currentSide,
                              size: coinSize,
                              isFlipping: coinState.isFlipping,
                              onTossRequested: _triggerToss,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Result typography
                      _buildResultSection(coinState, theme),

                      const SizedBox(height: 16),

                      // Statistics Summary (Heads / Tails / Total)
                      if (coinState.tossHistory.isNotEmpty) ...[
                        _buildStatsSummary(coinState, theme, isDarkMode),
                        const SizedBox(height: 14),
                        // Compact recent toss history
                        _buildRecentHistorySection(coinState, theme, isDarkMode),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom toss action button
              _buildBottomControls(coinState, theme),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateResponsiveCoinSize(double availableWidth) {
    if (availableWidth <= 330) {
      return 130.0;
    } else if (availableWidth <= 440) {
      return 155.0;
    } else if (availableWidth <= 600) {
      return 175.0;
    } else {
      return 210.0;
    }
  }

  Widget _buildResultSection(CoinState coinState, ThemeData theme) {
    if (coinState.isFlipping) {
      return Column(
        children: [
          Text(
            'Flipping...',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tossing in the air',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      );
    }

    final sideName = coinState.lastResult?.displayName ?? 'HEADS';

    return Semantics(
      label: 'Coin result: $sideName',
      child: Column(
        children: [
          Text(
            sideName,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toss Result',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.secondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap coin or button to toss',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(CoinState coinState, ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatPill('HEADS', '${coinState.headsCount}', theme),
          Container(
            height: 16,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: theme.dividerColor,
          ),
          _buildStatPill('TAILS', '${coinState.tailsCount}', theme),
          Container(
            height: 16,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: theme.dividerColor,
          ),
          _buildStatPill('TOTAL', '${coinState.totalTosses}', theme),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentHistorySection(
    CoinState coinState,
    ThemeData theme,
    bool isDarkMode,
  ) {
    final recent = coinState.tossHistory.take(12).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 15,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Recent Tosses',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: recent.asMap().entries.map((entry) {
              final index = entry.key;
              final side = entry.value;
              final isLatest = index == 0;

              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isLatest
                        ? (isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFEBEBEB))
                        : (isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isLatest
                          ? const Color(0xFFC18A42).withValues(alpha: 0.4)
                          : (isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0)),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: side == CoinSide.heads
                              ? const Color(0xFFC18A42)
                              : (isDarkMode ? Colors.white60 : Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        side == CoinSide.heads ? 'H' : 'T',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isLatest ? FontWeight.bold : FontWeight.w600,
                          color: isLatest
                              ? (isDarkMode ? Colors.white : const Color(0xFF1A1A1A))
                              : theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(CoinState coinState, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: coinState.isFlipping ? null : _triggerToss,
            child: coinState.isFlipping
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white70,
                    ),
                  )
                : const Text(
                    'TOSS COIN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
