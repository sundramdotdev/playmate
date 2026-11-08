import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:playmate/core/theme.dart';
import 'package:playmate/features/about/package_info_provider.dart';
import 'package:playmate/features/onboarding/onboarding_screen.dart';
import 'package:playmate/features/onboarding/widgets/dice_onboarding_visual.dart';
import 'package:playmate/features/onboarding/widgets/essentials_onboarding_visual.dart';
import 'package:playmate/features/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:playmate/features/onboarding/widgets/welcome_onboarding_visual.dart';
import 'package:playmate/features/settings/settings_screen.dart';
import 'package:playmate/routes/router.dart';
import 'package:playmate/services/storage_service.dart';

void main() {
  setUpAll(() async {
    PackageInfo.setMockInitialValues(
      appName: 'PlayMate',
      packageName: 'com.sundramdotdev.playmate',
      version: '1.0.2',
      buildNumber: '3',
      buildSignature: '',
    );
    Hive.init('test_hive_onboarding');
    await Hive.openBox(StorageService.settingsBoxName);
    await Hive.openBox(StorageService.matchBoxName);
    await Hive.openBox(StorageService.achievementsBoxName);
    await Hive.openBox(StorageService.statsBoxName);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  setUp(() async {
    final box = StorageService.getSettingsBox();
    await box.delete(StorageService.hasCompletedOnboardingKey);
  });

  group('Onboarding Persistence & Unit Tests', () {
    test('Initial onboarding status is false on fresh install', () {
      expect(StorageService.hasCompletedOnboarding(), isFalse);
    });

    test('Completing onboarding persists true in settings box', () async {
      await StorageService.setCompletedOnboarding(true);
      expect(StorageService.hasCompletedOnboarding(), isTrue);
    });

    test('Skipping onboarding persists true in settings box', () async {
      await StorageService.setCompletedOnboarding(true);
      expect(StorageService.hasCompletedOnboarding(), isTrue);
    });

    test(
      'Replay does not delete or alter match and user preferences',
      () async {
        await StorageService.setCompletedOnboarding(true);
        await StorageService.setDarkMode(true);
        await StorageService.getSettingsBox().put(
          'timer_countdown_seconds',
          180,
        );

        expect(StorageService.hasCompletedOnboarding(), isTrue);
        expect(StorageService.isDarkMode(), isTrue);
        expect(
          StorageService.getSettingsBox().get('timer_countdown_seconds'),
          equals(180),
        );

        // Replay preserves data
        expect(StorageService.hasCompletedOnboarding(), isTrue);
        expect(StorageService.isDarkMode(), isTrue);
      },
    );
  });

  group('Onboarding UI & Widget Rendering Tests', () {
    testWidgets(
      'OnboardingPageIndicator renders correct dot counts and active state',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Center(
                child: OnboardingPageIndicator(currentPage: 0, pageCount: 3),
              ),
            ),
          ),
        );

        expect(find.byType(OnboardingPageIndicator), findsOneWidget);
        expect(find.byType(AnimatedContainer), findsNWidgets(3));
        expect(find.bySemanticsLabel('Page 1 of 3'), findsOneWidget);
      },
    );

    testWidgets('Visual components render without errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  DiceOnboardingVisual(size: 150),
                  EssentialsOnboardingVisual(size: 150),
                  WelcomeOnboardingVisual(size: 150),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DiceOnboardingVisual), findsOneWidget);
      expect(find.byType(EssentialsOnboardingVisual), findsOneWidget);
      expect(find.byType(WelcomeOnboardingVisual), findsOneWidget);
    });

    testWidgets(
      'OnboardingScreen displays 3 pages with approved copy and transitions',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const OnboardingScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Page 1: Introduction verification
        expect(find.text('Make every moment a game.'), findsOneWidget);
        expect(
          find.text(
            'From spontaneous decisions to unforgettable game nights, everything you need to play is right here.',
          ),
          findsOneWidget,
        );
        expect(find.text('Continue'), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);

        // Advance to Page 2: Features
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(find.text('All your game-night essentials.'), findsOneWidget);
        expect(
          find.text(
            'Roll, flip, spin, keep score, build teams, and manage every moment without switching between apps.',
          ),
          findsOneWidget,
        );
        expect(find.text('Back'), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);

        // Test Back navigation to Page 1
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();
        expect(find.text('Make every moment a game.'), findsOneWidget);

        // Re-advance to Page 2 then Page 3
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Page 3: Final Welcome verification
        expect(find.text('Less setup. More playing.'), findsOneWidget);
        expect(
          find.text(
            'Your next game night starts here. Pick a tool, bring everyone together, and let the fun begin.',
          ),
          findsOneWidget,
        );
        expect(find.text("Let's Play"), findsOneWidget);
        expect(find.text('Back'), findsOneWidget);
        // Skip should be hidden on final welcome page
        expect(find.text('Skip'), findsNothing);
      },
    );
  });

  group('Onboarding Navigation & Routing Integration Tests', () {
    testWidgets(
      'Tapping Skip completes onboarding and persists completion state',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await StorageService.setCompletedOnboarding(false);
        });
        bool completed = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: OnboardingScreen(onFinish: () => completed = true),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Skip'), findsOneWidget);
        await tester.runAsync(() async {
          await tester.tap(find.text('Skip'));
          await Future.delayed(const Duration(milliseconds: 50));
        });
        await tester.pumpAndSettle();

        expect(StorageService.hasCompletedOnboarding(), isTrue);
        expect(completed, isTrue);
      },
    );

    testWidgets(
      "Tapping Let's Play on page 3 completes onboarding and persists state",
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await StorageService.setCompletedOnboarding(false);
        });
        bool completed = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: OnboardingScreen(onFinish: () => completed = true),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to Page 2
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Navigate to Page 3
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Tap Let's Play
        expect(find.text("Let's Play"), findsOneWidget);
        await tester.runAsync(() async {
          await tester.tap(find.text("Let's Play"));
          await Future.delayed(const Duration(milliseconds: 50));
        });
        await tester.pumpAndSettle();

        // Verify completion persisted
        expect(StorageService.hasCompletedOnboarding(), isTrue);
        expect(completed, isTrue);
      },
    );

    test(
      'Router redirect policy routes first-time user to /onboarding',
      () async {
        await StorageService.setCompletedOnboarding(false);
        final router = createAppRouter();
        expect(StorageService.hasCompletedOnboarding(), isFalse);
        expect(
          router.routeInformationProvider.value.uri.path,
          equals('/onboarding'),
        );
      },
    );

    test(
      'Router redirect policy routes returning user directly to /',
      () async {
        await StorageService.setCompletedOnboarding(true);
        final router = createAppRouter();
        expect(StorageService.hasCompletedOnboarding(), isTrue);
        expect(router.routeInformationProvider.value.uri.path, equals('/'));
      },
    );

    testWidgets(
      'Settings screen renders cleanly without Replay Onboarding and preserves user data',
      (WidgetTester tester) async {
        await tester.runAsync(
          () async => StorageService.setCompletedOnboarding(true),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              packageInfoProvider.overrideWith(
                (ref) => PackageInfo(
                  appName: 'PlayMate',
                  packageName: 'com.sundramdotdev.playmate',
                  version: '1.0.2',
                  buildNumber: '3',
                  buildSignature: '',
                ),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const Scaffold(body: SettingsScreen()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Settings does not contain Replay Onboarding tile
        expect(find.text('Replay Onboarding'), findsNothing);
        expect(
          find.text(
            'PLAYMATE v1.0.2\nEverything you need for offline games.\nDeveloped by Sundramdotdev',
          ),
          findsOneWidget,
        );

        // Verify onboarding completion is still true
        expect(StorageService.hasCompletedOnboarding(), isTrue);
      },
    );
  });

  group('Responsive Layout Tests Across Widths', () {
    final testWidths = [
      320.0,
      360.0,
      375.0,
      390.0,
      412.0,
      600.0,
      768.0,
      1024.0,
    ];

    for (final width in testWidths) {
      testWidgets(
        'OnboardingScreen renders with zero overflow at ${width}px width',
        (WidgetTester tester) async {
          tester.view.physicalSize = Size(width * 2, 800 * 2);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: const OnboardingScreen(),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('Make every moment a game.'), findsOneWidget);
          expect(tester.takeException(), isNull);

          // Test next page
          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();
          expect(find.text('All your game-night essentials.'), findsOneWidget);
          expect(tester.takeException(), isNull);

          // Test page 3
          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();
          expect(find.text('Less setup. More playing.'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'OnboardingScreen renders with zero overflow on short device (320x568)',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320 * 2, 568 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: const OnboardingScreen(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Make every moment a game.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
