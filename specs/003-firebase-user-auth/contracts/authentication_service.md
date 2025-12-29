# Authentication Service Contract

**Purpose**: Define the interface for all authentication operations  
**Location**: Will be implemented as `lib/services/authentication_service.dart`  
**Pattern**: Service class with static/singleton access

---

## Interface Definition

```dart
/// Authentication service handling user registration, login, and account management
class AuthenticationService {
  
  // ============================================================================
  // REGISTRATION
  // ============================================================================
  
  /// Register a new user with email and password
  /// 
  /// Validates email format and password requirements client-side before
  /// sending to Firebase. Automatically migrates guest data upon successful
  /// registration.
  /// 
  /// Parameters:
  ///   - email: Valid email address
  ///   - password: Min 8 chars, 1 uppercase, 1 lowercase, 1 number
  /// 
  /// Returns: AuthResult with user or error
  /// 
  /// Errors:
  ///   - 'email-already-in-use': Email registered by another user
  ///   - 'invalid-email': Email format invalid
  ///   - 'weak-password': Password doesn't meet requirements
  ///   - 'network-request-failed': No internet connection
  Future<AuthResult> registerWithEmail(String email, String password);
  
  /// Register a new user with Google Sign-In
  /// 
  /// Opens Google Sign-In flow, exchanges credentials with Firebase,
  /// automatically links if email already exists. Migrates guest data
  /// upon successful registration.
  /// 
  /// Returns: AuthResult with user or error
  /// 
  /// Errors:
  ///   - 'sign_in_canceled': User cancelled Google sign-in flow
  ///   - 'sign_in_failed': Google authentication failed
  ///   - 'network-request-failed': No internet connection
  ///   - 'account-exists-with-different-credential': Account exists, linking attempted
  Future<AuthResult> registerWithGoogle();
  
  /// Register a new user with Apple Sign In
  /// 
  /// Opens Apple Sign In flow, exchanges credentials with Firebase,
  /// automatically links if email already exists. Migrates guest data
  /// upon successful registration.
  /// 
  /// Returns: AuthResult with user or error
  /// 
  /// Errors:
  ///   - 'sign_in_canceled': User cancelled Apple sign-in flow
  ///   - 'sign_in_failed': Apple authentication failed
  ///   - 'network-request-failed': No internet connection
  ///   - 'account-exists-with-different-credential': Account exists, linking attempted
  Future<AuthResult> registerWithApple();
  
  // ============================================================================
  // LOGIN
  // ============================================================================
  
  /// Sign in existing user with email and password
  /// 
  /// Authenticates with Firebase, discards guest data if present (cloud
  /// data takes precedence), creates new session.
  /// 
  /// Parameters:
  ///   - email: Registered email address
  ///   - password: User's password
  /// 
  /// Returns: AuthResult with user or error
  /// 
  /// Errors:
  ///   - 'user-not-found': No account with this email
  ///   - 'wrong-password': Incorrect password
  ///   - 'invalid-email': Email format invalid
  ///   - 'user-disabled': Account has been disabled
  ///   - 'network-request-failed': No internet connection
  Future<AuthResult> signInWithEmail(String email, String password);
  
  /// Sign in existing user with Google Sign-In
  /// 
  /// Opens Google Sign-In flow, authenticates with Firebase, discards guest
  /// data, creates new session.
  /// 
  /// Returns: AuthResult with user or error
  /// 
  /// Errors: Same as registerWithGoogle()
  Future<AuthResult> signInWithGoogle();
  
  /// Sign in existing user with Apple Sign In
  /// 
  /// Opens Apple Sign In flow, authenticates with Firebase, discards guest
  /// data, creates new session.
  /// 
  /// Returns: AuthResult with user or error
  /// 
  /// Errors: Same as registerWithApple()
  Future<AuthResult> signInWithApple();
  
  // ============================================================================
  // PASSWORD MANAGEMENT
  // ============================================================================
  
  /// Send password reset email to user
  /// 
  /// Firebase sends email with reset link. Email must be registered.
  /// 
  /// Parameters:
  ///   - email: Registered email address
  /// 
  /// Returns: Success (true) or error
  /// 
  /// Errors:
  ///   - 'user-not-found': No account with this email (security: don't reveal this)
  ///   - 'invalid-email': Email format invalid
  ///   - 'network-request-failed': No internet connection
  /// 
  /// Note: For security, success returned even if email doesn't exist
  Future<Result<void>> sendPasswordReset(String email);
  
  /// Change password for current user
  /// 
  /// Requires current password for re-authentication (security measure).
  /// Only available for email/password accounts.
  /// 
  /// Parameters:
  ///   - currentPassword: User's current password
  ///   - newPassword: New password meeting requirements
  /// 
  /// Returns: Success or error
  /// 
  /// Errors:
  ///   - 'wrong-password': Current password incorrect
  ///   - 'weak-password': New password doesn't meet requirements
  ///   - 'requires-recent-login': Session too old, re-auth needed
  ///   - 'network-request-failed': No internet connection
  Future<Result<void>> changePassword(String currentPassword, String newPassword);
  
  // ============================================================================
  // PROFILE MANAGEMENT
  // ============================================================================
  
  /// Update user's display name
  /// 
  /// Updates both Firebase Auth profile and local user profile.
  /// 
  /// Parameters:
  ///   - displayName: New display name (2-50 characters, optional null to clear)
  /// 
  /// Returns: Success or error
  /// 
  /// Errors:
  ///   - 'invalid-display-name': Name doesn't meet requirements
  ///   - 'network-request-failed': No internet connection (local only update)
  Future<Result<void>> updateDisplayName(String? displayName);
  
  /// Update user's email address
  /// 
  /// Sends verification email to new address. Email change pending verification.
  /// Requires recent authentication.
  /// 
  /// Parameters:
  ///   - newEmail: New email address
  ///   - password: Current password for re-authentication
  /// 
  /// Returns: Success or error
  /// 
  /// Errors:
  ///   - 'email-already-in-use': Email used by another account
  ///   - 'invalid-email': Email format invalid
  ///   - 'wrong-password': Password incorrect
  ///   - 'requires-recent-login': Need to re-authenticate
  ///   - 'network-request-failed': No internet connection
  Future<Result<void>> updateEmail(String newEmail, String password);
  
  /// Get current user profile
  /// 
  /// Returns current authenticated user or null if signed out.
  /// 
  /// Returns: User object or null
  User? getCurrentUser();
  
  /// Stream of authentication state changes
  /// 
  /// Emits current user whenever auth state changes (sign in, sign out, token refresh).
  /// Used by app to navigate between authenticated/unauthenticated screens.
  /// 
  /// Returns: Stream of User (signed in) or null (signed out)
  Stream<User?> authStateChanges();
  
  // ============================================================================
  // EMAIL VERIFICATION
  // ============================================================================
  
  /// Send email verification to current user
  /// 
  /// Firebase sends verification email with link. User can verify later.
  /// 
  /// Returns: Success or error
  /// 
  /// Errors:
  ///   - 'too-many-requests': Rate limited, try again later
  ///   - 'network-request-failed': No internet connection
  Future<Result<void>> sendEmailVerification();
  
  /// Check if current user's email is verified
  /// 
  /// Returns: true if verified, false if unverified or no user
  bool isEmailVerified();
  
  // ============================================================================
  // ACCOUNT DELETION
  // ============================================================================
  
  /// Delete user account permanently
  /// 
  /// Requires re-authentication for security. Deletes Firebase auth record
  /// and all local user data (profile, tracklogs, preferences).
  /// 
  /// Parameters:
  ///   - password: Current password for re-authentication (email/password accounts)
  ///     For social accounts, user must re-authenticate via social provider first
  /// 
  /// Returns: Success or error
  /// 
  /// Errors:
  ///   - 'wrong-password': Password incorrect
  ///   - 'requires-recent-login': Need recent authentication
  ///   - 'network-request-failed': No internet connection
  /// 
  /// Warning: This operation is irreversible. All data permanently deleted.
  Future<Result<void>> deleteAccount(String? password);
  
  // ============================================================================
  // SESSION MANAGEMENT
  // ============================================================================
  
  /// Sign out current user
  /// 
  /// Invalidates session, clears auth tokens, returns to unauthenticated state.
  /// 
  /// Returns: Success or error
  /// 
  /// Note: Rarely fails, local operation mostly
  Future<Result<void>> signOut();
  
  /// Check if user is currently authenticated
  /// 
  /// Returns: true if user signed in, false if signed out
  bool isSignedIn();
  
  // ============================================================================
  // ACCOUNT LINKING
  // ============================================================================
  
  /// Link email/password credentials to current social account
  /// 
  /// Allows user who signed up with Google/Apple to add password authentication.
  /// Enables future sign-in with either method.
  /// 
  /// Parameters:
  ///   - email: Email address (should match current account email)
  ///   - password: New password meeting requirements
  /// 
  /// Returns: Success or error
  /// 
  /// Errors:
  ///   - 'provider-already-linked': Email/password already linked
  ///   - 'credential-already-in-use': Email used by different account
  ///   - 'invalid-email': Email doesn't match current account
  ///   - 'weak-password': Password doesn't meet requirements
  Future<Result<void>> linkEmailPassword(String email, String password);
  
  /// Link Google account to current email/password account
  /// 
  /// Opens Google Sign-In flow, links to existing account if email matches.
  /// 
  /// Returns: Success or error
  /// 
  /// Errors: Similar to registerWithGoogle()
  Future<Result<void>> linkGoogleAccount();
  
  /// Link Apple account to current email/password account
  /// 
  /// Opens Apple Sign In flow, links to existing account if email matches.
  /// 
  /// Returns: Success or error
  /// 
  /// Errors: Similar to registerWithApple()
  Future<Result<void>> linkAppleAccount();
  
  // ============================================================================
  // GUEST DATA MIGRATION (Internal)
  // ============================================================================
  
  /// Migrate guest data to authenticated user
  /// 
  /// Called automatically after registration or first login.
  /// Copies guest tracklogs to user-specific storage, updates metadata.
  /// 
  /// Returns: Success or error (non-blocking, retries if fails)
  /// 
  /// Internal method - not exposed to UI layer
  Future<Result<void>> _migrateGuestData(String userId);
  
  /// Discard guest data when logging into existing account
  /// 
  /// Called automatically when user signs into existing account.
  /// Removes guest data as cloud data takes precedence.
  /// 
  /// Internal method - not exposed to UI layer
  Future<void> _discardGuestData();
}
```

