# Tasks: Delete Account Without Password

**Feature Branch**: `004-delete-account-nopass`  
**Input**: Design documents from `/specs/004-delete-account-nopass/`  
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: Not requested in specification; manual testing approach per project constitution.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

---

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Project initialization and folder structure for delete flow

- [X] T001 Create feature folder structure: `lib/features/auth/screens/` and `lib/features/auth/widgets/`
- [X] T002 Verify Firebase Auth, Google Sign-In, and Sign-In with Apple dependencies in `pubspec.yaml` (already present; no action needed)

**Checkpoint**: Folder structure ready for implementation

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core provider reauthentication infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T003 [P] Add provider detection helpers to `lib/services/authentication_service.dart`: `isGoogleLinked()`, `isAppleLinked()`, `isSocialOnlyUser()`, `getLinkedProviders()`
- [X] T004 [P] Add `reauthenticateWithGoogle()` method to `lib/services/authentication_service.dart` with Google Sign-In flow
- [X] T005 [P] Add `reauthenticateWithApple()` method to `lib/services/authentication_service.dart` with Apple Sign-In flow
- [X] T006 Extend error constants in `lib/features/auth/constants/auth_constants.dart` with provider reauthentication error messages: `requires-recent-login`, `provider-revoked`, `network-request-failed`, `popup-closed-by-user`, `invalid-credential`, `provider-not-linked`, `user-disabled`, `too-many-requests`, `reauthentication-failed`, `no-auth-method`

**Checkpoint**: Foundation ready - provider reauthentication APIs available; user story implementation can now begin

---

## Phase 3: User Story 1 - Delete account with social provider (Priority: P1) 🎯 MVP

**Goal**: Social-only user (Google or Apple, no email/password) can delete their account by reauthenticating with their provider; account and local data are removed.

**Independent Test**: Signed-in social-only user triggers delete, reauths with provider, account deleted, local data cleared, app shows sign-in screen on relaunch.

### Implementation for User Story 1

- [X] T007 [US1] Modify `deleteAccount({String? password})` in `lib/services/authentication_service.dart` to detect social-only users and route to provider reauthentication (no fallback logic yet; single provider only)
- [X] T008 [US1] Add `_cleanupLocalDataAfterDelete()` helper method in `lib/services/authentication_service.dart` with partial cleanup tolerance (continue on failures, log errors)
- [X] T009 [P] [US1] Create delete confirmation dialog widget in `lib/features/auth/widgets/delete_account_dialog.dart` with Cancel and Delete buttons
- [X] T010 [US1] Create delete account flow screen in `lib/features/auth/screens/delete_account_flow.dart` with confirmation, loading state, error display (retry/cancel buttons), and success navigation
- [X] T011 [US1] Add route `/delete_account` to app router (in `lib/main.dart` or router file) pointing to `DeleteAccountFlow`
- [X] T012 [US1] Add "Delete Account" button to account settings screen (`lib/screens/account_settings_screen.dart` or profile screen) that navigates to `/delete_account`
- [ ] T013 [US1] Manual test: Social-only user (Google) deletes account successfully; verify Firebase account removed, local data cleared (shared_preferences, tokens), app navigates to sign-in

**Checkpoint**: User Story 1 complete and independently functional - social-only users can delete accounts with single provider

---

## Phase 4: User Story 2 - Handle reauth friction (Priority: P2)

**Goal**: If Firebase requires recent login (stale session), user is guided to reauthenticate; deletion proceeds automatically after reauth succeeds (no manual retry needed).

**Independent Test**: Force `requires-recent-login` error; user completes provider reauth; delete succeeds automatically without additional confirmation.

### Implementation for User Story 2

- [X] T014 [US2] Extend `deleteAccount()` in `lib/services/authentication_service.dart` to detect `requires-recent-login` error and automatically retry deletion after successful reauthentication (per clarification Q2: auto-retry)
- [X] T015 [US2] Update delete account flow screen (`lib/features/auth/screens/delete_account_flow.dart`) to show progress indicator during auto-retry: "Deleting account..." after reauth succeeds
- [X] T016 [US2] Add fallback logic in `deleteAccount()` to attempt primary provider (Google) first, then secondary provider (Apple) if primary fails (per clarification Q1 and FR-002)
- [X] T017 [US2] Extend delete account flow screen to display provider fallback messages: "Trying Google...", "Google unavailable, trying Apple..."
- [X] T018 [US2] Handle reauth cancellation: If user cancels provider sign-in dialog, show clear message "Sign-in cancelled" with retry/cancel buttons; account remains intact
- [ ] T019 [US2] Manual test: Force stale session (wait >5 min); trigger delete; complete reauth; verify auto-retry succeeds with progress shown
- [ ] T020 [US2] Manual test: User with both Google and Apple linked; revoke Google access; trigger delete; verify fallback to Apple succeeds

