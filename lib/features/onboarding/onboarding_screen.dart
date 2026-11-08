import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/storage_service.dart';
import '../../shared/responsive_layout.dart';
import 'widgets/dice_onboarding_visual.dart';
import 'widgets/essentials_onboarding_visual.dart';
import 'widgets/onboarding_page.dart';
import 'widgets/onboarding_page_indicator.dart';
import 'widgets/welcome_onboarding_visual.dart';

/// Production-ready, premium first-time onboarding experience for PlayMate.
///
/// Features:
/// - Three distinct, carefully calibrated introduction pages
/// - Native tactile Flutter animations (floating dice, essentials cluster, welcome composition)
/// - Rapid-tap prevention and graceful lifecycle handling
/// - Persistent local completion state via [StorageService]
/// - Full accessibility semantics and reduced-motion support
/// - Zero-overflow responsive layout across 320px–1024px screens
class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onFinish;

  const OnboardingScreen({super.key, this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isNavigating = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_isNavigating) return;
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_isNavigating) return;
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      // If replaying from settings on page 0, allow popping back
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  Future<void> _completeOnboarding() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      await StorageService.setCompletedOnboarding(true);
    } catch (_) {
      // Storage error safeguard
    }

    if (widget.onFinish != null) {
      widget.onFinish!();
      return;
    }

    if (mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        try {
          context.go('/');
        } catch (_) {
          // Fallback when standalone without GoRouter
        }
      }
    }
  }

  Future<void> _skipOnboarding() async {
    await _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 680;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: isCompact ? AppSpacing.xs : AppSpacing.s,
                  ),
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Back button or discrete brand marker
                        _currentPage > 0
                            ? TextButton.icon(
                                onPressed: _previousPage,
                                icon: const Icon(Icons.arrow_back, size: 18),
                                label: const Text('Back'),
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.secondary,
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.sports_esports,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'PLAYMATE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                        // Right: Skip button (visible on pages 0 and 1)
                        if (_currentPage < 2)
                          Semantics(
                            button: true,
                            label: 'Skip onboarding',
                            child: TextButton(
                              onPressed: _isNavigating ? null : _skipOnboarding,
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.secondary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.m,
                                  vertical: AppSpacing.s,
                                ),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),

                // Main PageView Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: const [
                      // Screen 01: Introduction
                      OnboardingPage(
                        headline: 'Make every moment a game.',
                        supportingText:
                            'From spontaneous decisions to unforgettable game nights, everything you need to play is right here.',
                        visual: DiceOnboardingVisual(),
                      ),

                      // Screen 02: Features
                      OnboardingPage(
                        headline: 'All your game-night essentials.',
                        supportingText:
                            'Roll, flip, spin, keep score, build teams, and manage every moment without switching between apps.',
                        visual: EssentialsOnboardingVisual(),
                      ),

                      // Screen 03: Final Welcome
                      OnboardingPage(
                        headline: 'Less setup. More playing.',
                        supportingText:
                            'Your next game night starts here. Pick a tool, bring everyone together, and let the fun begin.',
                        visual: WelcomeOnboardingVisual(),
                      ),
                    ],
                  ),
                ),

                // Bottom Controls & Page Indicator
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.l,
                    right: AppSpacing.l,
                    top: AppSpacing.s,
                    bottom: isCompact ? AppSpacing.s : AppSpacing.m,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page Indicators
                      OnboardingPageIndicator(
                        currentPage: _currentPage,
                        pageCount: 3,
                        onDotTapped: (index) {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          );
                        },
                      ),

                      SizedBox(height: isCompact ? AppSpacing.s : AppSpacing.m),

                      // Navigation Action Button
                      if (_currentPage < 2)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _nextPage,
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _isNavigating
                                ? null
                                : _completeOnboarding,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Let's Play",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
