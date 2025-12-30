# Phase 1 Data Model: Delete Account Without Password

**Feature**: 004-delete-account-nopass  
**Date**: 2025-12-30  
**Phase**: Phase 1 Design

---

## Overview

This document defines the data entities required by the delete-account-nopass feature. Entities represent the state and audit trail of account deletion operations. Most operations use existing entities (`User`, `AuthResult`); new entities (`DeletionRequest`) are minimal and scoped only to deletion workflows.

---

## Entity: DeletionRequest

**Purpose**: Audit trail and status tracking for account deletion operations.  
**Scope**: In-memory during deletion flow; optionally logged to Firebase/Firestore for audit.  
**Lifecycle**: Created when user initiates delete; updated through reauth/cleanup stages; finalized on success/failure.

### Fields

| Field | Type | Required | Description | Validation |
|-------|------|----------|-------------|-----------|
| `id` | `String` | Yes | Unique ID for this deletion attempt (UUID or timestamp-based) | Non-empty; immutable |
| `userId` | `String` | Yes | Firebase user ID | Non-empty; immutable after creation |
| `initiatedAt` | `DateTime` | Yes | When deletion was requested | Not null; immutable |
| `providerUsed` | `String?` | No | Which provider was successfully used for reauthentication | Null until reauthentication succeeds; values: 'password', 'google.com', 'apple.com' |
| `reauthAttempts` | `int` | Yes | Number of reauthentication attempts | Starts at 0; incremented on each attempt |
| `reauthSucceededAt` | `DateTime?` | No | When reauthentication succeeded | Null until success; immutable after set |
| `accountDeletedAt` | `DateTime?` | No | When Firebase account was deleted | Null until deletion succeeds; immutable after set |
| `cleanupFailures` | `List<String>` | Yes | List of local cleanup operations that failed | Empty list if all succeed; contains: 'markers', 'tracklogs', 'tokens', 'preferences' |
| `completedAt` | `DateTime?` | No | When entire deletion flow finished (success or final failure) | Null until completion |
| `status` | `DeletionStatus` | Yes | Current status | Enum: INITIATED, REAUTHENTICATING, REAUTH_FAILED, DELETING, CLEANUP, COMPLETED, FAILED |
| `lastError` | `String?` | No | Last error message (for debugging) | Null if no errors; human-readable |

### Relationships

- **DeletionRequest → User**: One-to-one mapping via `userId`
- **DeletionRequest → AuthResult**: Reauthentication result feeds into `providerUsed` and `reauthSucceededAt`

### State Transitions

```
INITIATED 
  → REAUTHENTICATING (user taps "Delete")
  → REAUTH_FAILED (error) → [user retries] → REAUTHENTICATING
  → DELETING (reauth success)
  → CLEANUP (account deleted)
  → COMPLETED (success) or FAILED (cleanup error)
```

### Example Instance

```dart
final request = DeletionRequest(
  id: 'del_20251230_abc123',
  userId: 'user_firebase_uid',
  initiatedAt: DateTime.now(),
  providerUsed: 'google.com',
  reauthAttempts: 1,
  reauthSucceededAt: DateTime.now().subtract(Duration(seconds: 5)),
  accountDeletedAt: DateTime.now().subtract(Duration(seconds: 2)),
  cleanupFailures: ['tokens'], // token cleanup failed, but others succeeded
  completedAt: DateTime.now(),
  status: DeletionStatus.completed,
  lastError: null,
);
```

### Validation Rules

1. `userId` must not be empty
2. `initiatedAt` ≤ all subsequent timestamps
3. `reauthAttempts` ≥ 1 if `reauthSucceededAt` is set
4. `accountDeletedAt` cannot be set unless `reauthSucceededAt` is set
5. `completedAt` must be set when `status` is COMPLETED or FAILED
6. `cleanupFailures` cannot contain duplicates
7. If `status` is COMPLETED and `accountDeletedAt` is null, return error (invalid state)

---

## Entity: DeletionStatus (Enum)

