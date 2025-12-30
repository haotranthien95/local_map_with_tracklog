# Quickstart Guide: Delete Account Without Password (004)

**Feature**: 004-delete-account-nopass  
**Audience**: Developers implementing this feature  
**Date**: 2025-12-30

---

## Overview

This guide provides a step-by-step checklist for implementing social-provider-based account deletion. Use this as your primary reference during implementation. For detailed specifications, see [spec.md](spec.md). For API contracts, see [contracts/delete-account.interface.dart](contracts/delete-account.interface.dart).

---

## Prerequisites

✅ **Required Knowledge**:
- Firebase Auth API (reauthenticateWithCredential)
- Flutter async/await patterns
- Existing AuthenticationService implementation

✅ **Development Environment**:
- Flutter 3.5.4+
- Dart 3.5.4+
- Access to Firebase project console
- Test iOS device or simulator (for Apple Sign-In)
- Test Android device or emulator (for Google Sign-In)

✅ **Documentation**:
- [ ] Read [spec.md](spec.md) (feature specification)
- [ ] Read [research.md](research.md) (reauthentication APIs, error handling)
- [ ] Read [data-model.md](data-model.md) (DeletionRequest, state transitions)
- [ ] Read [contracts/delete-account.interface.dart](contracts/delete-account.interface.dart) (method signatures)

---

## Phase 1: Service Layer (Core)

### Step 1: Add Provider Reauthentication Methods

**File**: `lib/services/authentication_service.dart`

**Add** (after existing `_reauthenticateWithPassword` method):

```dart
/// Reauthenticate with Google Sign-In provider
Future<AuthResult> reauthenticateWithGoogle() async {
  try {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return AuthResult.failure(
        'No user signed in',
        errorCode: 'no-current-user',
      );
    }

    // Check if Google is linked
    final hasGoogle = user.providerData
        .any((provider) => provider.providerId == 'google.com');
    
    if (!hasGoogle) {
      return AuthResult.failure(
        'Google not linked to this account',
        errorCode: 'provider-not-linked',
      );
    }

    // Trigger Google Sign-In
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return AuthResult.failure(
        'Sign-in cancelled by user',
        errorCode: 'popup-closed-by-user',
      );
    }

    final GoogleSignInAuthentication googleAuth = 
        await googleUser.authentication;

    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await user.reauthenticateWithCredential(credential);

    return AuthResult.success(user: User.fromFirebaseUser(user));
  } on firebase_auth.FirebaseAuthException catch (e) {
    return AuthResult.failure(
      AuthConstants.getErrorMessage(e.code),
      errorCode: e.code,
    );
  } catch (e) {
    return AuthResult.failure(
      'Reauthentication failed: ${e.toString()}',
      errorCode: 'unknown-error',
    );
  }
}

/// Reauthenticate with Apple Sign-In provider
Future<AuthResult> reauthenticateWithApple() async {
  try {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return AuthResult.failure(
        'No user signed in',
        errorCode: 'no-current-user',
      );
    }

    // Check if Apple is linked
    final hasApple = user.providerData
        .any((provider) => provider.providerId == 'apple.com');
    
    if (!hasApple) {
      return AuthResult.failure(
        'Apple not linked to this account',
        errorCode: 'provider-not-linked',
      );
    }

    // Trigger Apple Sign-In
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

    return AuthResult.success(user: User.fromFirebaseUser(user));
  } on firebase_auth.FirebaseAuthException catch (e) {
    return AuthResult.failure(
      AuthConstants.getErrorMessage(e.code),
      errorCode: e.code,
    );
  } catch (e) {
    return AuthResult.failure(
      'Reauthentication failed: ${e.toString()}',
      errorCode: 'unknown-error',
    );
  }
}
```

**Verify**:
- [ ] Code compiles
- [ ] No import errors (firebase_auth, google_sign_in, sign_in_with_apple already imported)
- [ ] Lint warnings resolved

---

### Step 2: Add Provider Detection Helpers

**File**: `lib/services/authentication_service.dart`

**Add** (public methods for UI to call):

