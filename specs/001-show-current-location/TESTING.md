# Testing Guide: Show Current Location Feature

## Prerequisites
- Flutter 3.5.4+ installed
- iOS Simulator or Android Emulator configured
- Physical devices (optional, recommended for real GPS testing)

## Test Scenarios

### T033: iOS Testing - Permission Scenarios

#### Test 1: First Launch - Permission Granted
1. Launch app on iOS simulator/device (fresh install)
2. App requests location permission
3. Tap "Allow While Using App"
4. **Expected**: Blue marker at current location (or simulator location), banner shows "Your location"
5. **Performance**: Location displays within 2 seconds

#### Test 2: First Launch - Permission Denied
1. Launch app on iOS simulator/device (fresh install)
2. App requests location permission
3. Tap "Don't Allow"
4. **Expected**: Red marker at Ho Chi Minh City (10.7769, 106.7009), banner shows "Default location: Ho Chi Minh City"
5. **Performance**: Default location displays within 2 seconds

#### Test 3: Permission Change - Denied to Granted
1. Settings > Privacy > Location Services > [App Name] > "Never"
2. Launch app
3. **Expected**: Red marker at default location
4. Go to Settings > Location Services > [App Name] > "While Using App"
5. Return to app and tap refresh button
6. **Expected**: Blue marker at current location, banner updates to "Your location"

### T034: Android Testing - Permission Scenarios

#### Test 1: First Launch - Permission Granted
1. Launch app on Android emulator/device (fresh install)
2. App requests location permission
3. Tap "While using the app"
4. **Expected**: Blue marker at current location, banner shows "Your location"
5. **Performance**: Location displays within 2 seconds

#### Test 2: First Launch - Permission Denied
1. Launch app on Android emulator/device (fresh install)
2. App requests location permission
3. Tap "Don't allow"
4. **Expected**: Red marker at Ho Chi Minh City, banner shows "Default location: Ho Chi Minh City"
5. **Performance**: Default location displays within 2 seconds

#### Test 3: Permission Change via Settings
1. Settings > Apps > [App Name] > Permissions > Location > "Don't allow"
2. Launch app
3. **Expected**: Red marker at default location
4. Settings > Location > "Allow only while using the app"
5. Return to app and tap refresh button
6. **Expected**: Blue marker at current location

### T035: GPS Off Scenario (Airplane Mode)

#### iOS Test
1. Launch app with location permission granted
2. Wait for blue marker to appear (current location loaded)
3. Enable Airplane Mode (Settings or Control Center)
4. Tap refresh button
5. **Expected**: Blue marker at last known location, banner shows "Last known location"
6. If no last known location: Red marker at default, banner shows "Default location: Ho Chi Minh City"

#### Android Test
1. Launch app with location permission granted
2. Wait for blue marker to appear
3. Enable Airplane Mode (swipe down > tap airplane icon)
4. Tap refresh button
5. **Expected**: Blue marker at last known location, banner shows "Last known location"
6. If no last known: Red marker at default location

### T036: Rapid Permission Toggle

#### Test Sequence
1. Launch app with location permission granted
2. **Expected**: Blue marker at current location
3. Go to Settings > Location > Deny permission
4. Return to app, tap refresh
5. **Expected**: Red marker at default location
6. Go to Settings > Location > Grant permission
7. Return to app, tap refresh
8. **Expected**: Blue marker at current location
9. Repeat steps 3-8 three times quickly
10. **Expected**: App remains stable, no crashes, correct marker/banner each time

#### Edge Case: Toggle During Loading
1. Launch app (or clear app data)
2. Immediately go to Settings while loading indicator shows
3. Toggle location permission
4. Return to app
5. **Expected**: App handles state change gracefully, no crash, shows appropriate location

### T037: Performance Validation

#### 2-Second Target Test
1. Clear app data/reinstall
2. Start timer when launching app
3. Measure time until marker and banner appear
4. **Target**: ≤ 2 seconds from launch to location display
5. Test on both iOS and Android
6. Test with different network conditions (WiFi, cellular, offline)

#### Performance Checklist
- [ ] Initial launch: Location displays in ≤ 2 seconds
- [ ] Refresh button: Location updates in ≤ 2 seconds
- [ ] Permission change: Location updates in ≤ 2 seconds after returning to app
- [ ] No visible lag or janky animations
- [ ] Loading indicator shows immediately on load/refresh

## Test Matrix

| Scenario | iOS | Android | Expected Result | Pass/Fail |
|----------|-----|---------|-----------------|-----------|
| First launch + permission granted | [ ] | [ ] | Blue marker, "Your location" | [ ] |
| First launch + permission denied | [ ] | [ ] | Red marker, "Default location" | [ ] |
| GPS off + permission granted | [ ] | [ ] | Blue marker, "Last known location" | [ ] |
| GPS off + no last known | [ ] | [ ] | Red marker, "Default location" | [ ] |
| Permission denied → granted | [ ] | [ ] | Marker updates correctly | [ ] |
| Permission granted → denied | [ ] | [ ] | Marker updates correctly | [ ] |
| Rapid permission toggles | [ ] | [ ] | No crashes, stable behavior | [ ] |
| Performance (≤ 2 sec) | [ ] | [ ] | Meets target | [ ] |

## Known Issues / Notes

- **Simulator Limitations**: iOS/Android simulators may not perfectly replicate GPS behavior. Physical device testing recommended for comprehensive validation.
- **Location Service Availability**: Some emulators require manual location spoofing via developer tools.
- **Permission Prompt Timing**: System permission dialog may add 1-2 seconds to first launch time; this is acceptable as per spec.

## Running Tests

```bash
# iOS Simulator
flutter run -d "iPhone 15"

# Android Emulator
flutter run -d emulator-5554

# Physical Device
flutter devices  # List connected devices
flutter run -d <device-id>
```

## Test Completion Criteria

All scenarios in the test matrix must pass on both iOS and Android before marking Phase 4 complete.
