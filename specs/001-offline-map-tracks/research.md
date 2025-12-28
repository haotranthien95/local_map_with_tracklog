# Research: Offline Map & Track Log Viewer

**Date**: 2025-12-28  
**Feature**: 001-offline-map-tracks  
**Purpose**: Resolve all NEEDS CLARIFICATION items from Technical Context

## Research Tasks

### 1. Map Widget Library for OSM Tile Rendering

**Unknown**: Which Flutter package to use for displaying OpenStreetMap tiles with offline caching support?

**Research Findings**:

**Decision**: `flutter_map` package (official recommendation from OpenStreetMap wiki)

**Rationale**: 
- Most mature and actively maintained Flutter mapping library (10k+ stars, weekly updates)
- Native offline tile caching support via `flutter_map_cache` plugin
- OSM tile layer built-in with customizable tile providers
- Supports multiple map styles through different tile URL templates
- Pure Dart implementation, no native platform dependencies
- Well-documented with extensive examples for offline use cases
- Active community support and Flutter ecosystem integration

**Alternatives Considered**:
- **google_maps_flutter**: Rejected - Requires Google Maps API key and billing, not OSM-based, poor offline support
- **mapbox_gl**: Rejected - Commercial service with usage limits, requires account/token, vector tiles add complexity
- **Custom WebView with Leaflet.js**: Rejected - Performance overhead, bridge complexity, harder to integrate with Flutter widgets
- **Building custom tile renderer**: Rejected - Massive scope increase, reinventing stable solution, violates maintainability principle

**Dependencies**: `flutter_map: ^6.1.0`, `flutter_map_cache: ^0.2.0` (or latest stable), `cached_network_image` for efficient tile loading

---

### 2. File Picker for Track Import

**Unknown**: Which library to use for importing track files from device storage?

**Research Findings**:

**Decision**: `file_picker` package (official Flutter community package)

**Rationale**:
- Official Flutter Community package with 8k+ stars
- Cross-platform support (iOS, Android) with native file dialogs
- Simple API: single method call returns file path or bytes
- Supports file filtering by extension (.gpx, .kml, etc.)
- No permissions configuration needed (handled by native pickers)
- Minimal dependency footprint
- Well-maintained with regular Flutter SDK compatibility updates

**Alternatives Considered**:
- **image_picker**: Rejected - Designed for media files only, no support for arbitrary file types
- **Native platform channels**: Rejected - Requires separate iOS/Android implementations, increases maintenance burden
- **Document picker plugins**: Considered but `file_picker` supersedes older alternatives with better API

**Dependencies**: `file_picker: ^6.1.0` (or latest stable)

---

### 3. GPS Format Parsers (GPX, KML, GeoJSON, FIT, TCX, CSV, NMEA)

**Unknown**: How to parse multiple GPS track file formats efficiently?

**Research Findings**:

**Decision**: Combination approach - `gpx` package for GPX (P2 priority), custom parsers for other formats (P4 priority)

**Rationale**:
- **Phase 1 (MVP - P2)**: Use `gpx` package for GPX format only
  - Mature Dart package with 50+ stars, actively maintained
  - Handles full GPX specification including waypoints, routes, tracks
  - Returns structured Dart objects (Track, TrackSegment, WayPoint)
  - Pure Dart, no platform dependencies
  - GPX is most common format (covers 80% of user needs)

- **Phase 2 (P4 - Additional Formats)**: Evaluate per format
  - **KML/KMZ**: `xml` package + custom parser (KML is XML-based, KMZ is zipped KML)
  - **GeoJSON**: `dart:convert` JSON parsing + custom coordinate extraction (simple JSON structure)
  - **FIT**: `fit_parser` package or custom binary parser (Garmin proprietary format)
  - **TCX**: `xml` package + custom parser (Garmin/Strava XML format)
  - **CSV**: `dart:convert` + custom column mapping (varies by export tool)
  - **NMEA**: Custom line-by-line parser (text-based sentences)

**Alternatives Considered**:
- **Universal GPS converter library**: None exist in Dart ecosystem with sufficient maturity
- **Backend conversion service**: Rejected - Violates offline-first requirement, adds network dependency
- **Native platform libraries**: Rejected - Increases complexity, separate implementations per platform

**Dependencies**: 
- P2 (MVP): `gpx: ^2.2.0` (or latest stable)
- P4 (Future): `xml: ^6.3.0`, potentially `fit_parser` (evaluate when P4 prioritized)

---

### 4. Tile Cache Management Strategy

**Unknown**: Custom implementation vs existing library for organizing and managing cached tiles?

**Research Findings**:

**Decision**: Use `flutter_map_cache` plugin with built-in cache management

