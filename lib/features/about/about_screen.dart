import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/responsive_layout.dart';
import 'link_launcher.dart';
import 'package_info_provider.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final packageInfoAsync = ref.watch(packageInfoProvider);

    final String versionText = packageInfoAsync.when(
      data: (info) => info.version,
      loading: () => '1.1.0',
      error: (err, stack) => '1.1.0',
    );

    final String buildText = packageInfoAsync.when(
      data: (info) => info.buildNumber,
      loading: () => '2',
      error: (err, stack) => '2',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('About PlayMate'),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Brand Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.sports_esports,
                                size: 36,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PlayMate',
                                    style: theme.textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    'Everything you need for offline games.',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.secondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          'PlayMate combines physical tabletop and outdoor sports utilities into one seamless, ad-free toolkit. '
                          'Never worry about missing dice, lost scorepads, disputed coin tosses, or unorganized teams during game nights.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),

                // Version Metadata Card
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Version'),
                        trailing: Text(
                          versionText,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.build_circle_outlined),
                        title: const Text('Build Number'),
                        trailing: Text(
                          buildText,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.m),

                // Developer Information Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DESIGNED & DEVELOPED BY',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          ExternalLinks.developerName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.language),
                          title: const Text('Official Website'),
                          subtitle: const Text('sundramdotdev.xyz'),
                          trailing: const Icon(Icons.open_in_new, size: 18),
                          onTap: () => ExternalLinks.openUrl(ExternalLinks.websiteUrl),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.code),
                          title: const Text('GitHub'),
                          subtitle: const Text('github.com/sundramdotdev'),
                          trailing: const Icon(Icons.open_in_new, size: 18),
                          onTap: () => ExternalLinks.openUrl(ExternalLinks.githubUrl),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.work_outline),
                          title: const Text('LinkedIn'),
                          subtitle: const Text('linkedin.com/in/sundramdotdev'),
                          trailing: const Icon(Icons.open_in_new, size: 18),
                          onTap: () => ExternalLinks.openUrl(ExternalLinks.linkedinUrl),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.folder_zip_outlined),
                          title: const Text('PlayMate Repository'),
                          subtitle: const Text('github.com/sundramdotdev/playmate'),
                          trailing: const Icon(Icons.open_in_new, size: 18),
                          onTap: () => ExternalLinks.openUrl(ExternalLinks.repositoryUrl),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.camera_alt_outlined),
                          title: const Text('Instagram'),
                          subtitle: const Text('@devsundram_'),
                          trailing: const Icon(Icons.open_in_new, size: 18),
                          onTap: () => ExternalLinks.openUrl(ExternalLinks.instagramUrl),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),

                // Legal and Documentation Navigation Card
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.new_releases_outlined),
                        title: const Text('What\'s New in 1.1.0'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/changelog'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Privacy Policy'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/privacy'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.gavel_outlined),
                        title: const Text('Terms & Conditions'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/terms'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
