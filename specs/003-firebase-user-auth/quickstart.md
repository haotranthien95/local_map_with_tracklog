# Firebase Authentication Quickstart Guide

**Feature**: Firebase User Authentication (003-firebase-user-auth)  
**Target**: Flutter developers setting up authentication for the first time  
**Time**: ~30-45 minutes for complete setup

---

## Prerequisites

- Flutter 3.5.4+ installed
- Xcode 14+ (for iOS)
- Android Studio with Android SDK 33+ (for Android)
- Google account (for Firebase Console)
- Apple Developer account (for Apple Sign In - paid)
- Google Cloud Console access (for Google Sign-In)

---

## Phase 1: Firebase Project Setup

### 1.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `local-map-tracklog` (or your preferred name)
4. **Disable** Google Analytics (not needed for MVP)
5. Click **"Create project"**
6. Wait for project creation (~30 seconds)

### 1.2 Enable Authentication Methods

1. In Firebase Console, select your project
2. Navigate to **Build** → **Authentication**
3. Click **"Get started"**
4. Go to **"Sign-in method"** tab
5. Enable the following providers:
   - **Email/Password**: Click, toggle "Enable", Save
   - **Google**: Click, toggle "Enable", Save (note: iOS/Android config needed)
   - **Apple**: Click, toggle "Enable", Save (requires Apple Developer setup)

### 1.3 Configure Email Settings (Optional)

1. In **Authentication** → **Templates** tab
2. Customize **Email verification** template (optional)
3. Customize **Password reset** template (optional)
4. Set sender name to your app name

---

## Phase 2: iOS Configuration

### 2.1 Register iOS App in Firebase

1. In Firebase Console, click **iOS icon** (⊕ Add app)
2. Enter **iOS bundle ID**: Find in `ios/Runner.xcodeproj/project.pbxproj`
   - Search for `PRODUCT_BUNDLE_IDENTIFIER`
   - Example: `com.example.localMapWithTracklog`
3. Enter **App nickname**: `Local Map iOS` (optional)
4. **Skip** App Store ID for now
5. Click **"Register app"**

### 2.2 Download GoogleService-Info.plist

1. Click **"Download GoogleService-Info.plist"**
2. Save file to your project root temporarily
3. Open Xcode: `open ios/Runner.xcworkspace`
4. In Xcode, **right-click** `Runner` folder (left sidebar)
5. Select **"Add Files to Runner..."**
6. Navigate to downloaded `GoogleService-Info.plist`
7. **IMPORTANT**: Check **"Copy items if needed"**
8. Ensure **"Runner" target** is selected
9. Click **"Add"**
10. Verify file appears under `Runner/Runner` folder in Xcode

### 2.3 Update iOS Podfile

**Location**: `ios/Podfile`

Add at the top (after platform declaration):

```ruby
platform :ios, '15.0'

# Add this line
pod 'Firebase/Auth'
```

Run pod install:

```bash
cd ios
pod install
cd ..
```

### 2.4 Configure Google Sign-In for iOS

1. In `GoogleService-Info.plist`, find `REVERSED_CLIENT_ID` value
   - Example: `com.googleusercontent.apps.123456789-abcdefg`
2. Open `ios/Runner/Info.plist` in Xcode or text editor
3. Add URL scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Paste your REVERSED_CLIENT_ID here -->
      <string>com.googleusercontent.apps.123456789-abcdefg</string>
    </array>
  </dict>
