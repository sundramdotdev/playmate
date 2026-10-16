import 'package:flutter/material.dart';
import 'dice_face.dart';
import 'dice_state.dart';
import 'playmate_dice.dart';

/// Coordinates responsive layout and staggered physical rolling for 1 to 6 dice.
class DiceRollerView extends StatelessWidget {
  final List<int> rolls;
  final DiceType diceType;
  final bool isRolling;
  final VoidCallback onRollRequested;
  final VoidCallback? onAllDiceCompleted;
  final DiceStyle? style;

  const DiceRollerView({
    super.key,
    required this.rolls,
    required this.diceType,
    required this.isRolling,
    required this.onRollRequested,
    this.onAllDiceCompleted,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final count = rolls.length;

        // Calculate responsive die size based on available container width
        final double dieSize = _calculateResponsiveSize(availableWidth, count);

        // Layout arrangement
        if (count == 1) {
          return Center(
            child: PlayMateDice(
              value: rolls[0],
              size: dieSize,
              isRolling: isRolling,
              diceIndex: 0,
              delayMs: 0,
              diceType: diceType,
              style: style,
              onRollRequested: onRollRequested,
              onRollCompleted: onAllDiceCompleted,
            ),
          );
        }

        return Center(
          child: Wrap(
            spacing: count > 3 ? 12.0 : 18.0,
            runSpacing: count > 3 ? 12.0 : 18.0,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: List.generate(count, (index) {
              // Staggered launch delay: +35ms per die index
              final delay = index * 35;
              final isLastDie = index == count - 1;

              return PlayMateDice(
                key: ValueKey('die_$index'),
                value: rolls[index],
                size: dieSize,
                isRolling: isRolling,
                diceIndex: index,
                delayMs: delay,
                diceType: diceType,
                style: style,
                onRollRequested: onRollRequested,
                onRollCompleted: isLastDie ? onAllDiceCompleted : null,
              );
            }),
          ),
        );
      },
    );
  }

  double _calculateResponsiveSize(double availableWidth, int count) {
    if (availableWidth <= 330) {
      // Extremely compact screen (320px width)
      switch (count) {
        case 1:
          return 135.0;
        case 2:
          return 96.0;
        case 3:
        case 4:
          return 74.0;
        default:
          return 64.0;
      }
    } else if (availableWidth <= 440) {
      // Standard mobile screens (360px - 412px)
      switch (count) {
        case 1:
          return 165.0;
        case 2:
          return 120.0;
        case 3:
          return 98.0;
        case 4:
          return 92.0;
        default:
          return 80.0;
      }
    } else if (availableWidth <= 600) {
      // Large phone / small tablet
      switch (count) {
        case 1:
          return 185.0;
        case 2:
          return 135.0;
        case 3:
        case 4:
          return 105.0;
        default:
          return 92.0;
      }
    } else {
      // Tablet / desktop
      switch (count) {
        case 1:
          return 210.0;
        case 2:
          return 155.0;
        case 3:
        case 4:
          return 125.0;
        default:
          return 110.0;
      }
    }
  }
}
