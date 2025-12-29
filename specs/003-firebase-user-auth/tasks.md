# Tasks: Firebase User Authentication & Account Management

**Input**: Design documents from `/specs/003-firebase-user-auth/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/authentication_service.md, quickstart.md

**Tests**: Not explicitly requested in specification - test tasks EXCLUDED per constitution (no premature test infrastructure)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4, US5)
- Include exact file paths in descriptions

## Path Conventions

Flutter mobile application - paths relative to repository root:
- **Models**: `lib/models/`
- **Services**: `lib/services/`
- **Screens**: `lib/screens/`
- **Widgets**: `lib/widgets/`
- **Features**: `lib/features/auth/`
- **Platform Config**: `android/`, `ios/`
- **Tests**: `test/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and Firebase configuration

- [X] T001 Follow quickstart.md to create Firebase project and enable Authentication (Email/Password, Google, Apple)
- [X] T002 [P] Add iOS app to Firebase and download GoogleService-Info.plist to ios/Runner/
- [ ] T003 [P] Add Android app to Firebase and download google-services.json to android/app/
- [X] T004 Update pubspec.yaml with dependencies: firebase_core ^3.6.0, firebase_auth ^5.3.1, google_sign_in ^6.2.1, sign_in_with_apple ^6.1.2, flutter_secure_storage ^9.2.2, shared_preferences ^2.3.2
- [X] T005 Run flutter pub get to install dependencies
- [X] T006 [P] Configure iOS Podfile with platform :ios, '15.0' and pod 'Firebase/Auth'
- [X] T007 [P] Update android/build.gradle with google-services plugin classpath
- [X] T008 [P] Update android/app/build.gradle to apply google-services plugin
- [X] T009 [P] Configure Google Sign-In URL scheme in ios/Runner/Info.plist using REVERSED_CLIENT_ID
- [ ] T010 [P] Add Apple Sign In capability in Xcode Runner target
- [ ] T011 [P] Generate SHA-1 certificate for Android and add to Firebase Console
- [X] T012 Update lib/main.dart to initialize Firebase with await Firebase.initializeApp()
- [ ] T013 Test iOS build: flutter run -d ios (verify Firebase initialized successfully)
- [ ] T014 Test Android build: flutter run -d android (verify Firebase initialized successfully)

**Checkpoint**: Firebase setup complete - authentication infrastructure ready

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core models, services, and validators that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T015 [P] Create User model in lib/models/user.dart (userId, email, emailVerified, displayName, authProvider, createdAt, lastSignInAt, photoUrl)
- [X] T016 [P] Create AuthResult model in lib/models/auth_result.dart (success, user, error, errorCode)
- [X] T017 [P] Create AuthenticationSession model in lib/models/authentication_session.dart (sessionToken, refreshToken, expiresAt, userId)
- [X] T018 [P] Create UserProfile model in lib/models/user_profile.dart (userId, displayName, preferences, guestDataMigrated, migrationPending)
- [X] T019 [P] Create GuestDataTracker model in lib/models/guest_data_tracker.dart (hasGuestData, guestTracklogIds, createdAt)
- [X] T020 [P] Create AuthProvider enum in lib/models/user.dart (emailPassword, google, apple)
- [X] T021 [P] Create email validator in lib/features/auth/validators/email_validator.dart (isValidEmail method using regex)
- [X] T022 [P] Create password validator in lib/features/auth/validators/password_validator.dart (min 8 chars, uppercase, lowercase, number)
- [X] T023 [P] Create auth constants in lib/features/auth/constants/auth_constants.dart (error messages, validation rules)
- [X] T024 Create TokenStorageService in lib/services/token_storage_service.dart (secure token storage using flutter_secure_storage)
- [X] T025 Create GuestMigrationService skeleton in lib/services/guest_migration_service.dart (migrateGuestData, discardGuestData methods)
- [X] T026 Create AuthenticationService skeleton in lib/services/authentication_service.dart with singleton pattern
- [X] T027 [P] Implement getCurrentUser method in lib/services/authentication_service.dart
- [X] T028 [P] Implement authStateChanges stream in lib/services/authentication_service.dart
- [X] T029 [P] Implement isSignedIn method in lib/services/authentication_service.dart

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - New User Registration (Priority: P1) 🎯 MVP

**Goal**: Users can create accounts using email/password, Google, or Apple, with automatic guest data migration