```dart
/// Check if Google provider is linked
bool isGoogleLinked() {
  final user = _firebaseAuth.currentUser;
  if (user == null) return false;
  
  return user.providerData.any(
    (provider) => provider.providerId == 'google.com',
  );
}

/// Check if Apple provider is linked
bool isAppleLinked() {
  final user = _firebaseAuth.currentUser;
  if (user == null) return false;
  
  return user.providerData.any(
    (provider) => provider.providerId == 'apple.com',
  );
}

/// Check if user is social-only (no email/password)
bool isSocialOnlyUser() {
  final user = _firebaseAuth.currentUser;
  if (user == null) return false;
  
  final hasPassword = user.providerData.any(
    (provider) => provider.providerId == 'password',
  );
  
  return !hasPassword && user.providerData.isNotEmpty;
}

/// Get linked providers in priority order
List<String> getLinkedProviders() {
  final user = _firebaseAuth.currentUser;
  if (user == null) return [];
  
  const priority = ['password', 'google.com', 'apple.com'];
  final providers = user.providerData
      .map((p) => p.providerId)
      .toList();
  
  providers.sort((a, b) {
    final priorityA = priority.indexOf(a);
    final priorityB = priority.indexOf(b);
    if (priorityA == -1) return 1;
    if (priorityB == -1) return -1;
    return priorityA.compareTo(priorityB);
  });
  
  return providers;
}
```

**Verify**:
- [ ] Methods compile
- [ ] Add unit tests (optional per constitution)

---

### Step 3: Extend deleteAccount() with Provider Fallback

**File**: `lib/services/authentication_service.dart`

**Modify** existing `deleteAccount(String password)` to:

```dart
/// Delete account with intelligent provider selection
Future<AuthResult> deleteAccount({String? password}) async {
  try {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return AuthResult.failure('No user signed in');
    }

    // Determine reauth strategy
    final providers = getLinkedProviders();
    if (providers.isEmpty) {
      return AuthResult.failure(
        'No authentication method available',
        errorCode: 'no-auth-method',
      );
    }

    // Attempt reauthentication with fallback
    AuthResult reAuthResult;
    
    if (providers.contains('password') && password != null) {
      // Email/password path (existing flow)
      try {
        await _reauthenticateWithPassword(password);
        reAuthResult = AuthResult.success(user: User.fromFirebaseUser(user));
      } catch (e) {
        reAuthResult = AuthResult.failure(e.toString());
      }
    } else {
      // Social-only path: try providers in order
      bool reauthSucceeded = false;
      
      for (final providerId in providers) {
        try {
          switch (providerId) {
            case 'google.com':
              reAuthResult = await reauthenticateWithGoogle();
              break;
            case 'apple.com':
              reAuthResult = await reauthenticateWithApple();
              break;
            default:
              continue;
          }
          
          if (reAuthResult.isSuccess) {
            reauthSucceeded = true;
            break;
          }
        } catch (e) {
          continue; // Try next provider
        }
      }
      
      if (!reauthSucceeded) {
        return AuthResult.failure(
          'Could not authenticate with any provider',
          errorCode: 'reauthentication-failed',
        );
      }
    }

    // If reauth failed, return error
    if (!reAuthResult.isSuccess) {
      return reAuthResult;
    }

    // Delete Firebase account
    await user.delete();

    // Clean up local data (partial cleanup allowed)
    await _cleanupLocalDataAfterDelete();

    // Sign out
    await _firebaseAuth.signOut();

    return AuthResult.success(user: null);
  } on firebase_auth.FirebaseAuthException catch (e) {
    return AuthResult.failure(
      AuthConstants.getErrorMessage(e.code),
      errorCode: e.code,
    );
  } catch (e) {
    return AuthResult.failure(
      'Delete failed: ${e.toString()}',
      errorCode: 'unknown-error',
    );
  }
}
```

**Verify**:
- [ ] Existing email/password deletion still works (backward compatible)
- [ ] New social-only deletion path works
- [ ] Fallback logic executes correctly

---

### Step 4: Update Local Data Cleanup

**File**: `lib/services/authentication_service.dart`

**Modify** existing `_cleanupLocalDataAfterDelete()` or add if missing:

