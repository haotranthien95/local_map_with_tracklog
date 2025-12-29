# Data Model: Firebase User Authentication

**Date**: 2025-12-29  
**Feature**: 003-firebase-user-auth  
**Purpose**: Define entities, relationships, and data structures

## Overview

This feature introduces three primary entities for managing user authentication and profile data. All entities are technology-agnostic in concept but implemented using Firebase Authentication and local storage in Flutter.

## Entity Definitions

### 1. User Account

**Purpose**: Represents an authenticated user in the system

**Attributes**:

| Field | Type | Required | Description | Source |
|-------|------|----------|-------------|--------|
| `userId` | String (UID) | Yes | Unique identifier for user | Firebase Auth generates |
| `email` | String | Yes | User's email address | User input / OAuth provider |
| `emailVerified` | Boolean | Yes | Email verification status | Firebase Auth manages |
| `displayName` | String | No | User's display name | User input / OAuth provider |
| `authProvider` | Enum | Yes | Authentication method used | Email/Google/Apple |
| `createdAt` | DateTime | Yes | Account creation timestamp | Firebase Auth generates |
| `lastSignInAt` | DateTime | Yes | Last successful sign-in | Firebase Auth updates |
| `photoUrl` | String | No | Profile photo URL (OAuth only) | OAuth provider (not editable) |

**Validation Rules**:
- `email`: Must be valid email format (validated by `email_validator` package)
- `displayName`: Optional, 2-50 characters if provided, no special validation
- `authProvider`: One of `EmailPassword`, `Google`, `Apple`

**Relationships**:
- One User Account → Many Authentication Sessions (historical)
- One User Account → One User Profile (editable data)
- One User Account → Many Tracklogs (application data)

**Storage**:
- Managed by Firebase Authentication (cloud)
- Not stored locally except for cached session state
- Accessed via `FirebaseAuth.instance.currentUser`

**State Transitions**:
```
[Guest/Unauthenticated] 
  → (create account) → [Account Created, Email Unverified]
  → (verify email) → [Account Active, Email Verified]
  → (sign out) → [Signed Out]
  → (sign in) → [Authenticated]
  → (delete account) → [Account Deleted]
```

**Privacy/Security**:
- Password never stored (handled by Firebase)
- Email visible only to account owner
- userId is unique and immutable
- Account deletion removes all Firebase authentication data

---

### 2. Authentication Session

**Purpose**: Represents an active user session with authentication tokens

**Attributes**:

| Field | Type | Required | Description | Source |
|-------|------|----------|-------------|--------|
| `sessionToken` | String | Yes | Firebase ID token (JWT) | Firebase Auth generates |
| `refreshToken` | String | Yes | Token for refreshing expired sessions | Firebase Auth generates |
| `expiresAt` | DateTime | Yes | Token expiration time (1 hour default) | Firebase Auth manages |
| `userId` | String (UID) | Yes | Associated user identifier | Firebase Auth |
| `deviceInfo` | String | No | Device identifier (optional tracking) | Platform APIs |
| `lastActivity` | DateTime | Yes | Last authenticated request time | App tracks |

**Validation Rules**:
- Tokens are opaque strings, validated by Firebase SDK
- Auto-refresh before expiration
- Maximum session duration: 90 days of inactivity (Firebase default)

**Relationships**:
- Many Sessions → One User Account
- One Session → One Device (conceptually, not enforced)

**Storage**:
- Session tokens stored securely by Firebase Auth SDK
- Additional tokens (if needed) use `flutter_secure_storage`
- Automatic persistence across app restarts

**Lifecycle**:
```
[Sign In] → [Session Created] → [Token Expires] → [Auto Refresh]
  → [Sign Out] → [Session Invalidated]
  → [Inactivity 90 days] → [Session Expired]
```

**Security**:
- Tokens stored in platform secure storage (iOS Keychain, Android Keystore)
- Never logged or displayed in UI
- Automatically invalidated on sign out or account deletion
- Refresh handled transparently by Firebase SDK

