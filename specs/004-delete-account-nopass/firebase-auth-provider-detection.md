# Firebase Auth Provider Detection & Fallback Implementation Patterns

**Purpose**: Document Firebase Auth provider detection techniques and fallback strategies for account deletion in multi-provider authentication scenarios.

**Target**: Dart/Flutter with `firebase_auth` package

---

## Decision: Provider Detection Approach

**Chosen Pattern**: Query-based detection using `user.providerData` list with provider ID matching.

**Rationale**:
- Firebase Auth maintains linked providers in `providerData` array on `User` object
- Each provider has a unique `providerId` (e.g., `google.com`, `apple.com`, `password`)
- Checking provider availability is deterministic: if listed in `providerData`, it's linked
- Fallback logic can be implemented with priority-ordered retry mechanism
- Minimal performance overhead (local array iteration, no network calls for detection)

---

## Provider Data Reference

### Structure of `user.providerData`

```dart
List<UserInfo> providerData = FirebaseAuth.instance.currentUser!.providerData;
```

Each `UserInfo` object contains:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `providerId` | `String` | Unique provider identifier | `"google.com"`, `"apple.com"`, `"password"` |
| `uid` | `String?` | Provider-specific user ID | `"118123456789...` (Google) or `null` (password) |
| `email` | `String?` | Email associated with provider | `"user@example.com"` |
| `displayName` | `String?` | User's display name from provider | `"John Doe"` |
| `photoUrl` | `String?` | URL to profile photo | `"https://..."` |
| `phoneNumber` | `String?` | Phone number (for phone provider) | `"+1234567890"` |
| `isEmailVerified` | `bool` | Email verification status | `true`/`false` |

### Standard Provider IDs in Firebase

```dart
// Authentication provider IDs
const String GOOGLE_PROVIDER_ID = 'google.com';
const String APPLE_PROVIDER_ID = 'apple.com';
const String PASSWORD_PROVIDER_ID = 'password';
const String PHONE_PROVIDER_ID = 'phone';
const String FACEBOOK_PROVIDER_ID = 'facebook.com';
const String TWITTER_PROVIDER_ID = 'twitter.com';
const String GITHUB_PROVIDER_ID = 'github.com';
const String ANONYMOUS_PROVIDER_ID = 'anonymous';
const String CUSTOM_PROVIDER_ID = 'custom';
```

---

## Detection Code Examples

### Example 1: Detecting if Google is Linked

```dart
/// Check if Google provider is linked to current user
bool isGoogleLinked() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  
  return user.providerData.any(
    (userInfo) => userInfo.providerId == 'google.com',
  );
}

// Usage
if (isGoogleLinked()) {
  print('User has Google account linked');
}
```

### Example 2: Detecting if User is Social-Only (No Email/Password)

```dart
/// Check if user has ONLY social providers (Google, Apple, Facebook, etc.)
/// and NO email/password provider
bool isSocialOnlyUser() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  
  final hasEmailPassword = user.providerData.any(
    (userInfo) => userInfo.providerId == 'password',
  );
  
  return !hasEmailPassword && user.providerData.isNotEmpty;
}

// Usage
if (isSocialOnlyUser()) {
  print('User can only authenticate with social providers');
}
```

### Example 3: Detecting if User is Hybrid (Email/Password + Social)

```dart
/// Check if user has BOTH email/password AND at least one social provider
bool isHybridUser() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  
  final hasEmailPassword = user.providerData.any(
    (userInfo) => userInfo.providerId == 'password',
  );
  
  final hasSocialProvider = user.providerData.any(
    (userInfo) => ['google.com', 'apple.com', 'facebook.com'].contains(userInfo.providerId),
  );
  
  return hasEmailPassword && hasSocialProvider;
}

// Usage
if (isHybridUser()) {
  print('User can authenticate with email/password OR social login');
}
```

### Example 4: Get All Linked Provider IDs

