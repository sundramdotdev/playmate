import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'features/settings/settings_screen.dart';
import 'routes/router.dart';
import 'services/firebase_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Fast storage bootstrap for instantaneous frame rendering
  await StorageService.initialize();

  // Asynchronous background telemetry initialization (non-blocking for splash)
  unawaited(FirebaseService.initialize());

  runApp(
    const ProviderScope(
      child: PlaymateApp(),
    ),
  );
}

class PlaymateApp extends ConsumerWidget {
  const PlaymateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'PLAYMATE',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
