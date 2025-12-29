# Quickstart Guide: Bottom Navigation and Live Location Tracking

**Feature**: 002-navigation-location-ui  
**Date**: December 29, 2025  
**Branch**: `002-navigation-location-ui`

---

## Overview

This guide provides step-by-step instructions for developing and testing the bottom navigation and live location tracking feature. Follow these instructions to set up your environment, implement the feature, and verify functionality.

---

## Prerequisites

### Required Tools
- Flutter SDK 3.5.4 or higher
- Dart SDK 3.5.4 or higher
- Xcode (for iOS development)
- Android Studio or Android SDK (for Android development)
- Physical device or simulator with GPS capability

### Verify Installation
```bash
flutter --version
flutter doctor
```

Expected output: All required tools installed and configured

---

## Development Setup

### 1. Check Out Feature Branch

```bash
cd /path/to/local_map_with_tracklog
git checkout 002-navigation-location-ui
flutter pub get
```

### 2. Platform-Specific Configuration

#### iOS Setup

**Add location permissions to Info.plist**:

File: `ios/Runner/Info.plist`

Add before closing `</dict>` tag:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to display your position on the map and help you navigate.</string>
```

**Open iOS project**:
```bash
open ios/Runner.xcworkspace
```

#### Android Setup

**Add location permissions to AndroidManifest.xml**:

File: `android/app/src/main/AndroidManifest.xml`

Add inside `<manifest>` tag:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 3. Verify Dependencies

Check `pubspec.yaml` includes:
```yaml
dependencies:
  geolocator: ^10.1.0
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
```

Run:
```bash
flutter pub get
flutter pub outdated
```

---

## Implementation Order

Follow this sequence for MVP-first development:

### Phase 1: P1 - Bottom Navigation Structure (Independent)
1. Rename `lib/screens/home_screen.dart` → `lib/screens/map_screen.dart`
2. Create `lib/screens/dashboard_screen.dart` (placeholder)
3. Create `lib/screens/settings_screen.dart` (placeholder)
4. Create new `lib/screens/home_screen.dart` with BottomNavigationBar
5. Update `lib/main.dart` to use new HomeScreen

**Test checkpoint**: App launches, can switch between 3 tabs, map screen shows existing functionality

### Phase 2: P1 - Location Tracking Service (Independent)
1. Create `lib/models/device_location.dart`
2. Create `lib/services/location_service.dart`
3. Test permission handling on both platforms

**Test checkpoint**: Can request permissions, receive location updates in debug console

### Phase 3: P1 - Location Indicator (Depends on Phase 2)
1. Create `lib/widgets/location_indicator.dart`
2. Update `lib/widgets/map_view.dart` to accept location parameter
3. Add MarkerLayer for location indicator
4. Update `lib/screens/map_screen.dart` to integrate LocationService

**Test checkpoint**: Blue dot appears on map at current location, turns gray when GPS lost

### Phase 4: P2 - Center on Location Button (Depends on Phase 3)
1. Add `centerOnLocation()` method to MapViewState
2. Add FAB in MapScreen for centering
3. Wire up button to MapController

**Test checkpoint**: Tapping button centers map on current location

### Phase 5: P3 - Map Info Display (Independent)
1. Create `lib/models/map_information.dart`
2. Add info overlay to MapView widget
3. Wire up onMapPositionChanged callback

**Test checkpoint**: Info display shows and updates in real-time

---

## Testing Guide

### Manual Testing Procedures

#### Test 1: Bottom Navigation
**Steps**:
1. Launch app
2. Observe bottom navigation bar with 3 tabs
3. Tap Dashboard tab → See placeholder screen
4. Tap Map tab → See map with existing functionality
5. Tap Settings tab → See placeholder screen
6. Switch tabs multiple times rapidly
7. On Map tab, pan and zoom map
8. Switch to Dashboard and back to Map

**Expected Results**:
- ✓ All 3 tabs visible and labeled correctly
- ✓ Correct screen displays for each tab
- ✓ Tab switching is instant (<100ms perceived)
- ✓ Map state preserved (position, zoom, loaded tracks)
- ✓ No crashes or freezes

---

#### Test 2: Location Permissions (iOS)
**Steps**:
1. Uninstall app
2. Reinstall and launch
3. Navigate to Map tab
4. Observe permission dialog
5. Tap "Allow While Using App"
6. Observe location indicator

**Expected Results**:
- ✓ Permission dialog appears with correct message
- ✓ Dialog shows app name and icon
- ✓ After granting: Blue dot appears at current location
- ✓ App functions normally if permission denied

**Test 3: Location Permissions (Android)**
**Steps**:
1. Uninstall app
2. Reinstall and launch
3. Navigate to Map tab
4. Observe permission dialog
5. Tap "While using the app"

**Expected Results**:
- ✓ Permission dialog appears
- ✓ After granting: Blue dot appears
- ✓ App functions if permission denied

---

#### Test 4: Location Indicator - Active GPS
**Prerequisites**: Location permissions granted

**Steps**:
1. Open Map tab
2. Wait for GPS lock (may take 10-30 seconds)
3. Observe location indicator
4. Walk or drive around (if possible)
5. Observe indicator movement

**Expected Results**:
- ✓ Blue dot appears within 2 seconds of GPS lock
- ✓ Dot positioned at correct coordinates
- ✓ Dot has white border (clearly visible)
- ✓ Dot updates position as device moves
- ✓ Updates smooth (no jitter)
- ✓ Map rendering maintains 60 FPS

---

#### Test 5: Location Indicator - GPS Signal Loss
**Prerequisites**: Active GPS with blue dot visible

**Steps**:
1. With blue dot visible, go indoors or cover GPS antenna
2. Wait 10-15 seconds
3. Observe dot color change
4. Return to GPS-enabled area
5. Observe dot color change back

**Expected Results**:
- ✓ Dot changes from blue to gray when GPS lost
- ✓ Dot remains at last known position
- ✓ Dot changes from gray to blue when GPS restored
- ✓ Position updates when GPS restored

---

#### Test 6: Location Indicator - Permission Denied
**Steps**:
1. Open device Settings
2. Navigate to app permissions
3. Disable location permission
4. Return to app
5. Observe map screen

**Expected Results**:
- ✓ No location dot visible
- ✓ Map still functional (pan, zoom, track import)
- ✓ No error messages or crashes
- ✓ "Center on location" button hidden or disabled

---

#### Test 7: Center on Location Button
**Prerequisites**: Location permissions granted, GPS active

**Steps**:
1. Open Map tab with location indicator visible
2. Pan map away from current location
3. Observe "center on location" button (my_location icon)
4. Tap button
5. Observe map movement

**Expected Results**:
- ✓ Button visible in FAB stack
- ✓ Button enabled when location available
- ✓ Tapping button animates map to current location
- ✓ Animation smooth (500ms transition)
- ✓ Zoom level maintained or set appropriately
- ✓ Location dot centered in viewport

---

#### Test 8: Center on Location - No GPS
**Steps**:
1. Open Map tab with no location available (permissions denied or GPS disabled)
2. Observe FAB stack

**Expected Results**:
- ✓ "Center on location" button hidden or grayed out
- ✓ Tapping button (if visible) shows message "Location unavailable"
- ✓ No crashes

---

#### Test 9: Map Info Display
**Steps**:
1. Open Map tab
2. Observe bottom-left corner
3. Pan map
4. Zoom in and out
5. Change map style
6. Read displayed values

**Expected Results**:
- ✓ Info overlay visible in bottom-left
- ✓ Background semi-transparent black
- ✓ Text white and readable on all map styles
- ✓ Shows: Type, Zoom, Lat, Lng
- ✓ Values update in real-time (<100ms)
- ✓ Zoom shows 1 decimal place
- ✓ Coordinates show 4 decimal places
- ✓ No overlap with other UI elements

---

#### Test 10: State Preservation
**Steps**:
1. Open Map tab
2. Import a track
3. Pan to specific location
4. Zoom to specific level
5. Switch to Dashboard tab
6. Switch back to Map tab
7. Observe map state

**Expected Results**:
- ✓ Map at same position as before tab switch
- ✓ Same zoom level
- ✓ Imported track still visible
- ✓ Location indicator still visible (if was before)

---

#### Test 11: Performance Under Location Updates
**Prerequisites**: Active GPS, location indicator visible

**Steps**:
1. Open Map tab
2. Walk or simulate movement
3. Simultaneously pan and zoom map
4. Observe rendering performance

**Expected Results**:
- ✓ Map maintains 60 FPS during location updates
- ✓ No lag or stuttering
- ✓ Location dot updates smooth
- ✓ Map info updates smooth

---

#### Test 12: App Lifecycle
**Steps**:
1. Open Map tab with location tracking active
2. Press home button (background app)
3. Wait 30 seconds
4. Return to app
5. Observe location indicator

**Expected Results**:
- ✓ Location updates stop when backgrounded
- ✓ Location updates resume when foregrounded
- ✓ Dot color reflects current GPS state
- ✓ No crashes or errors

---

## Debugging Tips

### Location Not Updating
**Check**:
- Permissions granted in device settings
- GPS enabled on device
- Device has clear view of sky (if physical device)
- Simulator location set (if simulator)

**iOS Simulator Location**:
```
Debug → Location → Custom Location → Enter coordinates
```

**Android Emulator Location**:
```
Extended Controls (⋯) → Location → Set coordinates
```

### Performance Issues
**Check**:
- No excessive setState calls in map callbacks
- Location updates respect distanceFilter (10m)
- Map layers not duplicated

### Permission Dialog Not Showing
**iOS**: Check Info.plist has NSLocationWhenInUseUsageDescription
**Android**: Check AndroidManifest.xml has location permissions

---

## Development Tools

### Useful Flutter Commands
```bash
# Hot reload
r

