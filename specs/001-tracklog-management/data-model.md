# Data Model: Tracklog Management System

**Feature**: Tracklog Management with Persistent Storage  
**Date**: December 29, 2025  
**Related**: [research.md](research.md), [spec.md](spec.md)

## Overview

This data model defines the entities and their relationships for tracklog management functionality. The design supports persistent storage, visibility control, color customization, and efficient metadata retrieval for list display.

---

## Entity: TracklogMetadata

Lightweight representation of a tracklog for list display and persistence. Stored in shared_preferences for fast loading.

### Fields

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| id | String | Unique identifier (UUID) | Non-null, unique, immutable |
| name | String | User-assigned tracklog name | Non-empty after trim, max 100 chars |
| color | Color | Display color on map | Non-null, default #2196F3 (blue) |
| isVisible | bool | Whether tracklog shown on map | Non-null, default true |
| filePath | String | Path to coordinate data file | Non-null, relative to docs dir |
| importedAt | DateTime | When tracklog was added | Non-null, UTC timestamp |
| importedFrom | String | Original filename | Non-null |
| format | TrackFormat | File format type | Non-null enum value |
| boundsNorth | double | Northern latitude bound | Required for map centering |
| boundsSouth | double | Southern latitude bound | Required for map centering |
| boundsEast | double | Eastern longitude bound | Required for map centering |
| boundsWest | double | Western longitude bound | Required for map centering |

### Serialization

**To JSON** (for shared_preferences storage):
```json
{
  "id": "uuid-string",
  "name": "Morning Run",
  "color": "0xFF2196F3",
  "isVisible": true,
  "filePath": "tracklogs/uuid-string.json",
  "importedAt": "2025-12-29T10:30:00.000Z",
  "importedFrom": "morning_run.gpx",
  "format": "gpx",
  "boundsNorth": 37.7749,
  "boundsSouth": 37.7649,
  "boundsEast": -122.4194,
  "boundsWest": -122.4294
}
```

**From JSON**: Parse string fields, convert color int to Color object, parse DateTime from ISO string

### Operations

- **Create**: When new tracklog imported with name dialog
- **Read**: Load all metadata on app start for list display
- **Update**: When user renames, changes color, or toggles visibility
- **Delete**: When user confirms removal

### Validation Rules

- Name: Must have at least one non-whitespace character after trim
- Color: Must be valid Color object (ARGB format)
- FilePath: Must exist in file system (checked on load, orphaned entries cleaned up)
- Bounds: All four values must be present (required for map centering)

---

## Entity: Track (Extended)

Existing Track model from `lib/models/track.dart` extended with visibility field.

### New/Modified Fields

| Field | Type | Description | Default |
|-------|------|-------------|---------|
| isVisible | bool | Whether track shown on map | true |

### Impact on Existing Fields

- All existing fields (id, name, coordinates, importedFrom, format, importedAt, bounds, color, metadata) remain unchanged
- bounds field (LatLngBounds) already exists for map centering - reused for metadata storage

### Modifications Required

```dart
// In lib/models/track.dart
class Track {
  final String id;
  final String name;
  final List<TrackPoint> coordinates;
  final String importedFrom;
  final TrackFormat format;
  final DateTime importedAt;
  final LatLngBounds bounds;
  final Color color;
  final bool isVisible;  // NEW FIELD
  final Map<String, dynamic> metadata;

  Track({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.importedFrom,
    required this.format,
    required this.importedAt,
    required this.color,
    this.isVisible = true,  // NEW FIELD with default
    Map<String, dynamic>? metadata,
  }) : bounds = LatLngBounds.fromPoints(coordinates),
       metadata = metadata ?? {};
}
```

### Backward Compatibility

- Default value `isVisible = true` ensures existing code continues working
- No breaking changes to existing Track usage in map rendering
- Existing track imports automatically get `isVisible = true`

---

## Entity: TracklogCollection

Manages the complete set of user's tracklogs with metadata and coordinate data separation.

