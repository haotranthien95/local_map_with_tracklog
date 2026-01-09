# Research Findings: Modern UI Redesign and Localization

## UI Paradigms: Cupertino-Inspired Material

### Glassmorphism (Frosted Glass)
- **Decision**: Use `BackdropFilter` with `ImageFilter.blur` for Navigation Bars and persistent overlays.
- **Rationale**: Provides the signature iOS look and feel while remaining within the Flutter Material component tree.
- **Alternatives**: `glassmorphism` package was considered but manual `BackdropFilter` offers more granular control over `sigma` values and performance.

### Typography: Inter Font
- **Decision**: Use `google_fonts` package for dynamic loading/caching or local assets for offline stability.
- **Rationale**: Inter is the current gold standard for UI legibility and perfectly complements the Cupertino aesthetic.
- **Implementation**: Set as `fontFamily` in global `ThemeData`.

### Transitions: Universal iOS Slide
- **Decision**: Force `CupertinoPageTransitionsBuilder` in `PageTransitionsTheme`.
- **Rationale**: Consistent "Interactive" feel across both iOS and Android.

## Localization Strategy

### Package Selection
- **Decision**: Use `flutter_localizations` and `intl`.
- **Rationale**: Official Flutter packages, best supported, and works with standard ARB file formats.

## Color Harmonization (#01965D)

### Palette Mapping
- **Primary**: #01965D (Green)
- **Light Mode Surface**: White (Opacity 0.8 with blur for glass elements).
- **Dark Mode Surface**: #121212 / Dark Grey (Opacity 0.7 with blur).
- **Secondary**: Derived via `ColorScheme.fromSeed`.

## Hardcoded Strings Audit (Sample)
- `Dashboard`, `Settings`, `Login`, `Password`, `Email`, `Register`, `Delete Account`, `Are you sure?`, etc.
- A full grep will be performed during Phase 2.
