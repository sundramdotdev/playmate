import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens external URLs with graceful fallback between native OS application
/// and default mobile browser.
Future<void> openExternalUrl(String urlString) async {
  final Uri uri = Uri.parse(urlString);
  try {
    // Attempt opening in native app first (GitHub, LinkedIn, Instagram)
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      // Fallback to platform browser
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
    }
  } catch (e) {
    debugPrint("Failed to launch URL $urlString: $e");
    try {
      // Last-resort fallback
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (e2) {
      debugPrint("Secondary launch failure for $urlString: $e2");
    }
  }
}