</array>
```

### 2.5 Configure Apple Sign In

1. In Xcode, select **Runner** project (top of sidebar)
2. Select **Runner** target
3. Go to **"Signing & Capabilities"** tab
4. Click **"+ Capability"**
5. Add **"Sign in with Apple"** capability
6. Ensure your **Team** is selected in Signing section

**In Apple Developer Portal**:

1. Go to [Apple Developer](https://developer.apple.com/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Identifiers** → Your App ID
4. Enable **"Sign In with Apple"** capability
5. Click **"Save"**

### 2.6 Update iOS Minimum Version

**Location**: `ios/Podfile`

Ensure minimum iOS version is 15.0:

```ruby
platform :ios, '15.0'
```

---

## Phase 3: Android Configuration

### 3.1 Register Android App in Firebase

1. In Firebase Console, click **Android icon** (⊕ Add app)
2. Enter **Android package name**: Find in `android/app/build.gradle`
   - Look for `applicationId "com.example.local_map_with_tracklog"`
3. Enter **App nickname**: `Local Map Android` (optional)
4. **Leave SHA-1 blank** for now (will add later for Google Sign-In)
5. Click **"Register app"**

### 3.2 Download google-services.json

1. Click **"Download google-services.json"**
2. Move file to `android/app/` directory
   
   ```bash
   mv ~/Downloads/google-services.json android/app/
   ```

3. Verify location: `android/app/google-services.json`

### 3.3 Update Android Build Files

**1. Project-level build.gradle** (`android/build.gradle`):

```gradle
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.10'
        
        // Add this line
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**2. App-level build.gradle** (`android/app/build.gradle`):

At the **bottom** of the file, add:

```gradle
apply plugin: 'com.google.gms.google-services'
```

Update minSdkVersion if needed:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Changed from 19 if lower
        targetSdkVersion 33
    }
}
```

### 3.4 Get SHA-1 Certificate for Google Sign-In

**Debug SHA-1** (for development):

```bash
cd android
./gradlew signingReport
```

Look for **SHA-1** under **debug** variant (e.g., `AA:BB:CC:DD:...`)

**Add SHA-1 to Firebase**:

1. Firebase Console → Project Settings
2. Scroll to **"Your apps"** → Android app
3. Click **"Add fingerprint"**
4. Paste SHA-1 certificate
5. Click **"Save"**
6. **Download new** `google-services.json` and replace in `android/app/`

**Release SHA-1** (for production later):

```bash
keytool -list -v -keystore <path-to-keystore> -alias <alias-name>
```

Add release SHA-1 to Firebase similarly.

### 3.5 Configure ProGuard (Optional for Release)

**Location**: `android/app/proguard-rules.pro`

Add Firebase rules:

```proguard
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
```

---

## Phase 4: Flutter Dependencies

### 4.1 Update pubspec.yaml

**Location**: `pubspec.yaml`

Add dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  
  # Social Login
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.2
  
  # Storage
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.3.2
```

### 4.2 Install Dependencies

```bash
flutter pub get
```

### 4.3 Initialize Firebase in App

**Location**: `lib/main.dart`

Update to initialize Firebase:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Map with Tracklog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Your existing home screen
    );
  }
}
```

---

## Phase 5: Verification

### 5.1 Test iOS Build

```bash
flutter run -d ios
```

**Expected**: App launches without Firebase errors in console

**Check logs for**:
- ✅ `[Firebase] Firebase configured successfully`
- ❌ `[Firebase] GoogleService-Info.plist not found` → Repeat Step 2.2

### 5.2 Test Android Build

```bash
flutter run -d android
```

**Expected**: App launches without Firebase errors

**Check logs for**:
- ✅ `FirebaseApp initialization successful`
- ❌ `google-services.json missing` → Repeat Step 3.2

### 5.3 Test Firebase Connection

Add temporary test code in `main.dart`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Test Firebase connection
  print('Firebase initialized: ${Firebase.apps.length} apps');
  
  runApp(const MyApp());
}
```

**Expected output**: `Firebase initialized: 1 apps`

---

## Phase 6: OAuth Client Configuration

### 6.1 Google Sign-In OAuth Setup

**Required for both iOS and Android Google Sign-In**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project (same name)
3. Navigate to **APIs & Services** → **Credentials**
4. Click **"Create Credentials"** → **"OAuth client ID"**

**For iOS**:
- Application type: **iOS**
- Name: `Local Map iOS`
- Bundle ID: Your iOS bundle ID from Step 2.1
- Click **"Create"**

**For Android**:
- Application type: **Android**
- Name: `Local Map Android`
- Package name: Your Android package name from Step 3.1
- SHA-1: Your debug SHA-1 from Step 3.4
- Click **"Create"**

5. Note the **Client IDs** (already configured in Firebase)

### 6.2 Apple Sign In Configuration

**Apple Developer Portal**:

