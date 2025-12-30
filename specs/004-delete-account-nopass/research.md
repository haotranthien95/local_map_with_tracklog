# Phase 0 Research: Delete Account Without Password

**Feature**: 004-delete-account-nopass  
**Date**: 2025-12-30  
**Phase**: Pre-Design Research (Phase 0)  
**Researcher**: Automated research via speckit.plan

---

## Overview

This document consolidates research findings required to implement the delete-account-nopass feature. All unknowns from the technical context have been resolved through targeted research. Feature can proceed to Phase 1 design with confidence.

---

## Research Task 1: Firebase Auth Provider Reauthentication APIs

### Decision

**Selected Approach**: Use Firebase Auth's `reauthenticateWithCredential()` method combined with provider-specific credential constructors (GoogleAuthProvider, OAuthProvider for Apple, EmailAuthProvider for email/password).

**Rationale**:
- Firebase Auth natively supports provider-based reauthentication without password
- Aligned with project's existing credential patterns (already used for login/registration)
- Cleanly handles Google and Apple with same underlying Firebase API
- No custom OAuth implementation needed (firebase_auth + provider SDKs handle all complexity)
- Comprehensive exception handling with clear error codes

### Key Findings

#### 1. Reauthentication API Mechanics

**For Google**:
```dart
final GoogleSignIn googleSignIn = GoogleSignIn();
final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

final credential = firebase_auth.GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
);
await user.reauthenticateWithCredential(credential);
```

**For Apple**:
```dart
final appleCredential = await SignInWithApple.getAppleIDCredential(
  scopes: [
    AppleIDAuthorizationScopes.email,
    AppleIDAuthorizationScopes.fullName,
  ],
);

final oAuthProvider = firebase_auth.OAuthProvider('apple.com');
final credential = oAuthProvider.credential(
  idToken: appleCredential.identityToken,
  accessToken: appleCredential.authorizationCode,
);
await user.reauthenticateWithCredential(credential);
```

**For Email/Password** (existing pattern, reused):
```dart
final credential = firebase_auth.EmailAuthProvider.credential(
  email: user.email!,
  password: password,
);
await user.reauthenticateWithCredential(credential);
```

#### 2. Error Codes & Recovery Strategies

| Error | Cause | Recovery | User Message |
|-------|-------|----------|--------------|
| `requires-recent-login` | Session >5 min old | Prompt reauthentication; auto-retry after success | "Session expired. Please sign in again." |
| `invalid-credential` | Token malformed/expired | Request fresh provider tokens | "Authentication expired. Please try again." |
| `popup-closed-by-user` | User cancelled provider flow | Offer retry or cancel deletion | "Sign-in cancelled. Try again?" |
| `network-request-failed` | No internet or provider unreachable | Show retry with offline detection | "No connection. Check network and retry." |
| `user-disabled` | Firebase admin disabled account | Show support message; no recovery | "Account disabled. Contact support." |
| `too-many-requests` | Rate limit exceeded (5+ failed in ~5 min) | Show cooldown timer; disable retry button | "Too many attempts. Wait a few minutes." |

#### 3. Provider-Specific Differences

**Google vs. Apple**:
- Both use Firebase's native credential constructors
- Google: Requires accessToken + idToken
- Apple: Uses idToken + authorizationCode (different parameter names but same concept)
- Both throw FirebaseAuthException with consistent codes
- Google has broader platform support (Android + iOS native)
- Apple limited to iOS (web fallback on Android)

#### 4. Architecture Impact

**Minimal**: Extend existing `AuthenticationService` with 3 new methods:
- `reauthenticateWithGoogle()`
- `reauthenticateWithApple()`
- `deleteAccountWithProvider()`

Reuse existing error handling constants, `AuthResult` model, and exception patterns. No new services or models needed.

### Alternatives Considered & Rejected

