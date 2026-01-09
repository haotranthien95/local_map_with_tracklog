---

description: "Task list for feature implementation"
---

# Tasks: App Store Review Compliance

**Input**: Design documents from `specs/007-appstore-review-compliance/`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Minimal setup required to implement compliance work safely

- [ ] T001 Update dependencies for link + photo picking in pubspec.yaml
- [ ] T002 Refresh dependency lockfile after dependency changes in pubspec.lock
- [ ] T003 [P] Add compliance UI localization keys in lib/l10n/app_en.arb
- [ ] T004 [P] Add compliance UI localization keys in lib/l10n/app_vi.arb
- [ ] T005 [P] Add compliance UI localization keys in lib/l10n/app_zh.arb
- [ ] T006 [P] Add compliance UI localization keys in lib/l10n/app_ja.arb

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared building blocks that must exist before implementing any user story

- [ ] T007 Create URL opening helper service in lib/services/external_link_service.dart
- [ ] T008 Create local profile photo model in lib/models/profile_photo.dart
- [ ] T009 Create local profile photo storage service in lib/services/profile_photo_service.dart
- [ ] T010 Create app-level privacy manifest file in ios/Runner/PrivacyInfo.xcprivacy
- [ ] T011 Add PrivacyInfo.xcprivacy to Runner target resources in ios/Runner.xcodeproj/project.pbxproj

**Checkpoint**: Foundation ready — user story implementation can proceed

---

## Phase 3: User Story 1 - Clear Permissions & Privacy Transparency (Priority: P1) 🎯 MVP

**Goal**: Only request permissions on explicit user action, with clear explanations and denial-safe UX.

**Independent Test**: Follow section “1) Permission behavior” and “3) Profile picture update” in specs/007-appstore-review-compliance/quickstart.md on a fresh install.

- [ ] T012 [US1] Remove background/Always location usage description key in ios/Runner/Info.plist
- [ ] T013 [US1] Update location usage description text for When-In-Use clarity in ios/Runner/Info.plist
- [ ] T014 [US1] Update Photo Library usage description to “profile picture” purpose in ios/Runner/Info.plist
- [ ] T015 [US1] Restrict granted permission check to whileInUse only in lib/services/location_service.dart
- [ ] T016 [US1] Restrict granted permission check to whileInUse only in lib/features/show_current_location/services/location_service.dart
- [ ] T017 [US1] Add “Open Settings” guidance path for deniedForever location in lib/screens/map_screen.dart
- [ ] T018 [US1] Ensure no location permission request occurs during startup/initState in lib/screens/map_screen.dart
- [ ] T019 [US1] Add “Change profile picture” action entry point in lib/screens/profile_screen.dart
- [ ] T020 [US1] Implement image selection via image_picker in lib/screens/profile_screen.dart
- [ ] T021 [US1] Persist selected image on-device (copy into app storage) in lib/services/profile_photo_service.dart
- [ ] T022 [US1] Load persisted profile photo on profile screen and render it first in lib/screens/profile_screen.dart
- [ ] T023 [US1] Handle photo pick cancel/denial with localized messaging in lib/screens/profile_screen.dart
- [ ] T024 [US1] Ensure Photo Library access is requested only after user taps “Change profile picture” in lib/screens/profile_screen.dart

**Checkpoint**: Story 1 is complete and independently testable

---

## Phase 4: User Story 2 - Account & Sign-in Policy Compliance (Priority: P2)

**Goal**: Ensure sign-in options comply (Apple sign-in present where applicable) and in-app deletion remains robust and clear.

**Independent Test**: Follow “4) Account deletion” in specs/007-appstore-review-compliance/quickstart.md for email/password, Google, and Apple accounts.

- [ ] T025 [US2] Ensure Apple button appears on iOS with comparable prominence in lib/widgets/social_login_buttons.dart
- [ ] T026 [US2] Verify Apple sign-in flow is wired from login UI in lib/screens/login_screen.dart
- [ ] T027 [US2] Verify Apple sign-in flow is wired from registration UI in lib/screens/register_screen.dart
- [ ] T028 [US2] Ensure delete account confirmation explains what will be deleted in lib/features/auth/widgets/delete_account_dialog.dart
- [ ] T029 [US2] Ensure delete account flow handles cancel/error paths without destructive side-effects in lib/features/auth/screens/delete_account_flow.dart
- [ ] T030 [US2] Verify deletion clears local user data and signs out on success in lib/services/authentication_service.dart
- [ ] T031 [US2] Ensure account settings routes to delete flow and uses localized strings in lib/screens/account_settings_screen.dart
- [ ] T032 [US2] Update account deletion manual test steps for each provider in specs/007-appstore-review-compliance/quickstart.md

