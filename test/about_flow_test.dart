import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:playmate/core/theme.dart';
import 'package:playmate/features/about/about_screen.dart';
import 'package:playmate/features/about/changelog_screen.dart';
import 'package:playmate/features/about/privacy_policy_screen.dart';
import 'package:playmate/features/about/terms_screen.dart';
import 'package:playmate/features/about/package_info_provider.dart';

void main() {
  setUpAll(() async {
    Hive.init('test_hive_about');
    await Hive.openBox('settings');
    await Hive.openBox('matches');
    await Hive.openBox('achievements');
    await Hive.openBox('statistics');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('AboutScreen renders dynamic package info and developer details', (WidgetTester tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'PlayMate',
      packageName: 'com.sundramdotdev.playmate',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageInfoProvider.overrideWith(
            (ref) => PackageInfo(
              appName: 'PlayMate',
              packageName: 'com.sundramdotdev.playmate',
              version: '1.0.0',
              buildNumber: '1',
              buildSignature: '',
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AboutScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('PlayMate'), findsWidgets);
    expect(find.text('Everything you need for offline games.'), findsOneWidget);
    expect(find.text('Sundramdotdev'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('LinkedIn'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms & Conditions'), findsOneWidget);
    expect(find.text('What\'s New'), findsOneWidget);
  });

  testWidgets('PrivacyPolicyScreen renders and scrolls without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const PrivacyPolicyScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.text('1. Overview & Offline-First Privacy'), findsOneWidget);
    expect(find.text('2. Local Data Storage'), findsOneWidget);
  });

  testWidgets('TermsScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const TermsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Terms & Conditions'), findsWidgets);
    expect(find.text('1. Acceptance of Terms'), findsOneWidget);
  });

  testWidgets('ChangelogScreen renders release milestones', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const ChangelogScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('What\'s New'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);
    expect(find.text('LATEST'), findsOneWidget);
  });
}
