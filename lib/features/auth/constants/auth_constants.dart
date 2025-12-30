// T023: Authentication constants (error messages, validation rules)

/// Firebase auth error codes mapped to user-friendly messages
class AuthConstants {
  // Error messages for Firebase Authentication errors
  static const Map<String, String> firebaseErrorMessages = {
    // Email/Password errors
    'invalid-email': 'Please enter a valid email address',
    'user-disabled': 'This account has been disabled',
    'user-not-found': 'Invalid email or password',
    'wrong-password': 'Invalid email or password',
    'email-already-in-use': 'An account already exists with this email',
    'operation-not-allowed': 'This sign-in method is not enabled',
    'weak-password': 'Password is too weak. Please choose a stronger password',

    // Re-authentication errors
    'requires-recent-login': 'This operation requires recent authentication. Please sign in again',
    'user-mismatch': 'The credentials do not match the current user',
    'invalid-credential': 'The credentials are invalid or have expired',

    // Account linking errors
    'provider-already-linked': 'This account is already linked to this provider',
    'credential-already-in-use': 'This credential is already associated with a different account',
    'account-exists-with-different-credential':
        'An account already exists with the same email but different sign-in credentials',

    // Social login errors
    'popup-closed-by-user': 'Sign-in cancelled',
    'cancelled-popup-request': 'Sign-in cancelled',
    'popup-blocked': 'Sign-in popup was blocked. Please allow popups for this site',

    // Network errors
    'network-request-failed': 'Network error. Please check your connection and try again',
    'too-many-requests': 'Too many failed attempts. Please try again later',
    'timeout': 'The operation timed out. Please try again',

    // Provider reauthentication errors (Feature 004)
    'provider-revoked': 'Provider access has been revoked. Please try a different sign-in method',
    'provider-not-linked': 'This provider is not linked to your account',
    'reauthentication-failed': 'Failed to verify your identity. Please try again',
    'no-auth-method': 'No authentication method available for this account',

    // Generic errors
    'internal-error': 'An internal error occurred. Please try again',
    'invalid-api-key': 'Configuration error. Please contact support',
    'app-not-authorized': 'This app is not authorized to use Firebase Authentication',
  };

  /// Get user-friendly error message from Firebase error code
  static String getErrorMessage(String? errorCode) {
    if (errorCode == null || errorCode.isEmpty) {
      return 'An unknown error occurred. Please try again';
    }

    return firebaseErrorMessages[errorCode] ?? 'An error occurred: $errorCode. Please try again';
  }

  // Validation rules
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;
  static const int displayNameMinLength = 2;
  static const int displayNameMaxLength = 50;
  static const int emailMaxLength = 254;

  // Session constants
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration sessionInactivityTimeout = Duration(days: 90);

  // UI messages
  static const String emailVerificationSent = 'Verification email sent. Please check your inbox';
  static const String passwordResetSent = 'Password reset email sent. Please check your inbox';
  static const String profileUpdated = 'Profile updated successfully';
  static const String emailUpdated = 'Email updated. Please verify your new email address';
  static const String passwordUpdated = 'Password updated successfully';
  static const String accountDeleted = 'Account deleted successfully';
  static const String logoutSuccess = 'Logged out successfully';

  // Migration messages
  static const String migrationInProgress = 'Migrating your data...';
  static const String migrationComplete = 'Migration complete';
  static const String migrationFailed = 'Migration failed - retrying on next login';

  // Confirmation messages
  static const String deleteAccountWarning =
      'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted';
  static const String logoutConfirmation = 'Are you sure you want to log out?';

  // Age restriction (AppStore compliance)
  static const int minimumAge = 13;
  static const String ageRestrictionMessage =
      'You must be at least $minimumAge years old to create an account';

  // Privacy and terms
  static const String privacyPolicyUrl = 'https://yourapp.com/privacy';
  static const String termsOfServiceUrl = 'https://yourapp.com/terms';
}
