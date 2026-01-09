import 'package:flutter/material.dart';

abstract class ILocalizationService {
  /// Returns the current locale
  Locale get currentLocale;

  /// Updates the application locale and persists it
  Future<void> setLocale(Locale locale);

  /// Loads the persisted locale on startup
  Future<Locale> loadLocale();

  /// Supported locales list
  List<Locale> get supportedLocales;
}