---

## Data Types

### AuthResult

```dart
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final String? errorCode;
  
  AuthResult.success(this.user) 
    : success = true, 
      error = null, 
      errorCode = null;
  
  AuthResult.failure(this.errorCode, this.error)
    : success = false,
      user = null;
}
```

### Result<T>

```dart
class Result<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? errorCode;
  
  Result.success([this.data])
    : success = true,
      error = null,
      errorCode = null;
  
  Result.failure(this.errorCode, this.error)
    : success = false,
      data = null;
}
```

### User

```dart
class User {
  final String userId;
  final String email;
  final bool emailVerified;
  final String? displayName;
  final AuthProvider authProvider;
  final DateTime createdAt;
  final DateTime lastSignInAt;
  final String? photoUrl;
  
  // Convenience methods
  bool get isEmailPasswordAccount => authProvider == AuthProvider.emailPassword;
  bool get isSocialAccount => authProvider != AuthProvider.emailPassword;
}
```

### AuthProvider (Enum)

```dart
enum AuthProvider {
  emailPassword,
  google,
  apple,
}
```

---

## Error Handling Strategy

### User-Facing Messages

Map Firebase error codes to user-friendly messages:

| Firebase Code | User Message |
|---------------|--------------|
| `email-already-in-use` | "This email is already registered. Please sign in." |
| `user-not-found` | "Invalid email or password" (security) |
| `wrong-password` | "Invalid email or password" (security) |
| `weak-password` | "Password must be at least 8 characters with uppercase, lowercase, and number" |
| `invalid-email` | "Please enter a valid email address" |
| `network-request-failed` | "No internet connection. Please try again." |
| `sign_in_canceled` | "Sign-in cancelled" |
| `too-many-requests` | "Too many attempts. Please try again later." |
| `requires-recent-login` | "For security, please sign in again before making this change" |

