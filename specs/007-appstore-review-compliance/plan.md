# Implementation Plan: App Store Review Compliance

**Branch**: `007-appstore-review-compliance` | **Date**: 2026-01-09 | **Spec**: `specs/007-appstore-review-compliance/spec.md`
**Input**: Feature specification from `specs/007-appstore-review-compliance/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Bring the iOS app in line with App Store Review expectations by (1) requesting only necessary permissions at the moment of use, (2) providing an in-app HTTPS privacy policy link within 2 taps, (3) ensuring sign-in + account deletion flows are robust, (4) adding/aligning an app-level privacy manifest, and (5) implementing “change profile picture” to justify Photo Library access while keeping the photo on-device only.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Dart 3.5.4 / Flutter 3.24.5  
**Primary Dependencies**:
- Auth: `firebase_core`, `firebase_auth`, `google_sign_in`, `sign_in_with_apple`, `flutter_secure_storage`
- Map: `flutter_map`, `flutter_map_cache`, `flutter_cache_manager`, `http_cache_hive_store`, `latlong2`
- Location: `geolocator`
- Files: `file_picker`, `path_provider`, `archive`, `gpx`, `xml`
- UI/util: `shared_preferences`, `intl`, `google_fonts`
**Storage**: On-device only (files via `path_provider`, `SharedPreferences`, and `flutter_secure_storage`)  
**Testing**: `flutter_test` (widget tests only; no integration suite currently)  
**Target Platform**: iOS 15+ (Podfile), Android (Flutter standard)  
**Project Type**: Mobile app (Flutter)  
**Performance Goals**: Maintain smooth UI (60 fps) during map interactions and file imports; avoid blocking the UI thread  
**Constraints**: Offline-capable map tiles + tracklog usage; minimal permissions; no tracking/ATT prompts; privacy disclosures consistent with shipped behavior  
**Scale/Scope**: Single Flutter app; limited number of screens; focus on reviewer-friendly UX and compliance hardening

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Verify alignment with constitution principles:

- **MVP-First Development**: Yes — permission gating + privacy policy link + profile photo change are end-to-end flows.
- **Minimal Viable Features**: Yes — no analytics, no remote profile photo upload, no extra account/profile fields.
- **Independent User Stories**: Mostly — Story 1 (permissions) and Story 3 (privacy policy link + stability) are independent; Story 2 (account deletion) is existing but will be verified/hardened.
- **Progressive Enhancement**: Yes — start with app-level disclosures/strings and denial paths before deeper refactors.
- **Maintainability**: Yes — prefer small services/functions, reuse existing Settings UI patterns, avoid new architecture layers.

**Complexity Justification**: Add a single, focused dependency for photo selection (`image_picker`) only if the existing stack cannot select a profile photo from the Photo Library in a reviewer-friendly way.

## Project Structure

### Documentation (this feature)

```text
specs/007-appstore-review-compliance/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
lib/
├── main.dart
├── features/
├── screens/
├── services/
├── theme/
└── widgets/

ios/
├── Podfile
└── Runner/
  ├── Info.plist
  └── (will add app privacy manifest here)

android/
└── app/

specs/
└── 007-appstore-review-compliance/

test/
└── widget_test.dart
```

**Structure Decision**: Single Flutter mobile app. Compliance changes primarily touch `ios/Runner`, settings/auth UI under `lib/`, and supporting services.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

## Phase 0 — Outline & Research (output: `research.md`)

Goal: turn policy/compliance requirements into concrete engineering decisions with minimal scope.

Research tasks:

1. Permission inventory: identify every iOS permission key present and map it to an in-app user action.
2. Location scope: confirm `geolocator` usage is “When In Use” only and no background mode is enabled.
3. Profile photo approach: choose the simplest photo picker that supports on-device storage only.
4. Privacy manifest approach: define how we will satisfy Apple privacy manifest expectations (add app-level file; iterate based on Xcode build warnings).
5. Privacy policy surfacing: decide the exact in-app entry point (Settings/About) and 2-tap path.

## Phase 1 — Design & Contracts (outputs: `data-model.md`, `contracts/*`, `quickstart.md`)

Design deliverables:

- Data model for profile photo storage (local file path, lifecycle).
- UI contracts for “Privacy Policy” link and “Change Profile Picture” action (no server API).
- Quickstart with a reviewer-oriented manual test checklist.

**Post-Design Constitution Re-check**: PASS (scope remains minimal; no new architecture layers introduced)

## Phase 2 — Implementation Planning (inputs to `/speckit.tasks`)

Planned implementation slices (P1 first):

1. iOS permission alignment
  - Remove background/Always location usage keys and ensure runtime requests are When-In-Use only.
  - Update purpose strings to be specific (Location and Photo Library).
2. In-app privacy policy link
  - Replace placeholder URL with real HTTPS URL constant and add Settings/About link.
3. Profile picture update (on-device only)
  - Add minimal UI to pick an image from the Photo Library and persist it locally.
  - Ensure cancellation and denial paths keep the app usable.
4. Privacy manifest
  - Add app-level privacy manifest file and iterate based on build-time warnings.
5. Submission preflight sanity
  - Verify attribution visibility, offline behavior messaging, and account deletion flow still works end-to-end.