**Independent Test**: Register new account with valid credentials → account created → logged in → guest data migrated → can save tracklogs

### Implementation for User Story 1

#### Email/Password Registration

- [X] T030 [P] [US1] Implement registerWithEmail method in lib/services/authentication_service.dart (validate email/password, call Firebase createUserWithEmailAndPassword, trigger guest migration)
- [X] T031 [P] [US1] Implement sendEmailVerification method in lib/services/authentication_service.dart (non-blocking verification)
- [X] T032 [P] [US1] Implement isEmailVerified method in lib/services/authentication_service.dart

#### Google Sign-In Registration

- [X] T033 [P] [US1] Implement registerWithGoogle method in lib/services/authentication_service.dart (Google Sign-In flow, Firebase credential exchange, trigger guest migration)

#### Apple Sign In Registration

- [X] T034 [P] [US1] Implement registerWithApple method in lib/services/authentication_service.dart (Apple Sign In flow, Firebase credential exchange, trigger guest migration)

#### Guest Data Migration

- [X] T035 [US1] Implement _migrateGuestData internal method in lib/services/guest_migration_service.dart (copy guest tracklogs to user storage, update metadata)
- [X] T036 [US1] Add background retry logic for failed migrations in lib/services/guest_migration_service.dart (set migrationPending flag, retry on next app launch)
- [X] T037 [US1] Implement migration status notification UI (display snackbar/dialog showing "Migrating your data...", "Migration complete", or "Migration failed - retrying" per FR-001f)
- [X] T038 [US1] Update tracklog_storage_service.dart to support migration from guest to authenticated user context

#### Registration UI

- [X] T039 [US1] Create RegisterScreen in lib/screens/register_screen.dart (email/password fields, validation, register button, LoadingOverlay integration)
- [X] T040 [US1] Create AuthTextField widget in lib/widgets/auth_text_field.dart (styled text field for email/password with validation feedback)
- [X] T041 [US1] Create AuthButton widget in lib/widgets/auth_button.dart (styled button for authentication actions)
- [X] T042 [US1] Add Google Sign-In button to RegisterScreen using SocialLoginButtons widget
- [X] T043 [US1] Add Apple Sign In button to RegisterScreen using SocialLoginButtons widget
- [X] T044 [US1] Create SocialLoginButtons widget in lib/widgets/social_login_buttons.dart (Google/Apple sign-in buttons)
- [X] T045 [US1] Create LoadingOverlay widget in lib/widgets/loading_overlay.dart (show during auth operations)
- [X] T046 [US1] Implement registration form validation in RegisterScreen (client-side email/password checks before Firebase call)
- [X] T047 [US1] Add error handling to RegisterScreen (Firebase error codes → user-friendly messages per auth_constants.dart)
- [X] T048 [US1] Add success flow to RegisterScreen (navigate to main screen after successful registration)
- [X] T049 [US1] Handle "email-already-in-use" error with "Sign In" option redirect

#### Account Linking (for existing accounts with same email)

- [X] T050 [US1] Implement automatic account linking in registerWithGoogle for existing email/password accounts
- [X] T051 [US1] Implement automatic account linking in registerWithApple for existing email/password accounts
- [X] T052 [US1] Handle account-exists-with-different-credential error gracefully (link and sign in)

#### Navigation Integration

- [X] T053 [US1] Update lib/screens/home_screen.dart to check auth state and show "Create Account" prompt when user tries to save tracklog
- [X] T054 [US1] Add navigation from home_screen to RegisterScreen when authentication required

**Checkpoint**: At this point, User Story 1 should be fully functional - users can register and their guest data is migrated

---

## Phase 4: User Story 2 - User Login (Priority: P1) 🎯 MVP

**Goal**: Returning users can sign in with email/password, Google, or Apple; guest data discarded for existing accounts

**Independent Test**: Sign in with valid credentials → logged in → redirected to main screen → existing account data loaded

### Implementation for User Story 2

#### Email/Password Login

- [X] T055 [P] [US2] Implement signInWithEmail method in lib/services/authentication_service.dart (validate credentials, call Firebase signInWithEmailAndPassword, discard guest data)
- [X] T056 [P] [US2] Implement sendPasswordReset method in lib/services/authentication_service.dart (Firebase sendPasswordResetEmail)

#### Google Sign-In Login

