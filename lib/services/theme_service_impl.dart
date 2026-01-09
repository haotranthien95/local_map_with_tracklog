import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_service.dart';
import '../theme/app_theme_data.dart';

class ThemeServiceImpl implements IThemeService {
  static const String _themeModeKey = 'theme_mode';
  final SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeServiceImpl(this._prefs) {
    _loadThemeModeSync();
  }

  void _loadThemeModeSync() {
    final index = _prefs.getInt(_themeModeKey);
    if (index != null) {
      _themeMode = ThemeMode.values[index];
    }
  }

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_themeModeKey, mode.index);
  }

  @override
  Future<ThemeMode> loadThemeMode() async {
    final index = _prefs.getInt(_themeModeKey);
    if (index != null) {
      _themeMode = ThemeMode.values[index];
    }
    return _themeMode;
  }

  @override
  ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.light ? AppThemeData.lightTheme : AppThemeData.darkTheme;
  }
}