```dart
/// Get list of all provider IDs linked to current user
List<String> getLinkedProviderIds() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  
  return user.providerData
      .map((userInfo) => userInfo.providerId)
      .toList();
}

// Usage
final providers = getLinkedProviderIds();
print('Linked providers: $providers'); // ['google.com', 'password']
```

### Example 5: Get Provider Info by Type

```dart
/// Get provider information for a specific provider ID
UserInfo? getProviderInfo(String providerId) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  
  try {
    return user.providerData.firstWhere(
      (userInfo) => userInfo.providerId == providerId,
    );
  } catch (e) {
    return null; // Provider not linked
  }
}

// Usage
final googleInfo = getProviderInfo('google.com');
if (googleInfo != null) {
  print('Google email: ${googleInfo.email}');
  print('Google display name: ${googleInfo.displayName}');
}
```

---

## Fallback Implementation: Full Reauthentication Logic

### Strategy Overview

**Priority Order** (for account deletion scenarios):
1. **Hybrid Users** (Email/Password + Social):
   - Attempt email/password reauthentication first
   - Fallback to primary social provider (Google > Apple)
   
2. **Social-Only Users**:
   - Attempt primary provider first (Google > Apple > Facebook)
   - Fallback to secondary provider if primary fails

3. **Email/Password Only Users**:
   - Single provider, no fallback needed

### Full Implementation

```dart
import 'package:firebase_auth/firebase_auth.dart';

class ProviderFallbackService {
  static const String PROVIDER_GOOGLE = 'google.com';
  static const String PROVIDER_APPLE = 'apple.com';
  static const String PROVIDER_PASSWORD = 'password';
  static const String PROVIDER_FACEBOOK = 'facebook.com';
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Priority-ordered list of providers (most to least preferred)
  static const List<String> PROVIDER_PRIORITY = [
    PROVIDER_PASSWORD,      // Email/password (most familiar)
    PROVIDER_GOOGLE,        // Google (most widely available)
    PROVIDER_APPLE,         // Apple (iOS users)
    PROVIDER_FACEBOOK,      // Facebook (secondary option)
  ];
  
  /// Get available providers for current user in priority order
  List<String> getAvailableProvidersOrdered() {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    final availableProviders = user.providerData
        .map((p) => p.providerId)
        .toList();
    
    // Sort by priority
    availableProviders.sort((a, b) {
      final priorityA = PROVIDER_PRIORITY.indexOf(a);
      final priorityB = PROVIDER_PRIORITY.indexOf(b);
      return priorityA.compareTo(priorityB);
    });
    
    return availableProviders;
  }
  
  /// Check if user has specific provider linked
  bool hasProvider(String providerId) {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    return user.providerData.any(
      (p) => p.providerId == providerId,
    );
  }
  
  /// Attempt reauthentication with fallback strategy
  /// 
  /// Returns the provider ID that successfully reauthenticated
  /// Throws exception if all providers fail
  Future<String> reauthenticateWithFallback({
    required String emailForPassword,
    required String passwordForPassword,
    required Function(String provider) onGoogleSignIn,
    required Function(String provider) onAppleSignIn,
  }) async {
    final availableProviders = getAvailableProvidersOrdered();
    
    if (availableProviders.isEmpty) {
      throw FirebaseAuthException(
        code: 'no-providers',
        message: 'No authentication providers linked to this account',
      );
    }
    
    String? lastError;
    
    // Try each provider in priority order
    for (final providerId in availableProviders) {
      try {
        switch (providerId) {
          case PROVIDER_PASSWORD:
            await _reauthenticateWithPassword(
              email: emailForPassword,
              password: passwordForPassword,
            );
            return PROVIDER_PASSWORD;
            
          case PROVIDER_GOOGLE:
            await onGoogleSignIn(PROVIDER_GOOGLE);
            return PROVIDER_GOOGLE;
            
          case PROVIDER_APPLE:
            await onAppleSignIn(PROVIDER_APPLE);
            return PROVIDER_APPLE;
            
          case PROVIDER_FACEBOOK:
            // Facebook reauthentication logic here
            // (implement if needed for your app)
            continue;
            
          default:
            lastError = 'Unsupported provider: $providerId';
            continue;
        }
      } on FirebaseAuthException catch (e) {
        lastError = 'Provider $providerId failed: ${e.message}';
        continue; // Try next provider
      } catch (e) {
        lastError = 'Provider $providerId error: $e';
        continue; // Try next provider
      }
    }
    
    // All providers failed
    throw FirebaseAuthException(
      code: 'reauthentication-failed',
      message: 'All authentication providers failed. Last error: $lastError',
    );
  }
  
  /// Reauthenticate with email/password
  Future<void> _reauthenticateWithPassword({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No user currently signed in',
      );
    }
    
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    
    await user.reauthenticateWithCredential(credential);
  }
  
  /// Reauthenticate with Google (caller must handle OAuth flow)
  Future<void> reauthenticateWithGoogle({
    required OAuthCredential googleCredential,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No user currently signed in',
      );
    }
    
    await user.reauthenticateWithCredential(googleCredential);
  }
  
  /// Reauthenticate with Apple (caller must handle OAuth flow)
  Future<void> reauthenticateWithApple({
    required OAuthCredential appleCredential,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No user currently signed in',
      );
    }
    
    await user.reauthenticateWithCredential(appleCredential);
  }
}
```

