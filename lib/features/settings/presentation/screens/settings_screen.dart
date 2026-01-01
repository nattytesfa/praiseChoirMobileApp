import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/core/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("settings".tr())),
      body: ListView(
        children: [
          _buildSectionHeader(context, "appearance".tr()),
          _buildThemeSwitch(context),
          const Divider(),
          _buildSectionHeader(context, "language".tr()),
          _buildLanguageSelector(context),
          const Divider(),
          _buildSectionHeader(context, "aboutApp".tr()),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text("aboutApp".tr()),
            subtitle: const Text("Version 1.0.0"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "praiseChoirApp".tr(),
                applicationVersion: "1.0.0",
                applicationLegalese: "© 2026 Praise Choir",
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeSwitch(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark =
            themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return SwitchListTile(
          secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          title: Text("darkMode".tr()),
          value: isDark,
          onChanged: (value) {
            context.read<ThemeCubit>().setTheme(
              value ? ThemeMode.dark : ThemeMode.light,
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text("english").tr(),
          trailing: context.locale == const Locale('en')
              ? Icon(Icons.check, color: Theme.of(context).primaryColor)
              : null,
          onTap: () => context.setLocale(const Locale('en')),
        ),
        ListTile(
          title: Text("amharic").tr(),
          trailing: context.locale == const Locale('am')
              ? Icon(Icons.check, color: Theme.of(context).primaryColor)
              : null,
          onTap: () => context.setLocale(const Locale('am')),
        ),
      ],
    );
  }
}
