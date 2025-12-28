# Data Model: Offline Map & Track Log Viewer

**Date**: 2025-12-28  
**Feature**: 001-offline-map-tracks  
**Purpose**: Define entities, fields, relationships, and validation rules

---

## Entity: MapTile

**Description**: A raster image representing a specific geographic area at a specific zoom level and style. Tiles are uniquely identified by their zoom/x/y coordinates and style type. Used for offline map display.

### Fields

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `styleId` | `String` | Map style identifier (e.g., "standard", "satellite", "terrain") | Required, non-empty, alphanumeric |
| `zoom` | `int` | Zoom level (0 = world, higher = more detail) | Required, range: 0-19 |
| `x` | `int` | Tile X coordinate at zoom level | Required, range: 0 to 2^zoom - 1 |
| `y` | `int` | Tile Y coordinate at zoom level | Required, range: 0 to 2^zoom - 1 |
| `imageData` | `Uint8List` | PNG/JPEG image bytes | Required, non-empty, valid image format |
| `cachedAt` | `DateTime` | Timestamp when tile was cached | Required, not in future |
| `fileSize` | `int` | Size in bytes | Required, > 0 |

### Relationships

- **One MapStyle has many MapTiles** (via styleId foreign key)
- Tiles are organized hierarchically: zoom 0 has 1 tile, zoom 1 has 4 tiles, zoom N has 2^(2N) tiles
- Adjacent tiles at same zoom level connect spatially

### Validation Rules

- Tile key uniqueness: combination of (styleId, zoom, x, y) must be unique
- Coordinate validity: x and y must be within valid range for given zoom level
- Image validation: imageData must be parseable as PNG or JPEG
- Storage limit: total cache size should not exceed device constraints (warning at 500MB)

### State Transitions

```
[Not Cached] --download--> [Downloading] --success--> [Cached] --clear--> [Not Cached]
                                       |
                                       --failure--> [Not Cached]
```

**Implementation Notes**:
- Tiles stored as files: `{cacheDir}/{styleId}/{zoom}/{x}/{y}.png`
- Cache key format: `${styleId}_${zoom}_${x}_${y}`
- Tiles persist between app sessions (stored in app documents directory)
- LRU eviction when storage limit reached (oldest cachedAt first)

---

## Entity: Track

**Description**: A sequence of geographic coordinates representing a recorded GPS path (hiking route, cycling path, etc.). Visualized as a polyline overlay on the map.

### Fields

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `String` | Unique track identifier (UUID) | Required, unique |
| `name` | `String` | Track name/title | Optional, max 200 chars |
| `coordinates` | `List<TrackPoint>` | Ordered list of GPS points | Required, min 2 points |
| `importedFrom` | `String` | Source file path or name | Optional |
| `format` | `TrackFormat` | Original file format (GPX, KML, etc.) | Required, enum value |
| `importedAt` | `DateTime` | Timestamp of import | Required |
| `bounds` | `LatLngBounds` | Bounding box of all coordinates | Required, calculated from coordinates |
| `color` | `Color` | Line color for display | Optional, default: blue |
| `metadata` | `Map<String, dynamic>` | Additional data (author, description, etc.) | Optional |

### TrackPoint Sub-Entity

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `latitude` | `double` | Latitude in decimal degrees | Required, range: -90.0 to 90.0 |
| `longitude` | `double` | Longitude in decimal degrees | Required, range: -180.0 to 180.0 |
| `elevation` | `double?` | Altitude in meters | Optional, can be null |
| `timestamp` | `DateTime?` | Time of GPS reading | Optional, can be null |
| `accuracy` | `double?` | GPS accuracy in meters | Optional, can be null |

### TrackFormat Enum

```dart
enum TrackFormat {
  gpx,      // GPS Exchange Format (P2 priority)
  kml,      // Keyhole Markup Language (P4)
  kmz,      // Compressed KML (P4)
  geojson,  // GeoJSON LineString (P4)
  fit,      // Garmin FIT (P4)
  tcx,      // Training Center XML (P4)
  csv,      // Comma-separated values (P4)
  nmea,     // NMEA sentences (P4)
}
```

