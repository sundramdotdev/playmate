
enum DiceType {
  d4(4),
  d6(6),
  d8(8),
  d10(10),
  d12(12),
  d20(20);

  final int sides;
  const DiceType(this.sides);
}

class DiceRollState {
  final List<int> currentRolls;
  final DiceType diceType;
  final int diceCount;
  final bool isRolling;
  final List<List<int>> rollHistory;

  DiceRollState({
    required this.currentRolls,
    required this.diceType,
    required this.diceCount,
    required this.isRolling,
    required this.rollHistory,
  });

  DiceRollState copyWith({
    List<int>? currentRolls,
    DiceType? diceType,
    int? diceCount,
    bool? isRolling,
    List<List<int>>? rollHistory,
  }) {
    return DiceRollState(
      currentRolls: currentRolls ?? this.currentRolls,
      diceType: diceType ?? this.diceType,
      diceCount: diceCount ?? this.diceCount,
      isRolling: isRolling ?? this.isRolling,
      rollHistory: rollHistory ?? this.rollHistory,
    );
  }

  int get totalSum => currentRolls.fold(0, (sum, val) => sum + val);
}
