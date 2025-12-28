import 'package:latlong2/latlong.dart';
import 'location_type.dart';

/// Represents location data for display on the map
class LocationData {
  final LatLng coordinates;
  final LocationType type;
  final double? accuracy;
  final DateTime? timestamp;

  LocationData({
    required this.coordinates,
    required this.type,
    this.accuracy,
    this.timestamp,
  });

  /// Create LocationData for user's current location
  factory LocationData.current({
    required double latitude,
    required double longitude,
    double? accuracy,
  }) {
    return LocationData(
      coordinates: LatLng(latitude, longitude),
      type: LocationType.current,
      accuracy: accuracy,
      timestamp: DateTime.now(),
    );
  }

  /// Create LocationData for last known cached location
  factory LocationData.lastKnown({
    required double latitude,
    required double longitude,
    DateTime? timestamp,
  }) {
    return LocationData(
      coordinates: LatLng(latitude, longitude),
      type: LocationType.lastKnown,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Create LocationData for default location
  factory LocationData.defaultLocation({
    required double latitude,
    required double longitude,
  }) {
    return LocationData(
      coordinates: LatLng(latitude, longitude),
      type: LocationType.defaultLocation,
    );
  }

  /// Get banner message based on location type
  String get bannerMessage {
    switch (type) {
      case LocationType.current:
        return 'Your location';
      case LocationType.lastKnown:
        return 'Last known location';
      case LocationType.defaultLocation:
        return 'Default location: Ho Chi Minh City';
    }
  }

  /// Get marker color based on location type
  /// Blue for user/last known, red for default
  bool get isUserLocation => type == LocationType.current || type == LocationType.lastKnown;
}
