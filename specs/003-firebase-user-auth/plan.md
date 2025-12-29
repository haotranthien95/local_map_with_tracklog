# Implementation Plan: Firebase User Authentication & Account Management

**Branch**: `003-firebase-user-auth` | **Date**: 2025-12-29 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/003-firebase-user-auth/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implement Firebase-based user authentication system with email/password, Google Sign-In, and Apple Sign In to meet AppStore compliance requirements. Users can explore app features without authentication (guest mode) but must create an account to save tracklogs or sync data. Guest data automatically migrates to new accounts. Accounts can be linked across authentication providers using the same email address. Users can view/edit their profile and permanently delete their account per GDPR/CCPA requirements.

## Technical Context

**Language/Version**: Flutter 3.5.4+, Dart 3.5.4+  
**Primary Dependencies**: firebase_core, firebase_auth, google_sign_in, sign_in_with_apple  
**Storage**: Firebase Authentication (cloud), local secure storage for tokens (flutter_secure_storage), shared_preferences for guest data migration tracking  
**Testing**: flutter_test for widget tests, mockito for mocking Firebase services  
**Target Platform**: iOS 15+ and Android (mobile platforms)  
**Project Type**: Mobile (Flutter) - feature-based organization under lib/  
**Performance Goals**: <3 seconds for login/registration, <1 second for token validation, <5 seconds for social login flow  
**Constraints**: Must work offline for already-authenticated users, graceful degradation for network failures, secure token storage (iOS Keychain/Android Keystore)  
**Scale/Scope**: Single-user authentication, ~5 screens (login, register, profile, account settings), 3 authentication providers

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Initial Evaluation (Before Research & Design)

Verify alignment with constitution principles:

- **MVP-First Development**: ✅ PASS - Feature delivers working end-to-end authentication in first iteration. P1 stories (registration, login) provide complete functional flow. Users can create accounts, sign in, and access their data.

- **Minimal Viable Features**: ✅ PASS - Scope is minimal: email/password + 2 social providers as explicitly required for AppStore. Profile editing is basic (display name, email, password). No extra features like avatars, usernames, or social features. Account deletion meets compliance requirements without additional complexity.

- **Independent User Stories**: ✅ PASS - User stories are prioritized (P1-P3) and independently implementable. P1 (registration/login) can ship without P2 (profile editing) or P3 (logout). Each story delivers standalone value. Guest mode allows immediate app exploration without blocking on authentication.

- **Progressive Enhancement**: ✅ PASS - Starts with core authentication using Firebase (battle-tested platform service). Email/password is simplest method implemented first. Social login builds on that foundation. No custom auth server, no complex patterns. Uses Flutter's standard StatefulWidget for UI. Complexity (account linking, data migration) is justified by explicit requirements, not premature optimization.

- **Maintainability**: ✅ PASS - Simple service-based architecture following existing project pattern (see lib/services/). Single AuthenticationService class handles Firebase operations. No repository pattern, no complex state management initially. Direct Firebase SDK calls. Complexity is justified only where required: secure token storage (platform requirement), account linking (explicit feature requirement), guest data migration (explicit feature requirement).

**Complexity Justification**: 

1. **Firebase Authentication SDK** - Required dependency, industry standard, eliminates need for custom auth backend/security
2. **Google Sign-In SDK + Apple Sign In** - Explicit requirement for AppStore compliance and user convenience
3. **Secure Storage (flutter_secure_storage)** - Security requirement for OAuth tokens, platform best practice
4. **Account Linking Logic** - Explicit requirement from clarifications (automatic linking when same email used across providers)
5. **Guest Data Migration** - Explicit requirement from clarifications (preserve user work when upgrading from guest to authenticated)

All complexity directly maps to explicit requirements. No speculative features, no premature abstractions.

### Post-Design Re-Evaluation (After Phase 1)

**Verification Date**: 2025-12-29  
**Artifacts Reviewed**: research.md, data-model.md, contracts/authentication_service.md, quickstart.md, Project Structure

**Re-evaluation Results**:

- **MVP-First Development**: ✅ STILL PASS
  - Design maintains MVP focus with concrete implementation plan
  - authentication_service.md contract defines 18 methods covering all P1 requirements
  - quickstart.md provides complete Firebase setup path (30-45 min)
  - No scope creep detected: sticks to registration, login, profile, deletion
  - User can complete full workflow: register → verify email (non-blocking) → sign in → use app

