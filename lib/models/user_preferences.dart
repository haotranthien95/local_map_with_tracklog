import 'package:flutter/material.dart';

class UserPreferences {
  final Locale? selectedLocale;
  final ThemeMode themeMode;

  UserPreferences({
    this.selectedLocale,
    this.themeMode = ThemeMode.system,
  });

  UserPreferences copyWith({
    Locale? selectedLocale,
    ThemeMode? themeMode,
  }) {
    return UserPreferences(
      selectedLocale: selectedLocale ?? this.selectedLocale,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  String toString() => 'UserPreferences(locale: $selectedLocale, theme: $themeMode)';
}