### Usage Example: Account Deletion with Fallback

```dart
class DeleteAccountFlow {
  final ProviderFallbackService _fallbackService = ProviderFallbackService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Delete user account with provider fallback reauthentication
  Future<void> deleteAccountWithFallback({
    required String emailForPassword,
    required String passwordForPassword,
    required Function(String provider) onGoogleSignIn,
    required Function(String provider) onAppleSignIn,
  }) async {
    try {
      // Step 1: Attempt reauthentication with fallback
      final successfulProvider = await _fallbackService.reauthenticateWithFallback(
        emailForPassword: emailForPassword,
        passwordForPassword: passwordForPassword,
        onGoogleSignIn: onGoogleSignIn,
        onAppleSignIn: onAppleSignIn,
      );
      
      print('✓ Reauthenticated with: $successfulProvider');
      
      // Step 2: Delete the user account
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        print('✓ Account deleted successfully');
      }
      
      // Step 3: Sign out
      await _auth.signOut();
      print('✓ User signed out');
      
    } on FirebaseAuthException catch (e) {
      print('✗ Account deletion failed: ${e.code} - ${e.message}');
      rethrow;
    }
  }
}
```

---

## Priority Order Rationale

### Why Email/Password > Google > Apple > Facebook?

| Priority | Provider | Rationale |
|----------|----------|-----------|
| **1st** | Email/Password | <ul><li>Most familiar to users (traditional login)</li><li>Always available on device (no external auth required)</li><li>Direct credential entry (user knows password)</li><li>No OAuth flow complications</li><li>Highest success rate for reauthentication</li></ul> |
| **2nd** | Google | <ul><li>Most widely used social provider globally</li><li>High availability (90%+ market share for social login)</li><li>Most users have active Google account</li><li>Device integration on Android (seamless)</li><li>Web/desktop support if needed</li></ul> |
| **3rd** | Apple | <ul><li>Required for iOS-native apps (platform requirement)</li><li>High availability on Apple devices</li><li>Good UX on iOS/macOS</li><li>Less universal than Google (limited to Apple ecosystem)</li></ul> |
| **4th** | Facebook | <ul><li>Declining market share</li><li>Account abandonment risk</li><li>Privacy concerns (user retention lower)</li><li>More complex OAuth flow</li><li>Fallback-only option</li></ul> |

### Practical Implications

