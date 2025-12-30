# Feature Specification: Delete Account Without Password

**Feature Branch**: `004-delete-account-nopass`  
**Created**: 2025-12-30  
**Status**: Draft  
**Input**: User description: "Check flow delete Account in case register without password"

## Clarifications

### Session 2025-12-30

- Q: When social-only user initiates delete, how should system select which provider to reauthenticate with? → A: Attempt primary provider first (e.g., Google if both linked); fall back to secondary if primary fails.
- Q: After successful provider reauthentication, should deletion proceed automatically or return control to user? → A: Automatically retry delete immediately after reauth succeeds; show progress and result to user.
- Q: When provider token is revoked, expired, or user is offline, how should error recovery UI behave? → A: Keep user on current screen with retry and cancel buttons; show actionable error message above buttons.
- Q: When Firebase account deletion succeeds, should local data cleanup be rolled back if individual cleanup operations fail, or should the system continue clearing remaining data? → A: Continue clearing remaining local data even if some cleanup operations fail; log failures and report to user at end (partial cleanup approach).
- Q: When user has both email/password AND social provider credentials linked, which path should delete flow take? → A: Attempt email/password reauthentication first (primary); fall back to primary social provider if email/password is unavailable (consistent with social-only fallback logic).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Delete account with social provider (Priority: P1)

User who registered via social provider (Google, Apple) confirms account deletion; system reauthenticates with their social provider, then deletes the account and all local/session data tied to it.

**Why this priority**: Enables social-only users (without email/password) to exercise account control and privacy rights. Email/password delete flow already implemented and unchanged.

**Independent Test**: Signed-in social-only user triggers delete, reauths with provider, and is removed; on relaunch the account is gone and local data cleared.

**Acceptance Scenarios**:

1. **Given** a signed-in social-only user (no email/password credential), **When** they confirm delete and complete reauthentication with their provider, **Then** the account is deleted, session ends, and local user data is wiped.
2. **Given** deletion completes, **When** the app restarts, **Then** the user is not signed in and no user-linked local data remains.

---

### User Story 2 - Handle reauth friction (Priority: P2)

If recent sign-in is required, the user is guided to reauthenticate with their provider, then deletion resumes automatically.

**Why this priority**: Reduces failure loops from stale credentials and keeps the flow self-contained.

**Independent Test**: Force requires-recent-login; user reauths with provider; delete succeeds without manual retry.

**Acceptance Scenarios**:

1. **Given** delete is blocked for recent login, **When** the user completes provider reauth, **Then** the delete request is retried automatically and succeeds (user sees progress and result; no additional confirmation required).
2. **Given** the user cancels reauth, **When** returning to the delete flow, **Then** no deletion occurs and they remain signed in with a clear message.

---

### User Story 3 - Error and cancel handling (Priority: P3)

Errors (network, provider revoked, offline) and user cancellation are surfaced clearly without partial deletion.

**Why this priority**: Prevents confusion and data-loss fear; keeps user informed.

**Independent Test**: Simulate network failure; user sees actionable message and remains signed in with data intact; simulate user-cancel at any prompt and nothing is deleted.

**Acceptance Scenarios**:

1. **Given** a network or provider error during delete, **When** the flow fails, **Then** the user stays signed in, data remains, and an actionable error is shown.
2. **Given** the user cancels at any step, **When** the flow closes, **Then** no deletion occurs and the account/session stays active.

---

### Edge Cases

- **Provider token expired or revoked mid-flow**: Display actionable error message on current screen with retry and cancel buttons; allow user to tap retry to attempt reauth again.
- **Offline during delete**: Show error message with retry button; do not modify local state until confirmed success via network retry.
- **Multiple linked providers with no password**: Ensure deletion works if at least one provider can reauth; communicate clearly if primary is unavailable (e.g., "Google sign-in unavailable; trying Apple...") and provide manual retry option.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The delete account action MUST support both email/password users (via existing `_reauthenticateWithPassword()` flow) and social-only users. Users with both email/password AND social credentials MUST attempt email/password reauthentication first; if unavailable, fall back to primary social provider.
- **FR-002**: For social-only users, the flow MUST request recent authentication when required and route through their active provider(s) (e.g., Google, Apple) without a password prompt. Primary provider MUST be attempted first; secondary provider used as fallback if primary is unavailable.
- **FR-003**: On successful delete, the system MUST remove the user account and end the session. Local cleanup (tracklogs, preferences, markers) is attempted; if individual cleanup operations fail, the system continues clearing remaining data, logs failures, and reports the outcome to the user.
- **FR-004**: If reauthentication is canceled or fails, the system MUST keep the account intact and show a clear message with retry guidance.
- **FR-005**: Error conditions (network, provider revoked, offline) MUST be surfaced on the current screen with actionable next steps (error message + retry and cancel buttons); no partial deletion or local data removal may occur.
- **FR-006**: The flow MUST confirm completion to the user and return them to a signed-out state.
- **FR-007**: System MUST detect whether user has email/password credential or only social providers and route to appropriate reauth method.


### Key Entities *(include if feature involves data)*

- **DeletionRequest**: contains user id, provider used for reauth, timestamp, and outcome (success/fail/canceled) for audit messaging.
- **UserSession**: current auth state and linked providers, used to choose reauth path and post-delete cleanup.

### Assumptions & Dependencies

- Users who registered with email/password use existing `deleteAccount(password)` flow with `_reauthenticateWithPassword()` (already implemented and unchanged).
- Users who registered with social providers only (no email/password credential) require new provider-based reauthentication flow.
- Network connectivity is required to complete deletion; offline blocks the operation until retry.
- Local user-scoped data (e.g., cached preferences, markers) is stored in app storage that can be cleared on delete.
- At least one active provider credential is available for social-only users to reauthenticate.


## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% of social-only users who initiate delete can complete it end-to-end in under 90 seconds, including reauth.
- **SC-002**: 0% of delete attempts result in partial state: either account remains with all data intact, or account is fully deleted with data cleared.
- **SC-003**: 95% of reauth-required delete attempts succeed on the first retry when the user completes provider reauth.
- **SC-004**: Error/cancel flows present actionable messaging in 100% of failure cases observed during testing.
