# Feature Specification: App Store Review Compliance

**Feature Branch**: `007-appstore-review-compliance`  
**Created**: 2026-01-09  
**Status**: Draft  
**Input**: User description: "Refactor the app to follow Apple App Store Review Guidelines and Apple Developer Program policies so it can pass App Store review and be published for everyone"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Clear Permissions & Privacy Transparency (Priority: P1)

As an iOS user, I can understand why the app asks for access (e.g., location and files), and I can continue using the app even if I deny optional permissions.

**Why this priority**: Review rejection risk is highest when permission prompts are confusing, excessive, or block core usage.

**Independent Test**: Can be fully tested by installing a fresh build and walking through all permission prompts and denial paths while still being able to browse the map UI and settings.

**Acceptance Scenarios**:

1. **Given** a fresh install, **When** the app first launches, **Then** the app does not request any permission until a user action requires it.
2. **Given** a user denies location permission, **When** they return to the map screen, **Then** the app remains usable and shows a clear message about the reduced functionality.
3. **Given** the app requests access to location or files, **When** the system prompt appears, **Then** the in-app UI and the system usage description clearly explain what the permission is used for.
4. **Given** the app does not use a particular sensitive capability, **When** the app is inspected (permissions and prompts), **Then** it never requests that permission.
5. **Given** a signed-in user wants to update their profile picture, **When** they tap "Change profile picture", **Then** the app requests Photo Library permission only at that moment and explains how the photo will be used.

---

### User Story 2 - Account & Sign-in Policy Compliance (Priority: P2)

As a user who can create an account, I can sign in using the supported methods and I can delete my account from inside the app without needing external support.

**Why this priority**: Apple requires in-app account deletion when account creation exists, and sign-in options must not violate platform policies.

**Independent Test**: Can be fully tested by creating an account, signing in/out, and completing the in-app account deletion flow end-to-end.

**Acceptance Scenarios**:

1. **Given** the app offers third-party sign-in options, **When** the app runs on iOS, **Then** "Sign in with Apple" is available wherever other third-party sign-in is available.
2. **Given** a signed-in user, **When** they choose "Delete Account" and complete the required confirmation steps, **Then** the account is deleted and the user is signed out.
3. **Given** a user starts account deletion but cancels, **When** they return to the app, **Then** the account remains active and no destructive changes occur.

---

### User Story 3 - Submission Readiness & Legal Disclosures (Priority: P3)

As a reviewer or user, I can find required disclosures (e.g., privacy policy) and the app behaves consistently without crashes or broken links.

**Why this priority**: Even if core features work, missing disclosures or unstable behavior can trigger rejection.

**Independent Test**: Can be fully tested by running a "submission preflight" checklist against a release build and verifying all in-app disclosures and settings.

**Acceptance Scenarios**:

1. **Given** the app is opened from a release build, **When** a user navigates to settings/about, **Then** they can access the privacy policy (and any other required legal text) from inside the app.
2. **Given** the app uses third-party map tiles, **When** the map is displayed, **Then** attribution is visible and matches the selected map source.
3. **Given** a device is offline, **When** the user opens the map and tracklog screens, **Then** the app does not crash and provides a user-friendly error state.

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

- User denies location permission permanently ("Don't Allow") and later wants to enable it.
- User has no network connectivity when tiles/remote services are needed.
- User signs in via one provider and attempts to delete the account while the session is expired.
- User imports an unsupported or corrupted track file.
- App is resumed from background after permissions/settings changed.

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: The app MUST request sensitive permissions only when a user action requires them (no permission prompts on first launch unless essential).
- **FR-002**: The app MUST provide clear, user-facing explanations for each permission request aligned to actual functionality (including system usage descriptions).
- **FR-003**: The app MUST NOT request permissions it does not actively use in the shipped product.
- **FR-004**: The app MUST remain functional (no crash, no dead-end) when optional permissions are denied; it MUST present a clear fallback state.
- **FR-005**: The app MUST provide an in-app path to learn how to enable permissions later (e.g., via Settings guidance).

- **FR-005a**: The iOS app MUST use **When In Use** location authorization only and MUST NOT request background ("Always") location access.

