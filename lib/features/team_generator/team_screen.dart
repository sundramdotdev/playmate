import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/responsive_layout.dart';
import 'team_provider.dart';

class TeamGeneratorScreen extends ConsumerStatefulWidget {
  const TeamGeneratorScreen({super.key});

  @override
  ConsumerState<TeamGeneratorScreen> createState() => _TeamGeneratorScreenState();
}

class _TeamGeneratorScreenState extends ConsumerState<TeamGeneratorScreen> {
  final TextEditingController _playerController = TextEditingController();

  void _addPlayer() {
    if (_playerController.text.isNotEmpty) {
      ref.read(teamProvider.notifier).addPlayer(_playerController.text);
      _playerController.clear();
    }
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => ref.read(teamProvider.notifier).clearAll(),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _playerController,
                        decoration: const InputDecoration(
                          hintText: 'Enter player name',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addPlayer(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    IconButton.filled(
                      onPressed: _addPlayer,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: teamState.generatedTeams.isNotEmpty
                    ? _buildTeamsResult(teamState.generatedTeams, theme)
                    : _buildPlayersList(teamState.players, theme),
              ),
              _buildConfigPanel(teamState, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersList(List<String> players, ThemeData theme) {
    if (players.isEmpty) {
      return Center(
        child: Text(
          'No players added yet.\nAdd players to get started!',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Text('Players (${players.length})', style: theme.textTheme.titleLarge),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            padding: const EdgeInsets.all(AppSpacing.m),
            itemBuilder: (context, index) {
              final player = players[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.s),
                child: ListTile(
                  title: Text(player),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => ref.read(teamProvider.notifier).removePlayer(player),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeamsResult(List<List<String>> teams, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Generated Teams', style: theme.textTheme.titleLarge),
              TextButton(
                onPressed: () => ref.read(teamProvider.notifier).generateTeams(),
                child: const Text('Shuffle Again'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: teams.length,
            padding: const EdgeInsets.all(AppSpacing.m),
            itemBuilder: (context, index) {
              final team = teams[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.m),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team ${index + 1}',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      ...team.map((player) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                            child: Text(player, style: theme.textTheme.bodyLarge),
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfigPanel(TeamGeneratorState teamState, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Number of Teams', style: theme.textTheme.bodyLarge),
              DropdownButton<int>(
                value: teamState.numberOfTeams,
                items: [2, 3, 4].map((e) {
                  return DropdownMenuItem<int>(
                    value: e,
                    child: Text('$e Teams'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref.read(teamProvider.notifier).setNumberOfTeams(val);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: teamState.players.length >= teamState.numberOfTeams
                  ? () => ref.read(teamProvider.notifier).generateTeams()
                  : null,
              child: const Text('GENERATE TEAMS', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
