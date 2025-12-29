# Research: Firebase User Authentication & Account Management

**Date**: 2025-12-29  
**Feature**: 003-firebase-user-auth  
**Purpose**: Resolve all technical unknowns before design phase

## Research Areas

### 1. Firebase Authentication Setup for Flutter

**Decision**: Use firebase_core + firebase_auth packages  
**Rationale**: Official Firebase packages for Flutter, actively maintained by Google, comprehensive documentation, proven at scale

**Key Findings**:
- `firebase_core` ^3.6.0 - Required base package for all Firebase services
- `firebase_auth` ^5.3.1 - Authentication SDK with email/password, social providers, account linking
- Requires platform-specific configuration:
  - **iOS**: GoogleService-Info.plist in ios/Runner/
  - **Android**: google-services.json in android/app/
- Firebase console setup required: Create project, enable Authentication providers
- Supports persistence: Users stay logged in across app restarts by default

**Alternatives Considered**:
- Custom backend with JWT - Rejected: adds complexity, security burden, maintenance overhead
- Supabase - Rejected: similar feature set but less Flutter ecosystem maturity
- AWS Amplify - Rejected: more complex setup, less Flutter-specific documentation

### 2. Email/Password Authentication Best Practices

**Decision**: Use Firebase's built-in email/password with password strength validation  
**Rationale**: Firebase handles hashing, salting, rate limiting server-side. Client validates format/strength before sending

**Key Findings**:
- Firebase automatically enforces minimum 6 character password (configurable to 8 in Firebase Console settings)
- Email format validation available via `EmailValidator` package or manual regex
- Password requirements (uppercase, lowercase, number) validated client-side before submission
- Email verification handled by Firebase: `user.sendEmailVerification()`
- Password reset via `FirebaseAuth.instance.sendPasswordResetEmail(email)`
- Best practice: Show specific validation errors before submission, generic errors after (security)

**Implementation Pattern**:
```dart
final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);
await authResult.user?.sendEmailVerification();
```

### 3. Google Sign-In Integration

**Decision**: Use google_sign_in ^6.2.1 package with Firebase Auth integration  
**Rationale**: Official Google package, seamless Firebase integration, handles OAuth flow

**Key Findings**:
- Requires OAuth 2.0 client IDs for iOS and Android (from Google Cloud Console)
- iOS requires URL schemes configured in Info.plist
- Android requires SHA-1 certificate fingerprints in Firebase Console
- Web client ID required for iOS (from Firebase Console)
- Account linking handled automatically by Firebase when email matches

**Setup Requirements**:
1. Enable Google Sign-In in Firebase Console
2. Configure OAuth consent screen in Google Cloud Console
3. Add platform-specific configurations
4. Handle sign-in flow with credential exchange

**Implementation Pattern**:
```dart
final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
);
await FirebaseAuth.instance.signInWithCredential(credential);
```

### 4. Apple Sign In Integration

**Decision**: Use sign_in_with_apple ^6.1.2 package  
**Rationale**: Required by AppStore when offering other social login options, official Apple package

**Key Findings**:
- **MANDATORY**: Apple requires this when offering Google/Facebook login (AppStore Review Guideline 4.8)
- iOS 13+ support only (graceful degradation needed for older versions)
- Requires Apple Developer account with "Sign In with Apple" capability enabled
- Service ID configuration required in Apple Developer portal
- Firebase integration similar to Google Sign-In pattern
- Apple can provide anonymous email relay (privaterelay.appleid.com) - still valid for account linking

**Setup Requirements**:
1. Enable "Sign In with Apple" capability in Xcode
2. Create Service ID in Apple Developer portal
3. Configure redirect URLs in Apple Developer portal
4. Enable Apple Sign-In provider in Firebase Console
5. Add SHA-256 certificate in Firebase Console for Android support

**Implementation Pattern**:
```dart
final appleCredential = await SignInWithApple.getAppleIDCredential(
  scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
);
final oAuthCredential = OAuthProvider('apple.com').credential(
  idToken: appleCredential.identityToken,
  accessToken: appleCredential.authorizationCode,
);
await FirebaseAuth.instance.signInWithCredential(oAuthCredential);
```

### 5. Account Linking Between Providers

**Decision**: Use Firebase's automatic account linking with email matching  
**Rationale**: Firebase built-in feature, prevents duplicate accounts, seamless UX

**Key Findings**:
- Firebase links accounts automatically when email matches across providers
- Requires enabling "One account per email address" in Firebase Console Authentication settings
- If user signs in with Google (email@example.com) after registering with email/password (same email), Firebase links them
- Supports adding additional sign-in methods to existing account: `user.linkWithCredential(credential)`
- Error handling: `FirebaseAuthException` with code `account-exists-with-different-credential` if linking fails

