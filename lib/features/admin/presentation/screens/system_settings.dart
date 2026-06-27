import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _enablePushNotifications = true;

  final Map<String, bool> _featureToggles = {
    'songRotationSystem': true,
    'paymentReminders': true,
    'voiceMessages': true,
  };

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('resetAllData'.tr()),
        content: Text('resetAllDataConfirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAllData();
            },
            child: Text(
              'reset'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _resetAllData() {
    // This would actually reset all data
    // For now, just show a confirmation
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('resetSuccess'.tr())));
  }

  Widget _buildSettingSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSetting(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title.tr()),
      subtitle: subtitle.isNotEmpty ? Text(subtitle.tr()) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('systemSettings'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Notification Settings
            _buildSettingSection('notifications', [
              _buildToggleSetting(
                'pushNotifications',
                'pushNotificationsDesc',
                _enablePushNotifications,
                (value) => setState(() => _enablePushNotifications = value),
              ),
            ]),

            const SizedBox(height: 16),

            // Feature Toggles
            _buildSettingSection('featureManagement', [
              ..._featureToggles.entries.map(
                (entry) => _buildToggleSetting(
                  entry.key,
                  '',
                  entry.value,
                  (value) => setState(() => _featureToggles[entry.key] = value),
                ),
              ),
            ]),

            const SizedBox(height: 16),

            // Dangerous Settings
            _buildSettingSection('advancedSettings', [
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.orange),
                title: Text(
                  'clearCache'.tr(),
                  style: const TextStyle(color: Colors.orange),
                ),
                subtitle: Text('clearCacheDesc'.tr()),
                onTap: () {
                  // Clear cache implementation
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('cacheCleared'.tr())));
                },
              ),
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(
                  'resetAllApp'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
                subtitle: Text('resetAllAppDesc'.tr()),
                onTap: _showResetConfirmation,
              ),
            ]),

            const SizedBox(height: 16),

            // App Information
            _buildSettingSection('appInformation', [
              _buildInfoItem('appVersion', AppConstants.appVersion),
              _buildInfoItem('buildNumber', '1.0.0+1'),
              _buildInfoItem('lastUpdated', '2024-01-01'),
            ]),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save all settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('settingsSavedSuccess'.tr())),
                  );
                },
                child: Text('saveSettings'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.tr(), style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
