import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import '../../shared/responsive_layout.dart';
import 'dice_provider.dart';
import 'dice_state.dart';

class DiceScreen extends ConsumerStatefulWidget {
  const DiceScreen({super.key});

  @override
  ConsumerState<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends ConsumerState<DiceScreen> with SingleTickerProviderStateMixin {
  StreamSubscription<UserAccelerometerEvent>? _shakeSubscription;
  late AnimationController _animationController;
  DateTime _lastShakeTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Shake detection configuration
    _shakeSubscription = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      final double acceleration = event.x * event.x + event.y * event.y + event.z * event.z;
      if (acceleration > 200) { // Shake threshold
        final now = DateTime.now();
        if (now.difference(_lastShakeTime) > const Duration(milliseconds: 800)) {
          _lastShakeTime = now;
          _triggerRoll();
        }
      }
    });
  }

  void _triggerRoll() {
    _animationController.forward(from: 0.0);
    ref.read(diceProvider.notifier).roll();
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diceState = ref.watch(diceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Roller'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
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
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animation support
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              final double angle = _animationController.value * 2 * 3.14159;
                              return Transform.rotate(
                                angle: diceState.isRolling ? angle : 0,
                                child: child,
                              );
                            },
                            child: Wrap(
                              spacing: AppSpacing.m,
                              runSpacing: AppSpacing.m,
                              alignment: WrapAlignment.center,
                              children: diceState.currentRolls.map((roll) {
                                return _buildDiceWidget(roll, diceState.diceType, theme);
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            diceState.isRolling ? 'Rolling...' : 'Total: ${diceState.totalSum}',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            'Tap the dice or shake your phone to roll',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildControlPanel(diceState, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiceWidget(int value, DiceType type, ThemeData theme) {
    return GestureDetector(
      onTap: _triggerRoll,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$value',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                type.name.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel(DiceRollState diceState, ThemeData theme) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dice Count', style: theme.textTheme.titleLarge),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: diceState.diceCount > 1
                        ? () => ref.read(diceProvider.notifier).setDiceCount(diceState.diceCount - 1)
                        : null,
                  ),
                  Text('${diceState.diceCount}', style: theme.textTheme.headlineMedium),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: diceState.diceCount < 6
                        ? () => ref.read(diceProvider.notifier).setDiceCount(diceState.diceCount + 1)
                        : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DiceType.values.map((type) {
                final isSelected = diceState.diceType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s),
                  child: ChoiceChip(
                    label: Text(type.name.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
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
              onPressed: _triggerRoll,
              child: const Text('ROLL DICE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
