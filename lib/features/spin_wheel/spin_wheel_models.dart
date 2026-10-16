import 'package:flutter/material.dart';

/// Represents an individual option on the PlayMate Spin Wheel with a stable identity.
class WheelOption {
  final String id;
  final String label;
  final Color? customColor;

  const WheelOption({
    required this.id,
    required this.label,
    this.customColor,
  });

  WheelOption copyWith({
    String? id,
    String? label,
    Color? customColor,
  }) {
    return WheelOption(
      id: id ?? this.id,
      label: label ?? this.label,
      customColor: customColor ?? this.customColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        if (customColor != null) 'color': customColor!.toARGB32(),
      };

  factory WheelOption.fromJson(Map<String, dynamic> json) {
    return WheelOption(
      id: json['id'] as String,
      label: json['label'] as String,
      customColor: json['color'] != null ? Color(json['color'] as int) : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WheelOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label;

  @override
  int get hashCode => id.hashCode ^ label.hashCode;
}

/// A preconfigured wheel collection for instant game-night utility.
class SpinWheelPreset {
  final String id;
  final String name;
  final List<String> optionLabels;

  const SpinWheelPreset({
    required this.id,
    required this.name,
    required this.optionLabels,
  });

  List<WheelOption> toOptions() {
    return optionLabels.asMap().entries.map((entry) {
      return WheelOption(
        id: '${id}_${entry.key}_${DateTime.now().microsecondsSinceEpoch}',
        label: entry.value,
      );
    }).toList();
  }

  static const List<SpinWheelPreset> builtInPresets = [
    SpinWheelPreset(
      id: 'truth_or_dare',
      name: 'Truth or Dare',
      optionLabels: ['Truth', 'Dare', 'Pass', 'Double Dare'],
    ),
    SpinWheelPreset(
      id: 'decisions',
      name: 'Quick Decisions',
      optionLabels: ['Yes', 'No', 'Maybe', 'Ask Again'],
    ),
    SpinWheelPreset(
      id: 'food_picker',
      name: 'Food Picker',
      optionLabels: ['Pizza', 'Burgers', 'Sushi', 'Tacos', 'Pasta', 'Salad'],
    ),
    SpinWheelPreset(
      id: 'dice_numbers',
      name: 'D6 Roll Wheel',
      optionLabels: ['1', '2', '3', '4', '5', '6'],
    ),
    SpinWheelPreset(
      id: 'teams',
      name: 'Team Selector',
      optionLabels: ['Team Red', 'Team Blue', 'Team Green', 'Team Gold'],
    ),
  ];
}

/// Recorded historical outcome of a spin.
class SpinWheelRecord {
  final String winnerLabel;
  final DateTime timestamp;

  const SpinWheelRecord({
    required this.winnerLabel,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'winner': winnerLabel,
        'time': timestamp.millisecondsSinceEpoch,
      };

  factory SpinWheelRecord.fromJson(Map<String, dynamic> json) {
    return SpinWheelRecord(
      winnerLabel: json['winner'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
    );
  }
}

