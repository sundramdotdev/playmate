import 'package:flutter/material.dart';
import '../domain/timer_models.dart';

/// Renders recorded stopwatch laps in a compact, readable table.
class LapList extends StatelessWidget {
  final List<StopwatchLap> laps;

  const LapList({
    super.key,
    required this.laps,
  });

  String _formatLapTime(Duration d) {
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    final centis = ((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$centis';
  }

  @override
  Widget build(BuildContext context) {
    if (laps.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Find fastest and slowest if 2 or more laps exist
    int? fastestLapIndex;
    int? slowestLapIndex;

    if (laps.length >= 2) {
      Duration minSplit = laps.first.splitTime;
      Duration maxSplit = laps.first.splitTime;
      fastestLapIndex = 0;
      slowestLapIndex = 0;

      for (int i = 0; i < laps.length; i++) {
        if (laps[i].splitTime < minSplit) {
          minSplit = laps[i].splitTime;
          fastestLapIndex = i;
        }
        if (laps[i].splitTime > maxSplit) {
          maxSplit = laps[i].splitTime;
          slowestLapIndex = i;
        }
      }
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LAP',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'SPLIT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'TOTAL',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: laps.length,
              itemBuilder: (context, index) {
                final lap = laps[index];
                final isFastest = fastestLapIndex == index;
                final isSlowest = slowestLapIndex == index;

                Color? splitColor;
                if (isFastest) splitColor = Colors.greenAccent.shade400;
                if (isSlowest) splitColor = Colors.orangeAccent.shade400;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lap ${lap.lapNumber.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        _formatLapTime(lap.splitTime),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: splitColor,
                        ),
                      ),
                      Text(
                        _formatLapTime(lap.totalTime),
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
