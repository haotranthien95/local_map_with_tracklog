import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/map_tile.dart';

/// Service interface for tile caching operations
abstract class TileCacheService {
  /// Check if a specific tile is cached
  Future<bool> isTileCached(String styleId, int zoom, int x, int y);

  /// Get a cached tile by coordinates
  Future<MapTile?> getTile(String styleId, int zoom, int x, int y);

  /// Save a tile to cache
  Future<void> saveTile(MapTile tile);

  /// Get cache information and statistics
  Future<CacheInfo> getCacheInfo();

  /// Clear all cached tiles
  Future<void> clearCache();

  /// Evict oldest cached tiles
  Future<void> evictOldest(int count);

  /// Check if storage warning should be shown
  Future<bool> shouldShowStorageWarning();
}

/// Implementation of TileCacheService using file system
class TileCacheServiceImpl implements TileCacheService {
  static const String _cacheSubDir = 'tile_cache';
  static const double _storageWarningThreshold = 0.8;

  late final Directory _cacheDirectory;
  bool _initialized = false;

  /// Initialize the cache service with path_provider
  Future<void> initialize() async {
    if (_initialized) return;

    // Get application documents directory
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDirectory = Directory('${appDir.path}/$_cacheSubDir');

    // Create cache directory if it doesn't exist
    if (!await _cacheDirectory.exists()) {
      await _cacheDirectory.create(recursive: true);
    }

    _initialized = true;
  }

  @override
  Future<bool> isTileCached(String styleId, int zoom, int x, int y) async {
    await initialize();
    final file = File('${_cacheDirectory.path}/$styleId/$zoom/$x/$y.png');
    return await file.exists();
  }

  @override
  Future<MapTile?> getTile(String styleId, int zoom, int x, int y) async {
    await initialize();
    final file = File('${_cacheDirectory.path}/$styleId/$zoom/$x/$y.png');

    if (!await file.exists()) return null;

    final imageData = await file.readAsBytes();
    final stat = await file.stat();

    return MapTile(
      styleId: styleId,
      zoom: zoom,
      x: x,
      y: y,
      imageData: imageData,
      cachedAt: stat.modified,
      fileSize: stat.size,
    );
  }

  @override
  Future<void> saveTile(MapTile tile) async {
    await initialize();
    final file = File('${_cacheDirectory.path}/${tile.filePath}');

    // Create parent directories if they don't exist
    await file.parent.create(recursive: true);

    // Write tile data to file
    await file.writeAsBytes(tile.imageData);
  }

  @override
  Future<CacheInfo> getCacheInfo() async {
    await initialize();

    int totalSize = 0;
    int tileCount = 0;

    // Recursively scan cache directory
    if (await _cacheDirectory.exists()) {
      await for (final entity in _cacheDirectory.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.png')) {
          final stat = await entity.stat();
          totalSize += stat.size;
          tileCount++;
        }
      }
    }

    // Get device storage info (if available)
    int? deviceStorage;
    try {
      // This is platform-specific and may not be available on all platforms
      // For now, we'll use a rough estimate or skip it
      deviceStorage = null;
    } catch (e) {
      deviceStorage = null;
    }

    return CacheInfo(
      totalSizeBytes: totalSize,
      tileCount: tileCount,
      storageWarningThreshold: _storageWarningThreshold,
      deviceStorageBytes: deviceStorage,
    );
  }

  @override
  Future<void> clearCache() async {
    await initialize();

    if (await _cacheDirectory.exists()) {
      await _cacheDirectory.delete(recursive: true);
      await _cacheDirectory.create(recursive: true);
    }
  }

  @override
  Future<void> evictOldest(int count) async {
    await initialize();

    // Get all tile files with their modification times
    final tiles = <File, DateTime>{};

    await for (final entity in _cacheDirectory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.png')) {
        final stat = await entity.stat();
        tiles[entity] = stat.modified;
      }
    }

    // Sort by modification time (oldest first)
    final sortedTiles = tiles.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

    // Delete oldest tiles
    for (int i = 0; i < count && i < sortedTiles.length; i++) {
      await sortedTiles[i].key.delete();
    }
  }

  @override
  Future<bool> shouldShowStorageWarning() async {
    final cacheInfo = await getCacheInfo();

    // If device storage is not available, use a simple threshold (e.g., 500 MB)
    if (cacheInfo.deviceStorageBytes == null) {
      return cacheInfo.totalSizeBytes > 500 * 1024 * 1024; // 500 MB
    }

    return cacheInfo.shouldShowWarning;
  }
}