**Checkpoint**: User Story 2 complete - reauth friction handled automatically with provider fallback

---

## Phase 5: User Story 3 - Error and cancel handling (Priority: P3)

**Goal**: Network errors, provider revoked, offline conditions, and user cancellation are surfaced with actionable messages; no partial deletion occurs (account stays intact if errors).

**Independent Test**: Simulate network failure during delete; user sees error message on current screen with retry/cancel buttons; data intact; cancel returns to account settings.

### Implementation for User Story 3

- [X] T021 [P] [US3] Add offline detection in `deleteAccount()` before attempting reauthentication; return error if no network connection (per FR-005 and edge case)
- [X] T022 [US3] Extend error handling in delete account flow screen (`lib/features/auth/screens/delete_account_flow.dart`) to keep user on current screen with actionable error message + retry/cancel buttons (per clarification Q3)
- [X] T023 [P] [US3] Add error message mapping in screen for provider-specific errors: `provider-revoked` → "Re-enable this app in your [Provider] settings", `network-request-failed` → "No connection. Check network and retry"
- [X] T024 [US3] Handle user cancellation at any step: If user taps cancel on delete confirmation dialog OR during reauth error recovery, return to account settings without any deletion
- [X] T025 [US3] Add partial cleanup reporting: If `_cleanupLocalDataAfterDelete()` encounters failures, log to console and optionally show message to user: "Account deleted. Some local data may remain."
- [ ] T026 [US3] Manual test: Disable network; attempt delete; verify error message shows with retry button; re-enable network; tap retry; verify deletion succeeds
- [ ] T027 [US3] Manual test: Revoke provider access in provider settings; attempt delete; verify actionable error message guides user to re-enable app
- [ ] T028 [US3] Manual test: Cancel at confirmation dialog → account stays active; cancel during reauth error → account stays active

**Checkpoint**: User Story 3 complete - comprehensive error and cancel handling with no partial deletions

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Enhancements that affect multiple user stories

- [X] T029 [P] Add linked account detection for hybrid users (email/password + social) in `deleteAccount()`: Attempt email/password first, fall back to social provider (per clarification Q5 and FR-001)
- [X] T030 [P] Code review: Verify all error messages in `auth_constants.dart` are user-friendly and actionable per FR-004 and FR-005
- [X] T031 Update documentation: Add provider reauthentication examples to project README or developer guide (if applicable)
- [ ] T032 Run quickstart.md validation: Follow all steps in `quickstart.md` to ensure implementation completeness
- [ ] T033 Final manual test: Test all 3 user stories end-to-end on iOS and Android devices with real Firebase project

**Checkpoint**: Feature complete, polished, and ready for deployment

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - User stories can proceed in parallel (if team capacity allows)
  - Or sequentially in priority order: US1 (MVP) → US2 → US3
- **Polish (Phase 6)**: Depends on US1, US2, US3 completion

### User Story Dependencies

- **User Story 1 (P1)**: MVP - Can start after Foundational (Phase 2) complete. No dependencies on other stories.
- **User Story 2 (P2)**: Depends on US1 completion (extends `deleteAccount()` and UI from US1). Adds auto-retry and fallback logic.
- **User Story 3 (P3)**: Depends on US1 and US2 completion (extends error handling from US1/US2). Adds comprehensive error recovery.

### Within Each User Story

**User Story 1**:
- T003-T006 (Foundational) MUST complete before T007
- T007 (service method) MUST complete before T010 (UI screen uses service)
- T008 (cleanup helper) can run in parallel with T007 (no direct dependency)
- T009 (dialog widget) can run in parallel with T007-T008 (independent UI component)
- T010 (flow screen) depends on T007 (calls service) and T009 (uses dialog)
- T011-T012 (navigation wiring) depend on T010 (screen must exist)
- T013 (manual test) runs after all implementation tasks

**User Story 2**:
- T014 extends T007 → sequential
- T015 extends T010 → sequential
- T016 extends T007 → sequential
- T017 extends T010 → sequential
- T018 extends T010 → sequential
- T019-T020 (manual tests) run after all implementation tasks

**User Story 3**:
- T021 (offline detection) can run in parallel with T023 (error mapping) → both extend different parts
- T022 extends T010 (error UI) → sequential
- T024 extends T010 and T009 (cancel handling) → sequential
- T025 extends T008 (cleanup reporting) → sequential
- T026-T028 (manual tests) run after all implementation tasks

### Parallel Opportunities

