import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/responsive_layout.dart';
import 'timer_provider.dart';
import 'timer_state.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  final TextEditingController _minutesController = TextEditingController(text: '5');

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _applyCustomDuration() {
    final mins = int.tryParse(_minutesController.text) ?? 5;
    final duration = Duration(minutes: mins);
    final currentMode = ref.read(timerProvider).mode;
    if (currentMode == TimerMode.chess) {
      ref.read(timerProvider.notifier).configureChess(duration);
    } else {
      ref.read(timerProvider.notifier).configureCountdown(duration);
    }
  }

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timers'),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Column(
            children: [
              _buildModeSelector(timerState, theme),
              if (timerState.mode == TimerMode.countdown || timerState.mode == TimerMode.chess)
                _buildConfigurationPanel(theme),
              Expanded(
                child: Center(
                  child: timerState.mode == TimerMode.chess
                      ? _buildChessTimerView(timerState, theme)
                      : _buildStandardTimerView(timerState, theme),
                ),
              ),
              if (timerState.mode != TimerMode.chess) _buildStandardControls(timerState, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector(TimerState timerState, ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: TimerMode.values.map((mode) {
          final isSelected = timerState.mode == mode;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s),
            child: ChoiceChip(
              label: Text(mode.name.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(timerProvider.notifier).setMode(mode);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConfigurationPanel(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (Minutes)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          ElevatedButton(
            onPressed: _applyCustomDuration,
            child: const Text('APPLY'),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardTimerView(TimerState timerState, ThemeData theme) {
    final displayTime = timerState.mode == TimerMode.stopwatch
        ? _formatDuration(timerState.elapsed)
        : _formatDuration(timerState.remaining);

    return Text(
      displayTime,
      style: theme.textTheme.headlineLarge?.copyWith(
        fontSize: 80,
        fontWeight: FontWeight.w900,
        fontFamily: 'monospace',
      ),
    );
  }

  Widget _buildChessTimerView(TimerState timerState, ThemeData theme) {
    return Column(
      children: [
        // Player B (Top) - Rotated for face to face play
        Expanded(
          child: RotatedBox(
            quarterTurns: 2,
            child: InkWell(
              onTap: !timerState.isPlayerATurn && timerState.isRunning
                  ? () => ref.read(timerProvider.notifier).switchChessTurn()
                  : null,
              child: Container(
                color: !timerState.isPlayerATurn 
                    ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                    : Colors.transparent,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('PLAYER B', style: theme.textTheme.titleLarge),
                      Text(
                        _formatDuration(timerState.chessPlayerBRemaining),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (!timerState.isPlayerATurn && timerState.isRunning)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text('TAP TO END TURN', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 60,
          color: theme.colorScheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(timerState.isRunning ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  if (timerState.isRunning) {
                    ref.read(timerProvider.notifier).stop();
                  } else {
                    ref.read(timerProvider.notifier).start();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.read(timerProvider.notifier).reset(),
              ),
            ],
          ),
        ),
        // Player A (Bottom)
        Expanded(
          child: InkWell(
            onTap: timerState.isPlayerATurn && timerState.isRunning
                ? () => ref.read(timerProvider.notifier).switchChessTurn()
                : null,
            child: Container(
              color: timerState.isPlayerATurn 
                  ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                  : Colors.transparent,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('PLAYER A', style: theme.textTheme.titleLarge),
                    Text(
                      _formatDuration(timerState.chessPlayerARemaining),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: 60,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (timerState.isPlayerATurn && timerState.isRunning)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('TAP TO END TURN', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardControls(TimerState timerState, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => ref.read(timerProvider.notifier).reset(),
              child: const Text('RESET'),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: () {
                if (timerState.isRunning) {
                  ref.read(timerProvider.notifier).stop();
                } else {
                  ref.read(timerProvider.notifier).start();
                }
              },
              child: Text(timerState.isRunning ? 'PAUSE' : 'START'),
            ),
          ),
        ],
      ),
    );
  }
}
