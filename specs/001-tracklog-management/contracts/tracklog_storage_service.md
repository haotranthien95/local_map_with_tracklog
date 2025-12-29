# Service Contract: TracklogStorageService

**Purpose**: Persist and retrieve tracklog metadata and coordinate data across application sessions.

**Implementation Path**: `lib/services/tracklog_storage_service.dart`

---

## Interface Definition

```dart
/// Service for persistent storage of tracklogs
abstract class TracklogStorageService {
  /// Save a new tracklog with full data (metadata + coordinates)
  /// 
  /// Parameters:
  ///   - track: Complete Track entity with coordinates
  /// 
  /// Behavior:
  ///   - Generates TracklogMetadata from Track
  ///   - Saves metadata to shared_preferences
  ///   - Serializes coordinates to JSON file
  ///   - Adds tracklog ID to ordered list
  /// 
  /// Returns: Future that completes when save is successful
  /// 
  /// Throws: StorageException if save fails (disk full, permissions, etc.)
  Future<void> saveTracklog(Track track);

  /// Load all tracklog metadata (fast operation for list display)
  /// 
  /// Returns: List of TracklogMetadata sorted by importedAt (newest first)
  /// 
  /// Behavior:
  ///   - Loads metadata from shared_preferences
  ///   - Validates file existence for each entry
  ///   - Removes orphaned metadata (file missing)
  ///   - Returns empty list if no tracklogs stored
  /// 
  /// Throws: StorageException if prefs read fails
  Future<List<TracklogMetadata>> loadAllMetadata();

  /// Load full track data including coordinates for specific tracklog
  /// 
  /// Parameters:
  ///   - id: Tracklog unique identifier
  /// 
  /// Returns: Complete Track entity with all coordinates
  /// 
  /// Behavior:
  ///   - Reads coordinate file from documents directory
  ///   - Deserializes JSON to Track entity
  ///   - Preserves all original track properties
  /// 
  /// Throws:
  ///   - TracklogNotFoundException if ID not found
  ///   - StorageException if file read/parse fails
  Future<Track> loadTrack(String id);

  /// Update tracklog metadata only (name, color, visibility)
  /// 
  /// Parameters:
  ///   - metadata: Updated TracklogMetadata
  /// 
  /// Behavior:
  ///   - Updates metadata in shared_preferences
  ///   - Preserves coordinate file unchanged
  ///   - Fast operation (<20ms)
  /// 
  /// Throws:
  ///   - TracklogNotFoundException if ID not found
  ///   - StorageException if prefs write fails
  Future<void> updateMetadata(TracklogMetadata metadata);

  /// Delete tracklog permanently (metadata and coordinate file)
  /// 
  /// Parameters:
  ///   - id: Tracklog unique identifier
  /// 
  /// Behavior:
  ///   - Removes metadata from shared_preferences
  ///   - Deletes coordinate file from file system
  ///   - Removes ID from tracklog list
  ///   - No-op if ID not found (idempotent)
  /// 
  /// Throws: StorageException if deletion fails
  Future<void> deleteTracklog(String id);

  /// Cleanup orphaned coordinate files (files without metadata)
  /// 
  /// Returns: Number of files deleted
  /// 
  /// Behavior:
  ///   - Scans tracklogs directory
  ///   - Deletes files with IDs not in metadata
  ///   - Called on app start (maintenance task)
  /// 
  /// Throws: StorageException if file system access fails
  Future<int> cleanupOrphanedFiles();
}
```

---

## Data Structures

### TracklogMetadata

```dart
class TracklogMetadata {
  final String id;
  final String name;
  final Color color;
  final bool isVisible;
  final String filePath;
  final DateTime importedAt;
  final String importedFrom;
  final TrackFormat format;
  final double boundsNorth;
  final double boundsSouth;
  final double boundsEast;
  final double boundsWest;

  TracklogMetadata({
    required this.id,
    required this.name,
    required this.color,
    required this.isVisible,
    required this.filePath,
    required this.importedAt,
    required this.importedFrom,
    required this.format,
    required this.boundsNorth,
    required this.boundsSouth,
    required this.boundsEast,
    required this.boundsWest,
  });

  /// Serialize to JSON for storage
  Map<String, dynamic> toJson();

  /// Deserialize from JSON
  factory TracklogMetadata.fromJson(Map<String, dynamic> json);

  /// Create metadata from Track entity
  factory TracklogMetadata.fromTrack(Track track);

  /// Create LatLngBounds from stored bounds
  LatLngBounds get bounds;
}
```

### Exceptions

```dart
class StorageException implements Exception {
  final String message;
  final dynamic cause;
  StorageException(this.message, [this.cause]);
}

class TracklogNotFoundException implements Exception {
  final String id;
  TracklogNotFoundException(this.id);
}
```

---

## Implementation Requirements

### Storage Strategy

**shared_preferences keys**:
- `tracklog_ids`: JSON array `["id1", "id2", "id3"]` (ordered newest first)
- `tracklog_<id>`: JSON string of TracklogMetadata

**File system structure**:
```
{Application Documents Directory}/
└── tracklogs/
    ├── {uuid-1}.json
    ├── {uuid-2}.json
    └── {uuid-3}.json
```

### Transactional Guarantees

