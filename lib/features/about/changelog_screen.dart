import 'package:flutter/material.dart';
import '../../shared/responsive_layout.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final releases = [
      {
        'version': 'v1.0.0',
        'date': 'October 2026',
        'isLatest': true,
        'highlights': [
          'Full suite of 8 offline gaming tools.',
          'Polyhedral Dice Roller (D4, D6, D8, D10, D12, D20) with shake-to-roll physics.',
          '3D Coin Toss with multi-coin flipping and streak tracking.',
          'Smart Team Generator with random and skill-balanced modes.',
          'Universal Score Tracker with round-by-round history and undo.',
          'Gully & Club Cricket Scorer with legal delivery counting and run rate.',
          'Custom Spin Wheel with angular velocity physics and elimination mode.',
          'Tournament Generator for 4 to 32 team elimination brackets.',
          'Game Timers: Countdown, Stopwatch, Chess Clock with increments, Turn Timer.',
          'Material 3 Dark and Light modes with local Hive persistence.',
        ],
      },
      {
        'version': 'v0.5.0',
        'date': 'August 2026',
        'isLatest': false,
        'highlights': [
          'Introduced Gully Cricket Scorer prototype.',
          'Added Chess Clock mode with increment support.',
          'Tactile haptic feedback and audio synthesis integration.',
          'Persistent local storage via Hive database.',
        ],
      },
      {
        'version': 'v0.2.0',
        'date': 'June 2026',
        'isLatest': false,
        'highlights': [
          'Initial Team Generator with random assignment.',
          'Multiplayer Score Tracker.',
          'Countdown and Stopwatch timers.',
          'Light and Dark theme foundation.',
        ],
      },
      {
        'version': 'v0.1.0',
        'date': 'April 2026',
        'isLatest': false,
        'highlights': [
          'Initial prototype of Dice Roller and Coin Toss.',
          'Accelerometer shake detection proof-of-concept.',
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('What\'s New'),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.m),
            itemCount: releases.length,
            itemBuilder: (context, index) {
              final release = releases[index];
              final isLatest = release['isLatest'] as bool;
              final highlights = release['highlights'] as List<String>;

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.m),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                release['version'] as String,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isLatest) ...[
                                const SizedBox(width: AppSpacing.s),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'LATEST',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            release['date'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: AppSpacing.l),
                      ...highlights.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
