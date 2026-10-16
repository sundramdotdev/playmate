import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../shared/responsive_layout.dart';
import 'dice_provider.dart';
import 'dice_roller_view.dart';
import 'dice_state.dart';

class DiceScreen extends ConsumerStatefulWidget {
  const DiceScreen({super.key});

  @override
  ConsumerState<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends ConsumerState<DiceScreen> {
  StreamSubscription<UserAccelerometerEvent>? _shakeSubscription;
  DateTime _lastShakeTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initAccelerometer();
  }

  void _initAccelerometer() {
    try {
      _shakeSubscription = userAccelerometerEventStream().listen(
        (UserAccelerometerEvent event) {
          final double acceleration =
              event.x * event.x + event.y * event.y + event.z * event.z;
          if (acceleration > 190) {
            final now = DateTime.now();
            if (now.difference(_lastShakeTime) > const Duration(milliseconds: 1100)) {
              _lastShakeTime = now;
              _triggerRoll();
            }
          }
        },
        onError: (error) {
          debugPrint("Accelerometer unavailable: $error");
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint("Accelerometer initialization bypassed: $e");
    }
  }

  void _triggerRoll() {
    final diceState = ref.read(diceProvider);
    if (diceState.isRolling) return;
    ref.read(diceProvider.notifier).roll();
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diceState = ref.watch(diceProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Roller'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: diceState.isRolling
                ? null
                : () {
                    ref.read(diceProvider.notifier).resetDice();
                  },
            tooltip: 'Reset Dice',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: (diceState.rollHistory.isEmpty || diceState.isRolling)
                ? null
                : () {
                    ref.read(diceProvider.notifier).clearHistory();
                  },
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Column(
            children: [
              // Main hero area with tactile dice
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),

                      // Hero 3D Physical Dice (Interactive press & roll)
                      DiceRollerView(
                        rolls: diceState.currentRolls,
                        diceType: diceState.diceType,
                        isRolling: diceState.isRolling,
                        onRollRequested: _triggerRoll,
                      ),

                      const SizedBox(height: 18),

                      // Result typography
                      _buildResultSection(diceState, theme),

                      const SizedBox(height: 16),

                      // Compact roll history
                      if (diceState.rollHistory.isNotEmpty)
                        _buildRecentRollsSection(diceState, theme, isDarkMode),
                    ],
                  ),
                ),
              ),

              // Bottom control panel & roll button
              _buildBottomControls(diceState, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection(DiceRollState diceState, ThemeData theme) {
    if (diceState.isRolling) {
      return Column(
        children: [
          Text(
            'Rolling...',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tumbling on table',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      );
    }

    final isSingleDie = diceState.diceCount == 1;

    return Semantics(
      label: isSingleDie
          ? 'Dice result: ${diceState.currentRolls.first}'
          : 'Dice results: ${diceState.currentRolls.join(", ")}. Total ${diceState.totalSum}.',
      child: Column(
        children: [
          if (isSingleDie) ...[
            Text(
              '${diceState.currentRolls.first}',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Rolled Result',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
          ] else ...[
            Text(
              'Total: ${diceState.totalSum}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              diceState.currentRolls.join(' + '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Tap dice or button to roll',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRollsSection(
    DiceRollState diceState,
    ThemeData theme,
    bool isDarkMode,
  ) {
    final recent = diceState.rollHistory.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 15,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Recent Rolls',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: recent.asMap().entries.map((entry) {
              final index = entry.key;
              final roll = entry.value;
              final sum = roll.fold(0, (prev, element) => prev + element);
              final isLatest = index == 0;

              final label = roll.length == 1 ? '$sum' : '$sum (${roll.join('+')})';

              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isLatest
                        ? (isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFEBEBEB))
                        : (isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isLatest
                          ? const Color(0xFFC18A42).withValues(alpha: 0.4)
                          : (isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0)),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isLatest ? FontWeight.bold : FontWeight.w500,
                      color: isLatest
                          ? (isDarkMode ? Colors.white : const Color(0xFF1A1A1A))
                          : theme.colorScheme.secondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(DiceRollState diceState, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dice count row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Dice Quantity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: (!diceState.isRolling && diceState.diceCount > 1)
                          ? () => ref.read(diceProvider.notifier).setDiceCount(diceState.diceCount - 1)
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(
                        '${diceState.diceCount}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: (!diceState.isRolling && diceState.diceCount < 6)
                          ? () => ref.read(diceProvider.notifier).setDiceCount(diceState.diceCount + 1)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Dice type selector (D6, D4, D8, etc.)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: DiceType.values.map((type) {
                final isSelected = diceState.diceType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(type.name.toUpperCase()),
                    selected: isSelected,
                    onSelected: diceState.isRolling
                        ? null
                        : (selected) {
                            if (selected) {
                              ref.read(diceProvider.notifier).setDiceType(type);
                            }
                          },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSpacing.m),

          // Tactile Roll Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: diceState.isRolling ? null : _triggerRoll,
              child: diceState.isRolling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white70,
                      ),
                    )
                  : const Text(
                      'ROLL DICE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
