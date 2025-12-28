# Quickstart: Offline Map & Track Log Viewer

**Feature**: 001-offline-map-tracks  
**Last Updated**: 2025-12-28

**Recent Clarifications**:
- Storage warning displays at 80% capacity with user control
- Multiple imported tracks display simultaneously with different colors

---

## Prerequisites

### Required Software

- **Flutter SDK**: 3.5.4 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: 3.5.4+ (included with Flutter)
- **iOS Development** (Mac only):
  - Xcode 15.0+
  - CocoaPods (`sudo gem install cocoapods`)
- **Android Development**:
  - Android Studio or Android SDK CLI tools
  - Java JDK 17+
  - Android SDK Platform 21+ (Android 5.0)

### Verify Installation

```bash
flutter doctor -v
```

Expected output should show:
- ✓ Flutter (version 3.5.4+)
- ✓ Dart (version 3.5.4+)
- ✓ Android toolchain (if developing for Android)
- ✓ Xcode (if developing for iOS on Mac)

---

## Project Setup

### 1. Clone Repository and Switch Branch

```bash
# Clone the repository (if not already cloned)
git clone <repository-url>
cd local_map_with_tracklog

# Switch to feature branch
git checkout 001-offline-map-tracks

# Or create if not exists
git checkout -b 001-offline-map-tracks
```

### 2. Install Dependencies

Add the required packages to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  
  # Map and tile management (P1)
  flutter_map: ^6.1.0
  flutter_map_cache: ^0.2.0
  cached_network_image: ^3.3.0
  latlong2: ^0.9.0  # LatLng coordinates (dependency of flutter_map)
  
  # File system and storage (P1)
  path_provider: ^2.1.0
  
  # File picker (P2)
  file_picker: ^6.1.0
  
  # GPS format parsers (P2 for GPX only)
  gpx: ^2.2.0
  
  # Future dependencies (P4 - commented out for MVP)
  # xml: ^6.3.0  # For KML/TCX parsing
```

Install packages:

```bash
flutter pub get
```

### 3. Verify Project Structure

Ensure the following directories exist (create if needed):

```bash
mkdir -p lib/models
mkdir -p lib/services
mkdir -p lib/widgets
mkdir -p lib/screens
mkdir -p test/fixtures
```

---

## Running the App

### Development Mode

#### iOS Simulator (Mac only)

```bash
# List available simulators
xcrun simctl list devices

# Open default simulator
open -a Simulator

# Run app
flutter run -d <simulator-id>
# or simply
flutter run
```

#### Android Emulator

```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator-id>

# Run app
flutter run
```

#### Physical Device

**iOS**:
1. Connect iPhone/iPad via USB
2. Trust computer on device
3. Open Xcode, set development team in Signing & Capabilities
4. Run: `flutter run -d <device-id>`

**Android**:
1. Enable Developer Options on device (tap Build Number 7 times)
2. Enable USB Debugging in Developer Options
3. Connect via USB and authorize debugging
4. Run: `flutter run -d <device-id>`

### Production Build

**Android APK**:
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle** (for Play Store):
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS IPA** (Mac only):
```bash
flutter build ios --release
# Then archive in Xcode for App Store submission
```

---

## Development Workflow

### Phase 1: Map Display & Caching (P1 - MVP)

**Objective**: Display OpenStreetMap with automatic tile caching for offline use.

**Implementation Order**:
1. Create `MapStyle` model class in `lib/models/map_style.dart`
2. Create `MapTile` model class in `lib/models/map_tile.dart`
3. Implement `TileCacheService` in `lib/services/tile_cache_service.dart`
4. Create `MapView` widget in `lib/widgets/map_view.dart` using `flutter_map`
5. Create `HomeScreen` in `lib/screens/home_screen.dart`
6. Update `main.dart` to launch HomeScreen

**Testing**:
1. Run app and verify map displays
2. Pan and zoom around different areas
3. Close app and reopen → previously viewed areas should load instantly
4. Enable airplane mode → verify cached areas still visible
5. Fill cache to >80% capacity → verify storage warning displays with options to continue or stop

**Success Criteria**:
- Map displays within 3 seconds of launch
- Tiles cache automatically during browsing
- Offline mode shows cached tiles without errors
- Storage warning appears at 80% capacity threshold

---

### Phase 2: GPX Track Import (P2)

**Objective**: Import and display GPX tracks on the map.

**Implementation Order**:
1. Create `Track` and `TrackPoint` models in `lib/models/track.dart`
2. Implement `FilePickerService` in `lib/services/file_picker_service.dart`
3. Implement `TrackParserService` in `lib/services/track_parser_service.dart`
4. Create `TrackOverlay` widget in `lib/widgets/track_overlay.dart`
5. Add "Import Track" button to HomeScreen
6. Wire up file picker → parser → display flow

**Testing**:
1. Create test GPX file or download sample from GPS device
2. Tap "Import Track" and select GPX file
3. Verify track displays as line on map
4. Verify map auto-zooms to show entire track
5. Test with invalid GPX → should show error message
6. Import additional GPX files → verify all tracks display simultaneously with different colors

**Test Fixtures**:
Create `test/fixtures/sample_track.gpx`:
```xml
<?xml version="1.0"?>
<gpx version="1.1" creator="TestApp">
  <trk>
    <name>Sample Track</name>
    <trkseg>
      <trkpt lat="37.7749" lon="-122.4194"><ele>10</ele></trkpt>
      <trkpt lat="37.7750" lon="-122.4195"><ele>12</ele></trkpt>
      <trkpt lat="37.7751" lon="-122.4196"><ele>15</ele></trkpt>
    </trkseg>
  </trk>
