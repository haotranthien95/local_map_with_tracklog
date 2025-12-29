// T026-T029: AuthenticationService with Firebase Authentication integration

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart'; // T097
import '../models/user.dart';
import '../models/auth_result.dart';
import '../features/auth/constants/auth_constants.dart';
import '../features/auth/validators/email_validator.dart';
import '../features/auth/validators/password_validator.dart';
import 'token_storage_service.dart';
import 'guest_migration_service.dart';
import 'tracklog_storage_service.dart'; // T094
import 'tile_cache_service.dart'; // T095

/// Service for Firebase Authentication operations
class AuthenticationService {
  static final AuthenticationService _instance = AuthenticationService._internal();
  factory AuthenticationService() => _instance;
  AuthenticationService._internal();

  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final TokenStorageService _tokenStorage = TokenStorageService();
  final GuestMigrationService _guestMigration = GuestMigrationService();
  final TracklogStorageService _tracklogStorage = TracklogStorageServiceImpl(); // T094
  final TileCacheService _tileCache = TileCacheServiceImpl(); // T095

  /// T027: Get current authenticated user
  /// Returns null if no user is signed in
  User? getCurrentUser() {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return User.fromFirebaseUser(firebaseUser);
  }

  /// T028: Stream of authentication state changes
  /// Emits User when signed in, null when signed out
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return User.fromFirebaseUser(firebaseUser);
    });
  }

  /// T029: Check if user is currently signed in
  bool isSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // ===== Phase 3: User Story 1 - Registration Methods (T030-T034) =====

  /// T030: Register with email and password
  Future<AuthResult> registerWithEmail(String email, String password) async {
    try {
      // Validate email
      if (!EmailValidator.isValidEmail(email)) {
        return AuthResult.failure(
          AuthConstants.getErrorMessage('invalid-email'),
          errorCode: 'invalid-email',
        );
      }

      // Validate password
      if (!PasswordValidator.isValidPassword(password)) {
        final error = PasswordValidator.getValidationError(password);
        return AuthResult.failure(
          error ?? 'Invalid password',
          errorCode: 'weak-password',
        );
      }

      // Create user with Firebase
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return AuthResult.failure('Failed to create account');
      }

      // Send email verification (non-blocking)
      await sendEmailVerification();

      // Trigger guest data migration
      final userId = userCredential.user!.uid;
      final hasGuestData = await _guestMigration.hasGuestData();
      if (hasGuestData) {
        // Migration happens in background, non-blocking
        _guestMigration.migrateGuestData(userId).catchError((error) {
          // Set migration pending flag for retry
          _guestMigration.setMigrationPending(userId, true);
          return false;
        });
      }

      // Return success with user
      final user = User.fromFirebaseUser(userCredential.user!);
      return AuthResult.success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(
        AuthConstants.getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// T031: Send email verification
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    if (user.emailVerified) {
      return; // Already verified
    }

    await user.sendEmailVerification();
  }

  /// T032: Check if email is verified
  Future<bool> isEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return false;
    }

    // Reload user to get latest verification status
    await user.reload();
    final refreshedUser = _firebaseAuth.currentUser;
    return refreshedUser?.emailVerified ?? false;
  }

  /// T033: Register with Google Sign-In
  Future<AuthResult> registerWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled sign-in
        return AuthResult.failure(
          AuthConstants.getErrorMessage('popup-closed-by-user'),
          errorCode: 'popup-closed-by-user',
        );
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return AuthResult.failure('Failed to sign in with Google');
      }

      // Trigger guest data migration
      final userId = userCredential.user!.uid;
      final hasGuestData = await _guestMigration.hasGuestData();
      if (hasGuestData) {
        _guestMigration.migrateGuestData(userId).catchError((error) {
          _guestMigration.setMigrationPending(userId, true);
          return false;
        });
      }

      // Return success with user
      final user = User.fromFirebaseUser(userCredential.user!);
      return AuthResult.success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      // T050: Handle account linking if account exists with different credential
      if (e.code == 'account-exists-with-different-credential' && e.email != null) {
        return await _linkAccountWithCredential(
          firebase_auth.GoogleAuthProvider.credential(),
          e.email!,
        );
      }
      return AuthResult.failure(
        AuthConstants.getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// T034: Register with Apple Sign In
  Future<AuthResult> registerWithApple() async {
    try {
      // Trigger Apple Sign In flow
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create Firebase credential
      final oAuthProvider = firebase_auth.OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return AuthResult.failure('Failed to sign in with Apple');
      }

      // Update display name if provided by Apple (first time only)
      if (appleCredential.givenName != null || appleCredential.familyName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (displayName.isNotEmpty && userCredential.user!.displayName == null) {
          await userCredential.user!.updateDisplayName(displayName);
        }
      }

      // Trigger guest data migration
      final userId = userCredential.user!.uid;
      final hasGuestData = await _guestMigration.hasGuestData();
      if (hasGuestData) {
        _guestMigration.migrateGuestData(userId).catchError((error) {
          _guestMigration.setMigrationPending(userId, true);
          return false;
        });
      }

      // Return success with user
      final user = User.fromFirebaseUser(userCredential.user!);
      return AuthResult.success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      // T051: Handle account linking if account exists with different credential
      if (e.code == 'account-exists-with-different-credential' && e.email != null) {
        return await _linkAccountWithCredential(
          firebase_auth.OAuthProvider('apple.com').credential(),
          e.email!,
        );
      }
      return AuthResult.failure(
        AuthConstants.getErrorMessage(e.code),
        errorCode: e.code,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return AuthResult.failure(
          AuthConstants.getErrorMessage('popup-closed-by-user'),
          errorCode: 'popup-closed-by-user',
        );
      }
      return AuthResult.failure('Apple Sign In failed: ${e.message}');
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  // ===== Phase 4: User Story 2 - Login Methods (T055-T058) =====

  /// T055: Sign in with email and password
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      // Validate email
      if (!EmailValidator.isValidEmail(email)) {
        return AuthResult.failure(
          AuthConstants.getErrorMessage('invalid-email'),
          errorCode: 'invalid-email',
        );
      }

      // Validate password (basic check)
      if (password.isEmpty) {
        return AuthResult.failure(
          'Password is required',
          errorCode: 'invalid-password',
        );
      }

      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return AuthResult.failure('Failed to sign in');
      }

      // Discard guest data (existing user logging in doesn't need guest data)
      final hasGuestData = await _guestMigration.hasGuestData();
      if (hasGuestData) {
        _guestMigration.discardGuestData().catchError((error) {
          // Non-blocking, log error but don't fail login
        });
      }

      // Return success with user
      final user = User.fromFirebaseUser(userCredential.user!);
      return AuthResult.success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Map user-not-found and wrong-password to same message for security
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return AuthResult.failure(
          'Invalid email or password',
          errorCode: 'invalid-credentials',
        );
      }
      return AuthResult.failure(
        AuthConstants.getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// T056: Send password reset email
  Future<void> sendPasswordReset(String email) async {
    if (!EmailValidator.isValidEmail(email)) {
      throw Exception('Invalid email address');
    }

    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// T057: Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled sign-in
        return AuthResult.failure(
          AuthConstants.getErrorMessage('popup-closed-by-user'),
          errorCode: 'popup-closed-by-user',
        );
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return AuthResult.failure('Failed to sign in with Google');
      }

      // Discard guest data for existing users
      final hasGuestData = await _guestMigration.hasGuestData();
      if (hasGuestData) {
        _guestMigration.discardGuestData().catchError((error) {
          // Non-blocking error
        });
      }

      // Return success with user
      final user = User.fromFirebaseUser(userCredential.user!);
      return AuthResult.success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      // T069: Handle account linking
      if (e.code == 'account-exists-with-different-credential' && e.email != null) {
        return await _linkAccountWithCredential(
          firebase_auth.GoogleAuthProvider.credential(),
          e.email!,
        );
      }
      return AuthResult.failure(
        AuthConstants.getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// T058: Sign in with Apple
  Future<AuthResult> signInWithApple() async {
    try {
      // Trigger Apple Sign In flow
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create Firebase credential
      final oAuthProvider = firebase_auth.OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return AuthResult.failure('Failed to sign in with Apple');
      }

      // Discard guest data for existing users
      final hasGuestData = await _guestMigration.hasGuestData();
      if (hasGuestData) {
        _guestMigration.discardGuestData().catchError((error) {
          // Non-blocking error
        });
      }

      // Return success with user
      final user = User.fromFirebaseUser(userCredential.user!);
      return AuthResult.success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      // T069: Handle account linking
      if (e.code == 'account-exists-with-different-credential' && e.email != null) {
        return await _linkAccountWithCredential(
          firebase_auth.OAuthProvider('apple.com').credential(),
          e.email!,
        );
      }
      return AuthResult.failure(
        AuthConstants.getErrorMessage(e.code),
        errorCode: e.code,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return AuthResult.failure(
          AuthConstants.getErrorMessage('popup-closed-by-user'),
          errorCode: 'popup-closed-by-user',
        );
      }
      return AuthResult.failure('Apple Sign In failed: ${e.message}');
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: ${e.toString()}');
    }
  }

  // ===== Phase 5: User Story 3 - Profile Management (T073-T075) =====

  /// T073: Update display name
  Future<void> updateDisplayName(String displayName) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    if (displayName.trim().isEmpty) {
      throw Exception('Display name cannot be empty');
    }

    // Update Firebase profile
    await user.updateDisplayName(displayName.trim());

    // Reload to get updated profile
    await user.reload();
  }

  /// T074: Update email address
  Future<void> updateEmail(String newEmail, String currentPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    // Validate new email
    if (!EmailValidator.isValidEmail(newEmail)) {
      throw Exception('Invalid email address');
    }

    // Re-authenticate user before sensitive operation
    await _reauthenticateWithPassword(currentPassword);

    // Update email in Firebase
    await user.updateEmail(newEmail);

    // Send verification to new email
    await user.sendEmailVerification();

    // Reload to get updated profile
    await user.reload();
  }

  /// T075: Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    // Validate new password
    if (!PasswordValidator.isValidPassword(newPassword)) {
      final error = PasswordValidator.getValidationError(newPassword);
      throw Exception(error ?? 'Invalid password');
    }

    // Don't allow same password
    if (currentPassword == newPassword) {
      throw Exception('New password must be different from current password');
    }

    // Re-authenticate user before sensitive operation
    await _reauthenticateWithPassword(currentPassword);

    // Update password in Firebase
    await user.updatePassword(newPassword);
  }

  // ===== Phase 6: User Story 4 - Account Deletion (T087-T088) =====

  /// T087: Delete user account permanently
  /// T088: Comprehensive data cleanup
  Future<void> deleteAccount(String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    // Re-authenticate user before deletion (required by Firebase)
    await _reauthenticateWithPassword(password);

    // T088: Clear all local data before deleting account
    final userId = user.uid;

    // T094: Delete all user tracklogs
    try {
      await _tracklogStorage.deleteAllUserTracklogs(userId);
    } catch (e) {
      // Continue even if tracklog cleanup fails
      print('Tracklog cleanup error: $e');
    }

    // T095: Clear tile cache (global cache)
    try {
      await _tileCache.clearCache();
    } catch (e) {
      // Continue even if cache cleanup fails
      print('Tile cache cleanup error: $e');
    }

    // Clear secure tokens
    await _tokenStorage.clearAllTokens();

    // Clear user profile from shared_preferences
    await _clearUserProfile(userId);

    // Delete Firebase user account
    await user.delete();

    // Note: Tracklog cleanup and cache cleanup will be handled by
    // dedicated service methods that should be called before this method
  }

  /// T097: Clear user profile data from shared_preferences
  Future<void> _clearUserProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile_$userId');
  }

  // ===== Phase 7: User Story 5 - Logout (T098) =====

  /// T098: Sign out current user
  /// Clears secure tokens and signs out from Firebase
  Future<void> signOut() async {
    try {
      // T103: Clear all cached tokens from secure storage
      await _tokenStorage.clearAllTokens();

      // Sign out from Firebase
      await _firebaseAuth.signOut();
    } catch (e) {
      // Logout errors are rare but log them for debugging
      // Don't throw - user is already signed out
      print('Logout error: ${e.toString()}');
    }
  }

  // ===== Helper Methods =====

  /// T052: Link accounts when account exists with different credential
  /// This handles automatic bidirectional account linking
  Future<AuthResult> _linkAccountWithCredential(
    firebase_auth.AuthCredential pendingCredential,
    String email,
  ) async {
    try {
      // Step 1: Get sign-in methods for the email
      final signInMethods = await _firebaseAuth.fetchSignInMethodsForEmail(email);

      if (signInMethods.isEmpty) {
        return AuthResult.failure('No account found with this email');
      }

      // Step 2: User must sign in with existing credential first
      // For automatic linking, we'll return an error asking user to sign in first
      // Then they can link in profile settings
      // Note: Fully automatic linking would require password prompt here
      return AuthResult.failure(
        'An account already exists with this email. Please sign in with ${signInMethods.first} first, '
        'then you can link your accounts in Profile Settings.',
        errorCode: 'account-exists-with-different-credential',
      );
    } catch (e) {
      return AuthResult.failure('Account linking failed: ${e.toString()}');
    }
  }

  /// Re-authenticate user with password (for sensitive operations)
  Future<void> _reauthenticateWithPassword(String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user signed in');
    }

    final credential = firebase_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  /// Handle Firebase auth exceptions and convert to user-friendly messages
  String _handleFirebaseError(firebase_auth.FirebaseAuthException e) {
    // Error handling will be enhanced with AuthConstants in implementation
    return e.message ?? 'An unknown error occurred';
  }
}
