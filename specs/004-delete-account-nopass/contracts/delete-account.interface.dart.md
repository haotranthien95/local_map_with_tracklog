/**
 * API Contracts: Delete Account Without Password (004-delete-account-nopass)
 *
 * This file defines the public API contracts for account deletion with provider
 * reauthentication. These are the service method signatures that feature 004
 * introduces to the AuthenticationService.
 *
 * Language: Dart
 * Target: lib/services/authentication_service.dart
 */

// ============================================================================
// REAUTHENTICATION CONTRACTS (Provider-Specific)
// ============================================================================

/// Reauthenticate current user with Google Sign-In
///
/// Returns: AuthResult with success/failure
/// Throws: No exceptions; all errors wrapped in AuthResult
/// Side Effects:
///   - Displays Google Sign-In dialog
///   - Updates Firebase Auth session if successful
///
/// Error Codes (via AuthResult.errorCode):
///   - 'popup-closed-by-user': User cancelled the sign-in dialog
///   - 'network-request-failed': No internet or provider unreachable
///   - 'invalid-credential': Token malformed or expired
///   - 'user-disabled': Firebase admin disabled the account
///   - 'too-many-requests': Rate limited; user should retry after cooldown
///   - 'no-current-user': No user signed in
///   - 'provider-not-linked': Google not linked to this account
///   - 'unknown-error': Unexpected error
///
/// Example:
/// ```dart
/// final result = await authService.reauthenticateWithGoogle();
/// if (result.isSuccess) {
///   print('Google reauthentication succeeded');
///   // Proceed with account deletion
/// } else {
///   print('Reauthentication failed: ${result.message}');
///   // Show error dialog to user
/// }
/// ```
///
Future<AuthResult> reauthenticateWithGoogle()

/// Reauthenticate current user with Apple Sign-In
///
/// Returns: AuthResult with success/failure
/// Throws: No exceptions; all errors wrapped in AuthResult
/// Side Effects:
///   - Displays Apple Sign-In dialog
///   - Updates Firebase Auth session if successful
///   - On iOS: Native ASAuthorizationController
///   - On Android: Web-based fallback
///
/// Error Codes (via AuthResult.errorCode):
///   - 'popup-closed-by-user': User cancelled the sign-in dialog
///   - 'network-request-failed': No internet or provider unreachable
///   - 'invalid-credential': Token malformed or expired
///   - 'user-disabled': Firebase admin disabled the account
///   - 'too-many-requests': Rate limited; user should retry after cooldown
///   - 'no-current-user': No user signed in
///   - 'provider-not-linked': Apple not linked to this account
///   - 'unknown-error': Unexpected error
///
/// Example:
/// ```dart
/// final result = await authService.reauthenticateWithApple();
/// if (result.isSuccess) {
///   print('Apple reauthentication succeeded');
///   // Proceed with account deletion
/// } else {
///   print('Reauthentication failed: ${result.message}');
///   // Show error dialog to user
/// }
/// ```
///
Future<AuthResult> reauthenticateWithApple()

// ============================================================================
// ACCOUNT DELETION CONTRACTS
// ============================================================================

