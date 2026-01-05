import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/core/theme/theme_cubit.dart';

import '../../../../core/theme/app_text_styles.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text("settings".tr())),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, "appearance".tr()),
            const SizedBox(height: 12),
            _buildSettingsCard(_buildThemeSwitch(context)),
            _coolDivider(context),
            _buildSectionHeader(context, "language".tr()),
            const SizedBox(height: 12),
            _buildSettingsCard(_buildLanguageSelector(context)),
            _coolDivider(context),
            const SizedBox(height: 15),
            _buildSectionHeader(context, "aboutApp".tr()),

            const SizedBox(height: 8),

            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text("aboutApp".tr()),
                subtitle: const Text("Version 1.0.0"),
                tileColor: Colors.transparent,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Center(child: Text("Praise Choir App")),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Version 1.0.0"),
                          const SizedBox(height: 16),
                          Text(
                            "© 2026 PraiseChoir\n All Rights Reserved.",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Developed With ❤️ by Natnael",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("close".tr()),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSectionHeader(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _buildSettingsCard(Widget anotherBuilder) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
    clipBehavior: Clip.antiAlias,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(children: [anotherBuilder]),
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
        secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
        title: Text(isDark ? "darkMode".tr() : "lightMode".tr()),
        value: isDark,
        tileColor: Colors.transparent,
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
        title: Text("english".tr()),
        tileColor: Colors.transparent,
        trailing: context.locale == const Locale('en')
            ? Icon(Icons.check, color: Colors.amber)
            : null,
        onTap: () => context.setLocale(const Locale('en')),
      ),
      ListTile(
        title: Text("amharic".tr()),
        tileColor: Colors.transparent,
        trailing: context.locale == const Locale('am')
            ? Icon(Icons.check, color: Colors.amber)
            : null,
        onTap: () => context.setLocale(const Locale('am')),
      ),
    ],
  );
}

Widget _coolDivider(BuildContext context) {
  final color = Theme.of(context).colorScheme.onSurface;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.withValues(color, 0.0),
                  AppColors.withValues(color, 0.12),
                  AppColors.withValues(color, 0.0),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    ),
  );
}