**Purpose**: Track the current stage of account deletion.

```dart
enum DeletionStatus {
  /// User has initiated deletion; awaiting reauthentication
  initiated,
  
  /// Provider reauthentication in progress (UI shows loading)
  reauthenticating,
  
  /// Reauthentication failed (user can retry or cancel)
  reauthFailed,
  
  /// Reauthentication succeeded; deleting account from Firebase
  deleting,
  
  /// Account deleted; cleaning up local data
  cleanup,
  
  /// Entire flow succeeded (account and local data deleted)
  completed,
  
  /// Flow failed at some stage (reauth failed multiple times, or cleanup error after deletion)
  failed,
}
```

---

## Entity: UserSession (Extended)

**Purpose**: Represents the current user's authentication state including linked providers.  
**Scope**: In-memory during app session.  
**Lifecycle**: Created/updated on sign-in; updated when providers are linked/unlinked; cleared on sign-out.

### Fields (Additions for Feature 004)

| Field | Type | Required | Description | Source |
|-------|------|----------|-------------|--------|
| `linkedProviders` | `List<String>` | Yes | List of provider IDs linked to this account | `FirebaseAuth.currentUser.providerData.map(p => p.providerId)` |
| `hasEmailPassword` | `bool` | Yes | Whether email/password provider is linked | Derived from `linkedProviders` |
| `primaryProvider` | `String?` | No | Fallback for deletion (email/password if available, else first social) | Logic: email/password > google.com > apple.com |
| `isSocialOnlyUser` | `bool` | Yes | Whether user has ONLY social providers (no password) | `!hasEmailPassword && linkedProviders.isNotEmpty` |

### Example Instance

```dart
final session = UserSession(
  uid: 'user_firebase_uid',
  email: 'user@example.com',
  displayName: 'John Doe',
  linkedProviders: ['google.com', 'apple.com'],
  hasEmailPassword: false,
  primaryProvider: 'google.com', // Google is primary social provider
  isSocialOnlyUser: true, // No email/password
);
```

### Validation Rules

1. `linkedProviders` cannot be empty (user must have at least one auth method)
2. `hasEmailPassword` = `linkedProviders.contains('password')`
3. `primaryProvider` must be one of the values in `linkedProviders`
4. `isSocialOnlyUser` = `!hasEmailPassword && linkedProviders.isNotEmpty`

---

## Entity: ProviderInfo (Optional Helper)

**Purpose**: Encapsulate provider-specific details and reauthentication flow.  
**Scope**: Transient; created when provider reauthentication is attempted.  
**Lifecycle**: Created at start of reauth attempt; discarded after success/failure.

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `providerId` | `String` | 'google.com', 'apple.com', or 'password' |
| `displayName` | `String` | "Sign in with Google", "Sign in with Apple", etc. |
| `isAvailable` | `bool` | Whether provider is currently reachable |
| `lastError` | `String?` | Last error attempting to use this provider |
| `retryCount` | `int` | How many times this specific provider was attempted |

### Example Usage

```dart
final providerInfo = ProviderInfo(
  providerId: 'google.com',
  displayName: 'Sign in with Google',
  isAvailable: true,
  lastError: null,
  retryCount: 1,
);
```

---

## Relationship Diagram

```
┌─────────────────────────────────────────────────────┐
│ User (Firebase)                                     │
├─────────────────────────────────────────────────────┤
│ uid: String                                         │
│ email: String?                                      │
│ providerData: List<UserInfo>  ←──┐                 │
└─────────────────────────────────────────────────────┘
                                    │
                                    ↓
                    ┌──────────────────────────────┐
                    │ UserSession (Project)        │
                    ├──────────────────────────────┤
                    │ linkedProviders              │
                    │ hasEmailPassword             │
                    │ primaryProvider              │
                    │ isSocialOnlyUser             │
                    └──────────────────────────────┘
                            │
                            ↓
                    ┌──────────────────────────────┐
                    │ DeletionRequest (This Feature)│
                    ├──────────────────────────────┤
                    │ userId                       │
                    │ providerUsed                 │
                    │ reauthAttempts               │
                    │ status                       │
                    │ cleanupFailures              │
                    └──────────────────────────────┘
```

