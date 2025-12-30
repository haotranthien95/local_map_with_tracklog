# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

# Implementation Plan: Delete Account Without Password

**Branch**: `004-delete-account-nopass` | **Date**: 2025-12-30 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/004-delete-account-nopass/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Enable users registered with social providers (Google Sign-In, Sign-In with Apple) only—with no email/password credential—to delete their accounts. Feature uses Firebase Auth provider-based reauthentication (instead of password prompts) combined with intelligent fallback (primary provider first, secondary as backup). Account deletion triggers local data cleanup (markers, tracklogs, preferences) with partial cleanup tolerance (continue clearing remaining data if individual operations fail). Error recovery UI keeps user on current screen with actionable messages + retry/cancel buttons. Architecture remains minimal: no new state management, direct service method calls, existing authentication patterns extended for provider support.

## Technical Context

**Language/Version**: Dart 3.5.4+, Flutter 3.5.4  
**Primary Dependencies**: 
- `firebase_auth: ^5.3.1` (core account management)
- `google_sign_in: ^6.2.1` (Google OAuth provider flow)
- `sign_in_with_apple: ^6.1.2` (Apple OAuth provider flow)  
- `shared_preferences: ^2.3.2` (local data persistence; existing)
- `flutter_secure_storage: ^9.2.2` (token storage; existing)

**Storage**: 
- Firebase Auth (user accounts, linked providers, session state)
- shared_preferences (user preferences, marker data, tracklog metadata)
- flutter_secure_storage (API tokens, refresh tokens)

**Testing**: Flutter testing framework (widget_test SDK built-in); integration tests for critical user flows when explicitly required; project constitution favors manual testing + minimal unit tests for business logic.

**Target Platform**: iOS 13.0+, Android API 21+ (same as existing project)

**Project Type**: Mobile app (single platform: Flutter for iOS/Android)

**Performance Goals**: 
- Account deletion end-to-end: <90 seconds including reauthentication (SC-001)
- Reauthentication on first retry: 95% success rate (SC-003)
- Error/cancel flows: 100% actionable messaging (SC-004)