- **FR-006**: If the app supports user accounts, the app MUST provide an in-app account deletion capability that fully deletes the account and completes without requiring the user to contact support.
- **FR-007**: The app MUST clearly communicate what data will be deleted during account deletion and what (if anything) remains on-device.

- **FR-008**: If the app offers third-party sign-in on iOS, the app MUST offer "Sign in with Apple" with comparable prominence and availability.

- **FR-009**: The app MUST provide an in-app, discoverable link to a **real HTTPS privacy policy URL**.
- **FR-009a**: The privacy policy link MUST be reachable from the settings/about area in 2 taps or fewer.
- **FR-010**: The app MUST accurately disclose its data collection and data usage in the app’s disclosures (including any third-party SDK behavior used in the shipped build).

- **FR-011**: The iOS build MUST include the required privacy manifest declarations and MUST not trigger preventable platform compliance warnings related to privacy manifests.
- **FR-012**: The app MUST not show tracking consent prompts unless the app actually performs tracking as defined by Apple.

- **FR-012a**: The shipped build MUST NOT include analytics/tracking SDKs that collect behavioral analytics; authentication-only SDKs are allowed.
- **FR-012b**: The app MUST NOT request App Tracking Transparency authorization.

- **FR-013**: The app MUST show map attribution when third-party map tiles are displayed.
- **FR-014**: The app MUST handle offline and error conditions gracefully across core screens (map, tracklogs, settings) with user-friendly messaging.

- **FR-015**: The app MUST allow signed-in users to update their profile picture.
- **FR-016**: The app MUST request Photo Library permission only when the user initiates a profile picture change.
- **FR-017**: The app MUST clearly explain how the selected photo is used (e.g., only as the user’s profile picture) and provide a cancel path.
- **FR-018**: The app MUST store the selected profile picture on-device only and MUST NOT upload it to any backend.

### Key Entities *(include if feature involves data)*

- **User Account**: Represents a signed-in user identity and authentication state.
- **User Profile Photo**: Represents the user-selected profile image and its storage location.
- **User Profile Photo**: Represents the user-selected profile image stored on-device (no upload).
- **Tracklog**: Represents an imported/recorded track with name, timestamp, bounds, visibility, and optional metadata.
- **Map Tile Cache**: Represents locally stored map tiles and storage usage state.
- **Map Marker**: Represents a user-created marker (position, name, icon, color).
- **Preferences**: Represents user choices such as theme mode and language.

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: 100% of permission prompts shown in the app have a clear, user-understandable explanation and occur only after a user-initiated action.
- **SC-002**: A user who denies location access can still reach the map UI and settings without a crash or blocking error.
- **SC-003**: A signed-in user can complete in-app account deletion in under 2 minutes, end-to-end.
- **SC-004**: A submission preflight run yields zero missing-disclosure items (privacy policy link present, attributions visible, disclosures consistent with shipped behavior).

## Assumptions

- The app is intended for general audiences and will be distributed publicly on the App Store.
- Location access is used to show the user’s current position on the map.
- Location access is **When In Use only** (no background location / no “Always” permission).
- Tracklogs and map tiles are stored on-device unless a user account feature explicitly syncs or stores them remotely.
- Profile pictures are stored on-device only.
- The shipped app does not perform user tracking.
- The shipped build does not include analytics or crash reporting.

## Dependencies & Constraints

- App Store Connect disclosures (privacy nutrition label and any required legal URLs) must match the shipped behavior and included third-party SDKs.
- Any third-party services used for authentication must comply with Apple policies and provide a reliable sign-in and deletion path.

## Clarifications

### Session 2026-01-09

- Q: What location permission scope should the iOS app require? → A: When In Use only
- Q: How should the app provide the Privacy Policy? → A: Real HTTPS Privacy Policy URL (linked in-app)
- Q: What analytics/tracking should the shipped build include? → A: No analytics / no tracking SDKs
- Q: Should the app request Photo Library permission? → A: Yes, to support updating profile picture
- Q: Where should profile photos be stored? → A: On-device only (no upload)