- **Minimal Viable Features**: ✅ STILL PASS
  - Data model defines only 3 primary entities (User Account, Authentication Session, User Profile)
  - Service contract includes only required methods, no "nice-to-have" features
  - Profile editing limited to displayName and email (not photoUrl, bio, preferences beyond migration flags)
  - No social features (friend lists, activity feeds, etc.)
  - No advanced auth (MFA, biometrics) unless explicitly needed later

- **Independent User Stories**: ✅ STILL PASS
  - Project structure shows clear feature isolation: lib/features/auth/ is self-contained
  - authentication_service.dart can be implemented independently
  - UI screens (login, register, profile) have no dependencies on each other
  - Guest mode preserved: users can skip authentication entirely
  - P1 (registration/login) implementable without P2 (profile editing) or P3 (logout)

- **Progressive Enhancement**: ✅ STILL PASS
  - Design starts with Firebase SDK (platform service, not custom implementation)
  - Email/password authentication is baseline, social login builds on it
  - No premature optimization: uses shared_preferences for local storage (simple), only secure storage for sensitive tokens
  - No complex state management introduced (will use StatefulWidget)
  - Account linking and guest migration deferred to background operations (non-blocking)
  - Error handling follows standard try-catch patterns, no elaborate error framework

- **Maintainability**: ✅ STILL PASS
  - Service-based architecture matches existing project pattern (location_service, tile_cache_service, etc.)
  - Single AuthenticationService class for all auth operations (no fragmentation)
  - Clear separation of concerns: models/ (data), services/ (logic), screens/ (UI), widgets/ (components)
  - Data model is simple: 3 entities with clear relationships, no complex nested structures
  - Contract documentation is extensive but implementation will be straightforward (Firebase SDK wrapping)
  - Testing strategy deferred until implementation (no premature test infrastructure)
  - Total new files: ~18 files (reasonable for a complete authentication feature)

**Design Concerns Addressed**:

1. ✅ **No Over-Engineering**: authentication_service.md defines 18 methods but these directly map to user requirements (register 3 ways, sign in 3 ways, profile ops, session ops, linking). No speculative methods.

2. ✅ **No Architectural Complexity**: Sticking to service pattern, no repositories, no CQRS, no event sourcing. Direct Firebase SDK calls wrapped in service methods.

3. ✅ **Justified Dependencies**: All 6 dependencies have clear justification (firebase_core/auth for backend, google_sign_in/sign_in_with_apple for AppStore requirement, flutter_secure_storage for security, shared_preferences for simple local data).

4. ✅ **Incremental Delivery**: Project structure shows feature can be built incrementally:
   - Phase A: Models + authentication_service skeleton
   - Phase B: Email/password auth (login_screen, register_screen)
   - Phase C: Social login buttons
   - Phase D: Profile management
   - Phase E: Guest migration background logic

**Final Verdict**: ✅ **CONSTITUTION ALIGNMENT MAINTAINED**

Design does not introduce unjustified complexity. All design decisions trace back to explicit requirements in spec.md or AppStore/security best practices. Feature remains MVP-focused with clear delivery path.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

**Structure Type**: Flutter mobile application (iOS + Android) - single project

