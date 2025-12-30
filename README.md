# local_map_with_tracklog

A Flutter application for managing maps with track logs and user authentication.

## Features

### Authentication
- **Email/Password Registration and Login**: Traditional authentication with Firebase
- **Google Sign-In**: OAuth2 authentication via Google
- **Apple Sign-In**: OAuth2 authentication via Apple (iOS 13+)
- **Account Deletion with Provider Reauthentication**: Delete your account securely, even if you signed in with a social provider

### Account Deletion (Feature 004)

Users can permanently delete their accounts through the account settings screen. The deletion process includes:

#### For Social-Only Users (Google/Apple Sign-In)
- **Automatic Provider Detection**: System detects your sign-in method automatically
- **Provider Reauthentication**: You'll be prompted to sign in with your provider (Google or Apple) to verify your identity
- **Provider Fallback**: If your primary provider fails, the system will try alternative linked providers
- **Data Cleanup**: All local data (tracklogs, cache, tokens, preferences) is cleared after account deletion

#### For Email/Password Users
- **Password Verification**: Enter your current password to verify your identity
- **Hybrid Support**: If you have both email/password and social providers linked, the system will attempt social provider fallback if password verification fails

#### For Hybrid Users (Email/Password + Social)
- **Primary Method**: Password verification is attempted first
- **Automatic Fallback**: If password fails, linked social providers are tried automatically
- **Seamless Experience**: No manual intervention needed for fallback

#### Error Handling
- **Network Errors**: Actionable messages guide you to check your connection and retry
- **Provider Revoked**: Clear instructions to re-enable app access in provider settings
- **Cancellation**: Cancel at any point - your account remains active
- **Partial Cleanup**: If some local data cleanup fails, deletion proceeds with logging

#### User Experience
1. Navigate to **Account Settings**
2. Tap **Delete Account** (red button in Danger Zone)
3. Confirm deletion in dialog
4. System detects your sign-in method
5. Verify your identity (password or provider sign-in)
6. Account is deleted, local data cleared
7. Redirected to sign-in screen

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Technical Documentation

For detailed technical specifications, see:
- **Feature 004 Specification**: `specs/004-delete-account-nopass/spec.md`
- **Implementation Plan**: `specs/004-delete-account-nopass/plan.md`
- **API Contracts**: `specs/004-delete-account-nopass/contracts/`
- **Quickstart Guide**: `specs/004-delete-account-nopass/quickstart.md`
