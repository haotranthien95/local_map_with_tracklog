# UI Contracts (No Backend API)

This feature does not add or modify any server API. Contracts below describe the user-visible surfaces that must exist for App Review.

## Settings / About

**Entry points**
- Settings screen includes an “About” (or “Legal”) section.
- Within that section, there is a “Privacy Policy” row.

**Contract**
- Tapping “Privacy Policy” opens a real HTTPS URL in an in-app browser or external browser.
- The link is reachable within 2 taps from the main app navigation.

## Account / Profile

**Entry points**
- When signed in, Account/Profile area includes “Change profile picture”.

**Contract**
- Tapping “Change profile picture” launches a photo picker.
- If the user cancels, no changes occur.
- If permission is denied (if applicable), show a clear message and keep the app usable.
- The chosen image is stored on-device only and displayed as the user’s profile picture.

## Permissions behavior

**Contract**
- No permission prompts on first launch.
- Location prompt only when user uses a location-related action (e.g., “My location”).
- Photo access prompt only when user initiates profile photo change.
