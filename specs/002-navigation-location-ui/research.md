# Research: Bottom Navigation and Live Location Tracking

**Feature**: 002-navigation-location-ui  
**Date**: December 29, 2025  
**Status**: Complete

## Overview

This document consolidates research findings for implementing bottom navigation with three tabs and live device location tracking in a Flutter application. All technical decisions are based on the existing project dependencies (geolocator 10.1.0, flutter_map 6.1.0) and Flutter best practices for maintainability.

---

## 1. Location Services Implementation

### Decision: Use Geolocator with StreamSubscription for Foreground Tracking

**Rationale**:
- Geolocator 10.1.0 is already included in pubspec.yaml
- Provides cross-platform location services with built-in permission handling
- Stream-based API fits naturally with Flutter's reactive programming model
- Supports foreground-only tracking with lifecycle management
- No additional dependencies required

**Implementation Approach**:
```dart
// Key APIs from geolocator package:
// 1. Check and request permissions
final permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  await Geolocator.requestPermission();
}

// 2. Get position stream with settings
final positionStream = Geolocator.getPositionStream(
  locationSettings: LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Meters before update
  ),
);

// 3. Subscribe to stream
StreamSubscription<Position>? _positionSubscription;
_positionSubscription = positionStream.listen((Position position) {
  // Update location indicator
});

// 4. Lifecycle management
@override
void dispose() {
  _positionSubscription?.cancel();
  super.dispose();
}
```

**Battery Optimization**:
- Use `LocationAccuracy.high` (not `best`) for balanced accuracy/battery
- Set `distanceFilter: 10` to reduce update frequency
- Cancel subscription when map screen not visible
- No background location tracking

**Alternatives Considered**:
- **location package**: Popular but geolocator is more actively maintained and already in project
- **Platform channels**: Too much complexity for straightforward location needs
- **flutter_location**: Redundant with geolocator already included

---

## 2. Bottom Navigation Patterns

### Decision: BottomNavigationBar with IndexedStack for State Preservation

**Rationale**:
- `BottomNavigationBar` is Flutter's built-in widget for tab navigation
- `IndexedStack` preserves widget state across tab switches (map position, zoom maintained)
- Simple integer index for selected tab state
- No additional packages needed
- Follows Material Design guidelines

**Implementation Approach**:
```dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Default to Map tab

  final List<Widget> _screens = [
    DashboardScreen(),
    MapScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
```

**State Preservation Benefits**:
- All three screens stay in memory (acceptable for 3 lightweight screens)
- Map maintains position, zoom, loaded tracks
- No need to serialize/deserialize state
- Instant tab switching with no rebuild delay

**Alternatives Considered**:
- **PageView + TabBar**: More complex, unnecessary swipe gestures
- **Navigator with named routes**: Overkill for simple 3-tab structure
- **AutomaticKeepAliveClientMixin**: IndexedStack is simpler and more explicit

---

## 3. Map Overlay Techniques

### Decision: flutter_map Layers with Custom MarkerLayer and Positioned Widget

**Rationale**:
- flutter_map 6.1.0 supports layered approach for custom overlays
- `MarkerLayer` for location indicator (existing flutter_map feature)
- `Positioned` widget with `Container` for map info overlay
- No need for custom painting unless performance issues observed
- Maintains separation of concerns

**Implementation Approach**:

**Location Indicator (Blue/Gray Dot)**:
```dart
// In MapView widget, add to FlutterMap layers:
MarkerLayer(
  markers: [
    if (_currentLocation != null)
      Marker(
        point: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        width: 20,
        height: 20,
        child: Container(
          decoration: BoxDecoration(
            color: _isLocationActive ? Colors.blue : Colors.grey,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
  ],
)
```

**Map Info Display (Bottom-Left Corner)**:
```dart
// Wrap FlutterMap in Stack:
Stack(
  children: [
    FlutterMap(
      options: _mapOptions,
      children: [...layers],
    ),
    Positioned(
      left: 8,
      bottom: 8,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Type: ${_mapStyle.name}\n'
          'Zoom: ${_currentZoom.toStringAsFixed(1)}\n'
          'Lat: ${_center.latitude.toStringAsFixed(4)}°\n'
          'Lng: ${_center.longitude.toStringAsFixed(4)}°',
          style: TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    ),
  ],
)
```