</gpx>
```

**Success Criteria**:
- GPX files with 1000 points load in < 2 seconds
- Track displays accurately on map
- Invalid files show clear error messages
- Multiple tracks display simultaneously with distinct colors

---

### Phase 3: Map Style Switching (P3)

**Objective**: Allow switching between standard, satellite, and terrain map styles.

**Implementation Order**:
1. Define additional MapStyle constants (satellite, terrain)
2. Create `StyleSelector` widget in `lib/widgets/style_selector.dart`
3. Update HomeScreen to manage active style state
4. Update MapView to use active style
5. Verify independent caching per style

**Testing**:
1. Switch to satellite style → verify new tiles load
2. Pan around in satellite mode
3. Switch to terrain style → verify different tiles load
4. Go offline → switch between styles → verify cached tiles display

**Success Criteria**:
- Style switch completes in < 1 second for cached areas
- Each style caches independently
- Offline mode supports all cached styles

---

### Phase 4: Additional Track Formats (P4)

**Objective**: Support KML, GeoJSON, FIT, TCX, CSV, NMEA formats.

**Implementation Order**:
1. Add format-specific parsers to TrackParserService
2. Update FilePickerService allowedExtensions
3. Test each format with sample files

**Testing**: Create test fixture for each format in `test/fixtures/`

**Success Criteria**:
- All formats parse correctly
- Format detection works automatically
- Unsupported formats show clear error

---

## Debugging Tips

### Common Issues

**Issue**: "MissingPluginException: No implementation found for method pick"  
**Solution**: 
```bash
flutter clean
flutter pub get
# Restart IDE
flutter run
```

**Issue**: Tiles not caching  
**Solution**: Check storage permissions, verify cache directory with:
```dart
import 'package:path_provider/path_provider.dart';
final dir = await getApplicationDocumentsDirectory();
print('Cache dir: ${dir.path}');
```

**Issue**: Map tiles not loading  
**Solution**: 
- Check internet connection (for first load)
- Verify tile URL in MapStyle.tileUrlTemplate
- Check console for HTTP errors

**Issue**: GPX parsing fails  
**Solution**:
- Validate GPX with online validator
- Check file encoding (should be UTF-8)
- Verify GPX schema version (1.0 or 1.1)

### Flutter DevTools

Enable DevTools for debugging:
```bash
flutter run --observatory-port=9100
# Then open: http://localhost:9100
```

Use DevTools for:
- Widget inspector (debug UI layout)
- Memory profiling (detect leaks)
- Performance view (measure FPS)
- Network inspector (monitor tile downloads)

---

## Testing

### Run Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/services/track_parser_service_test.dart

# With coverage
flutter test --coverage
```

### Manual Testing Checklist

**P1 - Map Display**:
- [ ] App launches and shows map
- [ ] Pan and zoom work smoothly
- [ ] Tiles cache during browsing
- [ ] Offline mode displays cached tiles
- [ ] Uncached areas show placeholder
- [ ] Storage warning at 80% capacity

**P2 - Track Import**:
- [ ] File picker opens
- [ ] GPX file imports successfully
- [ ] Track displays on map
- [ ] Map auto-zooms to track
- [ ] Invalid GPX shows error
- [ ] Multiple tracks display with different colors

**P3 - Map Styles**:
- [ ] Style selector works
- [ ] Satellite tiles display
- [ ] Terrain tiles display
- [ ] Each style caches independently

**P4 - Additional Formats**:
- [ ] KML/KMZ import works
- [ ] GeoJSON import works
- [ ] FIT/TCX/CSV/NMEA import works

---

## Performance Benchmarks

Monitor these metrics during development:

| Metric | Target | Measurement |
|--------|--------|-------------|
| App launch to map display | < 3s | Stopwatch from splash to interactive map |
| Track import (1000 points) | < 2s | Time from file select to display |
| Map style switch (cached) | < 1s | Time from tap to new tiles visible |
| Map frame rate | 30+ FPS | Flutter DevTools performance view |
| Cache lookup | < 1ms | Profile TileCacheService.isTileCached() |

---

## Project Resources

**Documentation**:
- [Feature Spec](./spec.md): User stories and requirements
- [Research](./research.md): Technology decisions
- [Data Model](./data-model.md): Entity definitions
- [Service Contracts](./contracts/): API interfaces

**External Resources**:
- [flutter_map Documentation](https://docs.fleaflet.dev/)
- [OpenStreetMap Tile Servers](https://wiki.openstreetmap.org/wiki/Tile_servers)
- [GPX Format Specification](https://www.topografix.com/gpx.asp)
- [Flutter Documentation](https://docs.flutter.dev/)

**Sample Data**:
- GPX samples: [GPSies.com](https://www.gpsies.com/)
- Test tiles: OpenStreetMap (no auth required)

---

## Next Steps After MVP

1. **User Feedback**: Test with real users and GPS devices
2. **Performance Tuning**: Profile and optimize tile loading
3. **Cache Management**: Add UI for cache clearing and statistics
4. **Track Persistence**: Save imported tracks between sessions
5. **Multiple Tracks**: Display multiple tracks simultaneously
6. **Track Metadata**: Show distance, duration, elevation profiles

---

## Support

**Issues**: Report bugs and feature requests in project issue tracker

**Questions**: Check existing documentation first:
- Spec, research, data-model, contracts
- Flutter documentation
- Package-specific documentation

**Contributing**: Follow constitution principles when adding features:
- MVP-first: Ship working functionality
- Minimal scope: Smallest change that delivers value
- Independent stories: Testable in isolation
- Progressive enhancement: Core first, polish later
- Maintainability: Simple over clever
