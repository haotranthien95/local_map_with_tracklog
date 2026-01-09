# Data Model: Modern UI Redesign and Localization

## Entities

### UserPreferences
Represents the user's localized and visual settings.
- **Fields**:
  - `selectedLocale`: String (e.g., 'en', 'vi', 'zh', 'ja')
  - `themeMode`: Enum (light, dark, system)
- **Validation**:
  - `selectedLocale` MUST be one of the supported 4 languages.
- **State Transitions**:
  - User updates locale → App triggers rebuild with new `Locale`.
  - User updates theme → App triggers rebuild with new `ThemeMode`.

### AppThemeConfig (Internal)
Technical configuration for the design system.
- **Fields**:
  - `primaryColor`: Color (Fixed: #01965D)
  - `fontFamily`: String (Fixed: 'Inter')
  - `glassEffectSigma`: Double (Default: 10.0)
- **Rationale**: Keeps style constants centralized and decoupled from widgets.

## Relationships
- `UserPreferences` is persisted to local storage (Settings).
- `AppThemeConfig` is consumed by `MaterialApp.theme` and `MaterialApp.darkTheme`.
