import 'package:flutter/material.dart';
import 'package:praise_choir_app/config/routes.dart';
import 'package:praise_choir_app/core/theme/app_theme.dart' show AppTheme;

class ChoirApp extends StatelessWidget {
  const ChoirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PCS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: Routes.generateRoute,
      initialRoute: Routes.splash,
      debugShowCheckedModeBanner: false,
    );
  }
}