**Implementation Strategy**:
1. Enable "One account per email address" in Firebase Console (recommended setting)
2. Handle `account-exists-with-different-credential` error gracefully
3. For explicit linking (user adding password to social account): use `linkWithCredential()`

**Pattern for Explicit Linking**:
```dart
try {
  final emailCredential = EmailAuthProvider.credential(email: email, password: password);
  await FirebaseAuth.instance.currentUser?.linkWithCredential(emailCredential);
} on FirebaseAuthException catch (e) {
  if (e.code == 'provider-already-linked') {
    // Already linked
  } else if (e.code == 'credential-already-in-use') {
    // Email used by another account
  }
}
```

### 6. Guest Data Migration Strategy

**Decision**: Use shared_preferences to track guest data, migrate on first authentication  
**Rationale**: Simple, works offline, no backend changes needed

**Key Findings**:
- Guest data stored locally (tracklogs, preferences) with flag `isGuest: true`
- On account creation/login: check for guest data, associate with user UID
- Migration pattern: Copy guest data files/records to authenticated user's space
- Use Firebase Auth's user UID as primary key for user-specific data
- Delete guest data after successful migration to save storage

**Migration Flow**:
1. User creates account/logs in → gets Firebase UID
2. Check shared_preferences for `hasGuestData` flag
3. If true: Copy tracklogs from guest directory to user-specific directory (named by UID)
4. Update database records to associate with user UID
5. Clear `hasGuestData` flag, delete guest directory
6. Handle migration failures: keep guest data, set `migrationPending` flag, retry on next app start

**Storage Pattern**:
```
local_storage/
├── guest/                    # Guest mode data
│   ├── tracklogs/
│   └── preferences.json
└── users/
    └── {firebase_uid}/       # Per-user data
        ├── tracklogs/
        └── preferences.json
```

### 7. Secure Token Storage

**Decision**: Use flutter_secure_storage ^9.2.2 for OAuth tokens  
**Rationale**: Platform-specific secure storage (iOS Keychain, Android Keystore), industry standard

**Key Findings**:
- Firebase Auth tokens stored automatically by SDK (secure by default)
- Additional tokens (refresh tokens, custom claims) should use secure storage
- flutter_secure_storage uses:
  - **iOS**: Keychain Services
  - **Android**: EncryptedSharedPreferences (Keystore-backed)
- No plaintext storage in shared_preferences for sensitive data
- Tokens automatically invalidated on logout

**Implementation**:
```dart
final storage = FlutterSecureStorage();
await storage.write(key: 'firebase_token', value: token);
final token = await storage.read(key: 'firebase_token');
await storage.delete(key: 'firebase_token'); // On logout
```

### 8. Offline Support & Error Handling

**Decision**: Firebase Auth works offline for already-authenticated users, graceful degradation for online operations  
**Rationale**: Users need to access app even without connectivity

**Key Findings**:
- Firebase Auth maintains local session state (persisted tokens)
- Already-authenticated users can use app offline
- Operations requiring network (registration, login, password reset) fail gracefully
- Show user-friendly messages: "No internet connection. Please try again."
- Implement retry logic for transient failures
- Token refresh happens automatically when online

**Error Handling Pattern**:
```dart
try {
  await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No account found with this email';
    case 'wrong-password':
      return 'Invalid email or password';
    case 'network-request-failed':
      return 'No internet connection. Please try again.';
    default:
      return 'Sign in failed. Please try again.';
  }
}
```

### 9. Account Deletion & Data Privacy

**Decision**: Firebase account deletion with local data cleanup  
**Rationale**: GDPR/CCPA compliance, AppStore requirement

**Key Findings**:
- Firebase: `user.delete()` removes authentication record
- Requires recent authentication (reauthenticate before deletion for security)
- Must manually delete user data:
  - Local: Delete user's directory from local storage
  - Cloud (if added later): Delete Firestore/Storage records
- Re-authentication pattern: `user.reauthenticateWithCredential(credential)` before `user.delete()`

**Deletion Flow**:
1. Show warning dialog
2. Prompt user for password (re-authentication)
3. Call `user.reauthenticateWithCredential()`
4. Delete local user data (tracklogs, preferences)
5. Call `user.delete()` to remove Firebase auth record
6. Navigate to login screen

### 10. UI/UX Patterns for Authentication

**Decision**: Standard Flutter forms with loading states and error messages  
**Rationale**: Simple, follows Flutter conventions, no custom state management needed initially

**Key Findings**:
- Use `Form` widget with `TextFormField` for input validation
- `GlobalKey<FormState>` for form state management
- Show `CircularProgressIndicator` during async operations
- Display errors in `SnackBar` or `AlertDialog`
- Disable buttons during loading to prevent duplicate submissions
- Keyboard handling: `TextInputAction.next` for email → password flow

