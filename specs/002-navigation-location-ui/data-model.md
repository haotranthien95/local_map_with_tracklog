# Data Model: Bottom Navigation and Live Location Tracking

**Feature**: 002-navigation-location-ui  
**Date**: December 29, 2025  
**Status**: Complete

## Overview

This document defines the data structures and entities for implementing bottom navigation and live device location tracking. All models are designed to be simple, immutable where possible, and follow Dart/Flutter conventions.

---

## 1. DeviceLocation

**Purpose**: Represents a single device location reading from GPS/GNSS with metadata.

**Attributes**:
- `latitude` (double): Latitude coordinate in decimal degrees (-90 to +90)
- `longitude` (double): Longitude coordinate in decimal degrees (-180 to +180)
- `accuracy` (double): Horizontal accuracy in meters (larger values = less accurate)
- `timestamp` (DateTime): When this location was captured
- `isActive` (bool): Whether location services are currently providing updates

**Relationships**: None (standalone value object)

**Validation Rules**:
- Latitude must be between -90 and +90
- Longitude must be between -180 and +180
- Accuracy must be positive (> 0)
- Timestamp cannot be in the future

**State Transitions**:
- N/A (immutable value object, new instances created for each update)

**Usage**:
```dart
final location = DeviceLocation(
  latitude: 37.7749,
  longitude: -122.4194,
  accuracy: 10.5,
  timestamp: DateTime.now(),
  isActive: true,
);
```

---

## 2. LocationIndicatorState

**Purpose**: Represents the visual state of the location indicator dot on the map.

**Attributes**:
- `position` (LatLng?): Current position to display indicator (null if no location)
- `color` (Color): Display color (blue for active, gray for inactive)
- `isVisible` (bool): Whether indicator should be shown at all

**Relationships**: 
- Derived from `DeviceLocation` model
- Used by `LocationIndicator` widget

**Validation Rules**:
- If `isVisible` is true, `position` must not be null
- Color must be either blue (active) or gray (inactive)

**State Transitions**:
1. **No Location → First Location**: `isVisible: false` → `isVisible: true, color: blue`
2. **Active → Inactive**: `color: blue` → `color: gray` (when location updates stop)
3. **Inactive → Active**: `color: gray` → `color: blue` (when location updates resume)
4. **Location Update**: Update `position` while maintaining `color` and `isVisible`

**Usage**:
```dart
// Active location
final activeState = LocationIndicatorState(
  position: LatLng(37.7749, -122.4194),
  color: Colors.blue,
  isVisible: true,
);

// Inactive (no updates but last known position)
final inactiveState = LocationIndicatorState(
  position: LatLng(37.7749, -122.4194),
  color: Colors.grey,
  isVisible: true,
);

// No location ever obtained
final noLocationState = LocationIndicatorState(
  position: null,
  color: Colors.grey,
  isVisible: false,
);
```

---

## 3. NavigationTab

**Purpose**: Represents a single tab in the bottom navigation bar with its configuration.

**Attributes**:
- `index` (int): Position in the tab bar (0-based: 0=Dashboard, 1=Map, 2=Settings)
- `icon` (IconData): Icon to display in tab
- `label` (String): Text label for tab
- `screen` (Widget): The screen widget to display when tab is selected

**Relationships**: 
- Collection of tabs managed by `HomeScreen`
- Associated with screen widgets (DashboardScreen, MapScreen, SettingsScreen)

**Validation Rules**:
- Index must be >= 0 and unique within tab collection
- Label must not be empty
- Screen must not be null

**State Transitions**:
- N/A (static configuration, tabs don't change at runtime)

**Usage**:
```dart
final tabs = [
  NavigationTab(
    index: 0,
    icon: Icons.dashboard,
    label: 'Dashboard',
    screen: DashboardScreen(),
  ),
  NavigationTab(
    index: 1,
    icon: Icons.map,
    label: 'Map',
    screen: MapScreen(),
  ),
  NavigationTab(
    index: 2,
    icon: Icons.settings,
    label: 'Settings',
    screen: SettingsScreen(),
  ),
];
```

**Note**: This may be implemented as a simple list of BottomNavigationBarItem instead of a formal class, depending on implementation simplicity.

---

## 4. MapInformation

**Purpose**: Collection of current map state values for display in the info overlay.

**Attributes**:
- `styleName` (String): Human-readable name of current map style (e.g., "Standard", "Satellite")
- `zoomLevel` (double): Current zoom level (typically 0-20)
- `centerLatitude` (double): Latitude of map center in decimal degrees
- `centerLongitude` (double): Longitude of map center in decimal degrees

**Relationships**: 
- Derived from `MapController.camera` and current `MapStyle`
- Used by map info display widget

**Validation Rules**:
- Style name must not be empty
- Zoom level must be >= 0
- Center latitude must be between -90 and +90
- Center longitude must be between -180 and +180

**State Transitions**:
- Updates on every map pan, zoom, or style change
- Continuous updates during user interaction

**Usage**:
```dart
final mapInfo = MapInformation(
  styleName: 'Standard',
  zoomLevel: 13.5,
  centerLatitude: 37.7749,
  centerLongitude: -122.4194,
);

// Format for display:
final display = '''
Type: ${mapInfo.styleName}
Zoom: ${mapInfo.zoomLevel.toStringAsFixed(1)}
Lat: ${mapInfo.centerLatitude.toStringAsFixed(4)}°
Lng: ${mapInfo.centerLongitude.toStringAsFixed(4)}°
''';
```

---

## Entity Relationships Diagram

```
┌─────────────────┐
│  DeviceLocation │
│  (from service) │
└────────┬────────┘
         │
         │ transforms to
         │
         ▼
┌──────────────────────┐
│ LocationIndicatorState│───► Used by LocationIndicator widget
│   (for display)      │     (visual representation on map)
└──────────────────────┘

┌─────────────────┐
│  NavigationTab  │───► Used by HomeScreen
│  (config data)  │     (bottom navigation bar)
└─────────────────┘

┌─────────────────┐
│ MapInformation  │───► Used by MapInfoDisplay widget
│ (derived state) │     (bottom-left overlay)
└─────────────────┘
```

---

## Implementation Notes

### Immutability
- **DeviceLocation**: Immutable (create new instance for each location update)
- **LocationIndicatorState**: Immutable (create new instance when state changes)
- **NavigationTab**: Immutable (static configuration)
- **MapInformation**: Immutable (create new instance on each map change)

### Data Flow
1. **Location Updates**:
   - GPS → DeviceLocation → LocationIndicatorState → UI update

2. **Navigation**:
   - User tap → Update selected index → IndexedStack shows different screen

3. **Map Information**:
   - Map interaction → MapController → MapInformation → Display update

### Serialization
Not required for this feature. All data is transient (runtime only):
- Location data not persisted
- Navigation state not saved between sessions
- Map information is display-only

### Type Safety
All models use strong typing:
- No dynamic types
- Enums for discrete states where appropriate (could add `LocationState` enum if needed)
- Null safety with explicit nullable types (e.g., `LatLng?`)

---

## Validation Summary

| Model | Key Validations | Error Handling |
|-------|----------------|----------------|
| DeviceLocation | Coordinate bounds, positive accuracy | Validated by geolocator, defensive checks in service |
| LocationIndicatorState | Visibility requires position | Enforced by state machine logic |
| NavigationTab | Non-empty label, valid index | Compile-time checks (const configuration) |
| MapInformation | Coordinate bounds, non-negative zoom | Derived from validated MapController state |

---

## Next Steps

Proceed to defining service contracts (contracts/location-service.md and contracts/map-controller.md) that use these data models.