```dart
/// Clean up local data after successful account deletion
/// Partial cleanup allowed (per FR-003)
Future<void> _cleanupLocalDataAfterDelete() async {
  final List<String> failures = [];

  // Clear tracklogs
  try {
    await _tracklogStorage.deleteAllUserTracklogs(''); // User already deleted
  } catch (e) {
    failures.add('tracklogs');
    print('Tracklog cleanup error: $e');
  }

  // Clear tile cache
  try {
    await _tileCache.clearCache();
  } catch (e) {
    failures.add('tile-cache');
    print('Tile cache cleanup error: $e');
  }

  // Clear secure tokens
  try {
    await _tokenStorage.clearAllTokens();
  } catch (e) {
    failures.add('tokens');
    print('Token cleanup error: $e');
  }

  // Clear preferences
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  } catch (e) {
    failures.add('preferences');
    print('Preferences cleanup error: $e');
  }

  if (failures.isNotEmpty) {
    print('Partial cleanup: Failed to clear ${failures.join(", ")}');
  }
}
```

**Verify**:
- [ ] Cleanup continues even if individual operations fail
- [ ] Failures are logged
- [ ] User is notified of partial cleanup (UI task)

---

### Step 5: Extend Error Constants

**File**: `lib/features/auth/constants/auth_constants.dart`

**Add** to existing `errorMessages` map:

```dart
static const Map<String, String> errorMessages = {
  ...existing messages...,
  'requires-recent-login': 'Your session has expired. Please sign in again to delete your account.',
  'provider-revoked': 'Please re-enable this app in your provider settings, then try again.',
  'network-request-failed': 'No internet connection. Please check your network and retry.',
  'popup-closed-by-user': 'Sign-in was cancelled. Tap retry to try again.',
  'invalid-credential': 'Authentication tokens expired. Please sign in again.',
  'provider-not-linked': 'This sign-in method is not linked to your account.',
  'user-disabled': 'Your account has been disabled. Please contact support.',
  'too-many-requests': 'Too many login attempts. Please wait a few minutes and try again.',
  'reauthentication-failed': 'Could not sign in with any authentication method. Please try again.',
  'account-deletion-failed': 'Account deletion failed. Your account remains active.',
  'no-auth-method': 'No authentication method available. Please contact support.',
};
```

**Verify**:
- [ ] Error messages compile
- [ ] Messages are user-friendly and actionable

---

## Phase 2: UI Layer

### Step 6: Create Delete Account Dialog

**File**: `lib/features/auth/widgets/delete_account_dialog.dart` (NEW)

**Create** with Material dialog:

```dart
import 'package:flutter/material.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Account'),
      content: const Text(
        'Are you sure you want to permanently delete your account? '
        'This action cannot be undone. All your data will be removed.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
```

**Verify**:
- [ ] Dialog shows correctly
- [ ] Cancel returns false
- [ ] Delete returns true

---

### Step 7: Create Delete Account Flow Screen

**File**: `lib/features/auth/screens/delete_account_flow.dart` (NEW)

**Create** with reauthentication + error handling:

```dart
import 'package:flutter/material.dart';
import '../../../services/authentication_service.dart';
import '../../../models/auth_result.dart';
import '../widgets/delete_account_dialog.dart';

class DeleteAccountFlow extends StatefulWidget {
  const DeleteAccountFlow({super.key});

  @override
  State<DeleteAccountFlow> createState() => _DeleteAccountFlowState();
}

class _DeleteAccountFlowState extends State<DeleteAccountFlow> {
  final AuthenticationService _authService = AuthenticationService();
  bool _isDeleting = false;
  String? _errorMessage;

  Future<void> _handleDeleteAccount() async {
    // Step 1: Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );

    if (confirmed != true) return;

    // Step 2: Execute deletion
    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.deleteAccount();

      if (!mounted) return;

      if (result.isSuccess) {
        // Success: Navigate to sign-in screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account has been deleted successfully.'),
          ),
        );
        
        // Navigate to sign-in
        Navigator.pushReplacementNamed(context, '/sign_in');
      } else {
        // Error: Show retry/cancel
        setState(() {
          _errorMessage = result.message;
          _isDeleting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Unexpected error: ${e.toString()}';
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isDeleting)
              const CircularProgressIndicator()
            else if (_errorMessage != null) ...[
              Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _handleDeleteAccount,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ] else ...[
              const Icon(Icons.delete_forever, size: 64),
              const SizedBox(height: 16),
              const Text(
                'You are about to delete your account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleDeleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete My Account'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

**Verify**:
- [ ] Screen shows correctly
- [ ] Delete button triggers flow
- [ ] Error UI shows with retry/cancel buttons
- [ ] Success navigates to sign-in

---

### Step 8: Add Navigation Route

**File**: `lib/main.dart` (or router file)

**Add** route:

```dart
routes: {
  ...existing routes...,
  '/delete_account': (context) => const DeleteAccountFlow(),
},
```

---

### Step 9: Add Delete Button to Account Settings

**File**: `lib/screens/account_settings_screen.dart` (or profile screen)

**Add** button:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/delete_account');
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
  ),
  child: const Text('Delete Account'),
),
```