/// Delete current user account with intelligent provider selection
///
/// This method extends the existing deleteAccount(password) method to support
/// social-only users. It implements the following strategy:
///
/// 1. For hybrid users (email/password + social):
///    - Attempt email/password reauthentication first
///    - If fails, fall back to primary social provider (Google > Apple)
///
/// 2. For social-only users:
///    - Attempt primary provider (Google > Apple)
///    - Automatically fall back to secondary provider if primary fails
///
/// 3. For email/password-only users:
///    - Use existing password-based reauthentication flow
///
/// Parameters:
///   - password: Required for email/password accounts; omit for social-only.
///              If provided and email/password provider exists, that path is used.
///
/// Returns: AuthResult.success(user: null) on completion
///
/// Side Effects:
///   - Reauthenticates user with chosen provider
///   - Deletes Firebase user account
///   - Clears local data (markers, tracklogs, tokens, preferences)
///   - Signs out user
///   - May log deletion details to audit trail (future)
///
/// Error Codes (via AuthResult.errorCode):
///   - 'requires-recent-login': Session too old; user must reauthenticate
///   - 'popup-closed-by-user': User cancelled provider sign-in
///   - 'network-request-failed': No internet during reauthentication
///   - 'invalid-credential': Provider credential invalid/expired
///   - 'reauthentication-failed': All providers failed (message includes details)
///   - 'no-auth-method': No authentication method available (invalid state)
///   - 'account-deletion-failed': Firebase account deletion failed
///   - 'user-disabled': Account disabled by admin
///   - 'too-many-requests': Rate limited
///   - 'unknown-error': Unexpected error
///
/// Atomicity:
///   - Account deletion: Atomic (either deleted or not)
///   - Local data cleanup: Partial cleanup allowed per FR-003
///     - If individual cleanup operation fails, continue clearing remaining data
///     - Success message includes cleanup failure list: "Account deleted. (Warnings: x, y)"
///
/// Example (Social-Only User):
/// ```dart
/// final result = await authService.deleteAccount();
/// if (result.isSuccess) {
///   print('Account deleted successfully');
///   // Navigate to sign-in screen
///   Navigator.pushReplacementNamed(context, '/sign_in');
/// } else if (result.errorCode == 'requires-recent-login') {
///   print('Session stale; user must reauthenticate');
///   // Show dialog: "Please sign in again to delete your account"
/// } else if (result.errorCode == 'popup-closed-by-user') {
///   print('User cancelled sign-in; show retry/cancel options');
/// } else {
///   print('Deletion failed: ${result.message}');
///   // Show error dialog to user
/// }
/// ```
///
/// Example (Hybrid User):
/// ```dart
/// try {
///   final password = await showPasswordPrompt(context);
///   final result = await authService.deleteAccount(password: password);
///   if (result.isSuccess) {
///     // Success
///   } else {
///     // Handle error
///   }
/// } on PasswordMismatchError {
///   // User entered wrong password; fallback will try Google
///   final result = await authService.deleteAccount();
/// }
/// ```
///
/// Related Methods:
///   - reauthenticateWithGoogle(): Explicit Google reauthentication
///   - reauthenticateWithApple(): Explicit Apple reauthentication
///   - _cleanupLocalDataAfterDelete(): Internal helper for data cleanup
///
Future<AuthResult> deleteAccount({
  String? password,
})

// ============================================================================
// PROVIDER DETECTION CONTRACTS (Public Helpers)
// ============================================================================

/// Check if Google provider is linked to current user's account
///
/// Returns: true if Google is linked; false if not linked or no current user
///
/// Example:
/// ```dart
/// if (authService.isGoogleLinked()) {
///   print('User can delete account using Google sign-in');
/// }
/// ```
///
bool isGoogleLinked()

/// Check if Apple provider is linked to current user's account
///
/// Returns: true if Apple is linked; false if not linked or no current user
///
/// Example:
/// ```dart
/// if (authService.isAppleLinked()) {
///   print('User can delete account using Apple sign-in');
/// }
/// ```
///
bool isAppleLinked()

/// Check if current user is "social-only" (no email/password credential)
///
/// Returns: true if user has at least one social provider and NO email/password
///          false if user has email/password, or no providers, or no current user
///
/// Example:
/// ```dart
/// if (authService.isSocialOnlyUser()) {
///   // Show social-provider-specific delete flow
///   showSocialDeleteDialog(context);
/// } else {
///   // Show password-based delete flow
///   showPasswordDeleteDialog(context);
/// }
/// ```
///
bool isSocialOnlyUser()

/// Get list of provider IDs linked to current user
///
/// Returns: List of provider IDs in priority order
///          Priority: 'password' > 'google.com' > 'apple.com'
///          Empty list if no current user
///
/// Example:
/// ```dart
/// final providers = authService.getLinkedProviders();
/// print('Linked: $providers'); // ['password', 'google.com']
/// ```
///
List<String> getLinkedProviders()

