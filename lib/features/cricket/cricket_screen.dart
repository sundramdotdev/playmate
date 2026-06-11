import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/responsive_layout.dart';
import 'cricket_provider.dart';

class CricketScreen extends ConsumerStatefulWidget {
  const CricketScreen({super.key});

  @override
  ConsumerState<CricketScreen> createState() => _CricketScreenState();
}

class _CricketScreenState extends ConsumerState<CricketScreen> {
  final TextEditingController _oversController = TextEditingController(
    text: '5',
  );
  final TextEditingController _targetController = TextEditingController();

  void _startInnings() {
    final overs = int.tryParse(_oversController.text) ?? 5;
    final target = int.tryParse(_targetController.text);
    ref.read(cricketProvider.notifier).startMatch(overs, target);
  }

  @override
  void dispose() {
    _oversController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = ref.watch(cricketProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cricket Scorer')),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: match == null
              ? _buildSetupView(theme)
              : _buildScoringView(match, theme),
        ),
      ),
    );
  }

  Widget _buildSetupView(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gully Cricket Setup', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _oversController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Number of Overs',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target Runs (Optional - leave blank for 1st Innings)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
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
              onPressed: _startInnings,
              child: const Text(
                'START INNINGS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoringView(CricketMatchState match, ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.m),
                Text(
                  match.statusMessage,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.l),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'RUNS / WICKETS',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '${match.runs} - ${match.wickets}',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.xxl),
                    Column(
                      children: [
                        Text('OVERS', style: theme.textTheme.bodyMedium),
                        Text(
                          match.formattedOvers,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (match.isInningsCompleted) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Innings Completed!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (match.target == null) ...[
                    const SizedBox(height: AppSpacing.m),
                    Builder(
                      builder: (context) {
                        final nextTarget = match.runs + 1;
                        return ElevatedButton(
                          onPressed: () {
                            ref.read(cricketProvider.notifier).reset();
                            ref
                                .read(cricketProvider.notifier)
                                .startMatch(match.maxOvers, nextTarget);
                          },
                          child: Text(
                            'Start 2nd Innings (Target: $nextTarget)',
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        if (!match.isInningsCompleted) _buildScoringControls(theme),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ref.read(cricketProvider.notifier).reset(),
                  child: const Text('RESET'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoringControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [0, 1, 2, 3, 4, 6].map((run) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(AppSpacing.m),
                  ),
                  onPressed: () =>
                      ref.read(cricketProvider.notifier).addRuns(run),
                  child: Text(
                    '$run',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                  ),
                  onPressed: () => ref.read(cricketProvider.notifier).addWicket(),
                  icon: const Icon(Icons.outbox),
                  label: const Text('WICKET'),
                ),
                ElevatedButton(
                  onPressed: () => ref
                      .read(cricketProvider.notifier)
                      .addExtra(1, false), // Wide/No-ball
                  child: const Text('WD/NB (+1)'),
                ),
                ElevatedButton(
                  onPressed: () => ref
                      .read(cricketProvider.notifier)
                      .addExtra(1, true), // Bye/Leg-bye
                  child: const Text('LEG-BYE (+1)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