1. **Save Operation**:
   - Write metadata to prefs first
   - If metadata write succeeds, write coordinate file
   - If coordinate write fails, rollback metadata
   - Atomic: either both succeed or neither

2. **Update Operation**:
   - Only touches metadata, no coordination needed
   - Single prefs write is atomic

3. **Delete Operation**:
   - Delete metadata first (source of truth)
   - Then delete file (if fails, cleanup will handle)
   - Prefer leaving orphaned file over orphaned metadata

### Performance Targets

| Operation | Target | Notes |
|-----------|--------|-------|
| saveTracklog() | <300ms | Depends on track size |
| loadAllMetadata() | <50ms | For 20 tracklogs |
| loadTrack() | <200ms | For 5000 point track |
| updateMetadata() | <20ms | Prefs write only |
| deleteTracklog() | <50ms | Prefs + file delete |
| cleanupOrphanedFiles() | <100ms | Infrequent operation |

### Error Handling

**Disk Full**:
- Catch and wrap in StorageException
- User-friendly message: "Unable to save tracklog. Storage may be full."

**Permission Denied**:
- Should never happen (app documents directory)
- If occurs, treat as StorageException

**Corrupted Data**:
- Invalid JSON: Log error, skip tracklog, continue loading others
- Missing file: Remove metadata entry, log warning

**Concurrent Access**:
- shared_preferences handles concurrent reads/writes
- File operations: Single-threaded (UI thread), no locking needed

---

## Usage Examples

### Save New Tracklog

```dart
final service = TracklogStorageServiceImpl();

// After user imports and names tracklog
final track = Track(
  id: uuid.v4(),
  name: userEnteredName,
  coordinates: parsedCoordinates,
  color: Color(0xFF2196F3), // Default blue
  isVisible: true,
  // ... other fields
);

try {
  await service.saveTracklog(track);
  // Track now persisted, will survive app restart
} catch (e) {
  // Show error to user
}
```

### Load All Tracklogs on App Start

```dart
final service = TracklogStorageServiceImpl();

// In initState or app startup
final metadataList = await service.loadAllMetadata();

// metadataList contains lightweight metadata for list display
// Load full coordinates only for visible tracks:
for (final metadata in metadataList.where((m) => m.isVisible)) {
  final track = await service.loadTrack(metadata.id);
  // Render track on map
}
```

### Update Tracklog Name

```dart
// User renamed tracklog in list
final updatedMetadata = metadata.copyWith(name: newName);
await service.updateMetadata(updatedMetadata);
// Metadata updated, coordinates unchanged
```

### Delete Tracklog

```dart
// User confirmed deletion
await service.deleteTracklog(tracklogId);
// Both metadata and coordinate file removed
```

### Cleanup on App Start

```dart
// Background task during app initialization
final deletedCount = await service.cleanupOrphanedFiles();
if (deletedCount > 0) {
  print('Cleaned up $deletedCount orphaned files');
}
```

---

## Testing Strategy

### Unit Tests

1. **Serialization**:
   - TracklogMetadata.toJson() → fromJson() round-trip
   - Color serialization (ARGB int format)
   - DateTime serialization (ISO 8601)

2. **Mock Service**:
   - In-memory implementation for testing
   - Simulates delays, errors for testing

### Integration Tests

1. **Persistence**:
   - Save → reload → verify data matches
   - Save multiple → verify order preserved
   - Update → reload → verify changes applied

2. **File System**:
   - Verify files created in correct directory
   - Verify orphaned file cleanup works
   - Verify file deletion on tracklog removal

3. **Error Scenarios**:
   - Corrupted JSON → graceful handling
   - Missing file → metadata cleanup
   - Disk full simulation → proper error

### Performance Tests

1. **Load 20 tracklogs** → verify <50ms for metadata
2. **Load large track** (5000 points) → verify <200ms
3. **Rapid updates** (10 consecutive) → verify UI responsive

---

## Migration Considerations

**V1 (Current)**: No persistence, in-memory only

**V2 (This Feature)**: shared_preferences + file system

**Migration**: None needed - fresh start, no existing data to migrate

**Future Migration** (if storage format changes):
- Version field in metadata JSON
- Migration code in loadAllMetadata()
- Support reading old format, always save new format

---

## Dependencies

**Required Packages**:
- `shared_preferences: ^2.2.0` - Metadata storage
- `path_provider: ^2.1.0` - Already in project for documents directory
- `dart:convert` - Built-in JSON serialization
- `dart:io` - Built-in file I/O

**No Additional Dependencies**: Leverages existing project packages

---

## Related Contracts

- [tracklog_metadata.md](./tracklog_metadata.md) - TracklogMetadata entity definition
- [dialog_helpers.md](./dialog_helpers.md) - Name input dialog (creates tracklogs)
- [tracklog_list_screen.md](./tracklog_list_screen.md) - UI that displays loaded metadata

---

## Implementation Notes

1. **File Naming**: Use UUID as filename to avoid name collisions and special character issues
2. **JSON Format**: Use pretty printing in dev builds for debugging, compact in release
3. **Backup**: Consider future enhancement to export all tracklogs as single archive
4. **Platform Differences**: shared_preferences handles iOS/Android automatically
5. **Thread Safety**: All operations on main isolate, no multithreading concerns