---

### 3. User Profile

**Purpose**: Contains editable user information separate from authentication data

**Attributes**:

| Field | Type | Required | Description | Source |
|-------|------|----------|-------------|--------|
| `userId` | String (UID) | Yes | Links to User Account | Firebase Auth |
| `displayName` | String | No | Editable display name | User input |
| `preferences` | Map<String, dynamic> | No | App-specific settings | User input |
| `guestDataMigrated` | Boolean | Yes | Flag for data migration status | System tracks |
| `migrationPending` | Boolean | Yes | Retry flag if migration failed | System tracks |

**Validation Rules**:
- `displayName`: 2-50 characters if provided, alphanumeric + spaces
- `preferences`: JSON-serializable map, max 10KB size
- Migration flags: Boolean, system-managed

**Relationships**:
- One User Profile → One User Account (1:1)
- User Profile references Tracklogs via `userId`

**Storage**:
- Local: `shared_preferences` for simple key-value data
- Structure:
  ```
  user_profile_{userId}:
    {
      "displayName": "John Doe",
      "preferences": {...},
      "guestDataMigrated": true,
      "migrationPending": false
    }
  ```

**Lifecycle**:
```
[Account Created] → [Profile Created with defaults]
  → [User Edits] → [Profile Updated]
  → [Account Deleted] → [Profile Deleted]
```

**Privacy/Security**:
- Local storage only (not synced to cloud in MVP)
- Deleted when account is deleted
- No sensitive data stored here (use secure storage for sensitive items)

---

## Supporting Data Structures

### 4. Guest Data Tracker

**Purpose**: Tracks guest user data for migration upon authentication

**Attributes**:

| Field | Type | Description |
|-------|------|-------------|
| `hasGuestData` | Boolean | Flag indicating guest data exists |
| `guestTracklogIds` | List<String> | IDs of guest tracklogs to migrate |
| `createdAt` | DateTime | When guest session started |

**Storage**: `shared_preferences` with key `guest_data_tracker`

**Lifecycle**:
```
[App First Launch] → [hasGuestData = false]
  → [User Creates Tracklog as Guest] → [hasGuestData = true, tracklogIds added]
  → [User Creates Account] → [Migrate Data, Clear Guest Tracker]
  → [User Logs Into Existing Account] → [Discard Guest Data, Clear Tracker]
```

---

### 5. Authentication Provider Enum

**Purpose**: Identify authentication method used

**Values**:
- `EmailPassword` - Email and password authentication
- `Google` - Google Sign-In
- `Apple` - Apple Sign In

**Usage**: Stored in User Account, used for determining available account operations (e.g., password change only available for EmailPassword provider)

---

## Data Flow Diagrams

### Registration Flow

```
[Guest User] 
  ↓
[Tap "Create Account"]
  ↓
[Enter Email/Password OR Choose Social Login]
  ↓
[Firebase Creates User Account] → User Account entity created
  ↓
[Generate Session Tokens] → Authentication Session created
  ↓
[Create User Profile] → User Profile entity created
  ↓
[Check Guest Data Tracker]
  ↓
[Migrate Guest Data] → Associate tracklogs with userId
  ↓
[Clear Guest Tracker]
  ↓
[Navigate to Main Screen] → Authenticated state
```

### Login Flow

```
[Signed Out User]
  ↓
[Enter Credentials OR Choose Social Login]
  ↓
[Firebase Authenticates] → Validates credentials
  ↓
[Create Session] → Authentication Session created
  ↓
[Load User Profile] → Fetch from local storage
  ↓
[Check Guest Data Tracker]
  ↓
[Discard Guest Data] → Guest data removed (cloud data loaded instead)
  ↓
[Navigate to Main Screen] → Authenticated state
```

### Account Deletion Flow