**Phase 2 (Foundational)**:
- T003, T004, T005, T006 → All [P] → Can run in parallel (different code sections)

**Phase 3 (User Story 1)**:
- T008 [P] || T009 [P] → Can run in parallel with T007 (independent components)

**Phase 5 (User Story 3)**:
- T021 [P] || T023 [P] → Can run in parallel (different code sections)

**Phase 6 (Polish)**:
- T029 [P] || T030 [P] → Can run in parallel (service vs. constants)

**Cross-Story Parallelization** (if team capacity allows):
- Once US1 (T007-T012) is complete, US2 and US3 can be worked on by different developers in parallel since both extend existing US1 code in non-conflicting ways

---

## Parallel Execution Example: User Story 1

If you have 3 developers, tasks can be distributed as follows:

### Sprint 1: Foundational Phase
```bash
# Developer A
T003: Add provider detection helpers (30 min)
T004: Add reauthenticateWithGoogle() (1 hour)

# Developer B (parallel)
T005: Add reauthenticateWithApple() (1 hour)

# Developer C (parallel)
T006: Extend error constants (30 min)
T009: Create delete confirmation dialog (1 hour)
```

### Sprint 2: User Story 1 Implementation
```bash
# Developer A
T007: Modify deleteAccount() for social-only users (1.5 hours)

# Developer B (parallel, after T007 starts)
T008: Add _cleanupLocalDataAfterDelete() (1 hour)

# Developer C (parallel, independent)
T009: Already done from Sprint 1
T011: Add route to app router (15 min)
T012: Add "Delete Account" button to settings (30 min)
```

### Sprint 3: User Story 1 Completion
```bash
# Developer A (depends on T007, T009)
T010: Create delete account flow screen (2 hours)

# Developer B (testing)
T013: Manual test on iOS device

# Developer C (testing)
T013: Manual test on Android device
```

**Result**: User Story 1 (MVP) delivered in 3 sprints with parallel work

---

## Implementation Strategy

### MVP First (Ship User Story 1 Only)

**Minimum Viable Product** = User Story 1 complete:
- Social-only users can delete accounts
- Single provider reauthentication (no fallback yet)
- Basic error handling (show errors, user can retry manually)
- Local data cleanup (partial cleanup acceptable)

**Tasks for MVP**: T001-T013 (13 tasks)  
**Estimated Effort**: ~2 days (single developer) or ~1 day (team of 3 with parallel work)

**Deployment Decision Point**: After US1 completion, decide:
- Ship MVP to production → gather user feedback → iterate with US2/US3
- OR continue to US2 for better UX (auto-retry, fallback)

### Full Feature (All User Stories)

**Complete Feature** = User Stories 1, 2, 3 + Polish:
- Auto-retry on stale session
- Provider fallback (Google → Apple)
- Comprehensive error handling
- Hybrid user support (email/password + social)

**Tasks for Full Feature**: T001-T033 (33 tasks)  
**Estimated Effort**: ~5 days (single developer) or ~2 days (team of 3)

---

## Validation Checklist

After completing all tasks, verify:

- [ ] All acceptance scenarios from spec.md pass manual testing
- [ ] SC-001: Social-only user can delete account in <90 seconds
- [ ] SC-002: No partial deletions observed (0% failure rate)
- [ ] SC-003: Reauth-required deletes succeed on first retry (95%+ success)
- [ ] SC-004: All error cases show actionable messages (100% coverage)
- [ ] Firebase console shows account deleted after flow completes
- [ ] Shared preferences cleared after account deletion
- [ ] App navigates to sign-in screen after deletion
- [ ] Cancel at any step keeps account intact
- [ ] Error messages match `auth_constants.dart` definitions
- [ ] Provider fallback logic executes correctly (Google → Apple)
- [ ] Hybrid users (email/password + social) can delete with email/password first, social fallback

---

## Summary

**Total Tasks**: 33 (T001-T033)  
**MVP Tasks** (User Story 1): 13 (T001-T013)  
**Parallelizable Tasks**: 10 (marked with [P])  
**User Stories**: 3 (P1: Basic delete, P2: Reauth friction, P3: Error handling)  
**Phases**: 6 (Setup → Foundational → US1 → US2 → US3 → Polish)

**Recommended Approach**:
1. Complete Phase 1-2 (Setup + Foundational) → 6 tasks
2. Deliver MVP (Phase 3 - User Story 1) → 7 tasks
3. Get feedback, then proceed to Phase 4-6 (US2, US3, Polish) → 20 tasks

**Next Steps**: Execute tasks in order (T001 → T033) or parallelize where marked [P]. Use quickstart.md as implementation guide for code examples.
