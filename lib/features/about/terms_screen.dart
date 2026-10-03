import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import '../../shared/responsive_layout.dart';
import 'link_launcher.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms & Conditions',
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
                  title: '1. Acceptance of Terms',
                  body:
                      'By downloading, installing, or using PlayMate, you agree to these Terms and Conditions. If you do not agree to these terms, please do not use the application.',
                ),
                _buildSection(
                  theme: theme,
                  title: '2. License & Purpose',
                  body:
                      'PlayMate is licensed for personal, non-commercial entertainment and utility use. It serves as an offline companion toolkit for physical board games, team sports, tabletop gaming, and casual decision making.',
                ),
                _buildSection(
                  theme: theme,
                  title: '3. Randomization & Disclaimer',
                  body:
                      'Digital utilities including the dice roller, coin toss, and spin wheel generate pseudorandom outcomes for recreational gaming. PlayMate is not certified or intended for commercial gambling, financial wagers, or formal legal arbitration.',
                ),
                _buildSection(
                  theme: theme,
                  title: '4. Limitation of Liability',
                  body:
                      'PlayMate is provided "as is" without warranty of any kind. Under no circumstances shall the developer be liable for any indirect, incidental, or consequential damages resulting from the use or inability to use the application.',
                ),
                _buildSection(
                  theme: theme,
                  title: '5. Intellectual Property',
                  body:
                      'All source code, branding, and assets not covered by third-party open-source licenses are the intellectual property of Sundramdotdev.',
                ),
                _buildSection(
                  theme: theme,
                  title: '6. Contact & Support',
                  body:
                      'For support or legal inquiries, please contact:\nsupport@playmateapp.com\nhttps://github.com/sundramdotdev',
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
