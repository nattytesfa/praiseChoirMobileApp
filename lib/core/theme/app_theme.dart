import 'package:flutter/material.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.gray50,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.white,
      onSurface: AppColors.gray900,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.gray50,
      foregroundColor: AppColors.gray900,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: _inputDecorationTheme(
      baseColor: AppColors.gray200,
      focusedColor: AppColors.primary,
      fillColor: AppColors.white,
      textColor: AppColors.gray900,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      error: AppColors.darkError,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkOnAppBar,
      foregroundColor: AppColors.gray50,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: _inputDecorationTheme(
      baseColor: AppColors.gray400,
      focusedColor: AppColors.gray100,
      fillColor: AppColors.fillDark,
      textColor: AppColors.white60,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      titleTextStyle: TextStyle(inherit: false, color: Colors.white),
      tileColor: AppColors.darkOnSongsCard,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: AppColors.darkOnAppBar),
  );

  static InputDecorationTheme _inputDecorationTheme({
    required Color baseColor,
    required Color focusedColor,
    required Color fillColor,
    required Color textColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      prefixIconColor: AppColors.white38,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: baseColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: focusedColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: AppColors.error),
      ),
      labelStyle: TextStyle(
        color: textColor.withValues(alpha: 0.7),
        fontSize: 14,
      ),
    );
  }
}
