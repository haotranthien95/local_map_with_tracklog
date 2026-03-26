# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run app
flutter run

# Build
flutter build ipa --split-debug-info --obfuscate  # iOS
flutter build apk                                   # Android
./build.sh                                          # iOS with auto-incremented build number

# Analyze & test
flutter analyze
flutter test
flutter test test/path/to/test_file.dart           # Single test file

# Localization (regenerate after editing .arb files)
flutter gen-l10n
```

## Architecture

### Structure
- `lib/screens/` — Full-page widgets (route destinations)
- `lib/features/` — Feature-scoped code with `screens/`, `widgets/`, `services/`, `models/`, `constants/` subdirs
- `lib/services/` — Singleton business logic services
- `lib/models/` — Data models with JSON serialization
- `lib/widgets/` — Shared reusable widgets
- `lib/theme/` — Material 3 theme config
- `lib/l10n/` — ARB localization files (EN, JA, VI, ZH)
- `specs/` — Feature specification documents

### State Management
No Provider/Riverpod — uses plain `StatefulWidget` + `setState`. Global state (theme, locale) lives in `_MyAppState` in `main.dart`. Services use the singleton pattern via factory constructors.

### Navigation
Named routes + `IndexedStack` bottom tab navigation in `HomeScreen`. Main routes: `/home`, `/login`, `/register`, `/delete_account`.

### Services Pattern
All services are singletons:
```dart
class MyService {
  static final _instance = MyService._internal();
  factory MyService() => _instance;
  MyService._internal();
}
```

Key services:
- `AuthenticationService` — Firebase auth (email, Google, Apple), account deletion with provider reauthentication
- `TrackParserService` — Parses GPX, KML, KMZ, GeoJSON, CSV, TCX, FIT, NMEA files
- `TracklogStorageService` — SharedPreferences-based track persistence
- `TileCacheService` — Offline map tile caching via `flutter_map_cache`
- `LocationService` — GPS streaming via Geolocator
- `GuestMigrationService` — Migrates guest data when a guest user registers

### Authentication
Firebase-based with three providers: email/password, Google Sign-In (`google_sign_in` v7 — use `GoogleSignIn.instance.authenticate()`, not `GoogleSignIn().signIn()`), Apple Sign-In. Auth state is stream-based (`authStateChanges()`). Tokens stored securely via `flutter_secure_storage`.

**Cross-provider same-email rule:** If a user signs up/in with a provider but the email already exists under a different provider, the app must sign them into the existing account and link the new provider — never create a duplicate account. This is handled in `_linkAccountWithCredential`. Firebase Auth v6 removed `fetchSignInMethodsForEmail` (email enumeration protection), so the existing provider is inferred from the pending credential's provider ID: the complementary social provider is tried first; if the signed-in email matches, the new credential is linked. If the existing account uses email/password, a clear error directs the user to sign in with their password.

**Data preservation:** `User.fromFirebaseUser` resolves `authProvider` by priority (Google > Apple > password) so linked accounts always surface the richest profile. Apple only sends `givenName`/`familyName` on the first sign-in; `registerWithApple` writes `displayName` only when it is currently empty. Profile photo URL comes from `firebaseUser.photoURL` and is preserved across provider changes since they share the same Firebase UID.

**google_sign_in v7 API notes:** `authentication` is synchronous (no `await`); only `idToken` is available (no `accessToken`). Pass only `idToken` to `GoogleAuthProvider.credential()`.

Account deletion requires provider-specific reauthentication before Firebase deletion.

### Maps & Tracks
Map rendering via `flutter_map` with offline tile caching. Tracks are parsed from multiple GPS formats and stored as `Track` + `TrackPoint` models with metadata, color coding, and bounding box calculations.

### Localization
Use `context.l10n` (extension in `lib/l10n/l10n_extension.dart`) to access strings. Add new strings to all four ARB files (`app_en.arb`, `app_ja.arb`, `app_vi.arb`, `app_zh.arb`), then run `flutter gen-l10n`.