### Structure

```
TracklogCollection
├── metadataList: List<TracklogMetadata>    # In-memory cache of metadata
├── tracks: Map<String, Track>              # Lazily loaded coordinate data (id -> Track)
└── storage: TracklogStorageService         # Persistence layer
```

### Responsibilities

- **Metadata Management**: Maintain list of all tracklog metadata (sorted by import date, newest first)
- **Lazy Loading**: Load full Track data only when needed (tracklog becomes visible)
- **Synchronization**: Keep metadata and file system in sync
- **Cache Management**: Maintain map of loaded tracks to avoid redundant file reads

### Operations

| Operation | Input | Output | Side Effects |
|-----------|-------|--------|--------------|
| loadAll() | - | Future<void> | Load all metadata from storage |
| add(Track) | Track | Future<void> | Save metadata + coordinates, update lists |
| remove(id) | String | Future<void> | Delete metadata + file, update lists |
| update(metadata) | TracklogMetadata | Future<void> | Save updated metadata |
| getTrack(id) | String | Future<Track> | Load coordinates if not cached |
| getVisibleTracks() | - | List<Track> | Return tracks where isVisible=true |

### State Transitions

```
[App Start] --loadAll()--> [Metadata Loaded]
                                 |
                                 v
[User Adds Track] --add()--> [Track Saved] --cache--> [Available for Display]
                                 |
                                 v
[User Toggles Visibility] --update()--> [Metadata Updated] --refresh map--> [UI Updated]
                                 |
                                 v
[User Taps List Item] --getTrack()--> [Coordinates Loaded] --fitBounds()--> [Map Centered]
                                 |
                                 v
[User Removes] --confirm--> --remove()--> [Track Deleted] --refresh--> [UI Updated]
```

---

## Entity: TracklogStorageService (Abstract)

Service interface for persistence operations. Implementation uses shared_preferences + file system.

### Interface

```dart
abstract class TracklogStorageService {
  /// Save tracklog metadata and coordinate data
  Future<void> saveTracklog(Track track);
  
  /// Load all tracklog metadata (fast operation)
  Future<List<TracklogMetadata>> loadAllMetadata();
  
  /// Load full track coordinates for specific tracklog
  Future<Track> loadTrack(String id);
  
  /// Update tracklog metadata only (name, color, visibility)
  Future<void> updateMetadata(TracklogMetadata metadata);
  
  /// Delete tracklog (metadata and coordinate file)
  Future<void> deleteTracklog(String id);
  
  /// Cleanup orphaned files (files without metadata)
  Future<void> cleanupOrphanedFiles();
}
```

### Storage Layout

**shared_preferences keys**:
- `tracklog_ids`: JSON array of tracklog IDs (order matters: newest first)
- `tracklog_<id>`: JSON string of TracklogMetadata for each tracklog

**File system** (application documents directory):
```
documents/
└── tracklogs/
    ├── <uuid-1>.json    # Track coordinate data (full Track serialized)
    ├── <uuid-2>.json
    └── <uuid-3>.json
```

### Performance Characteristics

- **Load All Metadata**: ~10-50ms for 20 tracklogs (shared_preferences read)
- **Load Track Coordinates**: ~50-200ms depending on track size (file I/O + JSON parse)
- **Update Metadata**: ~10-20ms (shared_preferences write)
- **Save New Track**: ~100-300ms (shared_preferences + file write)
- **Delete Track**: ~20-50ms (shared_preferences + file delete)

---

## Data Flow Diagrams

### Add Named Tracklog Flow (P1)

```
User selects file
      ↓
FilePickerService returns File
      ↓
Show name dialog → User enters name
      ↓
TrackParserService parses file → Track (with default color #2196F3, isVisible=true)
      ↓
TracklogStorageService.saveTracklog() → Metadata to prefs, coordinates to file
      ↓
Add to TracklogCollection.metadataList + tracks cache
      ↓
MapScreen renders track on map
```