**For Hybrid Users (Email/Password + Social)**:
```
Attempt Order: Email/Password → Google → Apple → Facebook
Logic: User is familiar with password → most reliable social (Google) → platform-native (Apple)
```

**For Social-Only Users**:
```
Attempt Order: Google → Apple → Facebook
Logic: Most available → platform-specific → secondary option
```

**For Email/Password Only Users**:
```
No fallback needed - single provider always available (if user remembers password)
```

---

## Edge Case Handling

### Edge Case 1: User with No Providers

**Scenario**: Database corruption, account state mismatch, or rare edge case where `providerData` is empty.

**How to Detect**:
```dart
bool hasNoProviders() {
  final user = FirebaseAuth.instance.currentUser;
  return user != null && user.providerData.isEmpty;
}
```

**Handling Code**:
```dart
Future<void> handleNoProviders() async {
  try {
    // Attempt: Check if user truly has no providers
    final user = FirebaseAuth.instance.currentUser;
    
    if (user?.providerData.isEmpty ?? true) {
      // Case 1: User exists but has no providers (corrupted state)
      // Options:
      
      // Option A: Force sign-out (safest)
      await FirebaseAuth.instance.signOut();
      throw FirebaseAuthException(
        code: 'account-corrupted',
        message: 'Account state invalid. Please sign in again.',
      );
      
      // Option B: Delete account directly (if allowed by policy)
      // await user?.delete();
      
      // Option C: Link a provider (recovery flow)
      // - Prompt user to sign in with Google/Apple
      // - Link that provider to account
    }
  } catch (e) {
    print('Edge case - no providers: $e');
    rethrow;
  }
}
```

### Edge Case 2: User with Revoked Provider (Still Listed, But Disabled)

**Scenario**: User revoked Google access in Google Account settings, but `providerData` still lists Google.

**How to Detect**:
```dart
/// Attempt to use provider; if fails, it's revoked
Future<bool> isProviderRevoked(String providerId) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    // Check if provider is listed
    final isListed = user.providerData.any(
      (p) => p.providerId == providerId,
    );
    
    if (!isListed) return false; // Provider not linked
    
    // Try to use provider (this would fail if revoked)
    // This is validation-only; actual reauthentication happens later
    return true; // Assume linked = available for now
    
  } catch (e) {
    return true; // Treat as revoked if error
  }
}
```

**Handling Code**:
```dart
Future<String> reauthenticateWithRevokedCheck({
  required Function(String provider) onTryProvider,
}) async {
  final availableProviders = _fallbackService.getAvailableProvidersOrdered();
  
  for (final providerId in availableProviders) {
    try {
      // Attempt reauthentication
      await onTryProvider(providerId);
      return providerId; // Success
      
    } on FirebaseAuthException catch (e) {
      // Check for revocation-related errors
      if (e.code == 'invalid-user-token' || 
          e.code == 'user-token-expired' ||
          e.code == 'invalid-credential') {
        
        print('Provider $providerId appears revoked. Trying next...');
        
        // Optionally: Unlink this provider from account
        // await FirebaseAuth.instance.currentUser?.unlinkProvider(providerId);
        
        continue; // Try next provider
      }
      
      rethrow; // Other errors
    }
  }
  
  throw FirebaseAuthException(
    code: 'all-providers-revoked',
    message: 'All linked providers are revoked or unavailable',
  );
}
```

### Edge Case 3: Provider Linked But Needs Re-enabling by User

**Scenario**: User has Google linked but hasn't used it in 6+ months; Google session expired, or user needs to re-consent to scopes.

**How to Detect**:
```dart
/// Check if provider session might be stale (heuristic)
bool isProviderSessionLikelyStale(UserInfo providerInfo) {
  // This is a heuristic - actual freshness check requires OAuth flow
  
  // Firebase doesn't expose provider session timestamp, so we check:
  // 1. Provider is listed (means linked)
  // 2. We'll only know if stale when reauthentication is attempted
  
  return true; // Always treat as potentially stale; verify on use
}

/// Better approach: Check if provider supports re-consent flow
bool supportsReConsent(String providerId) {
  return ['google.com', 'apple.com', 'facebook.com'].contains(providerId);
}
```