**Screen Structure**:
- **LoginScreen**: Email/password fields, social login buttons, "Forgot Password" link, "Create Account" link
- **RegisterScreen**: Email/password fields, social login buttons, password requirements text
- **ProfileScreen**: Display name editor, email/password change options, account deletion button
- **AuthenticationWrapper**: Checks auth state, routes to appropriate screen

### 11. Testing Strategy

**Decision**: Widget tests for UI, mock Firebase for authentication service tests  
**Rationale**: Fast tests, no Firebase project required for CI/CD

**Key Findings**:
- Use `mockito` or `fake_firebase_auth` package for mocking Firebase Auth
- Widget tests: Verify UI renders, buttons work, form validation
- Unit tests: AuthenticationService methods with mocked Firebase
- Integration tests (optional): Test actual Firebase in debug mode
- Golden tests (optional): Visual regression testing for authentication screens

**Testing Pattern**:
```dart
// Mock Firebase Auth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

// Test authentication service
test('signIn with valid credentials succeeds', () async {
  when(mockAuth.signInWithEmailAndPassword(email: any, password: any))
      .thenAnswer((_) async => mockUserCredential);
  
  final result = await authService.signIn(email, password);
  expect(result.isSuccess, true);
});
```

## Technology Stack Decision Matrix

| Technology | Purpose | Decision | Why |
|------------|---------|----------|-----|
| firebase_core | Firebase initialization | ✅ Use | Required for all Firebase services |
| firebase_auth | Authentication SDK | ✅ Use | Official, proven, handles security |
| google_sign_in | Google OAuth | ✅ Use | Official Google package |
| sign_in_with_apple | Apple OAuth | ✅ Use | AppStore requirement, official |
| flutter_secure_storage | Token storage | ✅ Use | Platform secure storage |
| shared_preferences | Guest data tracking | ✅ Use | Simple key-value store |
| email_validator | Email validation | ✅ Use | Lightweight, common validation |

## Dependencies to Add to pubspec.yaml

```yaml
dependencies:
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  
  # Social login
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.2
  
  # Secure storage
  flutter_secure_storage: ^9.2.2
  
  # Utilities
  shared_preferences: ^2.3.2
  email_validator: ^3.0.0

dev_dependencies:
  # Testing
  mockito: ^5.4.4
  build_runner: ^2.4.13  # For mockito code generation
```

## Firebase Console Configuration Checklist

- [ ] Create Firebase project
- [ ] Add iOS app (Bundle ID)
- [ ] Add Android app (Package name)
- [ ] Download GoogleService-Info.plist (iOS)
- [ ] Download google-services.json (Android)
- [ ] Enable Email/Password provider
- [ ] Enable Google Sign-In provider
- [ ] Enable Apple Sign-In provider
- [ ] Configure OAuth consent screen
- [ ] Add OAuth 2.0 client IDs (iOS/Android)
- [ ] Enable "One account per email address" setting
- [ ] Configure password policy (minimum 8 characters)

## Apple Developer Configuration Checklist

- [ ] Enable "Sign In with Apple" capability in Xcode
- [ ] Create App ID with Sign In with Apple enabled
- [ ] Create Service ID
- [ ] Configure return URLs
- [ ] Generate and download key for Sign In with Apple

## Google Cloud Console Configuration Checklist

- [ ] Create OAuth 2.0 credentials
- [ ] Add Android SHA-1 fingerprint
- [ ] Configure OAuth consent screen
- [ ] Add authorized redirect URIs

## Security Considerations

1. **Never store passwords in plaintext** - Firebase handles hashing
2. **Use secure storage for tokens** - flutter_secure_storage
3. **Validate input client-side** - Prevent malformed requests
4. **Handle errors securely** - Don't reveal account existence
5. **Re-authenticate before sensitive operations** - Account deletion, email change
6. **Rate limiting** - Handled by Firebase server-side
7. **HTTPS only** - Firebase enforces this by default

## Open Questions Resolved

All questions from the specification have been resolved through this research:
- ✅ Firebase setup process documented
- ✅ Social login integration patterns defined
- ✅ Account linking strategy selected (automatic via Firebase)
- ✅ Guest data migration approach defined (shared_preferences + file copy)
- ✅ Secure token storage solution identified (flutter_secure_storage)
- ✅ Error handling patterns documented
- ✅ Testing strategy defined

## Next Steps

Phase 1: Use this research to create:
1. **data-model.md** - Define User, AuthSession, Profile entities
2. **contracts/** - Define AuthenticationService interface
3. **quickstart.md** - Firebase setup guide for developers
