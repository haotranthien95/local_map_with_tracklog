import 'dart:typed_data';

/// Represents a single map tile in the cache
class MapTile {
  final String styleId;
  final int zoom;
  final int x;
  final int y;
  final Uint8List imageData;
  final DateTime cachedAt;
  final int fileSize;

  const MapTile({
    required this.styleId,
    required this.zoom,
    required this.x,
    required this.y,
    required this.imageData,
    required this.cachedAt,
    required this.fileSize,
  });

  /// Generate unique key for this tile
  String get key => '$styleId/$zoom/$x/$y';

  /// Generate file path for this tile
  String get filePath => '$styleId/$zoom/$x/$y.png';
}

/// Cache statistics and metadata
class CacheInfo {
  final int totalSizeBytes;
  final int tileCount;
  final double storageWarningThreshold;
  final int? deviceStorageBytes;

  const CacheInfo({
    required this.totalSizeBytes,
    required this.tileCount,
    this.storageWarningThreshold = 0.8,
    this.deviceStorageBytes,
  });

  /// Get total cache size in MB
  double get totalSizeMB => totalSizeBytes / (1024 * 1024);

  /// Check if storage warning should be shown
  bool get shouldShowWarning {
    if (deviceStorageBytes == null) return false;
    final usageRatio = totalSizeBytes / deviceStorageBytes!;
    return usageRatio >= storageWarningThreshold;
  }

  /// Get storage usage percentage
  double? get storageUsagePercent {
    if (deviceStorageBytes == null) return null;
    return (totalSizeBytes / deviceStorageBytes!) * 100;
  }
}
