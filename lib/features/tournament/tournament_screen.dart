import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/responsive_layout.dart';
import 'tournament_provider.dart';

class TournamentScreen extends ConsumerStatefulWidget {
  const TournamentScreen({super.key});

  @override
  ConsumerState<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends ConsumerState<TournamentScreen> {
  final TextEditingController _teamController = TextEditingController();

  void _addTeam() {
    if (_teamController.text.isNotEmpty) {
      ref.read(tournamentProvider.notifier).addTeam(_teamController.text);
      _teamController.clear();
    }
  }

  @override
  void dispose() {
    _teamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tourState = ref.watch(tournamentProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(tournamentProvider.notifier).reset(),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: tourState.isGenerated
              ? _buildBracketView(tourState, theme)
              : _buildSetupView(tourState, theme),
        ),
      ),
    );
  }

  Widget _buildSetupView(TournamentState tourState, ThemeData theme) {
    final allowedCounts = [4, 8, 16, 32];
    final remaining = allowedCounts.contains(tourState.teams.length)
        ? 0
        : allowedCounts.firstWhere((e) => e > tourState.teams.length, orElse: () => 32) - tourState.teams.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _teamController,
                  decoration: const InputDecoration(
                    hintText: 'Enter Team / Player Name',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addTeam(),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              IconButton.filled(
                onPressed: _addTeam,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        if (remaining > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Text(
              'Add $remaining more team(s) to hit the next valid bracket (4, 8, 16, or 32)',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: tourState.teams.length,
            padding: const EdgeInsets.all(AppSpacing.m),
            itemBuilder: (context, index) {
              final team = tourState.teams[index];
              return ListTile(
                title: Text(team),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => ref.read(tournamentProvider.notifier).removeTeam(team),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: remaining == 0 && tourState.teams.isNotEmpty
                  ? () => ref.read(tournamentProvider.notifier).generateBrackets()
                  : null,
              child: const Text('GENERATE BRACKET', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBracketView(TournamentState tourState, ThemeData theme) {
    if (tourState.champion != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
              const SizedBox(height: AppSpacing.m),
              Text('CHAMPION!', style: theme.textTheme.headlineMedium),
              Text(
                tourState.champion!,
                style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.l),
              ElevatedButton(
                onPressed: () => ref.read(tournamentProvider.notifier).reset(),
                child: const Text('Start New Tournament'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: tourState.rounds.length,
      padding: const EdgeInsets.all(AppSpacing.m),
      itemBuilder: (context, roundIndex) {
        final round = tourState.rounds[roundIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              child: Text(
                'Round ${roundIndex + 1}',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ...List.generate(round.matches.length, (matchIndex) {
              final match = round.matches[matchIndex];
              final winner = round.winners[matchIndex];
              final teams = match.split(' vs ');
              final teamA = teams[0];
              final teamB = teams.length > 1 ? teams[1] : 'TBD';

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.s),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTeamAdvanceRow(teamA, winner, roundIndex, matchIndex, theme),
                          const SizedBox(height: AppSpacing.s),
                          _buildTeamAdvanceRow(teamB, winner, roundIndex, matchIndex, theme),
                        ],
                      ),
                      if (winner.isEmpty && teamA != 'TBD' && teamB != 'TBD')
                        Text(
                          'Select winner',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
                        )
                    ],
                  ),
                ),
              );
            }),
            const Divider(height: AppSpacing.l),
          ],
        );
      },
    );
  }

  Widget _buildTeamAdvanceRow(
    String team,
    String winner,
    int roundIndex,
    int matchIndex,
    ThemeData theme,
  ) {
    final isWinner = winner == team;
    final isClickable = team != 'TBD' && winner.isEmpty;

    return InkWell(
      onTap: isClickable
          ? () => ref.read(tournamentProvider.notifier).advanceWinner(roundIndex, matchIndex, team)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              isWinner ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: isWinner ? Colors.green : theme.colorScheme.secondary,
            ),
            const SizedBox(width: AppSpacing.s),
            Text(
              team,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                decoration: winner.isNotEmpty && !isWinner ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
