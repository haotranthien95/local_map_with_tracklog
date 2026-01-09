# Quickstart: Modern UI Redesign and Localization (006)

## Development Setup

1. **Install Dependencies**:
   ```bash
   flutter pub add intl flutter_localizations --sdk=flutter
   flutter pub add google_fonts shared_preferences
   ```

2. **Localization Code Generation**:
   Ensure `l10n.yaml` is present in the root:
   ```yaml
   arb-dir: lib/l10n
   template-arb-file: app_en.arb
   output-localization-file: app_localizations.dart
   ```
   Run `flutter gen-l10n` to generate translation keys.

3. **Inter Font**:
   The project uses `google_fonts` for Inter. If offline development is required, fonts are located in `assets/fonts/inter/`.

## Core Components

- **Theme**: `lib/services/theme_service.dart` manages `ThemeMode` and palette generation.
- **Localization**: `lib/l10n/` contains all ARB files.
- **UI Widgets**: Use `GlassBox` (custom widget) for consistent frosted glass effects.

## Verification Command

```bash
# Verify UI consistency across locales
flutter test test/ui_localization_test.dart
```
