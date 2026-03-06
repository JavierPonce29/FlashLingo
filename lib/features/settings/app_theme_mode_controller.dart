import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePreferenceKey = 'app_theme_mode';

final appThemeModeProvider =
    StateNotifierProvider<AppThemeModeController, ThemeMode>(
      (ref) => AppThemeModeController(),
    );

class AppThemeModeController extends StateNotifier<ThemeMode> {
  AppThemeModeController() : super(ThemeMode.system) {
    _loadSavedThemeMode();
  }

  Future<void> _loadSavedThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    final rawValue = preferences.getString(_themeModePreferenceKey);
    state = _themeModeFromStorage(rawValue);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (state == themeMode) return;
    state = themeMode;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _themeModePreferenceKey,
      _themeModeToStorage(themeMode),
    );
  }

  ThemeMode _themeModeFromStorage(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToStorage(ThemeMode value) {
    switch (value) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }
}