### Error Response Pattern

```dart
if (!result.success) {
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result.error ?? 'An error occurred')),
  );
}
```

---

## Usage Examples

### Registration

```dart
final authService = AuthenticationService.instance;

// Email/Password
final result = await authService.registerWithEmail(
  'user@example.com',
  'SecurePass123',
);

if (result.success) {
  // Navigate to main screen
  Navigator.pushReplacementNamed(context, '/home');
} else {
  // Show error
  showError(result.error);
}

// Social Login
final googleResult = await authService.registerWithGoogle();
```

### Login

```dart
final result = await authService.signInWithEmail(email, password);

if (result.success) {
  // Check email verification status
  if (!result.user!.emailVerified) {
    // Show reminder
    showEmailVerificationReminder();
  }
  navigateToHome();
}
```

### Profile Management

```dart
// Update display name
await authService.updateDisplayName('John Doe');

// Change password
final result = await authService.changePassword(
  'OldPass123',
  'NewPass456',
);

// Change email
await authService.updateEmail('newemail@example.com', 'CurrentPass123');
```

### Account Deletion

```dart
// Show warning dialog first
final confirmed = await showDeleteConfirmationDialog();

if (confirmed) {
  final password = await promptForPassword();
  final result = await authService.deleteAccount(password);
  
  if (result.success) {
    Navigator.pushReplacementNamed(context, '/login');
  }
}
```

### Auth State Listening

```dart
authService.authStateChanges().listen((user) {
  if (user != null) {
    // User signed in
    navigateToHome();
  } else {
    // User signed out
    navigateToLogin();
  }
});
```

---

## Implementation Notes

1. **Singleton Pattern**: Use `AuthenticationService.instance` for global access
2. **Firebase Integration**: All methods wrap `firebase_auth` package calls
3. **Error Handling**: Catch `FirebaseAuthException` and convert to user-friendly messages
4. **Loading States**: All async methods should trigger loading indicators in UI
5. **Validation**: Perform client-side validation before Firebase calls to provide immediate feedback
6. **Testing**: Use `MockAuthenticationService` for widget tests, Firebase Auth Emulator for integration tests

---

## Next Steps

1. Implement `lib/services/authentication_service.dart` following this contract
2. Create corresponding model classes in `lib/models/`
3. Build UI screens that call these service methods
4. Add error handling and loading states in UI
5. Write unit tests for service methods
6. Write widget tests for authentication screens
