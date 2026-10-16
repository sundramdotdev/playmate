import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Centralized registry for all verified developer profiles, project repositories,
/// and external destinations.
class ExternalLinks {
  // Developer & Brand Profiles
  static const String developerName = 'Sundramdotdev';
  static const String githubUrl = 'https://github.com/sundramdotdev';
  static const String linkedinUrl = 'https://linkedin.com/in/sundramdotdev';
  static const String websiteUrl = 'https://www.sundramdotdev.xyz';
  static const String portfolioFallbackUrl = 'https://sundramdotdev-portfolio.vercel.app';
  static const String instagramUrl = 'https://www.instagram.com/devsundram_?stkn=dXBva2IwMzZxbHY1';

  // Project Repositories & Resources
  static const String repositoryUrl = 'https://github.com/sundramdotdev/playmate';
  static const String supportEmail = 'support@playmateapp.com';

  /// Launches a verified external URL in the default system browser or native application.
  static Future<bool> openUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;

      return await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
    } catch (e) {
      debugPrint('Failed to open external link: $urlString ($e)');
      try {
        return await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (e2) {
        debugPrint('Secondary fallback failed for link: $urlString ($e2)');
        return false;
      }
    }
  }
}

/// Backward-compatible alias for [ExternalLinks.openUrl].
Future<void> openExternalUrl(String urlString) async {
  await ExternalLinks.openUrl(urlString);
}
