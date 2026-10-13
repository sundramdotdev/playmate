import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/responsive_layout.dart';
import 'playmate_spin_wheel.dart';
import 'spin_wheel_models.dart';
import 'spin_wheel_provider.dart';

class SpinWheelScreen extends ConsumerStatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  ConsumerState<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends ConsumerState<SpinWheelScreen> {
  final TextEditingController _optionController = TextEditingController();

  @override
  void dispose() {
    _optionController.dispose();
    super.dispose();
  }

  void _triggerSpin() {
    final wheelState = ref.read(spinWheelProvider);
    if (wheelState.isSpinning || wheelState.options.length < 2) return;
    ref.read(spinWheelProvider.notifier).spin();
  }

  void _showAddOptionDialog(BuildContext context) {
    _optionController.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Wheel Option'),
          content: TextField(
            controller: _optionController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Enter option label',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                ref.read(spinWheelProvider.notifier).addOption(val);
                Navigator.pop(ctx);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                if (_optionController.text.trim().isNotEmpty) {
                  ref.read(spinWheelProvider.notifier).addOption(_optionController.text);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  void _showPresetsBottomSheet(BuildContext context) {
    final activePreset = ref.read(spinWheelProvider).activePresetId;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                        'Wheel Presets',
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
                ...SpinWheelPreset.builtInPresets.map((preset) {
                  final isSelected = activePreset == preset.id;
                  return ListTile(
                    title: Text(
                      preset.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFFC18A42) : null,
                      ),
                    ),
                    subtitle: Text(
                      preset.optionLabels.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFFC18A42))
                        : null,
                    onTap: () {
                      ref.read(spinWheelProvider.notifier).applyPreset(preset);
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

  void _showEditOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final wheelState = ref.watch(spinWheelProvider);
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
                              'Edit Options (${wheelState.options.length})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () => _showAddOptionDialog(context),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(ctx),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: wheelState.options.length,
                          itemBuilder: (context, index) {
                            final option = wheelState.options[index];
                            final canDelete = wheelState.options.length > 2;
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
                              title: Text(option.label),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: canDelete ? Colors.red.shade400 : Colors.grey,
                                ),
                                onPressed: canDelete
                                    ? () => ref
                                        .read(spinWheelProvider.notifier)
                                        .removeOptionById(option.id)
                                    : null,
                                tooltip: canDelete ? 'Delete option' : 'Minimum 2 options required',
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

  @override
  Widget build(BuildContext context) {
    final wheelState = ref.watch(spinWheelProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin Wheel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: wheelState.isSpinning ? null : () => _showEditOptionsSheet(context),
            tooltip: 'Options',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            enabled: !wheelState.isSpinning,
            onSelected: (val) {
              if (val == 'presets') {
                _showPresetsBottomSheet(context);
              } else if (val == 'reset') {
                ref.read(spinWheelProvider.notifier).resetOptions();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'presets',
                child: Row(
                  children: [
                    Icon(Icons.palette_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Presets'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 8),
                    Text('Reset to Default'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: Column(
            children: [
              // Hero Wheel & Result Container
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
                      // Active Preset Banner / Options Badge
                      _buildPresetIndicator(wheelState, theme, isDarkMode),

                      const SizedBox(height: 12),

                      // Responsive Hero Physical Spin Wheel
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double wheelSize = _calculateResponsiveWheelSize(constraints.maxWidth);
                          return Center(
                            child: PlayMateSpinWheel(
                              options: wheelState.options,
                              targetWinner: wheelState.selectedWinner,
                              isSpinning: wheelState.isSpinning,
                              size: wheelSize,
                              onSpinRequested: _triggerSpin,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Winner / Result announcement card
                      _buildResultSection(wheelState, theme, isDarkMode),

                      const SizedBox(height: 14),

                      // Compact Recent History
                      if (wheelState.history.isNotEmpty) ...[
                        _buildRecentHistorySection(wheelState, theme, isDarkMode),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Control Bar
              _buildBottomControls(wheelState, theme),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateResponsiveWheelSize(double availableWidth) {
    if (availableWidth <= 330) {
      return 230.0;
    } else if (availableWidth <= 440) {
      return 265.0;
    } else if (availableWidth <= 600) {
      return 290.0;
    } else {
      return 330.0;
    }
  }

  Widget _buildPresetIndicator(SpinWheelState wheelState, ThemeData theme, bool isDarkMode) {
    final presetName = SpinWheelPreset.builtInPresets
        .firstWhere(
          (p) => p.id == wheelState.activePresetId,
          orElse: () => const SpinWheelPreset(
            id: 'custom',
            name: 'Custom Wheel',
            optionLabels: [],
          ),
        )
        .name;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 6.0,
      children: [
        InkWell(
          onTap: wheelState.isSpinning ? null : () => _showPresetsBottomSheet(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC18A42).withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tune, size: 14, color: Color(0xFFC18A42)),
                const SizedBox(width: 6),
                Text(
                  presetName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFFC18A42)),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: wheelState.isSpinning ? null : () => _showEditOptionsSheet(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pie_chart_outline, size: 13, color: theme.colorScheme.secondary),
                const SizedBox(width: 5),
                Text(
                  '${wheelState.options.length} options',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection(
    SpinWheelState wheelState,
    ThemeData theme,
    bool isDarkMode,
  ) {
    if (wheelState.isSpinning) {
      return Column(
        children: [
          Text(
            'Spinning...',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Watching the pointer tick past pegs',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      );
    }

    final winner = wheelState.selectedWinner;

    if (winner == null) {
      return Column(
        children: [
          Text(
            'Ready to Spin!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the wheel or button to spin',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      );
    }

    final canRemoveWinner = wheelState.options.length > 2;

    return Semantics(
      label: 'Winner selected: ${winner.label}',
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFC18A42).withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 16, color: Color(0xFFC18A42)),
                const SizedBox(width: 6),
                Text(
                  'WINNER SELECTED',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFC18A42),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.star, size: 16, color: Color(0xFFC18A42)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              winner.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: isDarkMode ? const Color(0xFF383838) : const Color(0xFFD0D0D0),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _triggerSpin,
                  icon: const Icon(Icons.replay, size: 16),
                  label: const Text('SPIN AGAIN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                if (canRemoveWinner)
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => ref.read(spinWheelProvider.notifier).removeWinner(),
                    icon: const Icon(Icons.remove_circle_outline, size: 16),
                    label: const Text('REMOVE WINNER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHistorySection(
    SpinWheelState wheelState,
    ThemeData theme,
    bool isDarkMode,
  ) {
    final recent = wheelState.history.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 15, color: theme.colorScheme.secondary),
            const SizedBox(width: 6),
            Text(
              'Recent Outcomes',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 16),
              visualDensity: VisualDensity.compact,
              tooltip: 'Clear history',
              onPressed: () => ref.read(spinWheelProvider.notifier).clearHistory(),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: recent.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              final isLatest = index == 0;

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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLatest
                              ? const Color(0xFFC18A42)
                              : (isDarkMode ? Colors.white60 : Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        record.winnerLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isLatest ? FontWeight.bold : FontWeight.w600,
                          color: isLatest
                              ? (isDarkMode ? Colors.white : const Color(0xFF1A1A1A))
                              : theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(SpinWheelState wheelState, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
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
            onPressed: (wheelState.isSpinning || wheelState.options.length < 2)
                ? null
                : _triggerSpin,
            child: wheelState.isSpinning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white70,
                    ),
                  )
                : const Text(
                    'SPIN WHEEL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
