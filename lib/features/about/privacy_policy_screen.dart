import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import '../../shared/responsive_layout.dart';
import 'link_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Last Updated: October 2026',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                _buildSection(
                  theme: theme,
                  title: '1. Overview & Offline-First Privacy',
                  body:
                      'PlayMate is designed as an offline gaming companion. You do not need to register an account, log in, or provide any personal identification (such as your name, email address, or phone number) to use any of the core utilities.',
                ),
                _buildSection(
                  theme: theme,
                  title: '2. Local Data Storage',
                  body:
                      'All gameplay records, match histories, score tallies, custom teams, cricket scorecards, tournament brackets, and preferences (such as dark mode and sound settings) are stored locally on your device using Hive local storage. This information remains private to your device.',
                ),
                _buildSection(
                  theme: theme,
                  title: '3. Cloud Services & Synchronization',
                  body:
                      'PlayMate does not require cloud synchronization. If optional cloud backup features are enabled in future updates, data will only be synchronized with your explicit consent.',
                ),
                _buildSection(
                  theme: theme,
                  title: '4. Anonymous Usage Analytics',
                  body:
                      'When your device is connected to the internet, PlayMate may collect non-identifiable, aggregated usage events through Firebase Analytics (for example, counts of dice rolled or coin tosses performed). These metrics help us understand which utilities are most useful and improve the user experience.',
                ),
                _buildSection(
                  theme: theme,
                  title: '5. Technical Crash Reporting',
                  body:
                      'To diagnose and fix software bugs, PlayMate uses Firebase Crashlytics to collect anonymous crash logs and diagnostic stack traces. These reports do not contain personal game contents or personal identity information.',
                ),
                _buildSection(
                  theme: theme,
                  title: '6. Data Deletion & Control',
                  body:
                      'You maintain complete control over your data. You can delete all locally stored matches, scores, and statistics at any time by navigating to Settings > Clear Match History. Uninstalling the app also permanently removes all local data.',
                ),
                _buildSection(
                  theme: theme,
                  title: '7. Children\'s Privacy',
                  body:
                      'PlayMate is a family-friendly game utility suitable for players of all ages. We do not knowingly solicit or collect personal information from children.',
                ),
                _buildSection(
                  theme: theme,
                  title: '8. Contact Information',
                  body:
                      'For privacy inquiries, questions, or feedback, you can contact the developer at:\nsupport@playmateapp.com\nhttps://github.com/sundramdotdev',
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Linkify(
            onOpen: (link) => openExternalUrl(link.url),
            text: body,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
            linkStyle: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
