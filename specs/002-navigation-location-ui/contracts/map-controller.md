# Widget Contract: MapView Enhancements

**Feature**: 002-navigation-location-ui  
**Date**: December 29, 2025  
**Purpose**: Define enhancements to existing MapView widget for location display and programmatic control

---

## Overview

The existing `MapView` widget will be enhanced with:
1. Location indicator overlay (blue/gray dot)
2. Map information display (bottom-left corner)
3. Programmatic map control (center on location)
4. Map state callbacks (for info updates)

**Principle**: Extend existing widget rather than creating new abstractions. Keep changes minimal and focused.

---

## Enhanced Widget Interface

### MapView (StatefulWidget)

**Existing Signature** (from current implementation):
```dart
class MapView extends StatefulWidget {
  final MapStyle mapStyle;
  final List<Track> tracks;
  final LatLng initialCenter;
  final double initialZoom;
  final Function(LatLngBounds)? onMapMoved;
  
  const MapView({
    Key? key,
    required this.mapStyle,
    required this.tracks,
    required this.initialCenter,
    required this.initialZoom,
    this.onMapMoved,
  }) : super(key: key);
}
```

**New Parameters** (add to constructor):
```dart
// Location tracking
final DeviceLocation? currentLocation;  // Null if no location available
final bool showLocationIndicator;       // Whether to show blue/gray dot
final VoidCallback? onCenterOnLocation; // Callback for "center" button tap

// Map info display
final bool showMapInfo;                 // Whether to show info overlay
final Function(MapInformation)? onMapStateChanged; // Callback when map moves/zooms
```

**Complete Enhanced Constructor**:
```dart
const MapView({
  Key? key,
  required this.mapStyle,
  required this.tracks,
  required this.initialCenter,
  required this.initialZoom,
  this.onMapMoved,
  // NEW: Location features
  this.currentLocation,
  this.showLocationIndicator = true,
  this.onCenterOnLocation,
  // NEW: Map info display
  this.showMapInfo = true,
  this.onMapStateChanged,
}) : super(key: key);
```

---

## Public Methods (via GlobalKey)

### `void centerOnLocation(LatLng location, {double? zoom})`

**Purpose**: Programmatically center map on specified location.

**Parameters**:
- `location`: Target coordinates
- `zoom` (optional): Zoom level (if null, keeps current zoom)

**Behavior**:
- Animates map movement (smooth transition)
- Updates map center to specified location
- Maintains current zoom if not specified
- No-op if MapController not initialized

**Usage**:
```dart
final GlobalKey<MapViewState> _mapKey = GlobalKey<MapViewState>();

// Center on location
_mapKey.currentState?.centerOnLocation(
  LatLng(37.7749, -122.4194),
);
```

---

### `void fitBounds(LatLngBounds bounds)`

**Purpose**: Zoom map to fit specified bounds (existing functionality, documented here for completeness).

**Parameters**:
- `bounds`: Bounding box to fit in viewport

**Behavior**:
- Adjusts zoom and center to show all content within bounds
- Maintains aspect ratio
- Adds padding around bounds

**Usage**:
```dart
// Existing usage for track bounds
_mapKey.currentState?.fitBounds(track.bounds);
```

---

## Visual Components

### 1. Location Indicator Overlay

**Implementation**: Added as a layer in FlutterMap

**Visual Specification**:
- **Active (GPS working)**: Blue circle with white border
- **Inactive (GPS lost)**: Gray circle with white border
- **Size**: 20x20 logical pixels
- **Border**: 2px white stroke
- **Position**: Exactly at DeviceLocation coordinates
- **Visibility**: Hidden if `showLocationIndicator = false` or `currentLocation = null`

**Z-Index**: Above map tiles, below tracks, below UI controls

**Rendering**:
```dart
if (widget.showLocationIndicator && widget.currentLocation != null)
  MarkerLayer(
    markers: [
      Marker(
        point: LatLng(
          widget.currentLocation!.latitude,
          widget.currentLocation!.longitude,
        ),
        width: 20,
        height: 20,
        child: Container(
          decoration: BoxDecoration(
            color: widget.currentLocation!.isActive 
                ? Colors.blue.withOpacity(0.8)
                : Colors.grey.withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    ],
  ),
```

---

### 2. Map Information Display

**Implementation**: Positioned widget overlaid on FlutterMap

**Visual Specification**:
- **Position**: Bottom-left corner (8px padding from edges)
- **Background**: Semi-transparent black (70% opacity)
- **Text**: White, 10px font size, monospace-style
- **Border Radius**: 4px
- **Padding**: 8px internal
- **Visibility**: Hidden if `showMapInfo = false`

**Content Format**:
```
Type: [Style Name]
Zoom: [Level to 1 decimal]
Lat: [Latitude to 4 decimals]°
Lng: [Longitude to 4 decimals]°
```

**Example**:
```
Type: Standard
Zoom: 13.5
Lat: 37.7749°
Lng: -122.4194°
```

**Rendering**:
```dart
if (widget.showMapInfo)
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
        'Type: ${widget.mapStyle.name}\n'
        'Zoom: ${_currentZoom.toStringAsFixed(1)}\n'
        'Lat: ${_currentCenter.latitude.toStringAsFixed(4)}°\n'
        'Lng: ${_currentCenter.longitude.toStringAsFixed(4)}°',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontFamily: 'monospace',
        ),
      ),
    ),
  ),
```