**Handling Code**:
```dart
Future<String> reauthenticateWithReConsentHandling({
  required Function(String provider, {bool forceRefresh}) onTryProvider,
}) async {
  final availableProviders = _fallbackService.getAvailableProvidersOrdered();
  
  for (final providerId in availableProviders) {
    try {
      // First attempt: Use cached session
      try {
        await onTryProvider(providerId, forceRefresh: false);
        return providerId;
      } on FirebaseAuthException catch (e) {
        // If session stale, force re-authentication
        if (e.code == 'user-token-expired' || 
            e.code == 'invalid-user-token') {
          
          print('Provider session stale for $providerId. Re-authenticating...');
          
          // Second attempt: Force fresh OAuth flow (user re-consents)
          await onTryProvider(providerId, forceRefresh: true);
          return providerId;
        }
        rethrow;
      }
      
    } on FirebaseAuthException catch (e) {
      print('Provider $providerId failed: ${e.code}');
      continue; // Try next provider
    }
  }
  
  throw FirebaseAuthException(
    code: 'reauthentication-exhausted',
    message: 'All reauthentication attempts failed',
  );
}
```

### Edge Case 4: Duplicate Providers (Should Not Happen)

**Scenario**: Rare case where `providerData` contains duplicate provider entries.

**Defensive Code**:
```dart
/// Get unique providers (handle duplicates)
List<String> getUniqueProviderIds() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  
  return user.providerData
      .map((p) => p.providerId)
      .toSet() // Deduplicate
      .toList();
}

/// Get primary provider info (first occurrence in case of duplicates)
UserInfo? getPrimaryProviderInfo(String providerId) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  
  return user.providerData.cast<UserInfo?>().firstWhere(
    (p) => p?.providerId == providerId,
    orElse: () => null,
  );
}
```

### Edge Case 5: Provider Link Pending Verification

**Scenario**: User linked a provider but verification email not sent/completed.

**Handling Code**:
```dart
Future<void> verifyProviderLinks() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  
  for (final provider in user.providerData) {
    print('Provider: ${provider.providerId}');
    print('  Email: ${provider.email}');
    print('  Display Name: ${provider.displayName}');
    print('  Email Verified: ${provider.isEmailVerified}');
    
    // For email/password provider specifically
    if (provider.providerId == 'password') {
      if (!(provider.isEmailVerified ?? false)) {
        print('  ⚠️  Email not verified - may have limited access');
        
        // Optionally: Send verification email
        // await user.sendEmailVerification();
      }
    }
  }
}
```

---

## Rationale: Why This Approach?

### Why Query-Based Detection?

1. **Reliability**: `providerData` is authoritative Firebase Auth source
2. **Performance**: O(n) array scan; no external API calls
3. **Simplicity**: Single array to check vs. multiple Auth state queries
4. **Real-time**: Reflects current linked providers immediately

### Why Priority Ordering?

1. **User Experience**: Email/password first (most familiar)
2. **Availability**: Google > Apple (market share)
3. **Platform**: Apple for iOS users (native integration)
4. **Fallback**: Facebook as last resort (declining relevance)

### Why Explicit Exception on All-Fail?

1. **Clarity**: User knows account cannot be deleted without action
2. **Safety**: Prevents accidental data loss from silent failures
3. **Debugging**: Clear error messages help support teams
4. **UX**: Can show specific "which provider to use?" guidance

---

## Alternatives Considered

### Alternative 1: Async Provider Validation (Rejected)

**Approach**: Query Firebase servers to validate provider freshness before attempting reauthentication.

