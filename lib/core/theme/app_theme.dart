import 'package:flutter/material.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.gray200,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      surface: AppColors.gray50,
      onSurface: AppColors.gray900,
      error: AppColors.error,
      onError: AppColors.white,
    ),
    iconTheme: const IconThemeData(color: AppColors.gray900),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.gray200,
      foregroundColor: AppColors.gray900,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.gray900),
    ),
    inputDecorationTheme: _inputDecorationTheme(
      baseColor: AppColors.gray200,
      focusedColor: AppColors.primary,
      fillColor: AppColors.white,
      textColor: AppColors.gray900,
      iconColor: AppColors.gray500,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.gray200, width: 1),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: AppColors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      iconColor: AppColors.gray600,
      textColor: AppColors.gray900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.gray200,
      thickness: 1,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.darkBackground,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.white,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      error: AppColors.darkError,
      onError: AppColors.darkBackground,
    ),
    iconTheme: const IconThemeData(color: AppColors.white60),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkOnAppBar,
      foregroundColor: AppColors.gray50,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.gray50),
    ),
    inputDecorationTheme: _inputDecorationTheme(
      baseColor: AppColors.gray400,
      focusedColor: AppColors.gray100,
      fillColor: AppColors.fillDark,
      textColor: AppColors.white60,
      iconColor: AppColors.white38,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkOnSongsCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    listTileTheme: const ListTileThemeData(
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      subtitleTextStyle: TextStyle(fontSize: 14, color: AppColors.white60),
      tileColor: AppColors.darkOnSongsCard,
      iconColor: AppColors.white60,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: AppColors.darkOnAppBar),
    dividerTheme: const DividerThemeData(
      color: AppColors.gray800,
      thickness: 1,
    ),
  );

  static InputDecorationTheme _inputDecorationTheme({
    required Color baseColor,
    required Color focusedColor,
    required Color fillColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      prefixIconColor: iconColor,
      suffixIconColor: iconColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: TextStyle(color: textColor.withValues(alpha: 0.5)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: baseColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: focusedColor, width: 1.5),
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