| Alternative | Why Rejected |
|---|---|
| Custom OAuth flow | Redundant—Firebase Auth + SDKs already handle OAuth complexity |
| Manual credential validation | Would duplicate Firebase's built-in validation; risky |
| Store provider tokens locally | Security risk; Firebase already manages tokens |
| Require password for all users | Violates GDPR (users can't delete accounts they created without password) |

---

## Research Task 2: Provider Detection & Fallback Strategy

### Decision

**Selected Approach**: Query `user.providerData` array; attempt providers in priority order (Email/Password > Google > Apple); catch/retry on failure.

**Rationale**:
- `providerData` is authoritative Firebase source for linked providers
- Simple O(n) array iteration; no network calls needed for detection
- Priority ordering mirrors user UX preference (familiar → widely available → platform-specific)
- Fallback logic is straightforward: loop providers, catch exceptions, try next

### Key Findings

#### 1. Provider Data Structure

```dart
List<UserInfo> providerData = FirebaseAuth.instance.currentUser!.providerData;

// Each UserInfo contains:
// - providerId: "google.com", "apple.com", "password", etc.
// - uid: Provider-specific user ID (null for password)
// - email: Email from provider
// - displayName: User name
// - photoUrl: Profile photo URL
// - phoneNumber: Phone (if applicable)
// - isEmailVerified: Verification status
```

#### 2. Detection Patterns

**Detect Google Linked**:
```dart
bool isGoogleLinked() => FirebaseAuth.instance.currentUser?.providerData
    .any((p) => p.providerId == 'google.com') ?? false;
```

**Detect Social-Only User**:
```dart
bool isSocialOnlyUser() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  
  final hasPassword = user.providerData
      .any((p) => p.providerId == 'password');
  
  return !hasPassword && user.providerData.isNotEmpty;
}
```

**Get Linked Providers (Ordered)**:
```dart
List<String> getProvidersOrdered() {
  const priority = ['password', 'google.com', 'apple.com'];
  final providers = FirebaseAuth.instance.currentUser?.providerData
      .map((p) => p.providerId)
      .toList() ?? [];
  
  providers.sort((a, b) => priority.indexOf(a).compareTo(priority.indexOf(b)));
  return providers;
}
```

#### 3. Fallback Implementation

**Strategy for Hybrid Users** (Email/Password + Social):
1. Attempt email/password reauthentication
2. If fails, fall back to primary social provider (Google)
3. If both fail, return clear error

**Strategy for Social-Only Users**:
1. Attempt primary provider (Google first)
2. If fails, fall back to secondary (Apple)
3. If all fail, return clear error

**Code Pattern**:
```dart
Future<String> reauthenticateWithFallback() async {
  final providers = getProvidersOrdered();
  
  for (final provider in providers) {
    try {
      switch (provider) {
        case 'password': await _reauthWithPassword(...); break;
        case 'google.com': await _reauthWithGoogle(...); break;
        case 'apple.com': await _reauthWithApple(...); break;
      }
      return provider; // Success
    } catch (e) {
      continue; // Try next provider
    }
  }
  
  throw Exception('All providers failed');
}
```

#### 4. Provider Priority Rationale

| Priority | Provider | Why |
|----------|----------|-----|
| 1 | Email/Password | Most familiar; always available; no OAuth flow |
| 2 | Google | 90%+ market share; universal availability |
| 3 | Apple | Native iOS integration; smaller user base |
| 4+ | Facebook, etc. | Declining relevance; secondary fallback |

#### 5. Edge Cases & Handling

**Multiple Providers All Unavailable**:
- Show clear message: "Unable to authenticate with any sign-in method"
- List available options: "Try: Email/Password, Google, Apple"
- Suggest support contact

**Provider Revoked by User**:
- User revoked app in provider settings (e.g., Google Account > Security > Third-party apps)
- Still listed in `providerData`, but reauthentication throws `invalid-credential`
- Detect: Catch error → show "Re-enable this app in your [Provider] settings"
- Option: Auto-unlink revoked provider from account for future attempts

**Provider Session Stale**:
- User last signed in 6+ months ago
- Provider token expired but not revoked
- Detect: Reauthentication attempt fails with token-related error
- Recovery: Force fresh OAuth flow (user re-consents to scopes)

### Alternatives Considered & Rejected

| Alternative | Why Rejected |
|---|---|
| Async provider validation | Extra network call adds latency; reauthentication attempt validates anyway |
| Hard-coded provider order | Breaks for Apple-only users; inflexible for future providers |
| User chooses provider in UI | Adds complexity; automatic fallback more resilient |
| Device token caching | Security risk; Firebase handles tokens; doesn't solve revocation |

---

## Integration Points with Existing Code

### AuthenticationService (`lib/services/authentication_service.dart`)

**Existing Methods** (no changes):
- `deleteAccount(String password)` — Email/password deletion (keep unchanged)
- `_reauthenticateWithPassword(String password)` — Password reauth (reuse pattern)
- `getCurrentUser()` — Get current user (use for provider detection)

**New Methods** (add):
- `reauthenticateWithGoogle()` — Provider-specific reauthentication
- `reauthenticateWithApple()` — Provider-specific reauthentication  
- `deleteAccountWithProvider({String? password})` — Extended delete with fallback
- `_cleanupLocalDataAfterDelete()` — Partial cleanup helper

**Pattern**: Extend existing service; no new files or classes.

### Models (`lib/models/`)

**Existing**:
- `User` — Current user representation
- `AuthResult` — Auth operation result

**Changes**:
- `AuthResult`: May extend to support partial cleanup feedback (e.g., `cleanupFailures: List<String>`)
- No new models needed

### UI Layer (`lib/features/auth/`)

**New Files**:
- `screens/delete_account_flow.dart` — Multi-step deletion flow (confirmation → reauth → result)
- `widgets/delete_account_dialog.dart` — Initial confirmation dialog
- `constants/auth_constants.dart` — Extend with provider reauthentication error messages

**Pattern**: Add to existing auth feature folder; reuse Material dialogs and TextFields.

---

## Testing Strategy

### Unit Tests (if added)

```dart
testWidgets('Detect Google-linked user', () {
  // Arrange: Mock FirebaseAuth with Google provider
  // Act: Call isGoogleLinked()
  // Assert: Returns true
});

testWidgets('Fallback: Try Google, then Apple on failure', () {
  // Arrange: Mock Google reauth to fail, Apple to succeed
  // Act: Call reauthenticateWithFallback()
  // Assert: Returns 'apple.com' as successful provider
});
```

### Manual Integration Tests (per project constitution)

1. **Social-only user deletes account**:
   - Sign in with Google (no password set)
   - Trigger delete account
   - Complete Google reauthentication
   - Confirm account deleted + local data cleared

2. **Hybrid user deletes account**:
   - Sign in with email/password, also link Google
   - Trigger delete account
   - Complete email/password reauthentication
   - Confirm account deleted

3. **Error recovery**:
   - Trigger delete; force provider token to expire mid-flow
   - See error message on current screen with retry button
   - Tap retry; complete reauthentication successfully
   - Confirm deletion succeeds

---

## Dependencies & Versions (Verified)

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_auth` | ^5.3.1 | Account management + reauthentication APIs |
| `google_sign_in` | ^6.2.1 | Google OAuth provider flow |
| `sign_in_with_apple` | ^6.1.2 | Apple OAuth provider flow |
| `shared_preferences` | ^2.3.2 | Local data persistence (cleanup) |
| `flutter_secure_storage` | ^9.2.2 | Token storage (cleanup) |

**All already in pubspec.yaml**; no new dependencies needed.

---

## Risk Assessment

### Low-Risk Items

✅ Provider reauthentication (Firebase handles OAuth complexity; well-tested APIs)  
✅ Error handling (Firebase error codes are consistent and well-documented)  
✅ Local data cleanup (existing patterns from feature 001, tracklog service)

### Medium-Risk Items

⚠️ **Multiple provider fallback**: Order/priority assumptions may not match all users. Mitigation: Show provider selection in UI if time permits (deferred to Phase 2).

⚠️ **Partial cleanup tolerance**: Accepting partial failures on local cleanup. Mitigation: Log failures clearly so team can debug; user informed of outcome.

### High-Risk Items

🔴 None identified. Architecture is straightforward, dependencies are stable, and research provides clear implementation path.

---

## Open Questions → RESOLVED ✅

**All questions from Clarifications section are answered and locked into spec.md:**

1. ✅ **Provider selection strategy**: Primary > Fallback
2. ✅ **Auto-retry on reauth**: Yes, immediately after reauth succeeds
3. ✅ **Error recovery UX**: Keep on current screen with retry/cancel buttons
4. ✅ **Data cleanup atomicity**: Partial cleanup (continue if some operations fail)
5. ✅ **Linked account handling**: Email/password > social provider fallback

---

## Recommendations for Phase 1 Design

### High Priority
1. Design `DeletionRequest` entity for audit logging (user, provider, timestamp, outcome)
2. Define service method contracts (signatures, parameters, return types)
3. Map error codes to user-friendly messages in `auth_constants.dart`

### Medium Priority
4. Sketch UI flows (deletion confirmation, reauthentication dialog, error messages)
5. Plan data model for `UserSession` (track linked providers, current auth state)

### Polish (Phase 2+)
6. Add provider selection UI for hybrid users (optional; fallback strategy handles most cases)
7. Implement provider-specific optimizations (e.g., Google Play Services detection)
8. Add device-level caching for provider availability (optional)

---

## Conclusion

**Status**: ✅ All research questions resolved. No blockers identified. Architecture is straightforward: extend existing AuthenticationService with provider-specific reauthentication + fallback + cleanup. Feature ready for Phase 1 design.

**Next Phase**: Generate data-model.md, contracts/, quickstart.md, and proceed to speckit.tasks for task breakdown.

---

*Generated by speckit.plan Phase 0 research*