**Constraints**:
- <5 seconds provider selection/fallback (UI doesn't hang)
- Network required (offline blocks deletion per FR-001; no local deletion without Firebase confirmation)
- No partial account deletion (atomic: Firebase deletes OR local data stays intact; no orphaned accounts)
- Partial local data cleanup acceptable (per Q4 answer: continue if individual cleanup operations fail)

**Scale/Scope**:
- Single feature (delete flow) for existing user base (~TBD users from prior stories)
- 3 independent user stories (P1: basic delete, P2: reauth friction, P3: error handling)
- 7 functional requirements (FR-001 through FR-007)
- Extends existing AuthenticationService (no new service files; ~200 LOC added)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

✅ **MVP-First Development**: P1 story (basic social-only delete with single provider reauthentication) delivers complete end-to-end user value. User can delete account, be reauthenticated, and see confirmation. P2 (reauth friction) and P3 (error handling) build on P1 without blocking it. **Pass**: MVP scope clear.

✅ **Minimal Viable Features**: Feature scope reduced to social-only account deletion. Email/password delete already implemented (unchanged). No deletion schedules, no data archival, no recovery flows, no audit dashboards—only the core "user confirms → reauth → delete → cleanup → sign out" flow. **Pass**: Minimal scope.

✅ **Independent User Stories**: 
- **US1** (social delete): Testable alone; doesn't depend on US2 or US3. 
- **US2** (reauth friction): Depends on US1 (basic delete works), but adds auto-retry logic; independently testable by forcing requires-recent-login error.
- **US3** (error handling): Independently testable; doesn't block US1 or US2.
Deployment: US1 + US2 = minimum viable for launch. US3 adds polish. **Pass**: Independent sequencing.

✅ **Progressive Enhancement**:
- **Phase 1 (Core)**: Google provider reauthentication only; basic error handling (required-recent-login, network-unavailable). 
- **Phase 2 (Fallback)**: Add Apple provider + fallback strategy; improve error UI.
- **Phase 3 (Polish)**: Provider detection optimizations, edge case handling (revoked, multiple providers).
Plan reflects this: reauthentication API first, then fallback, then edge cases.  **Pass**: Progressive.

✅ **Maintainability Over Premature Optimization**: 
- No new state management (use existing AuthResult + User models)
- No new services (extend existing AuthenticationService)
- No caching (rely on Firebase Auth token management)
- Error handling uses Firebase's native error codes (no custom mapping layer yet; deferred to Phase 2)
- Simple fallback: iterate providers in priority order, catch/retry (no backtracking state machines)
**Pass**: Straightforward architecture.

**Complexity Justification**: Feature introduces provider-specific reauthentication logic (3 providers: email/password, Google, Apple) with fallback strategy. This complexity is **justified** because:
1. **Problem**: Email/password reauth doesn't work for social-only users; Firebase doesn't expose a generic "reauth with any provider" method.
2. **Solution**: Query `user.providerData`, attempt providers in priority order, handle provider-specific errors.
3. **Simpler Alternative Rejected**: A single-provider approach (e.g., Google only) would exclude Apple users; no simpler alternative solves multi-provider scenario.
4. **Measured Impact**: ~150 LOC added to AuthenticationService; existing code unchanged; fallback loop is O(n) where n ≤ 3 providers.

**Constitution Status**: ✅ **PASS** — Feature aligns with all 5 core principles. Complexity is minimal and justified. Ready for Phase 0 research.

## Project Structure

### Documentation (this feature)

```text
specs/004-delete-account-nopass/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   └── delete-account.interface.dart  # Service method contracts
└── spec.md              # Feature specification (input)
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── screens/
│   └── account_settings_screen.dart      # (Existing; will add delete button)
├── services/
│   └── authentication_service.dart       # MODIFY: Add deleteAccountWithProvider()
│                                         #         Add reauthenticateWithGoogle()
│                                         #         Add reauthenticateWithApple()
│                                         #         Add _cleanupLocalDataAfterDelete()
│                                         #         Extend deleteAccount() for fallback
├── models/
│   └── user.dart                         # (Existing; no changes needed)
│   └── auth_result.dart                  # (Existing; may extend for partial cleanup feedback)
├── features/
│   └── auth/
│       ├── constants/
│       │   └── auth_constants.dart       # EXTEND: Add provider reauth error messages
│       ├── screens/
│       │   └── delete_account_flow.dart  # NEW: Multi-step delete confirmation + reauth UI
│       └── widgets/
│           └── delete_account_dialog.dart # NEW: Initial delete confirmation dialog
└── widgets/
    └── (existing shared widgets; no new files needed)

tests/
├── unit/
│   └── services/
│       └── authentication_service_test.dart  # (Existing; add tests for reauthentication if needed)
└── (integration tests as needed per constitution)
```

**Structure Decision**: Single project (Flutter mobile app). Feature extends existing `AuthenticationService` in `lib/services/` with new methods for provider-based reauthentication and deletion. New UI layer (delete flow screens/dialogs) added to `lib/features/auth/`. No new service classes (keep authentication logic centralized). No new models (reuse existing `User`, `AuthResult`). This maintains the simple, maintainable architecture per the project constitution.

## Next Steps: Phase 0 → Phase 1

**Phase 0 (Current)**:
- ✅ Constitution Check: Passed; no blockers identified
- ⏳ Research Phase: 
  - [Research/Firebase Auth provider reauthentication APIs](../../../.specify/memory/004-firebase-auth-reauth.md) — GENERATED
  - [Research/Provider detection & fallback patterns](../../../.specify/memory/004-provider-detection.md) — GENERATED
  - Action: Consolidate research findings into `research.md` (this section)

**Phase 1 (Design)**:
- Generate `data-model.md` with DeletionRequest and UserSession entities
- Generate `contracts/delete-account.interface.dart` with method signatures
- Generate `quickstart.md` with implementation checklist
- Update agent context (copilot) with new tech (provider APIs, fallback pattern)

**Phase 2 (Tasks)**:
- Run `/speckit.tasks` to generate task breakdown by user story and phase
- Expected: ~T001–T030 tasks spanning provider integration, UI flows, error handling, testing

---

*END OF PLAN TEMPLATE*
