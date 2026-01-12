# Phase 0 Research: App Store Review Compliance

This document resolves planning unknowns and locks in implementation decisions for Feature 007.

## Decisions

### 1) Permission prompts occur only on user action

**Decision**: Do not request permissions on first launch. Trigger permission requests only from explicit user actions (e.g., “My location”, “Change profile picture”).

**Rationale**: Matches FR-001/SC-001 and reduces review risk. Also keeps the app usable when permissions are denied.

**Alternatives considered**:
- Request on first launch: rejected due to higher rejection risk and worse UX.

---

### 2) iOS location scope is When-In-Use only

**Decision**: iOS will request **When In Use** location authorization only. Remove background/Always-related usage keys and avoid background location modes.

**Rationale**: This is explicitly clarified in the spec (FR-005a) and minimizes sensitive access.

**Alternatives considered**:
- Background location (Always): rejected; not required for the product described.

---

### 3) Profile photo selection uses a dedicated photo picker

**Decision**: Implement profile photo selection using a gallery picker suitable for iOS (plan: `image_picker` for Flutter), invoked only when the user taps “Change profile picture”.

**Rationale**: Reviewer-friendly UX and direct alignment to FR-015–FR-018. Keeps scope minimal (gallery-only; no camera required).

**Alternatives considered**:
- Use `file_picker`: may not integrate as a Photo Library picker on iOS in the expected way.
- Build custom Photos integration: rejected as too complex for MVP.

---

### 4) Profile photos are stored on-device only

**Decision**: Persist the selected profile photo to app storage (Documents/Application Support) and store only the local file path/reference. Do not upload to any backend.

**Rationale**: Matches clarified requirement and reduces privacy/compliance surface area.

**Alternatives considered**:
- Upload to Firebase Storage: rejected (explicitly out-of-scope).

---

### 5) Privacy policy is a real HTTPS URL and reachable within 2 taps

**Decision**: Add a Settings/About entry that opens a real HTTPS privacy policy URL. Replace any placeholder constant.

**Rationale**: Directly satisfies FR-009/FR-009a and is a common App Review expectation.

**Alternatives considered**:
- Only show privacy policy on a website or store listing: rejected; must be in-app.

---

### 6) App-level privacy manifest is added and validated via build warnings

**Decision**: Add an app-level privacy manifest file for iOS. During implementation, validate against Xcode build-time warnings and adjust the manifest declarations accordingly.

**Rationale**: Tooling expectations can vary by Xcode/iOS SDK; the most reliable way to avoid preventable warnings is to add the file and iterate based on compiler diagnostics.

**Alternatives considered**:
- Skip manifest and rely on pods: rejected; the feature requires an app-level compliance pass.

---

### 7) No analytics/tracking and no ATT prompt

**Decision**: Do not add analytics/tracking SDKs. Do not request App Tracking Transparency authorization.

**Rationale**: Explicitly clarified; reduces review complexity.

**Alternatives considered**:
- Add analytics/crash reporting: rejected as out-of-scope for this compliance pass.

---

## Implementation Notes (Verification)

### ATT prompt verification

Searched the repository for App Tracking Transparency usage (for example `ATTrackingManager`, `AppTrackingTransparency`, `trackingAuthorizationStatus`). No matches were found.

### Permissions-to-features mapping

- **Location (When In Use)**
	- Used only for user-initiated “center on current location” / showing current location on the map.
	- No background location use.
- **Photo Library**
	- Used only when the user taps “Change profile picture”.
	- Selected photo is stored on-device only.

### iOS privacy manifest (required reason API)

Declared required-reason API usage for:
- `NSPrivacyAccessedAPICategoryUserDefaults` (reason `CA92.1`)
- `NSPrivacyAccessedAPICategoryFileTimestamp` (reasons `C617.1`, `3B52.1`)
