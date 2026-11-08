import 'package:flutter/material.dart';
import '../../../shared/responsive_layout.dart';

/// Reusable layout for an onboarding screen.
///
/// Features:
/// - Prominent headline with strong typographical hierarchy
/// - Refined supporting body copy with restrained contrast
/// - Proportional visual area that scales safely across all form factors
/// - Built-in overflow protection and semantic accessibility labels
class OnboardingPage extends StatelessWidget {
  final String headline;
  final String supportingText;
  final Widget visual;
  final Widget? badge;

  const OnboardingPage({
    super.key,
    required this.headline,
    required this.supportingText,
    required this.visual,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 680;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600
                ? AppSpacing.xl
                : AppSpacing.l,
            vertical: isCompact ? AppSpacing.s : AppSpacing.m,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  (constraints.maxHeight -
                          (isCompact ? AppSpacing.m : AppSpacing.l * 2))
                      .clamp(0.0, double.infinity),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (badge != null) ...[
                  badge!,
                  const SizedBox(height: AppSpacing.s),
                ],

                // Central Visual Area
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: isCompact ? AppSpacing.s : AppSpacing.m,
                    ),
                    child: visual,
                  ),
                ),

                const SizedBox(height: AppSpacing.m),

                // Text Content Area
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        fontSize: isCompact ? 22 : 26,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s + 2),
                    Text(
                      supportingText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        height: 1.45,
                        fontSize: isCompact ? 13 : 15,
                      ),
                    ),
                    SizedBox(height: isCompact ? AppSpacing.s : AppSpacing.l),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
