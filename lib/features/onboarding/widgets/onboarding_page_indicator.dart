import 'package:flutter/material.dart';

/// Accessible, animated page indicator with smooth width transitions and theme awareness.
class OnboardingPageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final ValueChanged<int>? onDotTapped;

  const OnboardingPageIndicator({
    super.key,
    required this.currentPage,
    this.pageCount = 3,
    this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: 'Page ${currentPage + 1} of $pageCount',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(pageCount, (index) {
          final bool isActive = index == currentPage;
          return GestureDetector(
            onTap: onDotTapped != null ? () => onDotTapped!(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              height: 8.0,
              width: isActive ? 26.0 : 8.0,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.white24 : Colors.black12),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          );
        }),
      ),
    );
  }
}
