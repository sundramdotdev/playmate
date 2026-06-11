import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/storage_service.dart';
import '../../shared/responsive_layout.dart';

// Provider to manage dark mode state locally in UI
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final isDark = StorageService.isDarkMode();
  return isDark ? ThemeMode.dark : ThemeMode.light;
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: ListView(
            padding: const EdgeInsets.all(AppSpacing.m),
            children: [
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Theme'),
                      subtitle: const Text('Use clean Notion dark theme'),
                      value: themeMode == ThemeMode.dark,
                      onChanged: (value) async {
                        ref.read(themeModeProvider.notifier).state =
                            value ? ThemeMode.dark : ThemeMode.light;
                        await StorageService.setDarkMode(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.delete_sweep, color: theme.colorScheme.error),
                      title: Text(
                        'Clear Match History',
                        style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Deletes all local matches and dice histories'),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await StorageService.clearAllData();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('All data cleared successfully!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Center(
                child: Text(
                  'PLAYMATE v1.0.0\nEverything you need for offline games.\nDesigned and Developed by Sundramdotdev',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