```dart
// REJECTED - Why?
Future<List<String>> validateProvidersAsync() async {
  // Would require external API call to check session validity
  // - Adds network latency
  // - Complexity for minimal benefit
  // - We discover issues on reauthentication attempt anyway
}
```

**Why Rejected**:
- Extra network call adds 500ms+ latency
- Reauthentication attempt validates provider anyway
- Firebase doesn't expose provider session API
- Overcomplicated for the problem

### Alternative 2: Hard-Coded Provider Order (Rejected)

**Approach**: Instead of dynamic detection, hard-code "always try Google first" logic.

```dart
// REJECTED - Why?
Future<String> staticProviderFallback() async {
  // Try Google first, always
  try {
    await reauthenticateWithGoogle();
    return 'google.com';
  } catch (e) {
    // Fall back to Apple
    return reauthenticateWithApple();
  }
}
```

**Why Rejected**:
- Breaks for users without Google (Apple-only users fail hard)
- Ignores email/password (better UX than social)
- Inflexible for future provider additions
- Dynamic approach more maintainable

### Alternative 3: User Choice in UI (Partial Alternative)

**Approach**: Show list of available providers, let user choose.

```dart
// PARTIAL ALTERNATIVE
Future<String> userChoosesProvider(List<String> availableProviders) async {
  // UI shows list: "Sign in with: Google, Apple, Email/Password"
  // User taps choice
  // Attempt reauthentication with selected provider
}
```

**When to Use**: 
- Better for explicit user confirmation
- Combine with automatic fallback: first ask user, then auto-fallback if they abandon flow
- Improves UX for deletion confirmation

**When NOT to Use**:
- Adds extra UI/flow complexity
- Works against "seamless experience" goal
- Fallback strategy more resilient

### Alternative 4: Device Token Caching (Rejected)

**Approach**: Cache provider session tokens locally for faster reauth.

```dart
// REJECTED - Why?
Future<void> cacheProviderTokens() async {
  // Store Google/Apple tokens in secure storage
  // Use cached tokens for reauthentication
  // - Faster (local read)
  // - Works offline
}
```

**Why Rejected**:
- Security risk (tokens could be stolen)
- Token expiration not tracked
- Doesn't solve revocation issue
- Firebase already handles token management

---

## Implementation Recommendations

### For This Project (Feature 004)

1. **Start With**: Email/Password Detection (Example 1)
2. **Then Add**: Social-Only Detection (Example 2)
3. **Then Implement**: Fallback Service with Priority Order (Full Implementation)
4. **Handle Edge Cases**: Revoked providers, no providers, stale sessions
5. **Test**: 
   - Hybrid user (email + social): attempt email first ✓
   - Social-only user: attempt Google first ✓
   - Email-only user: single path ✓
   - All providers fail: clear error ✓

### Testing Strategy

```dart
// Test Cases
void testProviderDetection() {
  // Test 1: Hybrid user detection
  // Test 2: Social-only detection
  // Test 3: Email-only detection
  // Test 4: No providers (edge case)
  // Test 5: Fallback order execution
  // Test 6: Error handling for each provider
}
```

### Security Considerations

1. **Never cache credentials**: Let Firebase handle token management
2. **Always reauthenticate**: Don't skip for sensitive operations (deletion)
3. **Clear error messages**: Help users understand what went wrong
4. **Audit logging**: Log which provider was used for deletion
5. **Rate limiting**: Implement backoff for repeated failed attempts

---

## References

- [Firebase Auth Docs: Manage Users](https://firebase.google.com/docs/auth/manage-users)
- [FirebaseAuth (Dart): User.providerData](https://pub.dev/documentation/firebase_auth/latest/firebase_auth/User/providerData.html)
- [Firebase Auth: Link Multiple Providers](https://firebase.google.com/docs/auth/web/account-linking)
- [Flutter Firebase Auth Package](https://pub.dev/packages/firebase_auth)
