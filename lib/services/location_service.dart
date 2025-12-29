import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/device_location.dart';

/// Abstract interface for location tracking services
abstract class LocationService {
  /// Request location permissions from the user
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestPermission();

  /// Check if location permission is granted
  /// Returns true if permission is available, false otherwise
  Future<bool> hasPermission();

  /// Stream of device location updates
  /// Emits DeviceLocation objects when position changes
  /// Returns null if permission denied or location unavailable
  Stream<DeviceLocation?> get locationStream;

  /// Get the current device location once
  /// Returns DeviceLocation if available, null if unavailable
  Future<DeviceLocation?> getCurrentLocation();

  /// Clean up resources and stop location updates
  void dispose();
}

/// Implementation of LocationService using geolocator package
class LocationServiceImpl implements LocationService {
  StreamController<DeviceLocation?>? _locationController;
  StreamSubscription<Position>? _positionSubscription;
  bool _isDisposed = false;

  @override
  Future<bool> requestPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Return true if we have any level of permission
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<DeviceLocation?> get locationStream {
    _locationController ??= StreamController<DeviceLocation?>.broadcast(
      onCancel: () {
        _positionSubscription?.cancel();
      },
    );

    // Start position stream if not already started
    if (_positionSubscription == null && !_isDisposed) {
      _startLocationUpdates();
    }

    return _locationController!.stream;
  }

  void _startLocationUpdates() async {
    // Check permission before starting
    bool permitted = await hasPermission();
    if (!permitted) {
      _locationController?.add(null);
      return;
    }

    // Configure location settings for optimal accuracy
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
    );

    // Subscribe to position stream
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        if (!_isDisposed) {
          final deviceLocation = DeviceLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            timestamp: position.timestamp,
            isActive: true,
          );
          _locationController?.add(deviceLocation);
        }
      },
      onError: (error) {
        if (!_isDisposed) {
          _locationController?.add(null);
        }
      },
    );
  }

  @override
  Future<DeviceLocation?> getCurrentLocation() async {
    try {
      // Check permission
      bool permitted = await hasPermission();
      if (!permitted) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return DeviceLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
        isActive: true,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _locationController?.close();
    _locationController = null;
  }
}