---

## Storage & Persistence

### In-Memory (Session)

- **DeletionRequest**: Held in memory during deletion flow; not persisted to device storage
- **UserSession**: Held in memory; can be reconstructed from `FirebaseAuth.currentUser`
- **ProviderInfo**: Transient; created/destroyed during reauthentication attempts

### Optional Audit Logging (Future)

DeletionRequest could be logged to Firestore for compliance/audit:
```dart
// Pseudo-code (not implemented in Phase 1)
await firestore
  .collection('audit_logs')
  .doc(request.id)
  .set({
    'userId': request.userId,
    'action': 'account_deleted',
    'provider': request.providerUsed,
    'timestamp': request.completedAt,
    'cleanupFailures': request.cleanupFailures,
  });
```

---

## Data Model: JSON Serialization (If Needed)

### DeletionRequest JSON

```json
{
  "id": "del_20251230_abc123",
  "userId": "user_firebase_uid",
  "initiatedAt": "2025-12-30T10:15:30.000Z",
  "providerUsed": "google.com",
  "reauthAttempts": 1,
  "reauthSucceededAt": "2025-12-30T10:15:35.000Z",
  "accountDeletedAt": "2025-12-30T10:15:37.000Z",
  "cleanupFailures": ["tokens"],
  "completedAt": "2025-12-30T10:15:40.000Z",
  "status": "completed",
  "lastError": null
}
```

---

## Error States & Edge Cases

### Invalid State Transitions

| From | To | Allowed? | Reason |
|------|----|---------|----|
| INITIATED | CLEANUP | ❌ | Must go through REAUTHENTICATING and DELETING |
| COMPLETED | REAUTHENTICATING | ❌ | Cannot retry after completion |
| FAILED | DELETING | ❌ | Flow cannot recover; must start new deletion |

### Validation on State Changes

```dart
bool canTransition(DeletionStatus from, DeletionStatus to) {
  const allowedTransitions = {
    DeletionStatus.initiated: [DeletionStatus.reauthenticating],
    DeletionStatus.reauthenticating: [DeletionStatus.reauthFailed, DeletionStatus.deleting],
    DeletionStatus.reauthFailed: [DeletionStatus.reauthenticating], // Retry
    DeletionStatus.deleting: [DeletionStatus.cleanup],
    DeletionStatus.cleanup: [DeletionStatus.completed, DeletionStatus.failed],
    DeletionStatus.completed: [],
    DeletionStatus.failed: [],
  };
  
  return allowedTransitions[from]?.contains(to) ?? false;
}
```

---

## Scalability Considerations

### For Current Scope
- DeletionRequest is in-memory only; minimal overhead
- No database queries required
- Suitable for small-to-medium user bases

### If Audit Logging Added (Future)
- Add Firestore collection `audit_logs` with index on `userId` + `timestamp`
- Retention policy: Keep logs for 90 days (GDPR compliance)
- No impact on deletion performance (logged asynchronously)

---

## Conclusion

**Data Model Summary**:
1. **DeletionRequest**: Audit trail for deletion flow (in-memory, status tracking)
2. **UserSession Extension**: Track linked providers for smart fallback
3. **ProviderInfo**: Helper for provider-specific reauthentication
4. **Status Enum**: Clear state tracking through deletion stages

**Key Design Decisions**:
- ✅ Minimal entities; reuse existing `User`, `AuthResult`
- ✅ In-memory state; no local persistence (align with GDPR "forget me" principle)
- ✅ Optional audit logging (future; not required for MVP)
- ✅ Comprehensive validation; prevent invalid state transitions

**Ready for Phase 1 Design**: Proceed to contracts/ and quickstart.md.

---

*Data model generated by speckit.plan Phase 1*
