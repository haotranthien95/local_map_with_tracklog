import 'package:latlong2/latlong.dart';

/// Represents a single device location reading from GPS/GNSS with metadata
class DeviceLocation {
  /// Latitude coordinate in decimal degrees (-90 to +90)
  final double latitude;

  /// Longitude coordinate in decimal degrees (-180 to +180)
  final double longitude;

  /// Horizontal accuracy in meters (larger values = less accurate)
  final double accuracy;

  /// When this location was captured
  final DateTime timestamp;

  /// Whether location services are currently providing updates
  final bool isActive;

  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    required this.isActive,
  });

  /// Converts to LatLng for map display
  LatLng toLatLng() => LatLng(latitude, longitude);

  @override
  String toString() {
    return 'DeviceLocation(lat: $latitude, lng: $longitude, accuracy: ${accuracy}m, active: $isActive)';
  }

  /// Creates a copy with optional field updates
  DeviceLocation copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? timestamp,
    bool? isActive,
  }) {
    return DeviceLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      isActive: isActive ?? this.isActive,
    );
  }
}