### Relationships

- Track has no direct relationships to MapTile or MapStyle (tracks overlay any map)
- Track contains many TrackPoints (composition, points owned by track)
- Application maintains List<Track> for multiple simultaneous track display (clarified 2025-12-28)

### Validation Rules

- **Coordinate validation**: Each TrackPoint must have valid lat/lng within ranges
- **Minimum points**: Track must contain at least 2 points to be displayable
- **Maximum points**: Warn if >10,000 points (performance consideration, suggest simplification)
- **Bounds calculation**: bounds automatically computed from min/max lat/lng of all points
- **Temporal consistency**: If timestamps present, should be monotonically increasing (warn if not)
- **Duplicate detection**: Consecutive identical coordinates should be filtered

### State Transitions

```
[File Selected] --parse--> [Parsing] --success--> [Imported] --delete--> [Deleted]
                                  |
                                  --failure--> [Parse Error] (user notified)
```

**Implementation Notes**:
- Tracks stored in memory during session (not persisted between app restarts in MVP)
- Future: Add track persistence if multiple track management becomes priority
- Polyline rendering uses `flutter_map` Polyline widget
- Simplification algorithm (Douglas-Peucker) applied if >5000 points for performance

---

## Entity: MapStyle

**Description**: Configuration for a visual representation type of map tiles (street, satellite, terrain). Each style has independent tile sources and caching.

### Fields

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `String` | Style identifier (e.g., "standard", "satellite", "terrain") | Required, unique, alphanumeric |
| `name` | `String` | Display name for UI | Required, non-empty |
| `tileUrlTemplate` | `String` | Tile URL with {z}/{x}/{y} placeholders | Required, valid URL pattern |
| `attribution` | `String` | Required attribution text for tile source | Required (OSM license compliance) |
| `minZoom` | `int` | Minimum supported zoom level | Required, range: 0-19 |
| `maxZoom` | `int` | Maximum supported zoom level | Required, range: minZoom-19 |
| `isDefault` | `bool` | Whether this is the default style on app launch | Default: false, only one can be true |

### Predefined Styles

**Standard** (P1 - MVP):
```dart
MapStyle(
  id: 'standard',
  name: 'Standard',
  tileUrlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  attribution: '© OpenStreetMap contributors',
  minZoom: 0,
  maxZoom: 19,
  isDefault: true,
)
```

**Satellite** (P3):
```dart
MapStyle(
  id: 'satellite',
  name: 'Satellite',
  tileUrlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
  attribution: '© Esri',
  minZoom: 0,
  maxZoom: 18,
  isDefault: false,
)
```

**Terrain** (P3):
```dart
MapStyle(
  id: 'terrain',
  name: 'Terrain',
  tileUrlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
  attribution: '© OpenTopoMap (CC-BY-SA)',
  minZoom: 0,
  maxZoom: 17,
  isDefault: false,
)
```

### Relationships

- **One MapStyle has many MapTiles** (1:N, tiles reference style via styleId)
- Styles are independent: switching styles does not affect other style's cached tiles

### Validation Rules

- **URL validation**: tileUrlTemplate must contain {z}, {x}, {y} placeholders
- **Zoom consistency**: maxZoom must be >= minZoom
- **Unique default**: Only one style can have isDefault: true
- **Attribution required**: Must comply with tile source license terms

### State Transitions

```
[Available] --select--> [Active] --switch--> [Available]
```

**Implementation Notes**:
- Styles are hardcoded constants in MVP (no user-added styles)
- Active style tracked in app state (StatefulWidget state variable)
- Tile cache organized by style ID to prevent collisions

---

## Entity: Cache

**Description**: Metadata and management for the tile cache storage system. Tracks cache size, last cleanup, and provides cache control operations.

