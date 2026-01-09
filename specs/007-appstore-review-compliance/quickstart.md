# Quickstart: App Store Compliance Preflight (Feature 007)

This is a manual verification checklist intended for internal testing and App Review readiness.

## Prerequisites

- iOS device/simulator running iOS 15+
- Fresh install (delete app before testing)

## 1) Permission behavior

1. Launch the app (fresh install).
   - Expectation: no permission prompt appears immediately.
2. Navigate to map and perform a location-related action (e.g., center on current location).
   - Expectation: location permission prompt appears (When In Use).
3. Deny location permission.
   - Expectation: app remains usable and shows a clear message about reduced functionality.
4. Open OS Settings and toggle location permission, return to app.
   - Expectation: app updates behavior and can use location when enabled.

## 2) Privacy policy link

1. Open Settings.
2. Open About/Legal section.
3. Tap Privacy Policy.
   - Expectation: opens a real HTTPS URL.
   - Expectation: reachable within 2 taps from main navigation.

## 3) Profile picture update (on-device only)

1. Sign in.
2. Open Account/Profile.
3. Tap Change profile picture.
4. Pick an image and confirm.
   - Expectation: profile picture updates.
5. Re-launch the app.
   - Expectation: profile picture persists.
6. Optional: deny photo access if prompted.
   - Expectation: app remains usable; can cancel; shows guidance.

## 4) Account deletion

1. Sign in.
2. Navigate to Delete Account.
3. Complete required reauthentication and deletion.
   - Expectation: user is signed out and account is deleted.

## 5) Offline resilience

1. Put device in airplane mode.
2. Open map and tracklog screens.
   - Expectation: no crash; user-friendly offline/error state.