### Persistence Flow (P2)

```
App Startup
      ↓
TracklogStorageService.loadAllMetadata()
      ↓
Populate TracklogCollection.metadataList
      ↓
For each visible tracklog: TracklogStorageService.loadTrack()
      ↓
Populate TracklogCollection.tracks cache
      ↓
MapScreen renders visible tracks
```

### Tracklog List Navigation Flow (P3)

```
User taps tracklog list button
      ↓
Navigate to TracklogListScreen (pass TracklogCollection.metadataList)
      ↓
Display ListView of metadata
      ↓
User taps tracklog item
      ↓
Navigator.pop(selectedId)
      ↓
MapScreen receives selectedId
      ↓
TracklogCollection.getTrack(id) → Load if not cached
      ↓
MapController.fitBounds(track.bounds)
```

### Management Operations Flow (P4)

**Toggle Visibility**:
```
User taps show/hide → Update metadata.isVisible → Save to prefs → Refresh map
```

**Remove**:
```
User taps remove → Show confirmation → Confirmed → Delete metadata + file → Remove from lists → Refresh UI
```

**Rename**:
```
User taps rename → Show name dialog → Enter new name → Update metadata.name → Save to prefs → Refresh list
```

**Change Color**:
```
User taps change color → Show color picker → Select color → Update metadata.color → Save to prefs → Refresh map
```

---

## Consistency Guarantees

### Metadata-File Consistency

**Problem**: Metadata in prefs and coordinate files could become inconsistent (file deleted but metadata remains, or vice versa)

**Solution**:
1. **On Load**: Validate file existence for each metadata entry, remove orphaned metadata
2. **On Cleanup**: Delete coordinate files that don't have corresponding metadata
3. **Transactional Saves**: Save metadata first, then coordinates (if metadata save fails, nothing persists)
4. **Error Recovery**: If coordinate file missing, show tracklog in list as "corrupted" with error indicator

### Concurrent Modification

**Problem**: User might trigger operations while background tasks are running

**Solution**:
- Simple locking: Disable UI buttons during save/load/delete operations
- No complex locking needed: Single-user app, operations are fast (<300ms)

### Memory Management

**Problem**: Loading 20+ tracks with 5000 points each could consume significant memory

**Solution**:
- **Lazy Loading**: Only load coordinates when tracklog visible on map
- **Cache Eviction**: If memory pressure detected, evict least recently used tracks from cache (keep metadata)
- **Existing Pattern**: Map already handles multiple tracks efficiently, no changes needed to rendering logic

---

## Testing Considerations

### Unit Tests

- TracklogMetadata serialization/deserialization (toJson/fromJson)
- TracklogStorageService mock implementation for testing
- Validation rules (name trimming, empty name rejection)

### Integration Tests

- Save tracklog → Close app → Reopen → Verify tracklog appears
- Add 20 tracklogs → Verify list scrolling performance
- Toggle visibility → Verify map updates
- Remove tracklog → Verify file deleted

### Edge Cases

- Empty tracklog list (show empty state)
- Tracklog with 1 coordinate (center to point with reasonable zoom)
- Corrupted coordinate file (show error indicator, allow deletion)
- Duplicate names (allowed per clarification session)
- Very long name (truncate in UI, store full in metadata)

---

## Migration Path

**Current State**: Tracks stored in memory only (`_tracks` list in MapScreen), lost on app restart

**Target State**: Tracks persisted with metadata in prefs, coordinates in files

**Migration Strategy**: No migration needed
- Current implementation has no persistence, so no existing data to migrate
- First release of this feature starts with empty tracklog list
- Users will import tracklogs fresh into new persistent system

---

## Conclusion

Data model defined with clear separation between lightweight metadata (for list display) and full coordinate data (for map rendering). Persistence strategy leverages shared_preferences for fast metadata access and file system for large coordinate arrays. Design supports all specified requirements while maintaining simplicity and following Flutter best practices.
