# Contracts Index

**Feature**: 001-offline-map-tracks  
**Purpose**: Service interfaces and contracts for offline map and track log functionality

---

## Service Contracts

### Core Services (P1 - MVP)

1. **[TileCacheService](./tile_cache_service.md)**
   - Manage map tile caching and storage
   - Check tile existence, save/load tiles, clear cache
   - Implementation: `lib/services/tile_cache_service.dart`

### Import Services (P2)

2. **[FilePickerService](./file_picker_service.md)**
   - Handle file selection from device storage
   - Native file picker integration (iOS/Android)
   - Implementation: `lib/services/file_picker_service.dart`

3. **[TrackParserService](./track_parser_service.md)**
   - Parse GPS track files (GPX, KML, GeoJSON, FIT, TCX, CSV, NMEA)
   - Validate and simplify tracks
   - Implementation: `lib/services/track_parser_service.dart`

---

## Data Flow Contracts

### Map Tile Flow
```
User browses map
    ↓
MapView widget requests tiles
    ↓
TileCacheService.isTileCached(styleId, z, x, y)
    ↓
├─ true → TileCacheService.getTile() → Display tile
└─ false → Download from tile server → TileCacheService.saveTile() → Display tile
```

### Track Import Flow
```
User taps "Import Track"
    ↓
FilePickerService.pickTrackFile(allowedExtensions)
    ↓
└─ Returns FilePickResult or null (cancelled)
    ↓
TrackParserService.detectFormat(fileName)
    ↓
TrackParserService.parseTrackFile(path, format)
    ↓
TrackParserService.validateTrack(track)
    ↓
├─ valid → Display track on map
└─ invalid → Show error message to user
```

### Style Switch Flow
```
User selects new map style
    ↓
Update active MapStyle state
    ↓
MapView widget re-renders with new styleId
    ↓
TileCacheService requests tiles for new style
    ↓
(follows Map Tile Flow above)
```

---

## Error Handling Contracts

All services follow consistent error handling patterns:

### Exceptions
- **TileCacheException**: Thrown when tile operations fail (I/O errors, storage full)
- **TrackParseException**: Thrown when track parsing fails (invalid format, corrupted data)
- **FilePickerException**: Thrown when file selection fails (permissions, system errors)

### Error Messages
Must be user-friendly and actionable:
- ✅ "Storage full. Please free up space and try again."
- ✅ "Invalid GPX file: missing track data."
- ❌ "IOException: ENOSPC"

### Null Returns vs Exceptions
- **Return null**: User cancellation, optional data not found (e.g., pickTrackFile cancelled)
- **Throw exception**: Actual errors that prevent operation (permissions, I/O failures)

---

## Testing Contracts

### Unit Tests
Each service must have:
- Happy path tests (valid inputs, expected outputs)
- Error case tests (invalid inputs, exception handling)
- Edge case tests (empty data, boundary conditions)

### Mock Implementations
Provide test doubles for:
- `MockTileCacheService`: In-memory cache for testing
- `MockTrackParserService`: Parse from test fixtures
- `MockFilePickerService`: Return predefined file results

### Test Fixtures
Located in `test/fixtures/`:
- `sample_track.gpx`: Valid GPX with 100 points
- `large_track.gpx`: GPX with 10,000 points (performance test)
- `invalid_track.gpx`: Malformed GPX (error handling test)
- `empty_track.gpx`: GPX with no coordinates (validation test)

---

## Implementation Priority

**Phase 1 (P1 - MVP)**:
1. TileCacheService (basic: save, load, check existence)
2. Integration with flutter_map for tile display

**Phase 2 (P2)**:
1. FilePickerService (GPX only)
2. TrackParserService (GPX format only)
3. Track display on map

**Phase 3 (P3)**:
1. TileCacheService enhancements (statistics, eviction)
2. Multiple map styles support

**Phase 4 (P4)**:
1. TrackParserService (additional formats: KML, GeoJSON, FIT, TCX, CSV, NMEA)
2. FilePickerService (multi-file selection)

---

## API Design Principles

These contracts follow Flutter/Dart conventions:

1. **Async by default**: All I/O operations return `Future<T>`
2. **Named parameters**: Optional parameters use named syntax with defaults
3. **Null safety**: Explicit `?` for nullable returns, `!` for non-null assertions avoided
4. **Immutable data**: Result classes are immutable (final fields)
5. **Clear naming**: Method names describe action (parse, pick, save, get)
6. **Single responsibility**: Each service has one clear purpose
7. **Dependency injection**: Services are abstract interfaces (allow mocking)

---

## Related Documentation

- [Data Model](../data-model.md): Entity definitions and relationships
- [Research](../research.md): Technology decisions and rationale
- [Quickstart](../quickstart.md): Setup and development instructions