- [X] T057 [P] [US2] Implement signInWithGoogle method in lib/services/authentication_service.dart (same flow as register but for existing users)

#### Apple Sign In Login

- [X] T058 [P] [US2] Implement signInWithApple method in lib/services/authentication_service.dart (same flow as register but for existing users)

#### Guest Data Handling

- [X] T059 [US2] Implement _discardGuestData internal method in lib/services/guest_migration_service.dart (clear guest tracker, delete guest tracklogs)

#### Login UI

- [X] T060 [US2] Create LoginScreen in lib/screens/login_screen.dart (email/password fields, sign-in button, forgot password link, LoadingOverlay integration)
- [X] T061 [US2] Add Google Sign-In button to LoginScreen using SocialLoginButtons widget
- [X] T062 [US2] Add Apple Sign In button to LoginScreen using SocialLoginButtons widget
- [X] T063 [US2] Implement login form validation in LoginScreen (client-side checks before Firebase call)
- [X] T064 [US2] Add error handling to LoginScreen (map Firebase errors to user-friendly messages: user-not-found/wrong-password → "Invalid email or password")
- [X] T065 [US2] Add success flow to LoginScreen (navigate to main screen after successful login)
- [X] T066 [US2] Implement "Forgot Password" flow in LoginScreen (show dialog, collect email, call sendPasswordReset)
- [X] T067 [US2] Show email verification reminder for unverified users (non-blocking, with "Resend" button)
- [X] T068 [US2] Handle social login cancellation gracefully (show "Sign-in cancelled" message, return to login screen)

#### Account Linking (for existing accounts)

- [X] T069 [US2] Handle automatic account linking when social login email matches existing account (link and sign in)

#### Navigation Integration

- [X] T070 [US2] Update main.dart to show LoginScreen if user not authenticated on app launch
- [X] T071 [US2] Add navigation from RegisterScreen to LoginScreen ("Already have an account?" link)
- [X] T072 [US2] Add navigation from LoginScreen to RegisterScreen ("Create Account" link)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work - users can register and login

---

## Phase 5: User Story 3 - View and Edit Account Profile (Priority: P2)

**Goal**: Users can view and update their profile (display name, email, password)

**Independent Test**: Navigate to profile screen → view account info → update display name → save → confirmation shown

### Implementation for User Story 3

#### Profile Management Service Methods

- [X] T073 [P] [US3] Implement updateDisplayName method in lib/services/authentication_service.dart (update Firebase profile and local UserProfile)
- [X] T074 [P] [US3] Implement updateEmail method in lib/services/authentication_service.dart (re-authenticate, update email, send verification)
- [X] T075 [P] [US3] Implement changePassword method in lib/services/authentication_service.dart (re-authenticate with current password, update password)

#### Profile UI

- [X] T076 [US3] Create ProfileScreen in lib/screens/profile_screen.dart (display email, displayName, createdAt, emailVerified status, LoadingOverlay integration)
- [X] T077 [US3] Add edit display name functionality to ProfileScreen (text field, save button, validation)
- [X] T078 [US3] Add error handling to ProfileScreen (show user-friendly errors for update failures)
- [X] T079 [US3] Add success feedback to ProfileScreen (confirmation snackbar after successful updates)
- [X] T080 [US3] Add offline detection to ProfileScreen (graceful degradation with retry option)

#### Account Settings UI

- [X] T081 [US3] Create AccountSettingsScreen in lib/screens/account_settings_screen.dart (change email, change password options, LoadingOverlay integration)
- [X] T082 [US3] Add change email dialog to AccountSettingsScreen (new email input, password for re-auth, verification sent message)
- [X] T083 [US3] Add change password dialog to AccountSettingsScreen (current password, new password, validation)
- [X] T084 [US3] Implement requires-recent-login error handling (prompt re-authentication if needed)

#### Navigation Integration

- [X] T085 [US3] Add navigation from home_screen settings menu to ProfileScreen
- [X] T086 [US3] Add navigation from ProfileScreen to AccountSettingsScreen ("Account Settings" button)

**Checkpoint**: At this point, User Stories 1, 2, AND 3 should all work - users can manage their profiles

---

## Phase 6: User Story 4 - Delete Account (Priority: P2)

**Goal**: Users can permanently delete their account and all associated data (GDPR/CCPA compliance)

**Independent Test**: Navigate to account settings → tap "Delete Account" → confirm warning → re-authenticate → account deleted → logged out

