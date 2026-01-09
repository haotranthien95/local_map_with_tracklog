# Implementation Plan - Modern UI Redesign and Localization

**Feature Branch**: `006-modern-ui-localization`  
**Spec**: [spec.md](./spec.md)  
**Drafted**: 2026-01-09

## Technical Context

### Existing Architecture
- **Framework**: Flutter 3.5.4
- **State Management**: Using `StatefulWidget` and `setState` (matches Constitution Principle II).
- **Navigation**: Using named routes in `MaterialApp`.
- **Localization**: No current localization; strings are hardcoded.
- **Theme**: Basic Material 3 theme with `seedColor: Colors.blue`.

### Discovery Findings
- **Fonts**: Inter font family is NOT currently in the project. Needs to be added to `assets/fonts/` and declared in `pubspec.yaml`.
- **Localization Packages**: `flutter_localizations` and `intl` need to be added to `pubspec.yaml`.
- **UI System**: Transitioning from Material 3 to a Custom Cupertino-inspired design while retaining Material components where beneficial.

### NEEDS CLARIFICATION
- None (All resolved in clarification session).

---

## Constitution Check

| Principle | Adherence Plan |
|-----------|----------------|
| **I. MVP-First** | Deliver core theme and EN/VN localization first before adding CN/JP. |
| **II. Minimal Viable Features** | Focus on UI/UX facelift and externalizing strings; avoid rewriting business logic. |
| **III. Independent User Stories** | Each user story (Theme, Localization, Interactive) can be built and tested independently. |
| **IV. Progressive Enhancement** | Start with static theme values before adding dynamic theme switching. |
| **V. Maintainability** | Use standard Flutter localization patterns (ARB files) for easy maintenance. |

---

## Phase 0: Outline & Research

### Research Tasks
- **R-001**: Research best practices for implementing a "Cupertino-inspired" theme in a Material Flutter app (Glassmorphism, refined typography).
- **R-002**: Find license-compatible Inter font files (Google Fonts).
- **R-003**: Identify all hardcoded strings across `lib/` using grep.

---

## Phase 1: Design & Contracts

### Data Model Updates
- **M-001**: Create `ThemeSettings` model (ThemeMode: light/dark/system).
- **M-002**: Create `LanguageSettings` model (Locale).

### API & Contracts
- **C-001**: Define `LocalizationService` contract for setting/getting locale.
- **C-002**: Define `AppThemeData` contract providing color palettes and `TextStyle` overrides.

---

## Phase 2: Implementation Steps

### Step 1: Foundation & Dependencies
- Add `flutter_localizations`, `intl`, and `google_fonts` or assets for Inter font.
- Configure `l10n.yaml` and create initial ARB files.

### Step 2: Global Theme & Font
- Implement `AppTheme` class with Cupertino-inspired Light and Dark palettes.
- Set Inter as the default font family in `ThemeData`.
- Update `main.dart` to use the new theme system.

### Step 3: Localization Implementation
- Externalize strings in `LoginScreen`, `RegisterScreen`, and `HomeScreen`.
- Implement language switcher in `SettingsScreen`.

### Step 4: UI Refacelift (Vertical Slices)
- **Slice 1 (Auth)**: Update Login/Register screens with glassmorphic cards and refined inputs.
- **Slice 2 (Home/Dashboard)**: Update Dashboard navigation and cards.
- **Slice 3 (Map UI)**: Refine map controls and bottom sheets.

### Step 5: Persistance & Feedback
- Save theme/language preferences via `shared_preferences`.
- Add interactive animations (iOS transitions) and haptic feedback.

---

## Gate Evaluation

- **Gate 1 (Consistency)**: Do all screens share the same #01965D primary color and Inter font?
- **Gate 2 (Localization)**: Can the app switch between all 4 languages without restart?
- **Gate 3 (UX)**: Does the app behave with Cupertino-style transitions and aesthetics?

## Stop and Report
- **Branch**: `006-modern-ui-localization`
- **Plan Path**: [plan.md](./plan.md)
- **Artifacts**: `research.md` to be generated next.
