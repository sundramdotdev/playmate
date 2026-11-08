import 'package:flutter/material.dart';
import '../../../shared/responsive_layout.dart';
import '../../coin/coin_face.dart';
import '../../coin/coin_orientation.dart';
import '../../dice/dice_face.dart';

/// Screen 2 visual composition showcasing PlayMate's essential game-night toolkit.
///
/// Highlights four representative tools in a tactile focal cluster with
/// surrounding pill labels representing the full collection.
class EssentialsOnboardingVisual extends StatefulWidget {
  final double size;

  const EssentialsOnboardingVisual({super.key, this.size = 230.0});

  @override
  State<EssentialsOnboardingVisual> createState() =>
      _EssentialsOnboardingVisualState();
}

class _EssentialsOnboardingVisualState extends State<EssentialsOnboardingVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final diceStyle = DiceStyle.fromBrightness(theme.brightness);

    final content = SizedBox(
      width: widget.size * 1.15,
      height: widget.size,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Central Tactile Toolkit Cluster
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2E2E2E)
                          : const Color(0xFFE2E2E2),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.35 : 0.08,
                        ),
                        blurRadius: 16.0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dice preview
                      _ToolClusterItem(
                        label: 'Dice',
                        child: DiceFace(
                          value: 6,
                          size: 42,
                          style: diceStyle,
                          lightIntensity: 1.0,
                          isDarkMode: isDark,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),

                      // Coin preview
                      const _ToolClusterItem(
                        label: 'Coin',
                        child: CoinFace(
                          side: CoinSide.heads,
                          size: 42,
                          lightIntensity: 1.0,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),

                      // Spin Wheel preview
                      _ToolClusterItem(
                        label: 'Wheel',
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? const Color(0xFF262626)
                                : const Color(0xFFEFEFEF),
                            border: Border.all(
                              color: const Color(0xFFC18A42),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.track_changes,
                            size: 24,
                            color: Color(0xFFC18A42),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),

                      // Timers preview
                      _ToolClusterItem(
                        label: 'Timers',
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                          ),
                          child: Icon(
                            Icons.timer_outlined,
                            size: 24,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.m),

                // Secondary Tools Capsule Badges
                Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.xs + 2,
                  alignment: WrapAlignment.center,
                  children: const [
                    _FeaturePill(
                      icon: Icons.groups_outlined,
                      label: 'Team Gen',
                    ),
                    _FeaturePill(
                      icon: Icons.scoreboard_outlined,
                      label: 'Score Tracker',
                    ),
                    _FeaturePill(
                      icon: Icons.sports_cricket_outlined,
                      label: 'Cricket Scorer',
                    ),
                    _FeaturePill(
                      icon: Icons.emoji_events_outlined,
                      label: 'Tournament',
                    ),
                    _FeaturePill(icon: Icons.timer, label: 'Chess Clock'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (reduceMotion) {
      return Semantics(
        label: 'PlayMate essentials toolkit preview',
        child: content,
      );
    }

    return Semantics(
      label: 'PlayMate essentials toolkit preview',
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(scale: _scaleAnimation, child: content),
      ),
    );
  }
}

class _ToolClusterItem extends StatelessWidget {
  final Widget child;
  final String label;

  const _ToolClusterItem({required this.child, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }
}