### Fields

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `totalSizeBytes` | `int` | Current total cache size across all styles | >= 0 |
| `tileCount` | `int` | Total number of cached tiles | >= 0 |
| `lastCleanupAt` | `DateTime?` | Last cache cleanup timestamp | Optional, not in future |
| `maxSizeBytes` | `int` | Maximum allowed cache size | Default: 500MB, configurable |
| `sizeByStyle` | `Map<String, int>` | Cache size breakdown per style ID | Computed from tiles |
| `storageWarningThreshold` | `double` | Storage percentage to trigger warning | Default: 0.8 (80%), clarified 2025-12-28 |

### Operations

| Operation | Description | Parameters | Return |
|-----------|-------------|------------|--------|
| `getCacheInfo()` | Get current cache statistics | None | `CacheInfo` |
| `clearCache()` | Delete all cached tiles | `styleId: String?` (optional, null = all styles) | `int` (tiles deleted) |
| `getCachedTileKeys()` | List all cached tile identifiers | `styleId: String?` (optional) | `List<String>` |
| `isTileCached()` | Check if specific tile exists | `styleId, zoom, x, y` | `bool` |
| `evictOldest()` | Remove oldest tiles until size < max | `targetSizeBytes: int` | `int` (tiles evicted) |
| `shouldShowWarning()` | Check if storage warning should display | None | `bool` (true if >= 80% of available space) |

### Validation Rules

- Cache operations must be atomic (prevent partial clears)
- Size calculations must account for file system overhead
- Eviction must preserve at least most recent 50 tiles (prevent thrashing)
- Storage warning displays when cache exceeds 80% of available device storage (clarified 2025-12-28)

### State Transitions

```
[Empty] --download tiles--> [Partial] --continue caching--> [Full] --clear--> [Empty]
                                  |                            |
                                  <--evict oldest--------------
```

**Implementation Notes**:
- Cache managed by `flutter_map_cache` plugin
- Cache directory: `getApplicationDocumentsDirectory()` for persistence
- Cache statistics updated after each tile save/delete
- Background cleanup runs weekly or when app starts if cache > 80% of maxSize

---

## Relationships Diagram

```
MapStyle (1) ----< (N) MapTile
    |
    | styleId reference
    |
Track (independent, overlays any style)
    |
    | composition
    |
    +---> TrackPoint (N)

Cache (singleton, manages all MapTiles)
```

---

## Data Flow

### Map Display Flow
1. User opens app → load default MapStyle (standard)
2. Map widget requests tiles for visible area (zoom level, x/y ranges)
3. For each tile: check Cache → if exists, load from disk → display
4. If not cached: download from tileUrlTemplate → save to Cache → display

### Track Import Flow
1. User selects "Import Track" → file_picker opens
2. User selects file → parse based on extension/format
3. Validate coordinates → create Track entity with TrackPoints
4. Calculate bounds → auto-zoom map to fit track
5. Render track as Polyline overlay on map

### Style Switch Flow
1. User taps style selector → show available MapStyles
2. User selects new style → update active style state
3. Map widget refreshes → request tiles for new style
4. Cache lookup per tile → load cached or download new tiles
5. Display map with new style

---

## Implementation Priority

**P1 (MVP)**:
- MapTile entity (full implementation)
- MapStyle entity (standard style only)
- Cache operations (basic: save, load, check existence)

**P2**:
- Track entity (GPX format only via `gpx` package)
- TrackPoint sub-entity

**P3**:
- MapStyle additional styles (satellite, terrain)
- Cache statistics and management

**P4**:
- Track support for additional formats (KML, GeoJSON, FIT, TCX, CSV, NMEA)
- Track persistence between sessions
- Track simplification for large files

---

## Future Considerations (Out of Scope for MVP)

- Track editing (split, merge, trim)
- Multiple simultaneous tracks
- Track metadata enrichment (photos, notes)
- Offline geocoding integration
- Route planning entities
- POI (Point of Interest) entities
- User preferences/settings entity