1. Go to [Apple Developer](https://developer.apple.com/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select **Keys**
4. Click **"+"** to create new key
5. Enter key name: `Apple Sign In Key`
6. Enable **"Sign In with Apple"**
7. Click **"Configure"** → Select your App ID
8. Click **"Save"** → **"Continue"** → **"Register"**
9. **Download** the `.p8` key file (only shown once!)
10. Note **Key ID** and **Team ID**

**Firebase Configuration**:

1. Firebase Console → Authentication → Sign-in method
2. Click **"Apple"**
3. In OAuth code flow configuration:
   - **Service ID**: Create in Apple Developer (Identifiers → Services IDs)
   - **Apple Team ID**: Found in Apple Developer membership
   - **Key ID**: From step 9 above
   - **Private Key**: Paste content from `.p8` file
4. Click **"Save"**

---

## Phase 7: Common Issues & Troubleshooting

### Issue: "GoogleService-Info.plist not found" (iOS)

**Solution**:
- Verify file is in `ios/Runner/` directory
- Check Xcode → Runner → GoogleService-Info.plist exists
- Re-add file using Xcode (Step 2.2) with "Copy items" checked

### Issue: "google-services.json not found" (Android)

**Solution**:
- Verify file is in `android/app/` directory (not `android/`)
- Check `android/app/google-services.json` exists
- Run `flutter clean && flutter pub get`

### Issue: Google Sign-In fails with "DEVELOPER_ERROR"

**Solution**:
- Verify SHA-1 certificate added to Firebase
- Download new `google-services.json` after adding SHA-1
- Clean and rebuild: `flutter clean && flutter run`

### Issue: Apple Sign In not available

**Solution**:
- Verify capability added in Xcode (Step 2.5)
- Check Apple Developer Portal has "Sign In with Apple" enabled
- Ensure using real device (Apple Sign In doesn't work on simulator)

### Issue: "MissingPluginException" for Firebase

**Solution**:
- Run `flutter clean`
- Delete `ios/Pods`, `ios/Podfile.lock`, `build/` folders
- Run `cd ios && pod install && cd ..`
- Run `flutter pub get`
- Restart IDE

### Issue: Build fails with "Minimum iOS version"

**Solution**:
- Update `ios/Podfile`: `platform :ios, '15.0'`
- Run `cd ios && pod update && cd ..`

---

## Phase 8: Next Steps

After completing this setup:

1. **Implement AuthenticationService** (`lib/services/authentication_service.dart`)
   - See `contracts/authentication_service.md` for interface
2. **Create User model** (`lib/models/user.dart`)
   - See `data-model.md` for structure
3. **Build Authentication UI**:
   - Login screen (`lib/screens/login_screen.dart`)
   - Registration screen (`lib/screens/register_screen.dart`)
   - Profile screen (`lib/screens/profile_screen.dart`)
4. **Test Authentication Flow**:
   - Email/password registration
   - Email/password login
   - Google Sign-In
   - Apple Sign In
   - Password reset
   - Account deletion

---

## Reference Links

- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Auth Package](https://pub.dev/packages/firebase_auth)
- [Google Sign-In Plugin](https://pub.dev/packages/google_sign_in)
- [Apple Sign In Plugin](https://pub.dev/packages/sign_in_with_apple)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Apple Developer Portal](https://developer.apple.com/)

---

## Checklist

Use this to track setup progress:

- [ ] Firebase project created
- [ ] Email/Password authentication enabled
- [ ] Google authentication enabled
- [ ] Apple authentication enabled
- [ ] iOS app registered in Firebase
- [ ] GoogleService-Info.plist added to Xcode
- [ ] iOS Podfile updated and installed
- [ ] Google Sign-In URL scheme added (iOS)
- [ ] Apple Sign In capability added (iOS)
- [ ] Android app registered in Firebase
- [ ] google-services.json added to android/app/
- [ ] Android build.gradle files updated
- [ ] SHA-1 certificate added to Firebase
- [ ] Flutter dependencies added to pubspec.yaml
- [ ] Firebase initialized in main.dart
- [ ] iOS build verified
- [ ] Android build verified
- [ ] Google OAuth client IDs created
- [ ] Apple Sign In key created and configured

**Estimated Time**: 30-45 minutes  
**Difficulty**: Intermediate  
**Prerequisites Met**: ✅ Ready to implement authentication features
