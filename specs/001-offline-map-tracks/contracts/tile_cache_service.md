# Service Contract: TileCacheService

**Purpose**: Manage map tile caching, storage, and retrieval for offline map viewing.

**Implementation Path**: `lib/services/tile_cache_service.dart`

---

## Interface Definition

```dart
/// Service for managing cached map tiles
abstract class TileCacheService {
  /// Check if a tile is cached locally
  /// 
  /// Parameters:
  ///   - styleId: Map style identifier (e.g., "standard", "satellite")
  ///   - zoom: Zoom level (0-19)
  ///   - x: Tile X coordinate
  ///   - y: Tile Y coordinate
  /// 
  /// Returns: true if tile exists in cache, false otherwise
  Future<bool> isTileCached(String styleId, int zoom, int x, int y);

  /// Get cached tile image data
  /// 
  /// Parameters:
  ///   - styleId: Map style identifier
  ///   - zoom: Zoom level
  ///   - x: Tile X coordinate
  ///   - y: Tile Y coordinate
  /// 
  /// Returns: Image bytes if cached, null if not found
  /// 
  /// Throws: TileCacheException if file read fails
  Future<Uint8List?> getTile(String styleId, int zoom, int x, int y);

  /// Save tile image data to cache
  /// 
  /// Parameters:
  ///   - styleId: Map style identifier
  ///   - zoom: Zoom level
  ///   - x: Tile X coordinate
  ///   - y: Tile Y coordinate
  ///   - imageData: PNG/JPEG image bytes
  /// 
  /// Returns: void
  /// 
  /// Throws: TileCacheException if save fails or storage full
  Future<void> saveTile(String styleId, int zoom, int x, int y, Uint8List imageData);

  /// Get cache statistics
  /// 
  /// Returns: CacheInfo with size, tile count, and per-style breakdown
  Future<CacheInfo> getCacheInfo();

  /// Clear cache for specific style or all styles
  /// 
  /// Parameters:
  ///   - styleId: Optional style identifier; if null, clears all styles
  /// 
  /// Returns: Number of tiles deleted
  Future<int> clearCache({String? styleId});

  /// Evict oldest tiles to reduce cache size
  /// 
  /// Parameters:
  ///   - targetSizeBytes: Target cache size after eviction
  /// 
  /// Returns: Number of tiles evicted
  Future<int> evictOldest(int targetSizeBytes);

  /// Check if storage warning should be displayed
  /// 
  /// Returns: true if cache size >= 80% of available device storage
  /// 
  /// Note: Clarified 2025-12-28 - warning threshold at 80% capacity
  Future<bool> shouldShowStorageWarning();
}

/// Cache statistics and metadata
class CacheInfo {
  final int totalSizeBytes;
  final int tileCount;
  final DateTime? lastCleanupAt;
  final int maxSizeBytes;
  final Map<String, int> sizeByStyle;

  CacheInfo({
    required this.totalSizeBytes,
    required this.tileCount,
    this.lastCleanupAt,
    required this.maxSizeBytes,
    required this.sizeByStyle,
  });
}

/// Exception thrown by cache operations
class TileCacheException implements Exception {
  final String message;
  final dynamic cause;

  TileCacheException(this.message, [this.cause]);

  @override
  String toString() => 'TileCacheException: $message${cause != null ? ' ($cause)' : ''}';
}
```

---

## Behavior Requirements

### isTileCached
- **Preconditions**: Valid zoom (0-19), valid x/y for zoom level
- **Postconditions**: Returns true only if tile file exists and is readable
- **Error Handling**: Returns false on file system errors (don't throw)

### getTile
- **Preconditions**: Tile must exist (check with isTileCached first)
- **Postconditions**: Returns valid image bytes or null
- **Error Handling**: Throws TileCacheException if I/O error, returns null if not found

### saveTile
- **Preconditions**: Valid image data (PNG/JPEG format), sufficient storage space
- **Postconditions**: Tile saved to disk at `{cacheDir}/{styleId}/{zoom}/{x}/{y}.png`
- **Error Handling**: Throws TileCacheException if storage full or I/O error
- **Side Effects**: Creates directory structure if not exists, updates cache size

### getCacheInfo
- **Preconditions**: None
- **Postconditions**: Returns accurate cache statistics
- **Error Handling**: Returns empty CacheInfo if cache directory doesn't exist (don't throw)

### clearCache
- **Preconditions**: None (safe to call even if cache empty)
- **Postconditions**: All specified tiles deleted, cache statistics updated
- **Error Handling**: Continues on individual file deletion errors, returns count of successful deletions
- **Side Effects**: Frees disk space

### evictOldest
- **Preconditions**: targetSizeBytes < current cache size
- **Postconditions**: Cache size <= targetSizeBytes, oldest tiles removed first
- **Error Handling**: Throws TileCacheException if cannot reduce size below target
- **Side Effects**: Deletes tiles, updates cache statistics

### shouldShowStorageWarning
- **Preconditions**: None
- **Postconditions**: Returns accurate storage status
- **Error Handling**: Returns false on error (don't block operations)
- **Threshold**: 80% of available device storage (clarified 2025-12-28)
- **Calculation**: (totalSizeBytes / availableStorageBytes) >= 0.8

---

## Implementation Notes

**P1 (MVP)**: Implement using `flutter_map_cache` plugin or direct file system operations with `path_provider`

**Cache Directory Structure**:
```
{applicationDocumentsDirectory}/tile_cache/
├── standard/
│   ├── 12/
│   │   ├── 1234/
│   │   │   ├── 5678.png
│   │   │   └── 5679.png
│   └── 13/
├── satellite/
└── terrain/
```

**File Naming**: `{y}.png` (Y coordinate is the filename, X coordinate is the parent directory)

**Concurrency**: Operations should be thread-safe; consider using locks for write operations

**Performance**: isTileCached should be fast (<1ms), getTile should use async I/O