### Implementation for User Story 4

#### Account Deletion Service Methods

- [X] T087 [US4] Implement deleteAccount method in lib/services/authentication_service.dart (require re-auth, delete Firebase user, clear local data)
- [X] T088 [US4] Add comprehensive data cleanup in deleteAccount method (user profile, tracklogs, cached maps, preferences, secure tokens)

#### Account Deletion UI

- [X] T089 [US4] Add "Delete Account" button to AccountSettingsScreen with warning styling (red, destructive)
- [X] T090 [US4] Create delete account confirmation dialog in AccountSettingsScreen (explain irreversibility, "Cancel" and "Delete" buttons)
- [X] T091 [US4] Add re-authentication prompt in delete flow (password input for email/password accounts, social re-auth for Google/Apple)
- [X] T092 [US4] Implement deletion success flow (clear navigation stack, redirect to welcome/login screen)
- [X] T093 [US4] Add error handling for deletion failures (network errors, re-auth failures with user-friendly messages)

#### Data Cleanup Integration

- [X] T094 [US4] Update tracklog_storage_service.dart to delete all user tracklogs on account deletion
- [X] T095 [US4] Update tile_cache_service.dart to clear user-specific cached maps on account deletion
- [X] T096 [US4] Clear TokenStorageService secure storage on account deletion
- [X] T097 [US4] Clear shared_preferences user profile data on account deletion

**Checkpoint**: At this point, User Stories 1-4 should all work - complete account lifecycle implemented

---

## Phase 7: User Story 5 - Logout (Priority: P3)

**Goal**: Users can sign out to protect privacy or switch accounts

**Independent Test**: Tap logout → session cleared → redirected to login screen → cannot access protected features

### Implementation for User Story 5

#### Logout Service Method

- [X] T098 [US5] Implement signOut method in lib/services/authentication_service.dart (Firebase signOut, clear cached tokens)

#### Logout UI

- [X] T099 [US5] Add "Logout" button to settings_screen.dart settings menu
- [X] T100 [US5] Add logout confirmation dialog (optional: "Are you sure?" for better UX)
- [X] T101 [US5] Implement logout success flow (clear navigation stack, redirect to LoginScreen)
- [X] T102 [US5] Handle logout errors gracefully (rare but possible network issues)

#### Session Management

- [X] T103 [US5] Verify TokenStorageService clears all tokens on logout
- [X] T104 [US5] Update main.dart auth state listener to redirect to LoginScreen on logout

**Checkpoint**: All user stories (1-5) should now be independently functional - complete authentication feature delivered

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final validation