**Center on Location Button**:
```dart
// Use MapController for programmatic map control:
final MapController _mapController = MapController();

// In FloatingActionButton onPressed:
_mapController.move(
  LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
  _mapController.camera.zoom, // Maintain current zoom
);
```

**Alternatives Considered**:
- **CustomPainter**: More complex, only needed if performance issues with thousands of points
- **Third-party overlay libraries**: Unnecessary complexity for simple dot and text display
- **flutter_map plugins**: No existing plugin for this specific use case

---

## 4. Permission Handling

### Decision: Platform-Specific Configuration + Geolocator Permission APIs

**Rationale**:
- Location permissions required for both iOS and Android
- Geolocator handles runtime permission requests
- Platform-specific Info.plist and AndroidManifest.xml configuration mandatory
- Graceful degradation when permissions denied

**iOS Configuration (Info.plist)**:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to display your position on the map and help you navigate.</string>
```

**Android Configuration (AndroidManifest.xml)**:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**Runtime Permission Handling**:
```dart
class LocationService {
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Show dialog to open app settings
      return false;
    }
    
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
  }
}
```

**Graceful Degradation**:
- If permissions denied: Show gray indicator at last known location (if available)
- If no location ever obtained: Hide indicator completely
- Map functionality (viewing, panning, track import) continues to work
- No error dialogs unless user explicitly tries to use location feature

**Alternatives Considered**:
- **permission_handler package**: Redundant, geolocator includes permission handling
- **Always location permission**: Not needed, "while in use" sufficient for foreground-only tracking

---

## 5. Map Controller Access

### Decision: Use flutter_map's MapController for Programmatic Control

**Rationale**:
- flutter_map 6.1.0 provides `MapController` for programmatic map manipulation
- Can access current camera position (center, zoom, bounds)
- Supports animated movement with `move()` method
- Integrates with existing flutter_map setup

**Implementation Approach**:
```dart
// In MapView StatefulWidget:
final MapController _mapController = MapController();

// Pass to FlutterMap:
FlutterMap(
  mapController: _mapController,
  options: MapOptions(
    initialCenter: widget.initialCenter,
    initialZoom: widget.initialZoom,
    onPositionChanged: (MapPosition position, bool hasGesture) {
      // Update map info display
      setState(() {
        _currentCenter = position.center;
        _currentZoom = position.zoom;
      });
    },
  ),
  // ... layers
)

// Center on location:
void centerOnLocation(LatLng location) {
  _mapController.move(
    location,
    _mapController.camera.zoom, // Keep current zoom
  );
}

// Get current state:
MapCamera get currentCamera => _mapController.camera;
LatLng get currentCenter => _mapController.camera.center;
double get currentZoom => _mapController.camera.zoom;
```

**Animation Support**:
- `move()` provides smooth animation by default
- Can customize animation duration if needed
- Maintains current zoom level when centering

**Alternatives Considered**:
- **Direct state manipulation**: Would require complex coordinate calculations
- **GlobalKey for MapView**: MapController is more explicit and idiomatic

---

## Summary

All research questions resolved:

| Research Area | Decision | Key Dependencies |
|--------------|----------|------------------|
| Location Services | geolocator with StreamSubscription | geolocator 10.1.0 (existing) |
| Bottom Navigation | BottomNavigationBar + IndexedStack | Flutter SDK (built-in) |
| Map Overlays | MarkerLayer + Positioned widgets | flutter_map 6.1.0 (existing) |
| Permissions | Platform config + geolocator APIs | geolocator 10.1.0 (existing) |
| Map Control | MapController | flutter_map 6.1.0 (existing) |

**No new dependencies required.** All features can be implemented using existing packages and Flutter's standard widgets.

**Technical Risk Assessment**: LOW
- Well-established packages with stable APIs
- Standard Flutter patterns throughout
- No complex state management or custom rendering needed
- Existing project already using geolocator and flutter_map successfully

---

## Next Steps

Phase 1: Define data models, service contracts, and quickstart guide based on these research findings.
