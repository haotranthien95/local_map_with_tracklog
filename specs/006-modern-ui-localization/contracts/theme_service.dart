abstract class IThemeService {
  /// Returns the current theme mode
  ThemeMode get themeMode;

  /// Updates the theme mode and persists it
  Future<void> setThemeMode(ThemeMode mode);

  /// Returns the AppThemeData (computed colors/styles)
  ThemeData getTheme(Brightness brightness);
}
