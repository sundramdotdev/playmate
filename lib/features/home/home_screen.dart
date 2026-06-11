import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/responsive_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tools = [
      {
        'icon': Icons.casino,
        'title': 'Dice Roller',
        'desc': 'Roll multiple dice with shake detection.',
        'route': '/dice',
      },
      {
        'icon': Icons.monetization_on,
        'title': 'Coin Toss',
        'desc': 'Flip virtual coins for heads or tails.',
        'route': '/coin',
      },
      {
        'icon': Icons.groups,
        'title': 'Team Generator',
        'desc': 'Instantly balance and create teams.',
        'route': '/teams',
      },
      {
        'icon': Icons.scoreboard,
        'title': 'Score Tracker',
        'desc': 'Track score updates and match status.',
        'route': '/scores',
      },
      {
        'icon': Icons.sports_cricket,
        'title': 'Cricket Scorer',
        'desc': 'Quick score scoring for gully matches.',
        'route': '/cricket',
      },
      {
        'icon': Icons.track_changes,
        'title': 'Spin Wheel',
        'desc': 'Spin to pick options or pick a winner.',
        'route': '/spin',
      },
      {
        'icon': Icons.emoji_events,
        'title': 'Tournament Gen',
        'desc': 'Generate brackets for 4 to 32 players.',
        'route': '/tournament',
      },
      {
        'icon': Icons.timer,
        'title': 'Timers',
        'desc': 'Countdown, Stopwatch, Chess, Turn.',
        'route': '/timers',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('PLAYMATE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.m),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.m,
              mainAxisSpacing: AppSpacing.m,
              childAspectRatio: 1.0,
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final tool = tools[index];
              return Card(
                child: InkWell(
                  onTap: () => context.push(tool['route'] as String),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          tool['icon'] as IconData,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          tool['title'] as String,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          tool['desc'] as String,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
