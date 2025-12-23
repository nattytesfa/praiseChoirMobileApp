import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  // Toggle between light and dark
  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);
    _saveTheme(newMode);
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