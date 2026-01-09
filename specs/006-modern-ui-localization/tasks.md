# Tasks: Modern UI Redesign and Localization

**Input**: Design documents from `/specs/006-modern-ui-localization/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/
**Tests**: OPTIONAL - No specific test tasks requested in specification.
**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- File paths are absolute or relative to project root

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 [P] Add dependencies `flutter_localizations`, `intl`, `google_fonts`, `shared_preferences` to `pubspec.yaml`
- [x] T002 Initialize localization config in `l10n.yaml`
- [x] T003 [P] Create directory `lib/l10n/` for ARB files
- [x] T004 Create directory `lib/theme/` for styling logic

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented
**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 [P] Implement `UserPreferences` entity in `lib/models/user_preferences.dart`
- [x] T006 [P] Implement `ILocalizationService` contract in `lib/services/localization_service.dart` (interface)
- [x] T007 [P] Implement `IThemeService` contract in `lib/services/theme_service.dart` (interface)
- [x] T008 [P] Initialize base ARB template `lib/l10n/app_en.arb` with shared labels

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Unified Visual Identity (Priority: P1) 🎯 MVP

**Goal**: Implement the primary green theme (#01965D) and Inter font across all screens.

**Independent Test**: Verify that all screens use the same primary green, Inter typography, and rounded corners by navigating through all screens (Login, Home, Map).

### Implementation for User Story 1

- [ ] T009 [P] [US1] Define `AppThemeConfig` constants (Primary #01965D, Inter Font) in `lib/theme/app_theme_config.dart`
- [ ] T010 [US1] Implement `ThemeService` (Light/Dark palettes) in `lib/services/theme_service_impl.dart`
- [ ] T011 [US1] Set Inter as default font family in `ThemeData` within `lib/theme/app_theme_data.dart`
- [ ] T012 [US1] Update `main.dart` to consume `ThemeMode` from `ThemeService`
- [ ] T013 [US1] Update `AuthButton` and `AuthTextField` in `lib/widgets/` to use theme-aware colors and shapes
- [ ] T014 [US1] Refactor `lib/screens/login_screen.dart` to use `Theme.of(context).primaryColor`
- [ ] T015 [US1] Refactor `lib/screens/dashboard_screen.dart` and `lib/screens/home_screen.dart` to follow the new UI theme

**Checkpoint**: User Story 1 is functional. The app has a unified green brand identity and modern typography.

---

## Phase 4: User Story 2 - Multi-Language Support (Priority: P1)

**Goal**: Support EN, VN, CN, and JP languages with a switcher in settings.

**Independent Test**: Switch language in Settings and verify all labels update instantly in all 4 languages.

### Implementation for User Story 2

- [ ] T016 [P] [US2] Create Vietnamese localization in `lib/l10n/app_vi.arb`
- [ ] T017 [P] [US2] Create Chinese localization in `lib/l10n/app_zh.arb`
- [ ] T018 [P] [US2] Create Japanese localization in `lib/l10n/app_ja.arb`
- [ ] T019 [US2] Implement `LocalizationService` (Locale management) in `lib/services/localization_service_impl.dart`
- [ ] T020 [US2] Wrap `MaterialApp` with localization delegates in `lib/main.dart`
- [ ] T021 [US2] Externalize strings in `lib/screens/login_screen.dart` using `AppLocalizations`
- [ ] T022 [US2] Externalize strings in `lib/screens/register_screen.dart` using `AppLocalizations`
- [ ] T023 [US2] Externalize strings in `lib/screens/home_screen.dart` using `AppLocalizations`
- [ ] T024 [US2] Create language selection UI in `lib/screens/settings_screen.dart`

**Checkpoint**: User Stories 1 and 2 are complete. The app is consistent and multi-lingual.

---

## Phase 5: User Story 3 - Interactive & Modern Experience (Priority: P2)

**Goal**: Implement smooth transitions and glassmorphic UI elements.

**Independent Test**: Verify iOS-style slide transitions when navigating and visual blur effects in top/bottom bars.

### Implementation for User Story 3

- [ ] T025 [P] [US3] Implement `GlassBox` widget (BackdropFilter) in `lib/widgets/glass_box.dart`
- [ ] T026 [US3] Update `AppThemeData` to force `CupertinoPageTransitionsBuilder` for iOS and Android in `lib/theme/app_theme_data.dart`
- [ ] T027 [US3] Refactor `lib/features/map/widgets/map_view.dart` map controls to use glassmorphic backgrounds
- [ ] T028 [US3] Add subtle scale-on-press animations to `AuthButton` in `lib/widgets/auth_button.dart`

**Checkpoint**: All user stories are functional and the app feels premium and interactive.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final persistence, UX refinements, and validation.

- [ ] T029 [P] Implement `shared_preferences` persistence in `ThemeService` and `LocalizationService`
- [ ] T030 Ensure unified dark mode contrast for primary green #01965D across all screens
- [ ] T031 Clean up orphan hardcoded colors and styles in legacy files
- [ ] T032 Run `quickstart.md` validation steps and update documentation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies.
- **Phase 2 (Foundational)**: Depends on Phase 1.
- **Phase 3 (US1)**, **Phase 4 (US2)**, **Phase 5 (US3)**: All depend on Phase 2 completion.
  - US2 (Localization) depends on foundational ARB setup.
  - US3 (Interactive) depends on US1 (Theme) constants.
- **Phase 6 (Polish)**: Depends on all previous phases.

### Parallel Opportunities

- T001, T003 can run in parallel.
- T005, T006, T007, T008 in Phase 2 can run in parallel.
- US1 (Theme) and US2 (Localization) can be worked on in parallel once Phase 2 is done.
- T016, T017, T018 (Translating ARB files) can be done in parallel.

---

## Parallel Execution Examples

### User Story 2 (Localization)
```bash
# Parallel ARB creation:
Task: "Create Vietnamese localization in lib/l10n/app_vi.arb"
Task: "Create Chinese localization in lib/l10n/app_zh.arb"
Task: "Create Japanese localization in lib/l10n/app_ja.arb"
```

## Implementation Strategy

### MVP First (User Story 1 & 2 Core)

1. Complete Setup and Foundational tasks.
2. Complete US1 (Theme) up to the login and home screen.
3. Complete US2 (Localization) for EN and VN only.
4. **STOP and VALIDATE**: Verify the "Look and Feel" (Green + Inter) and "Language" (EN/VN) work.

### Incremental Delivery

1. Foundation ready.
2. Deliver US1 (Theme facelift).
3. Deliver US2 (multi-language).
4. Deliver US3 (Interactive polish).