// ============================================================================
// INTERNAL/PRIVATE CONTRACTS (Not Part of Public API)
// ============================================================================

/// Reauthenticate current user with email/password
///
/// Visibility: Private (use deleteAccount() instead)
/// Parameters:
///   - password: User's password
///
/// Returns: Throws FirebaseAuthException on failure
///
/// Note: Existing method; reused from email/password deletion flow
///
Future<void> _reauthenticateWithPassword(String password)

/// Clean up local data after successful account deletion
///
/// Visibility: Private (called automatically by deleteAccount())
/// Side Effects:
///   - Deletes all user markers via marker_store
///   - Clears tile cache
///   - Clears secure tokens
///   - Clears user profile from shared_preferences
///
/// Atomicity: Partial cleanup allowed
///   - If individual operation fails, logs error and continues
///   - No rollback; account is already deleted in Firebase
///
Future<void> _cleanupLocalDataAfterDelete()

// ============================================================================
// ERROR HANDLING REFERENCE
// ============================================================================

/**
 * AuthConstants Extensions (for error messages)
 *
 * Add these error message mappings to lib/features/auth/constants/auth_constants.dart:
 *
 * static const Map<String, String> errorMessages = {
 *   ...existing messages...
 *   'requires-recent-login': 'Your session has expired. Please sign in again to delete your account.',
 *   'provider-revoked': 'Please re-enable this app in your provider settings, then try again.',
 *   'network-request-failed': 'No internet connection. Please check your network and retry.',
 *   'popup-closed-by-user': 'Sign-in was cancelled. Tap retry to try again.',
 *   'invalid-credential': 'Authentication tokens expired. Please sign in again.',
 *   'provider-not-linked': 'This sign-in method is not linked to your account.',
 *   'user-disabled': 'Your account has been disabled. Please contact support.',
 *   'too-many-requests': 'Too many login attempts. Please wait a few minutes and try again.',
 *   'reauthentication-failed': 'Could not sign in with any authentication method. Please try again.',
 *   'account-deletion-failed': 'Account deletion failed. Your account remains active.',
 * };
 */

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

/**
 * Example: Delete Account Flow (from UI perspective)
 *
 * Step 1: User taps "Delete Account" button
 *   → Show confirmation dialog: "Are you sure you want to permanently delete your account?"
 *   → User taps "Delete"
 *
 * Step 2: Determine account type and call appropriate method
 *   if (isSocialOnlyUser()) {
 *     → Call deleteAccount() [no password]
 *     → Show "Signing in with Google..."
 *   } else {
 *     → Show password prompt: "Enter your password to confirm deletion"
 *     → Call deleteAccount(password: userPassword)
 *
 * Step 3: Handle response
 *   if (result.isSuccess) {
 *     → Show: "Your account has been deleted. You will be signed out."
 *     → Wait 2 seconds
 *     → Navigate to sign-in screen
 *   } else if (result.errorCode == 'requires-recent-login') {
 *     → Show: "Your session has expired. Please sign in again."
 *     → Call deleteAccount() [retry reauthentication]
 *   } else if (result.errorCode == 'popup-closed-by-user') {
 *     → Show: "Sign-in was cancelled. [Retry] [Cancel]"
 *     → User can retry reauthentication
 *   } else {
 *     → Show error dialog with message and retry button
 *
 * Step 4: Error recovery
 *   → Keep user on current screen with retry + cancel buttons
 *   → Retry calls deleteAccount() again
 *   → Cancel closes dialog and returns to account settings
 */

// ============================================================================
// RELATED DOCUMENTS
// ============================================================================

/**
 * For more details, see:
 * - spec.md: Feature specification with user stories and requirements
 * - research.md: Research findings on Firebase Auth APIs and error codes
 * - data-model.md: Data entities (DeletionRequest, UserSession)
 * - quickstart.md: Implementation checklist and getting started guide
 */
