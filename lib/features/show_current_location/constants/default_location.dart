import 'package:latlong2/latlong.dart';

/// Default location constants for Ho Chi Minh City
class DefaultLocationConstants {
  /// Ho Chi Minh City coordinates
  static const double latitude = 10.7769;
  static const double longitude = 106.7009;

  /// Label for default location
  static const String label = 'Ho Chi Minh City';

  /// Get default location as LatLng
  static LatLng get coordinates => const LatLng(latitude, longitude);

  /// Default zoom level for map
  static const double defaultZoom = 14.0;
}