```
[Authenticated User]
  ↓
[Tap "Delete Account"]
  ↓
[Show Warning Dialog] → Confirm irreversible action
  ↓
[Prompt for Re-authentication] → Security check
  ↓
[Firebase Re-authenticates]
  ↓
[Delete Local User Data] → Remove profile, tracklogs, preferences
  ↓
[Delete User Profile from shared_preferences]
  ↓
[Firebase Deletes User Account] → user.delete()
  ↓
[Session Invalidated] → Authentication Session cleared
  ↓
[Navigate to Login Screen] → Unauthenticated state
```

---

## Data Access Patterns

### By Feature

| Feature | Reads | Writes | Deletes |
|---------|-------|--------|---------|
| Registration | Guest Data Tracker | User Account, Session, Profile, Tracklogs (migration) | Guest Data |
| Login | User Account | Session, Profile (load) | Guest Data |
| Profile Edit | User Account, Profile | Profile (displayName, email, password) | - |
| Account Deletion | User Account, Profile, Tracklogs | - | All user data |
| Logout | Session | - | Session |

### By Entity

| Entity | Primary Access | Secondary Access |
|--------|---------------|------------------|
| User Account | AuthenticationService | ProfileService (read-only) |
| Authentication Session | AuthenticationService | App-wide (auth state listening) |
| User Profile | ProfileService | TracklogService (userId lookup) |

---

## Data Migration Strategy

### Guest to Authenticated User

**Trigger**: User creates account or logs in for first time

**Process**:
1. Check `hasGuestData` flag in shared_preferences
2. If true:
   - Load `guestTracklogIds`
   - For each tracklog: Update metadata to associate with `userId`
   - Move tracklog files from `guest/` directory to `users/{userId}/` directory
   - Update User Profile with `guestDataMigrated = true`
   - Clear Guest Data Tracker
3. If false: No action needed

**Failure Handling**:
- If migration fails (network error, storage error):
  - Account creation still succeeds
  - Set `migrationPending = true` in User Profile
  - Show notification: "Syncing your data in background..."
  - Retry on next app start
  - User can manually retry from settings

---

## Validation & Constraints

### Email Validation
- Format: RFC 5322 compliant (use `email_validator` package)
- Examples: `user@example.com` ✅, `invalid.email` ❌

### Password Requirements
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- Validated client-side before submission

### Display Name Constraints
- Optional field
- If provided: 2-50 characters
- Alphanumeric characters and spaces allowed
- No profanity filtering (out of scope for MVP)

---

## Data Retention & Privacy

### Account Active
- User Account: Retained indefinitely (managed by Firebase)
- Authentication Session: 90 days inactivity, then expired (auto-refresh if active)
- User Profile: Retained indefinitely

### Account Deleted
- User Account: Immediately deleted from Firebase
- Authentication Session: Immediately invalidated
- User Profile: Immediately deleted from local storage
- Tracklogs: Immediately deleted from local storage
- No data recovery possible (permanent deletion)

### Guest Data
- Retained until:
  - User creates account → migrated to authenticated storage
  - User logs into existing account → discarded
  - User manually clears app data → deleted by OS

---

## Testing Considerations

### Test Data Requirements
- Valid test emails: `test@example.com`, `user123@test.com`
- Valid test passwords: `TestPass123`, `Secure456!`
- Firebase Auth Emulator: Use for local testing without real accounts

### Edge Cases to Test
- Empty strings for email/password
- Extremely long display names (>50 chars)
- Special characters in display name
- Guest data with 0, 1, 100+ tracklogs
- Migration failure scenarios
- Network offline during registration
- Account deletion with pending migration

---

## Next Steps

Use this data model to:
1. Design `contracts/authentication_service.dart` interface
2. Implement `lib/models/user.dart`, `lib/models/auth_session.dart`, `lib/models/user_profile.dart`
3. Create `lib/services/authentication_service.dart` with methods matching contracts
4. Build UI screens using these models
