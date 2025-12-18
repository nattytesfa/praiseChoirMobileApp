import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/features/admin/presentation/cubit/admin_cubit.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _enableSmsNotifications = true;
  bool _enablePushNotifications = true;
  bool _autoBackupEnabled = false;
  bool _highContrastMode = false;
  double _audioQuality = 0.8;

  final Map<String, bool> _featureToggles = {
    'Song Rotation System': true,
    'Payment Reminders': true,
    'Voice Messages': true,
    'Social Sharing': true,
    'Offline Mode': true,
  };

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will delete all songs, payments, and chat history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAllData();
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
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
    ).showSnackBar(const SnackBar(content: Text('All data has been reset')));
  }

  void _exportData() {
    // This would export all data to a file
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data exported successfully')));
  }

  void _runSystemDiagnostics() {
    context.read<AdminCubit>().checkSystemHealth();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System diagnostics completed')),
    );
  }

  Widget _buildSettingSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
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
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSliderSetting(
    String title,
    String value,
    double currentValue,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title), Text(value)],
        ),
        Slider(
          value: currentValue,
          onChanged: onChanged,
          min: 0.1,
          max: 1.0,
          divisions: 9,
          label: (currentValue * 100).toStringAsFixed(0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Notification Settings
            _buildSettingSection('Notifications', [
              _buildToggleSetting(
                'SMS Notifications',
                'Send critical updates via SMS',
                _enableSmsNotifications,
                (value) => setState(() => _enableSmsNotifications = value),
              ),
              _buildToggleSetting(
                'Push Notifications',
                'App notifications for updates',
                _enablePushNotifications,
                (value) => setState(() => _enablePushNotifications = value),
              ),
            ]),

            const SizedBox(height: 16),

            // Feature Toggles
            _buildSettingSection('Feature Management', [
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

            // Audio Settings
            _buildSettingSection('Audio Settings', [
              _buildSliderSetting(
                'Audio Quality',
                '${(_audioQuality * 100).toStringAsFixed(0)}%',
                _audioQuality,
                (value) => setState(() => _audioQuality = value),
              ),
              const SizedBox(height: 8),
              Text(
                'Higher quality uses more storage',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ]),

            const SizedBox(height: 16),

            // Accessibility
            _buildSettingSection('Accessibility', [
              _buildToggleSetting(
                'High Contrast Mode',
                'Improved visibility',
                _highContrastMode,
                (value) => setState(() => _highContrastMode = value),
              ),
              _buildToggleSetting(
                'Large Text',
                'Increase text size',
                false,
                (value) {}, // Would implement
              ),
            ]),

            const SizedBox(height: 16),

            // Data Management
            _buildSettingSection('Data Management', [
              _buildToggleSetting(
                'Auto Backup',
                'Automatically backup data weekly',
                _autoBackupEnabled,
                (value) => setState(() => _autoBackupEnabled = value),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Export Data'),
                subtitle: const Text('Download all choir data as backup'),
                onTap: _exportData,
              ),
              ListTile(
                leading: const Icon(Icons.health_and_safety),
                title: const Text('Run System Diagnostics'),
                subtitle: const Text('Check system health and performance'),
                onTap: _runSystemDiagnostics,
              ),
            ]),

            const SizedBox(height: 16),

            // Dangerous Settings
            _buildSettingSection('Advanced Settings', [
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.orange),
                title: const Text(
                  'Clear Cache',
                  style: TextStyle(color: Colors.orange),
                ),
                subtitle: const Text('Clear temporary files and cache'),
                onTap: () {
                  // Clear cache implementation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text(
                  'Reset All Data',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('Delete all app data and start fresh'),
                onTap: _showResetConfirmation,
              ),
            ]),

            const SizedBox(height: 16),

            // App Information
            _buildSettingSection('App Information', [
              _buildInfoItem('App Version', AppConstants.appVersion),
              _buildInfoItem('Build Number', '1.0.0+1'),
              _buildInfoItem('Last Updated', '2024-01-01'),
              _buildInfoItem(
                'Database Size',
                'Calculate size',
              ), // Would calculate actual size
            ]),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save all settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings saved successfully'),
                    ),
                  );
                },
                child: const Text('Save Settings'),
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
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