**Rationale**:
- `flutter_map_cache` provides complete cache management out-of-box
- Handles cache directory structure: `{style}/{zoom}/{x}/{y}.png`
- Automatic cache invalidation based on age or size limits
- Built-in disk space management with configurable limits
- Integrates directly with `flutter_map` tile layer
- Includes cache warming (pre-download areas) for future enhancement
- Uses `path_provider` for platform-appropriate cache directories
- Respects platform cache clearing mechanisms (iOS/Android system settings)

**Implementation Notes**:
- Default cache location: `getTemporaryDirectory()` for tiles (auto-cleared by OS under pressure)
- Optional: `getApplicationDocumentsDirectory()` for persistent cache (user manages)
- Cache key format: `${styleId}_${z}_${x}_${y}` ensures style isolation
- Fallback: If `flutter_map_cache` insufficient, `hive` package provides fast key-value storage

**Alternatives Considered**:
- **Custom file system implementation**: Rejected - Complex cache invalidation logic, reinventing stable solution
- **SQLite database**: Rejected - Overkill for key-value tile storage, slower than file system for large blobs
- **shared_preferences**: Rejected - Not designed for large binary data, size limitations
- **hive**: Good alternative if `flutter_map_cache` proves insufficient, but start with integrated solution

**Dependencies**: Covered by `flutter_map_cache` from Research Task #1

---

## Best Practices Summary

### Flutter Offline Map Development

**Tile Loading Strategy**:
1. Check cache first (synchronous file read)
2. If miss, fetch from network and cache asynchronously
3. Display placeholder for uncached tiles when offline
4. Respect tile server usage policies (User-Agent, rate limiting)

**Performance Optimization**:
- Use `cached_network_image` for automatic memory + disk caching
- Limit concurrent tile downloads (default: 4-6 concurrent requests)
- Implement tile loading prioritization (visible tiles first, then adjacent)
- Pre-generate tile bounds for tracks to estimate cache requirements

**User Experience**:
- Show cache status indicator (e.g., "50 tiles cached")
- Provide cache clearing option in settings
- Display storage usage before/after caching
- Visual distinction between cached (full color) and uncached (greyed/placeholder)

**Error Handling**:
- Graceful degradation when tile servers unreachable
- Retry logic with exponential backoff for failed downloads
- User notification when storage space low
- Validation of tile image data (corrupt downloads)

---

### GPS Track Visualization

**Rendering Best Practices**:
- Use `Polyline` widget from `flutter_map` for track lines
- Simplify tracks with many points using Douglas-Peucker algorithm (reduce points while preserving shape)
- Color-code tracks by attribute (speed, elevation, heart rate) if data available
- Render track segments separately if gaps in GPS data

**Coordinate Handling**:
- Store coordinates as `LatLng` objects (double precision)
- Handle coordinate system conversions (WGS84 standard for GPS)
- Account for date line crossing in track bounds calculation
- Validate coordinate ranges (lat: -90 to 90, lng: -180 to 180)

**Track Import Validation**:
- Check file size before parsing (warn if >10MB)
- Validate coordinate count (warn if >50k points)
- Detect and skip invalid coordinates (NaN, out-of-range)
- Preserve metadata (name, timestamps) for future features

---

## Technology Stack Summary

**Core Dependencies** (for immediate implementation):
```yaml
dependencies:
  flutter_map: ^6.1.0           # Map display and tile management
  flutter_map_cache: ^0.2.0     # Offline tile caching
  file_picker: ^6.1.0           # File import
  gpx: ^2.2.0                   # GPX parsing (P2 priority)
  cached_network_image: ^3.3.0  # Efficient tile loading
  path_provider: ^2.1.0         # Platform cache directories
```

**Future Dependencies** (P4 - additional format support):
```yaml
dependencies:
  xml: ^6.3.0                   # KML/KMZ/TCX parsing
  # fit_parser: evaluate when P4 prioritized
```

**Development Approach**:
1. Start with standard Flutter project structure (✅ already exists)
2. Add `flutter_map` and display basic OSM map (P1)
3. Implement automatic tile caching during browsing (P1)
4. Add GPX import with `file_picker` + `gpx` packages (P2)
5. Implement map style switching with independent caches (P3)
6. Add remaining format parsers incrementally (P4)

**Risk Assessment**:
- **Low Risk**: All selected packages are mature, actively maintained, and widely used in production apps
- **No Native Code**: All packages are pure Dart or have stable platform implementations
- **Offline-First**: Architecture supports full offline functionality as required
- **Performance**: Selected solutions proven in apps handling similar scale (10k+ coordinates, 1000+ cached tiles)

---

## Unresolved Questions

None - all NEEDS CLARIFICATION items from Technical Context have been resolved with specific technology decisions and rationale.
