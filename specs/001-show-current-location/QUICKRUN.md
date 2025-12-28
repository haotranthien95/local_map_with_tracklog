# Quick Start: Running the Show Current Location Feature

## Prerequisites Verification

```bash
# Check Flutter version (need 3.5.4+)
flutter --version

# Check devices available
flutter devices

# Verify dependencies are installed
flutter pub get
```

## Running on iOS Simulator

```bash
# List available iOS simulators
xcrun simctl list devices

# Run on default iOS simulator
flutter run -d "iPhone 15"

# Or let Flutter choose
flutter run
```

### Setting Simulator Location (for testing)
1. Open Simulator
2. Features → Location → Custom Location...
3. Enter coordinates (e.g., 10.8231° N, 106.6297° E for Saigon)

## Running on Android Emulator

```bash
# List Android emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Run the app
flutter run -d emulator-5554
```

### Setting Emulator Location (for testing)
1. Open AVD Manager (Android Studio)
2. Click "..." (Extended Controls) in emulator
3. Location tab → Enter lat/long → Send

## Running on Physical Device

### iOS Device
```bash
# Connect device via USB
# Trust the computer on device when prompted

# List devices
flutter devices

# Run (will prompt for development team signing in Xcode if needed)
flutter run -d <device-id>
```

### Android Device
```bash
# Enable USB debugging on device (Settings > Developer Options)
# Connect device via USB

# List devices
flutter devices

# Run
flutter run -d <device-id>
```

## Testing Permission Scenarios

### Grant Permission
1. Launch app
2. Tap "Allow" on permission dialog
3. **Expected**: Blue marker at your location, "Your location" banner

### Deny Permission
1. Launch app
2. Tap "Don't Allow" on permission dialog
3. **Expected**: Red marker at Ho Chi Minh City, "Default location: Ho Chi Minh City" banner

### Change Permission
1. Open Settings > Privacy/Location > App > Change permission
2. Return to app, tap refresh button (top-right)
3. **Expected**: Marker and banner update accordingly

## Troubleshooting

### "No devices found"
- iOS: Open Xcode, launch a simulator
- Android: Open Android Studio, launch AVD Manager, start emulator

### "Location permission not requested"
- iOS: Check `ios/Runner/Info.plist` has `NSLocationWhenInUseUsageDescription`
- Android: Check `android/app/src/main/AndroidManifest.xml` has location permissions

### "Map tiles not loading"
- Check internet connection (OSM tiles require network)
- Try refresh button or restart app

### Build errors
```bash
# Clean build cache
flutter clean

# Reinstall dependencies
flutter pub get

# iOS: Update pods
cd ios && pod install && cd ..

# Rebuild
flutter run
```

## Performance Testing

Time from launch to location display should be ≤ 2 seconds.

```bash
# Run in profile mode for accurate performance measurement
flutter run --profile
```

## Hot Reload (for development)

While app is running, press `r` in terminal to hot reload changes without restarting.

## Full Restart

Press `R` (capital) in terminal to full restart the app.

## Logs

```bash
# View detailed logs
flutter logs

# Filter for specific tag
flutter logs | grep location
```

## Build for Release

### iOS
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode for archiving
```

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Common Test Commands

```bash
# Analyze code for issues
flutter analyze

# Run widget tests
flutter test

# Check device logs
flutter logs -d <device-id>
```

## Next Steps

After verifying the feature works:
1. See [TESTING.md](TESTING.md) for comprehensive manual test scenarios
2. See [IMPLEMENTATION.md](IMPLEMENTATION.md) for technical details
3. Ready to implement Feature 001-offline-map-tracks (track visualization and offline caching)
