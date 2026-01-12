# iOS Privacy & Permissions Contract

This document defines what must be true in the iOS bundle configuration for Feature 007.

## Info.plist permission keys

- Location: include only the usage description(s) needed for When-In-Use location.
- Do not include “Always”/background location usage description keys.
- Photo Library: include a clear, specific usage description aligned to “Change profile picture”.

## Privacy Manifest

- Add an app-level privacy manifest file for the Runner target.
- During implementation, validate configuration by building with Xcode and resolving any privacy-manifest-related warnings.

## Tracking

- Do not request App Tracking Transparency authorization.
- Do not add tracking/analytics SDKs as part of this feature.
