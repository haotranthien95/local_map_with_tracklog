# Service Contract: LocationService

**Feature**: 002-navigation-location-ui  
**Date**: December 29, 2025  
**Purpose**: Define the interface for device location tracking service

---

## Interface Definition

### LocationService (Abstract Class)

**Responsibility**: Provides device location updates and manages location permission state.

**Lifecycle**: 
- Created once by the MapScreen widget
- Active when MapScreen is visible
- Disposed when MapScreen is disposed

---

## Methods

### `Future<bool> requestPermission()`

**Purpose**: Request location permissions from the user.

**Parameters**: None

**Returns**: 
- `true` if permission granted (whileInUse or always)
- `false` if permission denied or deniedForever

**Side Effects**:
- May show system permission dialog
- Checks current permission status first
- Handles deniedForever case by returning false (caller should show settings dialog)

**Error Handling**:
- Returns `false` on any exception
- Does not throw

**Example**:
```dart
final hasPermission = await locationService.requestPermission();
if (!hasPermission) {
  // Show user a message or disable location features
}
```

---

### `Stream<DeviceLocation> get locationStream`

**Purpose**: Provides continuous stream of device location updates.

**Returns**: 
- Stream that emits `DeviceLocation` objects
- Stream is hot (starts immediately when subscribed)
- Stream continues until service is disposed

**Behavior**:
- Emits new location when device moves (respects distanceFilter)
- Only emits if permission granted
- Stream is empty if permissions denied
- Updates `isActive` field based on GPS availability

**Configuration**:
- Accuracy: `LocationAccuracy.high` (balanced mode)
- Distance filter: 10 meters minimum movement
- Foreground only (no background tracking)

**Error Handling**:
- Does not emit errors for permission denial (just stops emitting)
- Emits last known location with `isActive: false` if GPS signal lost
- Stream never closes until service disposed

**Example**:
```dart
StreamSubscription<DeviceLocation>? _subscription;

_subscription = locationService.locationStream.listen(
  (DeviceLocation location) {
    setState(() {
      _currentLocation = location;
      _locationIndicatorState = LocationIndicatorState(
        position: LatLng(location.latitude, location.longitude),
        color: location.isActive ? Colors.blue : Colors.grey,
        isVisible: true,
      );
    });
  },
);

// Later, in dispose:
_subscription?.cancel();
```

---

### `Future<DeviceLocation?> getCurrentLocation()`

**Purpose**: Get a single location reading without subscribing to stream.

**Parameters**: None

**Returns**: 
- `DeviceLocation` object with current position
- `null` if location unavailable or permissions denied

**Timeout**: 5 seconds maximum wait

**Use Case**: 
- Initial "center on location" when map first loads
- One-time location requests without continuous tracking

**Error Handling**:
- Returns `null` on timeout
- Returns `null` if permissions denied
- Does not throw

**Example**:
```dart
final location = await locationService.getCurrentLocation();
if (location != null) {
  _mapController.move(
    LatLng(location.latitude, location.longitude),
    13.0,
  );
}
```

---

### `bool get hasPermission`

**Purpose**: Synchronously check if location permission is currently granted.

**Returns**: 
- `true` if whileInUse or always permission granted
- `false` if denied, deniedForever, or not yet requested

**Use Case**:
- Check before attempting to use location features
- Update UI based on permission state

**Example**:
```dart
if (locationService.hasPermission) {
  // Show "center on location" button
} else {
  // Show "enable location" prompt
}
```

---

### `void dispose()`

**Purpose**: Clean up location tracking resources.

**Side Effects**:
- Cancels location stream subscriptions
- Stops GPS updates
- Releases system resources

**Must be called**: In MapScreen's dispose() method

**Example**:
```dart
@override
void dispose() {
  _locationService.dispose();
  super.dispose();
}
```

---

## Implementation Requirements

### Platform Configuration

**Android (AndroidManifest.xml)**:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS (Info.plist)**:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to display your position on the map and help you navigate.</string>
```

### Dependencies
- `geolocator` package (10.1.0, already in pubspec.yaml)
- `latlong2` package (for LatLng, already in project)

### Thread Safety
- All methods can be called from main UI thread
- Stream updates delivered on main thread
- No explicit synchronization needed (single-threaded Dart)

---

## Error Scenarios

| Scenario | Expected Behavior |
|----------|-------------------|
| Permission denied | `locationStream` stops emitting, `hasPermission` returns false |
| GPS disabled | `locationStream` emits last known location with `isActive: false` |
| Airplane mode | Same as GPS disabled |
| App backgrounded | Location updates stop (foreground-only tracking) |
| Service disposed while stream active | Stream closes gracefully, no errors |
| Multiple permission requests | Only one system dialog shown, subsequent calls return cached state |
| Location timeout | `getCurrentLocation()` returns null after 5 seconds |

---

## Testing Contract

### Unit Tests (When Required)
- Mock geolocator package
- Test permission state transitions
- Test stream emission behavior
- Test disposal cleanup

### Manual Testing
- Grant permissions → Verify blue indicator appears
- Deny permissions → Verify no indicator, app still functional
- Disable GPS → Verify gray indicator at last position
- Move device → Verify indicator updates position
- Background app → Verify location updates stop

---

## Implementation Notes

### Simple Implementation Strategy
```dart
class LocationServiceImpl implements LocationService {
  StreamController<DeviceLocation>? _controller;
  StreamSubscription<Position>? _positionSubscription;
  bool _isDisposed = false;

  @override
  Future<bool> requestPermission() async {
    // Implementation using Geolocator.checkPermission/requestPermission
  }

  @override
  Stream<DeviceLocation> get locationStream {
    _controller ??= StreamController<DeviceLocation>.broadcast();
    _startLocationUpdates();
    return _controller!.stream;
  }

  void _startLocationUpdates() {
    // Subscribe to Geolocator.getPositionStream
    // Transform Position to DeviceLocation
    // Add to controller
  }

  @override
  Future<DeviceLocation?> getCurrentLocation() async {
    // Use Geolocator.getCurrentPosition with timeout
  }

  @override
  bool get hasPermission {
    // Check Geolocator.checkPermission synchronously (cached)
  }

  @override
  void dispose() {
    _isDisposed = true;
    _positionSubscription?.cancel();
    _controller?.close();
  }
}
```

### No Additional Complexity
- No caching layer needed (geolocator handles this)
- No database persistence required
- No state management beyond simple stream
- No custom permission UI (use system dialogs)

---

## Contract Version

**Version**: 1.0.0  
**Status**: Final  
**Last Updated**: December 29, 2025