- [ ] T105 [P] Add user-friendly error messages for all Firebase error codes in lib/features/auth/constants/auth_constants.dart
- [ ] T106 [P] Implement proper loading states across all authentication screens (show LoadingOverlay during async operations)
- [ ] T107 [P] Add offline support indicators (show offline badge, disable network-dependent actions gracefully)
- [ ] T108 [P] Verify secure token storage on both iOS (Keychain) and Android (Keystore)
- [ ] T109 [P] Add authentication state persistence validation (stay logged in across app restarts for 90 days)
- [ ] T110 [P] Implement rate limiting feedback (show "too-many-requests" error gracefully with retry timer)
- [ ] T111 [P] Verify email enumeration prevention (same error message for user-not-found and wrong-password)
- [ ] T112 Add privacy policy and terms of service links to RegisterScreen
- [ ] T113 Add account age disclaimer to RegisterScreen (must be 13+ for AppStore compliance)
- [ ] T114 Update app settings to show authentication status (logged in as [email], account type)
- [ ] T115 Verify guest mode works seamlessly (users can explore without authentication)
- [ ] T116 [P] Test migration scenarios: guest → new account (data migrated) and guest → existing account (data discarded)
- [ ] T117 [P] Validate Firebase Security Rules prevent unauthorized data access
- [ ] T118 Run complete quickstart.md setup validation (Firebase Console, iOS/Android config, OAuth setup)
- [ ] T119 Test all authentication flows end-to-end on iOS device (including Apple Sign In which doesn't work on simulator)
- [ ] T120 Test all authentication flows end-to-end on Android device
- [ ] T121 Code cleanup: Remove any console.log debugging, unused imports, commented code
- [ ] T122 Verify AppStore compliance: account deletion works, privacy disclosures present, data management functional

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion (T001-T014) - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational (T015-T029) - Can start after Phase 2
- **User Story 2 (Phase 4)**: Depends on Foundational (T015-T029) - Can start after Phase 2, benefits from US1 UI widgets
- **User Story 3 (Phase 5)**: Depends on Foundational + US2 (need login to access profile) - Can start after Phase 4
- **User Story 4 (Phase 6)**: Depends on Foundational + US2 + US3 (delete from account settings) - Can start after Phase 5
- **User Story 5 (Phase 7)**: Depends on Foundational + US2 (need login to logout) - Can start after Phase 4
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Independence

Once Foundational phase (T015-T029) is complete:

- **User Story 1 (P1)**: Registration - Independent, can start immediately after Foundation
- **User Story 2 (P1)**: Login - Independent, can start immediately after Foundation (parallel with US1)
- **User Story 3 (P2)**: Profile Management - Depends on US2 (need login), but independently testable
- **User Story 4 (P2)**: Account Deletion - Depends on US3 (accessed from account settings), but independently testable
- **User Story 5 (P3)**: Logout - Depends on US2 (need login), but independently testable

**Recommended Order**: US1 → US2 → US3 → US4 → US5 (follows priority and logical flow)

**Parallel Opportunities**:
- After Foundation: US1 and US2 can be developed in parallel by different developers
- US3 and US5 can be developed in parallel (both depend on US2)
- All models (T015-T020) can be created in parallel
- All validators (T021-T023) can be created in parallel
- All Platform 1 setup tasks (T002-T011) can run in parallel

### Within Each User Story

**User Story 1 (Registration)**:
1. Service methods first (T030-T034) - can be parallel for different providers
2. Guest migration logic (T035-T037)
3. UI components (T038-T047) - widgets (T039-T044) can be parallel
4. Account linking (T049-T051) - can be parallel
5. Navigation integration (T052-T053)

**User Story 2 (Login)**:
1. Service methods first (T056-T058) - can be parallel for different providers
2. Guest discard logic (T059)
3. UI components (T060-T068) - LoginScreen depends on widgets from US1
4. Account linking (T069)
5. Navigation integration (T070-T072)

**User Story 3 (Profile)**:
1. Service methods (T073-T075) - can be parallel
2. Profile UI (T076-T081)
3. Account Settings UI (T082-T085)
4. Navigation (T086-T087)

**User Story 4 (Delete Account)**:
1. Service method (T088-T089)
2. UI (T090-T094)
3. Data cleanup integration (T095-T098) - can be parallel

**User Story 5 (Logout)**:
1. Service method (T099)
2. UI (T100-T103)
3. Session management (T104-T105)

### Parallel Opportunities by User Story

**Phase 1 (Setup) - 7 parallel opportunities**:
```bash
# Run in parallel:
T002, T003  # iOS and Android Firebase setup
T006, T007, T008  # Platform-specific build configs
T009, T010, T011  # Platform-specific auth configs
```

**Phase 2 (Foundational) - 11 parallel opportunities**:
```bash
# All models in parallel:
T015, T016, T017, T018, T019, T020

# All validators in parallel:
T021, T022, T023

# Auth state methods in parallel:
T027, T028, T029
```

**Phase 3 (User Story 1) - 8 parallel opportunities**:
```bash
# Registration methods in parallel:
T030, T031, T032, T033, T034

# UI widgets in parallel:
T039, T040, T043, T044

# Account linking in parallel:
T049, T050
```

**Phase 4 (User Story 2) - 7 parallel opportunities**:
```bash
# Login methods in parallel:
T056, T056, T057, T058

# Social login buttons (already exist from US1):
T061, T062
```

**Phase 5 (User Story 3) - 3 parallel opportunities**:
```bash
# Profile management methods in parallel:
T073, T074, T075
```

**Phase 6 (User Story 4) - 4 parallel opportunities**:
```bash
# Data cleanup tasks in parallel:
T095, T096, T097, T098
```

**Phase 8 (Polish) - 11 parallel opportunities**:
```bash
# All polish tasks can run in parallel:
T106, T107, T108, T109, T110, T111, T112, T117, T118
```

---

## Implementation Strategy

### MVP First (P1 Stories Only)

**Goal**: Ship working authentication as fast as possible

1. Complete Phase 1: Setup (T001-T014) - ~2-3 hours (following quickstart.md)
2. Complete Phase 2: Foundational (T015-T029) - ~4-6 hours (models, validators, service skeleton)
3. Complete Phase 3: User Story 1 (T030-T053) - ~8-12 hours (registration all 3 providers + UI)
4. Complete Phase 4: User Story 2 (T056-T072) - ~6-8 hours (login all 3 providers + UI)
5. **STOP and VALIDATE**: Test registration and login flows end-to-end on iOS and Android
6. Deploy/demo if ready (MVP complete: users can register and login!)

**MVP Scope**: 71 tasks (T001-T072)  
**Estimated Time**: 20-29 hours for full P1 implementation

### Incremental Delivery

Add value in increments:

1. **Setup + Foundational** (T001-T029) → Foundation ready
2. **+ User Story 1** (T030-T053) → MVP! Users can register
3. **+ User Story 2** (T056-T072) → Users can register and login (P1 complete)
4. **+ User Story 3** (T073-T087) → Users can manage profiles (P2 partial)
5. **+ User Story 4** (T088-T098) → Users can delete accounts (P2 complete, AppStore ready!)
6. **+ User Story 5** (T099-T105) → Users can logout (P3 complete)
7. **+ Polish** (T106-T123) → Production ready

**AppStore Submission Checkpoint**: Complete through User Story 4 (T001-T098) + essential polish tasks (T106-T112, T118-T121)

### Parallel Team Strategy

With 2-3 developers working simultaneously:

**Week 1: Foundation**
- Team completes Setup (T001-T014) together
- Team completes Foundational (T015-T029) together

**Week 2: P1 Stories**
- Developer A: User Story 1 (T030-T053) - Registration
- Developer B: User Story 2 (T056-T072) - Login
- (Stories share widgets from US1, minimal conflicts)

**Week 3: P2 Stories**
- Developer A: User Story 3 (T073-T087) - Profile Management
- Developer B: User Story 4 (T088-T098) - Account Deletion
- Developer C: User Story 5 (T099-T105) - Logout (quick, can help with testing)

**Week 4: Polish & Testing**
- All developers: Phase 8 polish tasks (T106-T123) in parallel
- Integration testing, bug fixes, AppStore preparation

---

## Task Summary

- **Total Tasks**: 122 tasks
- **Setup Phase**: 14 tasks (T001-T014)
- **Foundational Phase**: 15 tasks (T015-T029)
- **User Story 1 (P1)**: 25 tasks (T030-T054)
- **User Story 2 (P1)**: 18 tasks (T055-T072)
- **User Story 3 (P2)**: 14 tasks (T073-T086)
- **User Story 4 (P2)**: 11 tasks (T087-T097)
- **User Story 5 (P3)**: 7 tasks (T098-T104)
- **Polish Phase**: 18 tasks (T105-T122)

**MVP Task Count** (P1 only): 72 tasks (T001-T072)  
**AppStore Ready Task Count** (P1 + P2): 97 tasks (T001-T097)  
**Full Feature Task Count**: 122 tasks

**Parallel Opportunities**: 51 tasks marked [P] can run in parallel (42% of total)

**Independent Test Criteria**:
- **US1**: Can register new account → logged in → guest data migrated ✅
- **US2**: Can login with credentials → logged in → main screen shown ✅
- **US3**: Can view/edit profile → changes saved → confirmation shown ✅
- **US4**: Can delete account → data removed → logged out ✅
- **US5**: Can logout → session cleared → login screen shown ✅

**Suggested MVP Scope**: User Stories 1 & 2 (71 tasks) - delivers complete registration and login functionality

---

## Notes

- **[P] tasks**: Different files, no dependencies within phase - can run in parallel
- **[Story] labels**: Map task to specific user story (US1-US5) for traceability
- **Tests excluded**: Not explicitly requested in specification, following constitution (no premature test infrastructure)
- **File path specificity**: Every implementation task includes exact file path
- **Incremental delivery**: Each user story independently completable and testable
- **Format compliance**: All tasks follow strict checklist format: `- [ ] [ID] [P?] [Story?] Description with path`
- **Commit strategy**: Commit after each task or logical group of parallel tasks
- **Checkpoint validation**: Stop at each phase checkpoint to validate story independence
- **Avoid conflicts**: Tasks within same story touching same file are sequential (no [P] marker)
