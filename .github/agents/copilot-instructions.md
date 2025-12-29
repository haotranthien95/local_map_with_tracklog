# local_map_with_tracklog Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-12-28

## Active Technologies
- Dart 3.5.4+ / Flutter 3.5.4+ (SDK constraint from pubspec.yaml) + `flutter_map` (OSM tile display), `flutter_map_cache` (offline caching), `file_picker` (file import), `gpx` (GPX parsing for P2) (001-offline-map-tracks)
- Local file system for tile cache via `path_provider` (applicationDocumentsDirectory), organized by `{cacheDir}/{styleId}/{zoom}/{x}/{y}.png` (001-offline-map-tracks)
- Dart 3.5.4+, Flutter 3.5.4+ + flutter_map (or alternatives: google_maps_flutter, mapbox_gl), geolocator (for location permission and device location), permission_handler (if needed for fine-grained permission control) (001-show-current-location)
- N/A (no persistent storage required for this feature) (001-show-current-location)
- Dart 3.5.4+ with Flutter SDK 3.5.4+ + flutter_map (6.1.0) for map rendering, geolocator (10.1.0) for location services, latlong2 (0.9.0) for coordinate handling (002-navigation-location-ui)
- Local file system via path_provider (for tile cache) - no changes needed for this feature (002-navigation-location-ui)

- Dart 3.5.4+ / Flutter 3.5.4+ (SDK constraint from pubspec.yaml) (001-offline-map-tracks)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Dart 3.5.4+ / Flutter 3.5.4+ (SDK constraint from pubspec.yaml)

## Code Style

Dart 3.5.4+ / Flutter 3.5.4+ (SDK constraint from pubspec.yaml): Follow standard conventions

## Recent Changes
- 002-navigation-location-ui: Added Dart 3.5.4+ with Flutter SDK 3.5.4+ + flutter_map (6.1.0) for map rendering, geolocator (10.1.0) for location services, latlong2 (0.9.0) for coordinate handling
- 001-show-current-location: Added Dart 3.5.4+, Flutter 3.5.4+ + flutter_map (or alternatives: google_maps_flutter, mapbox_gl), geolocator (for location permission and device location), permission_handler (if needed for fine-grained permission control)
- 001-show-current-location: Added Dart 3.5.4+, Flutter 3.5.4+ + flutter_map (or alternatives: google_maps_flutter, mapbox_gl), geolocator (for location permission and device location), permission_handler (if needed for fine-grained permission control)


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