# Hot restart
R

# Clear build cache
flutter clean && flutter pub get

# Run on specific device
flutter devices
flutter run -d <device-id>

# Build for release (testing performance)
flutter build ios --release
flutter build apk --release
```

### Logging Location Updates
Add to LocationService implementation:
```dart
print('Location update: ${location.latitude}, ${location.longitude}, active: ${location.isActive}');
```

### Profiling Performance
```bash
flutter run --profile
# Then use DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

---

## Common Issues and Solutions

### Issue: "Location services disabled"
**Solution**: Enable GPS in device settings

### Issue: Permission denied on iOS
**Solution**: Check Info.plist has correct key and description

### Issue: Permission denied on Android
**Solution**: Check AndroidManifest.xml has both FINE and COARSE permissions

### Issue: Blue dot not appearing
**Solution**: 
1. Check permissions granted
2. Wait 10-30 seconds for GPS lock
3. Ensure device has GPS capability
4. Check LocationService is being instantiated

### Issue: Gray dot instead of blue
**Solution**: This is correct behavior when GPS signal lost. Move to area with clear sky view.

### Issue: Map state not preserved on tab switch
**Solution**: Verify using IndexedStack in HomeScreen, not rebuilding screens

### Issue: Center button not working
**Solution**: Check MapController is properly initialized before centerOnLocation() called

---

## Success Criteria Verification

After implementation, verify all success criteria met:

- ✅ **SC-001**: Tab switching completes within 100ms
- ✅ **SC-002**: Location indicator appears within 2 seconds of GPS lock
- ✅ **SC-003**: Location updates within 1 second of device movement
- ✅ **SC-004**: Center button animation completes within 500ms
- ✅ **SC-005**: Map info updates within 100ms of interaction
- ✅ **SC-006**: Map state preserved 100% across tab switches
- ✅ **SC-007**: Location tracking stops when map not visible (check battery drain)
- ✅ **SC-008**: No crashes on permission denial
- ✅ **SC-009**: All map features work without location permissions

---

## Next Steps

After completing implementation and testing:

1. Run full test suite from this guide
2. Fix any failing tests
3. Verify all success criteria
4. Create PR with detailed description
5. Include test results in PR description
6. Request code review

---

**Document Version**: 1.0.0  
**Last Updated**: December 29, 2025
