# Quickstart: Show Current Location or Default

## Prerequisites
- Flutter 3.5.4+
- Add dependencies to pubspec.yaml:
  - flutter_map
  - geolocator

## Steps
1. Add `flutter_map` and `geolocator` to pubspec.yaml
2. Create `lib/features/show_current_location/show_current_location_screen.dart`
3. On map open, request location permission using geolocator
4. If granted, get user location and center map, show blue marker and "Your location" banner
5. If granted but GPS unavailable, use last known location (if available), show blue marker and "Last known location" banner
6. If denied or no location available, center map on Ho Chi Minh City, show red marker and "Default location: Ho Chi Minh City" banner
7. Listen for permission changes and update map accordingly
8. Always show appropriate banner at bottom indicating which location type is displayed

## Example pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_map: ^6.0.0
  geolocator: ^10.0.0
```

## Run
```bash
flutter pub get
flutter run
```
