import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/responsive_layout.dart';
import 'domain/time_formatter.dart';
import 'timer_provider.dart';
import 'timer_state.dart';
import 'widgets/lap_list.dart';
import 'widgets/time_display.dart';
import 'widgets/timer_controls.dart';
import 'widgets/timer_mode_selector.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  // Custom duration controllers
  final TextEditingController _customMinutesController = TextEditingController(text: '5');
  final TextEditingController _customSecondsController = TextEditingController(text: '0');

  // Round timer controllers
  final TextEditingController _workMinController = TextEditingController(text: '3');
  final TextEditingController _restSecController = TextEditingController(text: '30');
  final TextEditingController _roundsController = TextEditingController(text: '3');

  // Player name controller for turn timer
  final TextEditingController _newPlayerController = TextEditingController();

  @override
  void dispose() {
    _customMinutesController.dispose();
    _customSecondsController.dispose();
    _workMinController.dispose();
    _restSecController.dispose();
    _roundsController.dispose();
    _newPlayerController.dispose();
    super.dispose();
  }

  // ==========================================
  // BOTTOM SHEETS & DIALOGS
  // ==========================================

  void _showCountdownPresetsSheet(BuildContext context) {
    final notifier = ref.read(timerProvider.notifier);
    final presets = [
      const Duration(seconds: 30),
      const Duration(minutes: 1),
      const Duration(minutes: 2),
      const Duration(minutes: 3),
      const Duration(minutes: 5),
      const Duration(minutes: 10),
      const Duration(minutes: 15),
      const Duration(minutes: 30),
      const Duration(hours: 1),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Countdown Presets',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presets.map((duration) {
                    final label = duration.inMinutes == 0
                        ? '${duration.inSeconds}s'
                        : duration.inHours == 0
                            ? '${duration.inMinutes}m'
                            : '${duration.inHours}h';
                    return ActionChip(
                      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        notifier.configureCountdown(duration);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Custom Duration',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customMinutesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _customSecondsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Seconds',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        final mins = int.tryParse(_customMinutesController.text) ?? 0;
                        final secs = int.tryParse(_customSecondsController.text) ?? 0;
                        final total = Duration(minutes: mins, seconds: secs);
                        if (total > Duration.zero) {
                          notifier.configureCountdown(total);
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('SET'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChessPresetsSheet(BuildContext context) {
    final notifier = ref.read(timerProvider.notifier);
    final activeId = ref.read(timerProvider).activePresetId;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chess Time Controls',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ...ChessTimeControlPreset.presets.map((preset) {
                  final isSelected = activeId == preset.id;
                  final incText = preset.increment > Duration.zero
                      ? ' (+${preset.increment.inSeconds}s inc)'
                      : '';
                  return ListTile(
                    title: Text(
                      preset.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFFC18A42) : null,
                      ),
                    ),
                    subtitle: Text('${preset.baseTime.inMinutes} mins$incText'),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFFC18A42))
                        : null,
                    onTap: () {
                      notifier.applyChessPreset(preset);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTurnPlayersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final timerState = ref.watch(timerProvider);
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              builder: (_, scrollController) {
                return SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Players (${timerState.turnPlayers.length})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newPlayerController,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  hintText: 'Add player name',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onSubmitted: (val) {
                                  if (val.trim().isNotEmpty) {
                                    ref.read(timerProvider.notifier).addTurnPlayer(val);
                                    _newPlayerController.clear();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () {
                                if (_newPlayerController.text.trim().isNotEmpty) {
                                  ref
                                      .read(timerProvider.notifier)
                                      .addTurnPlayer(_newPlayerController.text);
                                  _newPlayerController.clear();
                                }
                              },
                              child: const Text('ADD'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: timerState.turnPlayers.length,
                          itemBuilder: (context, index) {
                            final player = timerState.turnPlayers[index];
                            final canDelete = timerState.turnPlayers.length > 2;

                            return ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFFC18A42).withValues(alpha: 0.2),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC18A42),
                                  ),
                                ),
                              ),
                              title: Text(player.name),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: canDelete ? Colors.red.shade400 : Colors.grey,
                                ),
                                onPressed: canDelete
                                    ? () => ref.read(timerProvider.notifier).removeTurnPlayer(index)
                                    : null,
                                tooltip: canDelete ? 'Remove player' : 'Minimum 2 players required',
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showRoundConfigSheet(BuildContext context) {
    final notifier = ref.read(timerProvider.notifier);
    final currentConfig = ref.read(timerProvider).roundConfig;

    _workMinController.text = (currentConfig.workDuration.inMinutes).toString();
    _restSecController.text = (currentConfig.restDuration.inSeconds).toString();
    _roundsController.text = currentConfig.totalRounds.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Configure Round Timer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _workMinController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Work (Mins)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _restSecController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Rest (Secs)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _roundsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Rounds',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final workMins = int.tryParse(_workMinController.text) ?? 3;
                      final restSecs = int.tryParse(_restSecController.text) ?? 30;
                      final rounds = int.tryParse(_roundsController.text) ?? 3;

                      notifier.configureRoundTimer(RoundTimerConfig(
                        workDuration: Duration(minutes: workMins),
                        restDuration: Duration(seconds: restSecs),
                        totalRounds: rounds,
                      ));
                      Navigator.pop(ctx);
                    },
                    child: const Text('APPLY SETTINGS'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // MAIN BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timers'),
        actions: [
          if (timerState.mode == TimerMode.countdown)
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: timerState.isRunning ? null : () => _showCountdownPresetsSheet(context),
              tooltip: 'Presets & Duration',
            ),
          if (timerState.mode == TimerMode.timer)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: timerState.isRunning ? null : () => _showRoundConfigSheet(context),
              tooltip: 'Round Settings',
            ),
          if (timerState.mode == TimerMode.turn)
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: timerState.isRunning ? null : () => _showTurnPlayersSheet(context),
              tooltip: 'Manage Players',
            ),
          if (timerState.mode == TimerMode.chess)
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: timerState.isRunning ? null : () => _showChessPresetsSheet(context),
              tooltip: 'Time Controls',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(timerProvider.notifier).reset(),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Column(
            children: [
              // 1. Top Mode Selector Chip Row
              TimerModeSelector(
                selectedMode: timerState.mode,
                onModeChanged: (mode) => ref.read(timerProvider.notifier).setMode(mode),
              ),

              // 2. Mode Content Body
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                    child: _buildActiveModeContent(timerState, theme, isDark),
                  ),
                ),
              ),

              // 3. Bottom Controls (Start/Pause, Reset, and Mode Actions)
              if (timerState.mode != TimerMode.chess)
                _buildModeControls(timerState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveModeContent(TimerState timerState, ThemeData theme, bool isDark) {
    switch (timerState.mode) {
      case TimerMode.countdown:
        return _buildCountdownView(timerState, theme);
      case TimerMode.timer:
        return _buildRoundTimerView(timerState, theme, isDark);
      case TimerMode.stopwatch:
        return _buildStopwatchView(timerState, theme);
      case TimerMode.turn:
        return _buildTurnTimerView(timerState, theme, isDark);
      case TimerMode.chess:
        return _buildChessClockView(timerState, theme, isDark);
    }
  }

  // ==========================================
  // MODE VIEWS
  // ==========================================

  Widget _buildCountdownView(TimerState timerState, ThemeData theme) {
    final formatted = TimeFormatter.formatMmSs(timerState.countdownRemaining);
    final subtitle = timerState.countdownFinished
        ? 'COMPLETED!'
        : timerState.isRunning
            ? 'Counting down'
            : 'Paused / Ready';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TimeDisplay(
          formattedTime: formatted,
          subtitle: subtitle,
          fontSize: 84,
          isFlagged: timerState.countdownFinished,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: timerState.isRunning ? null : () => _showCountdownPresetsSheet(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFC18A42).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Color(0xFFC18A42)),
                const SizedBox(width: 6),
                Text(
                  'Initial: ${TimeFormatter.formatMmSs(timerState.countdownInitial)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFFC18A42)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoundTimerView(TimerState timerState, ThemeData theme, bool isDark) {
    final formatted = TimeFormatter.formatMmSs(timerState.roundRemaining);
    final isWork = timerState.intervalPhase == IntervalPhase.work;
    final isDone = timerState.roundFinished;

    final badgeColor = isDone
        ? Colors.grey
        : isWork
            ? (isDark ? const Color(0xFFC18A42) : const Color(0xFF1A1A1A))
            : Colors.blueAccent;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: badgeColor, width: 1.0),
          ),
          child: Text(
            isDone
                ? 'WORKOUT FINISHED'
                : '${isWork ? "WORK" : "REST"} • ROUND ${timerState.currentRound} / ${timerState.roundConfig.totalRounds}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TimeDisplay(
          formattedTime: formatted,
          subtitle: isDone
              ? 'Great effort!'
              : timerState.isRunning
                  ? 'Stay focused'
                  : 'Paused',
          fontSize: 84,
          isFlagged: isDone,
        ),
      ],
    );
  }

  Widget _buildStopwatchView(TimerState timerState, ThemeData theme) {
    final formatted = TimeFormatter.formatStopwatch(timerState.stopwatchElapsed);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TimeDisplay(
          formattedTime: formatted,
          subtitle: timerState.isRunning ? 'Running' : 'Ready / Paused',
          fontSize: 66,
        ),
        const SizedBox(height: 20),
        LapList(laps: timerState.stopwatchLaps),
      ],
    );
  }

  Widget _buildTurnTimerView(TimerState timerState, ThemeData theme, bool isDark) {
    final activePlayer = timerState.turnPlayers[timerState.activePlayerIndex];
    final nextPlayerIndex = (timerState.activePlayerIndex + 1) % timerState.turnPlayers.length;
    final nextPlayer = timerState.turnPlayers[nextPlayerIndex];

    final formatted = TimeFormatter.formatMmSs(timerState.turnRemaining);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFC18A42).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC18A42), width: 1.2),
          ),
          child: Column(
            children: [
              Text(
                'ROUND ${timerState.currentTurnRound}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
              const SizedBox(height: 2),
              Text(
                activePlayer.name.toUpperCase(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TimeDisplay(
          formattedTime: formatted,
          subtitle: timerState.turnExpired
              ? "TIME'S UP!"
              : 'Up Next: ${nextPlayer.name}',
          fontSize: 80,
          isFlagged: timerState.turnExpired,
        ),
      ],
    );
  }

  Widget _buildChessClockView(TimerState timerState, ThemeData theme, bool isDark) {
    return Column(
      children: [
        // Player B (Top) - Rotated 180 degrees for face-to-face play
        RotatedBox(
          quarterTurns: 2,
          child: _buildChessPlayerPad(
            playerName: 'PLAYER B',
            remainingTime: timerState.chessPlayerBRemaining,
            moves: timerState.chessPlayerBMoves,
            isActive: !timerState.isPlayerATurn && timerState.isRunning,
            isFlagged: timerState.chessPlayerBFlagged,
            theme: theme,
            isDark: isDark,
            onTap: () {
              if (!timerState.isPlayerATurn && timerState.isRunning) {
                ref.read(timerProvider.notifier).switchChessTurn();
              }
            },
          ),
        ),

        // Middle Control Strip
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: theme.colorScheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.read(timerProvider.notifier).reset(),
                tooltip: 'Reset Game',
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (timerState.isRunning) {
                    ref.read(timerProvider.notifier).stop();
                  } else {
                    ref.read(timerProvider.notifier).start();
                  }
                },
                icon: Icon(timerState.isRunning ? Icons.pause : Icons.play_arrow, size: 18),
                label: Text(timerState.isRunning ? 'PAUSE' : 'START'),
              ),
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: timerState.isRunning ? null : () => _showChessPresetsSheet(context),
                tooltip: 'Time Controls',
              ),
            ],
          ),
        ),

        // Player A (Bottom)
        _buildChessPlayerPad(
          playerName: 'PLAYER A',
          remainingTime: timerState.chessPlayerARemaining,
          moves: timerState.chessPlayerAMoves,
          isActive: timerState.isPlayerATurn && timerState.isRunning,
          isFlagged: timerState.chessPlayerAFlagged,
          theme: theme,
          isDark: isDark,
          onTap: () {
            if (timerState.isPlayerATurn && timerState.isRunning) {
              ref.read(timerProvider.notifier).switchChessTurn();
            }
          },
        ),
      ],
    );
  }

  Widget _buildChessPlayerPad({
    required String playerName,
    required Duration remainingTime,
    required int moves,
    required bool isActive,
    required bool isFlagged,
    required ThemeData theme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bgColor = isFlagged
        ? Colors.red.withValues(alpha: 0.2)
        : isActive
            ? (isDark
                ? const Color(0xFFC18A42).withValues(alpha: 0.2)
                : const Color(0xFF1A1A1A).withValues(alpha: 0.08))
            : Colors.transparent;

    final borderColor = isActive ? const Color(0xFFC18A42) : Colors.transparent;

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 2.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  playerName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: isActive ? const Color(0xFFC18A42) : theme.colorScheme.secondary,
                  ),
                ),
                if (moves > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '($moves moves)',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.secondary),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            TimeDisplay(
              formattedTime: TimeFormatter.formatChess(remainingTime),
              fontSize: 68,
              isFlagged: isFlagged,
            ),
            if (isActive)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'TAP TO END MOVE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CONTROLS CONFIGURATION
  // ==========================================

  Widget _buildModeControls(TimerState timerState) {
    final notifier = ref.read(timerProvider.notifier);

    VoidCallback? secondaryAction;
    String? secondaryLabel;
    IconData? secondaryIcon;

    if (timerState.mode == TimerMode.stopwatch) {
      secondaryAction = () => notifier.recordStopwatchLap();
      secondaryLabel = 'LAP';
      secondaryIcon = Icons.flag_outlined;
    } else if (timerState.mode == TimerMode.turn) {
      secondaryAction = () => notifier.advanceTurn();
      secondaryLabel = 'NEXT';
      secondaryIcon = Icons.skip_next;
    }

    return TimerControls(
      isRunning: timerState.isRunning,
      onStart: () => notifier.start(),
      onPause: () => notifier.stop(),
      onReset: () => notifier.reset(),
      onSecondaryAction: secondaryAction,
      secondaryActionLabel: secondaryLabel,
      secondaryActionIcon: secondaryIcon,
    );
  }
}
