import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  static const String _configUrl = 'https://pcma-fc751.web.app';

  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      // 1. Fetch remote JSON file details
      final response = await http.get(Uri.parse(_configUrl));
      if (response.statusCode != 200) return;

      final Map<String, dynamic> remoteData = json.decode(response.body);
      final int latestBuildNumber = remoteData['build_number'];
      final String downloadUrl = remoteData['apk_url'];
      final bool isRequired = remoteData['is_required'] ?? false;

      // 2. Read local project info (from pubspec.yaml version)
      final packageInfo = await PackageInfo.fromPlatform();
      final int currentBuildNumber = int.parse(packageInfo.buildNumber);

      // 3. Trigger alert dialog if server version is higher
      if (latestBuildNumber > currentBuildNumber && context.mounted) {
        _showUpdateDialog(context, downloadUrl, isRequired);
      }
    } catch (error) {
      debugPrint('Update check failed quietly: $error');
    }
  }

  static void _showUpdateDialog(
    BuildContext context,
    String apkUrl,
    bool isRequired,
  ) {
    showDialog(
      context: context,
      // If update is mandatory, block user from dismissing by clicking outside
      barrierDismissible: !isRequired,
      builder: (context) {
        return PopScope(
          // Block Android physical hardware back button if update is mandatory
          canPop: !isRequired,
          child: AlertDialog(
            title: const Text('Update Available'),
            content: Text(
              isRequired
                  ? 'A critical new update is required to continue using this application.'
                  : 'A new version with enhancements is available. Would you like to update now?',
            ),
            actions: [
              if (!isRequired)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Later'),
                ),
              ElevatedButton(
                onPressed: () async {
                  final Uri url = Uri.parse(apkUrl);
                  // Launching in externalApplication mode prompts browser download directly
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text('Update Now'),
              ),
            ],
          ),
        );
      },
    );
  }
}
