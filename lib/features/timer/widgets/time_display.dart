import 'package:flutter/material.dart';

/// Primary digital/tactile time display using tabular monospace figures to prevent layout jitter.
class TimeDisplay extends StatelessWidget {
  final String formattedTime;
  final String? subtitle;
  final double fontSize;
  final Color? color;
  final bool isFlagged;

  const TimeDisplay({
    super.key,
    required this.formattedTime,
    this.subtitle,
    this.fontSize = 72.0,
    this.color,
    this.isFlagged = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayColor = isFlagged
        ? Colors.redAccent
        : (color ?? theme.colorScheme.onSurface);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formattedTime,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              letterSpacing: -1.5,
              color: displayColor,
              fontFeatures: const [
                FontFeature.tabularFigures(),
              ],
            ),
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}