---

### 3. Center on Location Button

**Implementation**: Add to existing FloatingActionButton column in MapScreen (not part of MapView)

**Visual Specification**:
- **Icon**: `Icons.my_location`
- **Position**: In FAB stack, above existing "import track" button
- **Color**: Primary theme color
- **Behavior**: 
  - Tap → Call `mapKey.currentState?.centerOnLocation(currentLocation)`
  - Disabled (gray) if no location available
  - Hidden if location permissions denied

**Rendering** (in MapScreen, not MapView):
```dart
floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    // NEW: Center on location button
    if (_currentLocation != null)
      FloatingActionButton(
        heroTag: 'center_location',
        onPressed: () {
          _mapViewKey.currentState?.centerOnLocation(
            LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          );
        },
        child: Icon(Icons.my_location),
      ),
    SizedBox(height: 16),
    // Existing import button
    FloatingActionButton(
      heroTag: 'import',
      onPressed: _importTrack,
      child: Icon(Icons.add),
    ),
    // ... other existing buttons
  ],
),
```

---

## State Management

### Internal State (MapViewState)

**New State Variables**:
```dart
class MapViewState extends State<MapView> {
  late MapController _mapController;
  LatLng _currentCenter = widget.initialCenter;
  double _currentZoom = widget.initialZoom;
  
  // Existing state...
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }
  
  void _handleMapPositionChanged(MapPosition position, bool hasGesture) {
    setState(() {
      _currentCenter = position.center ?? _currentCenter;
      _currentZoom = position.zoom ?? _currentZoom;
    });
    
    // Notify parent of map state change
    if (widget.onMapStateChanged != null) {
      widget.onMapStateChanged!(MapInformation(
        styleName: widget.mapStyle.name,
        zoomLevel: _currentZoom,
        centerLatitude: _currentCenter.latitude,
        centerLongitude: _currentCenter.longitude,
      ));
    }
    
    // Existing onMapMoved callback
    if (widget.onMapMoved != null && hasGesture) {
      // ... existing logic
    }
  }
}
```

---

## Callbacks

### `onMapStateChanged(MapInformation info)`

**When Called**: On every map pan, zoom, or style change

**Purpose**: Notify parent widget of current map state for info display

**Frequency**: High (continuous during user interaction)

**Optimization**: Consider debouncing if performance issues observed

**Usage**:
```dart
MapView(
  // ... other params
  onMapStateChanged: (MapInformation info) {
    setState(() {
      _mapInfo = info;
    });
  },
)
```

---

### `onCenterOnLocation()`

**When Called**: User taps "center on location" button

**Purpose**: Give parent widget opportunity to handle centering logic

**Alternative**: Parent can call `centerOnLocation()` method directly via GlobalKey

**Usage**:
```dart
MapView(
  // ... other params
  onCenterOnLocation: () {
    _mapViewKey.currentState?.centerOnLocation(
      LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
    );
  },
)
```

**Note**: This callback is optional. Direct method call via GlobalKey is simpler and preferred.

---

## Backward Compatibility

### Existing Functionality Preserved
- All existing MapView features continue to work
- Track display unchanged
- Tile caching unchanged
- Map style switching unchanged
- Existing callbacks (`onMapMoved`) unchanged

### Default Behavior
- `showLocationIndicator = true` (but no indicator shown if `currentLocation = null`)
- `showMapInfo = true` (always show by default)
- All new parameters optional
- Existing code works without modification

---

## Testing Contract

### Manual Testing Checklist
1. **Location Indicator**:
   - ✓ Blue dot appears when GPS active
   - ✓ Gray dot appears when GPS lost
   - ✓ Dot position updates as device moves
   - ✓ No dot shown if permissions denied

2. **Center on Location**:
   - ✓ Button visible when location available
   - ✓ Map animates to current location on tap
   - ✓ Zoom level maintained (or set appropriately)
   - ✓ Multiple taps don't cause issues

3. **Map Info Display**:
   - ✓ Info updates on pan
   - ✓ Info updates on zoom
   - ✓ Info updates on style change
   - ✓ Coordinates formatted correctly
   - ✓ Text readable on all map styles

4. **Backward Compatibility**:
   - ✓ Existing map features work unchanged
   - ✓ Track import still functional
   - ✓ Map style switching still works
   - ✓ Tile caching still operational

---

## Performance Considerations

### Optimization Strategies
- Location indicator: Simple circle, no complex rendering
- Map info: Small text overlay, minimal draw cost
- State updates: Only setState when visible changes occur
- Callbacks: Consider debouncing `onMapStateChanged` if needed

### Expected Performance
- No measurable impact on 60 FPS map rendering
- Location updates: <1ms to update indicator position
- Map info updates: <1ms to redraw text
- Center animation: Smooth 300-500ms transition

---

## Contract Version

**Version**: 1.0.0  
**Status**: Final  
**Last Updated**: December 29, 2025

**Extends**: Existing MapView widget (lib/widgets/map_view.dart)
