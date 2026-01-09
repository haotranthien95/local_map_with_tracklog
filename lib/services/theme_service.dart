import 'package:flutter/material.dart';

abstract class IThemeService {
  /// Returns the current theme mode
  ThemeMode get themeMode;

  /// Updates the theme mode and persists it
  Future<void> setThemeMode(ThemeMode mode);

  /// Loads the persisted theme mode on startup
  Future<ThemeMode> loadThemeMode();

  /// Returns the ThemeData for the specified brightness
  ThemeData getTheme(Brightness brightness);
}