**Verify**:
- [ ] Button shows in account settings
- [ ] Tapping navigates to delete flow

---

## Phase 3: Testing

### Manual Test Cases

**Test 1: Social-Only User Deletes Account**
- [ ] Sign in with Google (no password set)
- [ ] Navigate to account settings
- [ ] Tap "Delete Account"
- [ ] Confirm deletion
- [ ] Complete Google reauthentication dialog
- [ ] Verify account deleted (Firebase console)
- [ ] Verify local data cleared (check shared_preferences)
- [ ] Verify app navigates to sign-in screen

**Test 2: Hybrid User Deletes Account**
- [ ] Sign in with email/password
- [ ] Link Google account
- [ ] Navigate to account settings
- [ ] Tap "Delete Account"
- [ ] Enter password in prompt
- [ ] Verify account deleted

**Test 3: Error Recovery (Network Failure)**
- [ ] Disable network mid-flow
- [ ] Attempt deletion
- [ ] Verify error message shows with retry button
- [ ] Re-enable network
- [ ] Tap retry
- [ ] Verify deletion succeeds

**Test 4: Error Recovery (User Cancels Reauthentication)**
- [ ] Initiate deletion
- [ ] Cancel Google/Apple sign-in dialog
- [ ] Verify error message shows with retry/cancel buttons
- [ ] Verify account remains active
- [ ] Tap cancel → return to account settings

**Test 5: Fallback Strategy (Primary Fails, Secondary Succeeds)**
- [ ] Sign in with both Google and Apple
- [ ] Revoke Google access in Google Account settings
- [ ] Initiate deletion
- [ ] Verify Google reauthentication fails
- [ ] Verify fallback attempts Apple
- [ ] Verify deletion succeeds with Apple

---

## Deployment Checklist

- [ ] All service methods implemented
- [ ] All UI screens/dialogs created
- [ ] Error messages added to AuthConstants
- [ ] Manual tests passed (P1 stories)
- [ ] Code reviewed
- [ ] No lint warnings
- [ ] Documentation updated (if public API exposed)
- [ ] Firebase project configured (Google, Apple providers enabled)
- [ ] iOS entitlements configured for Apple Sign-In
- [ ] Android Google Sign-In configured (SHA-1 certificates)

---

## Troubleshooting

### Issue: Google Sign-In Not Working on Android

**Cause**: Missing SHA-1 certificate in Firebase console  
**Fix**: Add SHA-1 to Firebase project settings → Android app → Add fingerprint

### Issue: Apple Sign-In Not Working on iOS

**Cause**: Missing entitlement or capability  
**Fix**: Xcode → Runner → Signing & Capabilities → Add "Sign in with Apple"

### Issue: "requires-recent-login" Error Always Shows

**Cause**: Firebase requires reauthentication for deletion (security)  
**Fix**: This is expected behavior; reauthentication flow handles it automatically

### Issue: Partial Cleanup Failures

**Cause**: Individual cleanup operations throw exceptions  
**Fix**: Check logs for specific operation; partial cleanup is expected per FR-003

---

## Related Documents

- [spec.md](spec.md) - Feature specification
- [plan.md](plan.md) - Implementation plan
- [research.md](research.md) - Research findings
- [data-model.md](data-model.md) - Data entities
- [contracts/delete-account.interface.dart](contracts/delete-account.interface.dart) - API contracts

---

## Support

Questions? Check:
1. [Firebase Auth Docs](https://firebase.google.com/docs/auth)
2. [Flutter Firebase Auth Package](https://pub.dev/packages/firebase_auth)
3. Project constitution (`.specify/memory/constitution.md`)

---

*Generated by speckit.plan Phase 1*