**Checkpoint**: Story 2 is complete and independently testable

---

## Phase 5: User Story 3 - Submission Readiness & Legal Disclosures (Priority: P3)

**Goal**: Ensure required disclosures are present in-app, map attribution is visible, and offline/error paths are stable.

**Independent Test**: Follow “2) Privacy policy link” and “5) Offline resilience” in specs/007-appstore-review-compliance/quickstart.md.

- [ ] T033 [US3] Replace placeholder privacy policy URL with real HTTPS URL in lib/features/auth/constants/auth_constants.dart
- [ ] T034 [US3] Add Settings/About section and Privacy Policy link (2 taps) in lib/screens/settings_screen.dart
- [ ] T035 [US3] Implement HTTPS-only URL launch (with failure handling) in lib/services/external_link_service.dart
- [ ] T036 [US3] Localize remaining compliance-critical strings on Settings screen in lib/screens/settings_screen.dart
- [ ] T037 [US3] Verify map attribution is always visible and adjust widget/layout if needed in lib/screens/map_screen.dart
- [ ] T038 [US3] Ensure offline handling on tracklog list is crash-free and user-friendly in lib/screens/tracklog_list_screen.dart
- [ ] T039 [US3] Ensure offline/error handling on map is crash-free and user-friendly in lib/screens/map_screen.dart
- [ ] T040 [US3] Fill out app privacy manifest declarations based on actual APIs used in ios/Runner/PrivacyInfo.xcprivacy

**Checkpoint**: Story 3 is complete and independently testable

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final reviewer-facing fit-and-finish and validation

- [ ] T041 [P] Remove compliance-related hardcoded strings introduced/remaining in lib/screens/profile_screen.dart
- [ ] T042 [P] Remove compliance-related hardcoded strings introduced/remaining in lib/screens/account_settings_screen.dart
- [ ] T043 Validate end-to-end preflight checklist and record results in specs/007-appstore-review-compliance/quickstart.md
- [ ] T044 Confirm no ATT prompt code exists (document search results) in specs/007-appstore-review-compliance/research.md
- [ ] T045 Document final permissions-to-features mapping in specs/007-appstore-review-compliance/research.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1) → blocks Foundational
- Foundational (Phase 2) → blocks all User Stories
- User Story 1 (Phase 3) → MVP checkpoint
- User Story 2 (Phase 4) and User Story 3 (Phase 5) → can proceed after Phase 2; implement in priority order unless parallelized
- Polish (Phase 6) → after all desired stories

### User Story Dependency Graph

- US1 depends on Phase 1–2 only
- US2 depends on Phase 1–2 only
- US3 depends on Phase 1–2 only

Suggested completion order (priority): Phase 1 → Phase 2 → US1 → US2 → US3 → Polish

---

## Parallel Execution Examples

### User Story 1

Run in parallel (different files): T012 (ios/Runner/Info.plist), T015 (lib/services/location_service.dart), T019 (lib/screens/profile_screen.dart)

### User Story 2

Run in parallel (different files): T025 (lib/widgets/social_login_buttons.dart), T028 (lib/features/auth/widgets/delete_account_dialog.dart), T031 (lib/screens/account_settings_screen.dart)

### User Story 3

Run in parallel (different files): T034 (lib/screens/settings_screen.dart), T037 (lib/screens/map_screen.dart), T038 (lib/screens/tracklog_list_screen.dart)

---

## Implementation Strategy

### MVP Scope (User Story 1 Only)

- Complete Phase 1 and Phase 2
- Implement US1 tasks (Phase 3)
- Validate with specs/007-appstore-review-compliance/quickstart.md

### Incremental Delivery

- After US1 passes the quickstart checks, implement US2 then US3
- Finish with Polish tasks and re-run the full quickstart checklist