```text
lib/
├── main.dart                          # Firebase initialization, app entry point
├── models/                            # Data models
│   ├── user.dart                     # User entity (userId, email, displayName, authProvider)
│   ├── authentication_session.dart   # Session tokens, expiry, state
│   ├── user_profile.dart             # Display name, preferences, migration flags
│   ├── guest_data_tracker.dart       # Guest mode data tracking
│   └── auth_result.dart              # Response wrapper (success, error, user)
├── services/                          # Business logic services
│   ├── authentication_service.dart   # NEW: Core authentication operations
│   ├── token_storage_service.dart    # NEW: Secure token storage (flutter_secure_storage)
│   ├── guest_migration_service.dart  # NEW: Guest data migration logic
│   ├── location_service.dart         # EXISTING: Location tracking
│   ├── tile_cache_service.dart       # EXISTING: Map tile caching
│   ├── track_parser_service.dart     # EXISTING: Parse tracklog files
│   ├── tracklog_storage_service.dart # EXISTING: Tracklog persistence
│   └── file_picker_service.dart      # EXISTING: File picker operations
├── screens/                           # UI screens
│   ├── login_screen.dart             # NEW: Email/password + social login
│   ├── register_screen.dart          # NEW: User registration
│   ├── profile_screen.dart           # NEW: View/edit user profile
│   ├── account_settings_screen.dart  # NEW: Delete account, change password
│   ├── home_screen.dart              # EXISTING: Main navigation
│   ├── map_screen.dart               # EXISTING: Map display
│   ├── dashboard_screen.dart         # EXISTING: Dashboard
│   ├── settings_screen.dart          # EXISTING: App settings
│   └── tracklog_list_screen.dart     # EXISTING: Tracklog management
├── widgets/                           # Reusable UI components
│   ├── auth_button.dart              # NEW: Styled auth buttons (email, Google, Apple)
│   ├── auth_text_field.dart          # NEW: Email/password input fields
│   ├── social_login_buttons.dart     # NEW: Google/Apple sign-in buttons
│   ├── loading_overlay.dart          # NEW: Loading indicator during auth
│   ├── map_view.dart                 # EXISTING: Map widget
│   └── tracklog_dialogs.dart         # EXISTING: Tracklog dialogs
└── features/                          # Feature-specific code
    ├── auth/                          # NEW: Authentication feature
    │   ├── providers/                # State management for auth
    │   │   └── auth_provider.dart    # Auth state provider
    │   ├── validators/               # Input validation
    │   │   ├── email_validator.dart
    │   │   └── password_validator.dart
    │   └── constants/                # Auth constants
    │       └── auth_constants.dart   # Error messages, validation rules
    └── show_current_location/         # EXISTING: Location feature

test/
├── models/                            # Model unit tests
│   └── user_test.dart                # NEW: User model tests
├── services/                          # Service unit tests
│   ├── authentication_service_test.dart  # NEW: Auth service tests
│   └── guest_migration_service_test.dart # NEW: Migration tests
├── screens/                           # Screen widget tests
│   ├── login_screen_test.dart        # NEW: Login screen tests
│   └── register_screen_test.dart     # NEW: Registration tests
└── fixtures/                          # EXISTING: Test fixtures

android/
├── app/
│   ├── google-services.json          # NEW: Firebase Android config
│   └── build.gradle                  # MODIFIED: Add Firebase dependencies
└── build.gradle                       # MODIFIED: Add Google services plugin

ios/
├── Runner/
│   ├── GoogleService-Info.plist      # NEW: Firebase iOS config
│   └── Info.plist                    # MODIFIED: Add URL schemes for Google Sign-In
└── Podfile                            # MODIFIED: Add Firebase pods
```

**Structure Decision**: Flutter mobile application following feature-based organization. New authentication feature integrates with existing project structure under `lib/` with separation of concerns: models (data), services (business logic), screens (UI), widgets (reusable components), features (feature-specific code). Test structure mirrors lib/ directory for easy navigation. Platform-specific Firebase configuration added to android/ and ios/ directories.

**Integration Points**:
- `authentication_service.dart` called by login/register/profile screens
- `guest_migration_service.dart` integrates with existing `tracklog_storage_service.dart`
- `home_screen.dart` modified to check auth state and redirect to login if needed
- `token_storage_service.dart` uses platform secure storage (iOS Keychain, Android Keystore)

**New Files Count**: ~17 new files (3 models, 3 services, 4 screens, 4 widgets, 3 validators)

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

**Status**: ✅ No violations - table not needed

All complexity in this feature has been justified in the Constitution Check section. No unjustified patterns or dependencies introduced.

---

## Planning Completion Summary

**Phase Status**:
- ✅ Phase 0 (Research): Complete
- ✅ Phase 1 (Design & Contracts): Complete
- ⏳ Phase 2 (Task Breakdown): Run `/speckit.tasks` to generate tasks.md

**Generated Artifacts**:
1. ✅ [research.md](research.md) - 400+ lines, 11 research areas, technology stack decisions
2. ✅ [data-model.md](data-model.md) - 384 lines, 3 primary entities, relationships, flows
3. ✅ [contracts/authentication_service.md](contracts/authentication_service.md) - Complete API contract with 18 methods
4. ✅ [quickstart.md](quickstart.md) - Firebase setup guide (30-45 min), iOS/Android configuration
5. ✅ Project Structure defined in this file
6. ✅ Constitution Check re-evaluated and passed
7. ✅ Agent context updated (.github/agents/copilot-instructions.md)

**Next Steps**:
1. Run `/speckit.tasks` to break down user stories into implementation tasks
2. Follow tasks.md to implement authentication feature
3. Use quickstart.md for Firebase setup
4. Reference contracts/authentication_service.md for service implementation
5. Refer to data-model.md for entity structures

**Branch**: 003-firebase-user-auth  
**Spec Location**: /Users/tranhao/Desktop/Working/PROJ/local_map_with_tracklog/specs/003-firebase-user-auth/  
**Ready for Implementation**: ✅ Yes - All design artifacts complete
