import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/responsive_layout.dart';
import 'score_provider.dart';

class ScoreTrackerScreen extends ConsumerStatefulWidget {
  const ScoreTrackerScreen({super.key});

  @override
  ConsumerState<ScoreTrackerScreen> createState() => _ScoreTrackerScreenState();
}

class _ScoreTrackerScreenState extends ConsumerState<ScoreTrackerScreen> {
  final TextEditingController _matchNameController = TextEditingController();
  final TextEditingController _teamAController = TextEditingController();
  final TextEditingController _teamBController = TextEditingController();

  void _startMatch() {
    ref.read(scoreTrackerProvider.notifier).startNewMatch(
          _matchNameController.text,
          _teamAController.text,
          _teamBController.text,
        );
  }

  @override
  void dispose() {
    _matchNameController.dispose();
    _teamAController.dispose();
    _teamBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = ref.watch(scoreTrackerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Tracker'),
        actions: match != null
            ? [
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: match.scoreHistory.isNotEmpty
                      ? () => ref.read(scoreTrackerProvider.notifier).undoLastAction()
                      : null,
                  tooltip: 'Undo Last Score',
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: match == null
              ? _buildSetupView(theme)
              : _buildLiveTrackerView(match, theme),
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
          Text('Create New Match', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _matchNameController,
            decoration: const InputDecoration(
              labelText: 'Match Name (e.g. Ping Pong)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _teamAController,
            decoration: const InputDecoration(
              labelText: 'Player / Team A',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _teamBController,
            decoration: const InputDecoration(
              labelText: 'Player / Team B',
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _startMatch,
              child: const Text('START MATCH', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTrackerView(MatchScore match, ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
          child: Text(
            match.matchName,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              // Team A Section
              Expanded(
                child: _buildTeamScoreButton(
                  name: match.teamAName,
                  score: match.teamAScore,
                  onTap: () => ref.read(scoreTrackerProvider.notifier).incrementScore(true),
                  onLongPress: () => ref.read(scoreTrackerProvider.notifier).decrementScore(true),
                  theme: theme,
                  isTeamA: true,
                ),
              ),
              const VerticalDivider(width: 1),
              // Team B Section
              Expanded(
                child: _buildTeamScoreButton(
                  name: match.teamBName,
                  score: match.teamBScore,
                  onTap: () => ref.read(scoreTrackerProvider.notifier).incrementScore(false),
                  onLongPress: () => ref.read(scoreTrackerProvider.notifier).decrementScore(false),
                  theme: theme,
                  isTeamA: false,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ref.read(scoreTrackerProvider.notifier).reset(),
                  child: const Text('CANCEL'),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  onPressed: () async {
                    await ref.read(scoreTrackerProvider.notifier).endAndSaveMatch();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Match saved successfully!')),
                    );
                    ref.read(scoreTrackerProvider.notifier).reset();
                  },
                  child: const Text('END MATCH'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamScoreButton({
    required String name,
    required int score,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
    required ThemeData theme,
    required bool isTeamA,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              '$score',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 80,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Tap to add  •  Hold to subtract',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
