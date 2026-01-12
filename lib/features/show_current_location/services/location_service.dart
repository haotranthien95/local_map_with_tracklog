import 'package:geolocator/geolocator.dart';
import '../models/location_data.dart';
import '../constants/default_location.dart';

/// Service for managing location permissions and fetching location data
class LocationService {
  /// Check current location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission from user
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current location from device GPS
  /// Returns null if location is unavailable
  Future<LocationData?> getCurrentLocation() async {
    try {
      var permission = await checkPermission();

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
      }

      if (permission != LocationPermission.whileInUse) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      return LocationData.current(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } catch (e) {
      // Location unavailable (GPS off, timeout, etc.)
      return null;
    }
  }

  /// Get last known location from device cache
  /// Returns null if no cached location exists
  Future<LocationData?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;

      return LocationData.lastKnown(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: position.timestamp,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get default location (Ho Chi Minh City)
  LocationData getDefaultLocation() {
    return LocationData.defaultLocation(
      latitude: DefaultLocationConstants.latitude,
      longitude: DefaultLocationConstants.longitude,
    );
  }

  /// Determine best available location in priority order:
  /// 1. Current location (if permission granted and GPS available)
  /// 2. Last known location (if available)
  /// 3. Default location (Ho Chi Minh City)
  Future<LocationData> getBestAvailableLocation() async {
    // Try current location first
    final current = await getCurrentLocation();
    if (current != null) return current;

    // Try last known location
    final lastKnown = await getLastKnownLocation();
    if (lastKnown != null) return lastKnown;

    // Fallback to default
    return getDefaultLocation();
  }

  /// Check if location services are enabled on device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
