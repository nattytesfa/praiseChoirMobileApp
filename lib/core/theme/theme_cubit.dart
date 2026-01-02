import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  // Toggle between light and dark
  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(newMode);
    _saveTheme(newMode);
  }

  void setTheme(ThemeMode mode) {
    emit(mode);
    _saveTheme(mode);
  }

  // Persist choice to Hive
  void _saveTheme(ThemeMode mode) async {
    var box = await Hive.openBox('settings');
    box.put('isDarkMode', mode == ThemeMode.dark);
  }

  void _loadTheme() async {
    var box = await Hive.openBox('settings');
    bool? isDark = box.get('isDarkMode');
    if (isDark != null) {
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    }
  }
}
