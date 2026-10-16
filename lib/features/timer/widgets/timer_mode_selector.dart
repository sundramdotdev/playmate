import 'package:flutter/material.dart';
import '../../../shared/responsive_layout.dart';
import '../domain/timer_models.dart';

/// Segmented responsive control for selecting between the 5 timer modes.
class TimerModeSelector extends StatelessWidget {
  final TimerMode selectedMode;
  final ValueChanged<TimerMode> onModeChanged;

  const TimerModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TimerMode.values.map((mode) {
          final isSelected = selectedMode == mode;
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                mode.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.black : Colors.white)
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
              selectedColor: isDark ? const Color(0xFFC18A42) : const Color(0xFF1A1A1A),
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF0F0F0),
              showCheckmark: false,
              side: BorderSide(
                color: isSelected
                    ? (isDark ? const Color(0xFFC18A42) : const Color(0xFF1A1A1A))
                    : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0)),
                width: 1.0,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              onSelected: (_) => onModeChanged(mode),
            ),
          );
        }).toList(),
      ),
    );
  }
}
