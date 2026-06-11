import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:playmate/core/theme.dart';
import 'package:playmate/routes/router.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing with an in-memory path
    Hive.init('test_hive');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('Playmate home screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          title: 'PLAYMATE',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          routerConfig: appRouter,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the home screen title is visible
    expect(find.text('PLAYMATE'), findsOneWidget);

    // Verify core feature cards are visible on home
    expect(find.text('Dice Roller'), findsOneWidget);
    expect(find.text('Coin Toss'), findsOneWidget);
    expect(find.text('Score Tracker'), findsOneWidget);
  });

  testWidgets('Dice Roller screen navigates correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          title: 'PLAYMATE',
          theme: AppTheme.lightTheme,
          routerConfig: appRouter,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on Dice Roller card
    await tester.tap(find.text('Dice Roller'));
    await tester.pumpAndSettle();

    // Verify navigation to Dice Roller
    expect(find.text('ROLL DICE'), findsOneWidget);
  });
}
