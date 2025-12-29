# Feature Specification: Bottom Navigation and Live Location Tracking

**Feature Branch**: `002-navigation-location-ui`  
**Created**: December 29, 2025  
**Status**: Draft  
**Input**: User description: "Implement bottom navigation bar with dashboard/map/settings tabs, and add live device location tracking with indicator and map info display"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Navigate Between App Sections (Priority: P1)

A user wants to quickly switch between different sections of the app (dashboard, map, settings) without losing their current context or having to navigate through multiple screens.

**Why this priority**: This establishes the fundamental navigation structure of the app, enabling users to access all major features. Without this, users cannot effectively explore different app sections.

**Independent Test**: Can be fully tested by tapping each tab in the bottom navigation bar and verifying that the correct screen is displayed. Each tab should be independently accessible without requiring interaction with other tabs.

**Acceptance Scenarios**:

1. **Given** the app is launched, **When** the user views the bottom navigation bar, **Then** three tabs are visible: Dashboard, Map, and Settings
2. **Given** the user is on any screen, **When** the user taps the Dashboard tab, **Then** the dashboard screen is displayed
3. **Given** the user is on any screen, **When** the user taps the Map tab, **Then** the map screen is displayed with the current map view preserved
4. **Given** the user is on any screen, **When** the user taps the Settings tab, **Then** the settings screen is displayed
5. **Given** the user switches between tabs multiple times, **When** returning to a previously visited tab, **Then** the screen state is preserved (e.g., map position, zoom level)

---

### User Story 2 - View Current Device Location on Map (Priority: P1)

A user wants to see their current location on the map with a clear visual indicator, allowing them to understand where they are in relation to the map tiles and imported tracks.

**Why this priority**: Core functionality for any map-based application. Users need to know "where am I?" to effectively use the app for navigation and tracking purposes.

**Independent Test**: Can be tested by opening the map screen and observing the location indicator. Grant location permissions and verify a blue dot appears at the device's current coordinates. Deny permissions or disable GPS and verify a gray dot appears at the last known position.

**Acceptance Scenarios**:

1. **Given** the user has granted location permissions, **When** the map screen is displayed, **Then** a blue dot indicator appears at the device's current location
2. **Given** the device location is being tracked, **When** the device moves, **Then** the blue dot indicator updates to reflect the new position in real-time
3. **Given** the user has denied location permissions or GPS is unavailable, **When** the map screen is displayed, **Then** a gray dot indicator appears at the last known location (or no indicator if no location was ever obtained)
4. **Given** location permissions were previously denied, **When** the user grants permissions, **Then** the indicator changes from gray to blue and moves to the current location
5. **Given** the device loses GPS signal, **When** location updates stop, **Then** the indicator remains at the last known position and changes to gray

---

### User Story 3 - Center Map on Current Location (Priority: P2)

A user who has scrolled or panned away from their current location wants a quick way to return the map view to their current position without manually searching.

**Why this priority**: Enhances user experience by providing a common map interaction pattern. While important, the app is still functional without this feature (users can manually pan to their location).

**Independent Test**: Can be tested by panning the map away from the current location, then tapping the "center on location" button and verifying the map smoothly animates back to center on the device's current position.

**Acceptance Scenarios**:

1. **Given** the user has panned the map away from their current location, **When** the user taps the "center on location" button, **Then** the map animates smoothly to center on the device's current location
2. **Given** the device location is unavailable, **When** the user taps the "center on location" button, **Then** the map centers on the last known location (if available) or displays a message indicating location is unavailable
3. **Given** the map is already centered on the user's location, **When** the user taps the "center on location" button, **Then** the map maintains its current position (no action needed)
4. **Given** the user is viewing a track or specific area, **When** they tap the "center on location" button, **Then** the map view changes to show their current location without affecting the zoom level significantly

---

### User Story 4 - Monitor Map Information in Real-Time (Priority: P3)

A user wants to see technical details about the current map view (map type, zoom level, coordinates) to understand their precise location and map configuration.

**Why this priority**: Useful for power users and debugging, but not essential for basic app functionality. Most users can use the app effectively without this information.

**Independent Test**: Can be tested by viewing the map screen and verifying that a text display in the bottom-left corner shows map type, current zoom level, and center coordinates. Pan and zoom the map to verify the values update in real-time.

**Acceptance Scenarios**:

1. **Given** the user is viewing the map screen, **When** the map is displayed, **Then** a small text display appears in the bottom-left corner showing map type, zoom level, and current center coordinates (latitude, longitude)
2. **Given** the map info display is visible, **When** the user zooms in or out, **Then** the zoom level value updates immediately
3. **Given** the map info display is visible, **When** the user pans the map, **Then** the coordinate values update to reflect the new center position
4. **Given** the map info display is visible, **When** the user changes the map style, **Then** the map type value updates to show the new style name
5. **Given** the text display is positioned in the bottom-left corner, **When** the map is in any state, **Then** the text remains readable and does not obscure important map features or controls

---

### Edge Cases

- What happens when location permissions are initially denied but later granted during an active session?
- How does the system handle rapid location updates (e.g., in a moving vehicle)?
- What happens when the user switches tabs while a location update is in progress?
- How does the app behave when location services are disabled at the system level (not just permissions)?
- What happens if the map tiles fail to load while showing the location indicator?
- How does the app handle displaying the location indicator when offline (no network, but GPS available)?
- What happens when the user taps "center on location" multiple times in rapid succession?
- How does the app display coordinates near the international date line or poles?
- What happens when the user backgrounds the app while location tracking is active?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a bottom navigation bar with three tabs: Dashboard, Map, and Settings
- **FR-002**: System MUST display the Dashboard tab content as a placeholder screen with text indicating future functionality
- **FR-003**: System MUST display the Map tab content showing the existing map functionality (previously home_screen.dart)
- **FR-004**: System MUST display the Settings tab content as a placeholder screen with sections for profile and logout functionality
- **FR-005**: System MUST maintain the selected tab state when the app is in the foreground
- **FR-006**: System MUST preserve the map state (position, zoom level, loaded tracks) when switching between tabs
- **FR-007**: System MUST request and handle location permissions appropriately for the platform (iOS/Android)
- **FR-008**: System MUST continuously track device location updates when the map screen is visible and permissions are granted
- **FR-009**: System MUST display a visual indicator (dot) at the device's current location on the map
- **FR-010**: System MUST use a blue color for the location indicator when location updates are successfully received
- **FR-011**: System MUST use a gray color for the location indicator when location updates are unavailable but a last known position exists
- **FR-012**: System MUST hide the location indicator when no location has ever been obtained
- **FR-013**: System MUST update the location indicator position in real-time as the device moves
- **FR-014**: System MUST provide a button to center the map view on the device's current location
- **FR-015**: System MUST animate the map movement when centering on the device location for smooth user experience
- **FR-016**: System MUST display real-time map information in the bottom-left corner of the map screen
- **FR-017**: Map information display MUST include: current map type/style name, current zoom level, and current map center coordinates (latitude and longitude)
- **FR-018**: System MUST update the map information display in real-time as the user interacts with the map (pan, zoom, style change)
- **FR-019**: System MUST format coordinate values in a readable format with appropriate decimal precision
- **FR-020**: System MUST handle location permission denial gracefully without crashing
- **FR-021**: System MUST continue functioning (map viewing, track import) even when location permissions are denied
- **FR-022**: System MUST clean up location tracking resources when the map screen is not visible to conserve battery

### Key Entities

- **NavigationTab**: Represents each tab in the bottom navigation (Dashboard, Map, Settings) with its associated screen content and icon
- **DeviceLocation**: Represents the device's geographical position with latitude, longitude, accuracy, and timestamp information
- **LocationIndicator**: Visual representation of device position on the map with state (active/inactive) determining its color (blue/gray)
- **MapInformation**: Collection of current map state values including style name, zoom level, and center coordinates for display purposes

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can switch between all three tabs (Dashboard, Map, Settings) with a single tap, and the correct screen displays within 100 milliseconds
- **SC-002**: Location indicator appears on the map within 2 seconds of granting location permissions (when GPS signal is available)
- **SC-003**: Location indicator position updates within 1 second of device location changes
- **SC-004**: Users can center the map on their current location with a single button tap, and the map completes the animation within 500 milliseconds
- **SC-005**: Map information display updates within 100 milliseconds of any map interaction (pan, zoom, style change)
- **SC-006**: App maintains map state (position, zoom, tracks) with 100% accuracy when switching between tabs
- **SC-007**: Location tracking consumes minimal battery by pausing updates when map screen is not visible
- **SC-008**: App handles location permission denial gracefully without displaying error messages or crashes
- **SC-009**: All map functionality (viewing, panning, zooming, track import) remains fully operational when location permissions are denied

## Assumptions *(mandatory)*

- The existing map implementation (home_screen.dart) is fully functional and does not require modifications beyond the specified requirements
- The app will use the device's native location services (GPS/GNSS) for position tracking
- Location updates will use standard accuracy settings (balanced power/accuracy) rather than high-precision mode
- The bottom navigation bar will be persistent across all main screens (always visible)
- Tab switching will not reload or reinitialize screens, only change visibility
- Dashboard and Settings screens will be implemented as simple placeholder screens for this feature (full implementation in future features)
- Location tracking will not continue when the app is in the background (no background location tracking)
- Map information display will show decimal degrees format for coordinates (e.g., "37.7749° N, 122.4194° W")
- The "center on location" button will maintain the current zoom level, only changing the map center position
- Location indicator will be rendered as a simple circular dot with a radius proportional to the map zoom level
- The app targets modern iOS (13+) and Android (8+) versions with standard location permission models
- Users will interact with one tab at a time (no split-screen or multi-window scenarios)

## Dependencies *(mandatory)*

- Device hardware: GPS/GNSS receiver for location tracking
- Platform permissions: ACCESS_FINE_LOCATION (Android), Location When In Use (iOS)
- Existing map view implementation must expose methods for programmatic map control (centering, getting current state)
- Flutter's location services integration (e.g., geolocator, location packages) or platform channels for native location APIs
- Existing map tile caching service must continue to function during location tracking
- No external network services required for location tracking (uses device GPS only)

## Out of Scope *(mandatory)*

- Background location tracking (tracking when app is not visible)
- Location history or tracking logs
- Compass or heading indicator
- Speed, altitude, or other motion sensor data display
- Custom location accuracy settings or high-precision mode
- Geofencing or location-based alerts
- Sharing current location with other users
- Saving or bookmarking favorite locations
- Routing or navigation instructions
- Address geocoding (converting coordinates to street addresses)
- Full implementation of Dashboard functionality (placeholder only)
- Full implementation of Settings functionality (placeholder only)
- User authentication or profile management
- Logout functionality implementation (UI placeholder only)
- Location permission request UI customization beyond platform defaults
- Accessibility features specific to location tracking (will follow platform standards)
- Offline location tracking when device has no GPS signal

## Non-Functional Requirements *(optional)*

### Performance
- Location updates should not impact map rendering performance (maintain 60 FPS during panning/zooming)
- Tab switching should feel instantaneous with no visible loading states
- Map information display updates should not cause visual flicker or layout shifts

### Usability
- Location indicator should be clearly visible against all map tile styles
- "Center on location" button should be easily accessible and not overlap with other critical map controls
- Map information text should be readable across different device sizes and in varying lighting conditions
- Bottom navigation bar icons and labels should be immediately recognizable

### Reliability
- App should handle rapid permission changes (grant/deny/grant) without crashes
- Location tracking should recover gracefully from GPS signal loss and restoration
- Tab state preservation should work reliably even under memory pressure

### Compatibility
- Feature should work consistently across iOS and Android platforms
- Location indicator rendering should work with all existing map styles
- Bottom navigation should adapt to different screen sizes and orientations

## Technical Notes *(optional)*

- Consider using a Flutter package like `geolocator` for cross-platform location services with permission handling
- Location indicator can be implemented as a custom map layer or marker overlay
- Map information display should use a semi-transparent background to ensure text readability over map tiles
- "Center on location" button could be positioned near existing floating action buttons for consistency
- Consider debouncing map information updates to avoid excessive redraws during continuous panning
- The renamed home_screen.dart to map_screen.dart should maintain all existing functionality including track import, map style selection, and cache management
- Bottom navigation state can be managed using Flutter's built-in `BottomNavigationBar` widget with a simple integer index for the selected tab

- **FR-020**: System MUST handle location permission denial gracefully without crashing
- **FR-021**: System MUST continue functioning (map viewing, track import) even when location permissions are denied
- **FR-022**: System MUST clean up location tracking resources when the map screen is not visible to conserve battery

### Key Entities

- **NavigationTab**: Represents each tab in the bottom navigation (Dashboard, Map, Settings) with its associated screen content and icon
- **DeviceLocation**: Represents the device's geographical position with latitude, longitude, accuracy, and timestamp information
- **LocationIndicator**: Visual representation of device position on the map with state (active/inactive) determining its color (blue/gray)
- **MapInformation**: Collection of current map state values including style name, zoom level, and center coordinates for display purposes

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can switch between all three tabs (Dashboard, Map, Settings) with a single tap, and the correct screen displays within 100 milliseconds
- **SC-002**: Location indicator appears on the map within 2 seconds of granting location permissions (when GPS signal is available)
- **SC-003**: Location indicator position updates within 1 second of device location changes
- **SC-004**: Users can center the map on their current location with a single button tap, and the map completes the animation within 500 milliseconds
- **SC-005**: Map information display updates within 100 milliseconds of any map interaction (pan, zoom, style change)
- **SC-006**: App maintains map state (position, zoom, tracks) with 100% accuracy when switching between tabs
- **SC-007**: Location tracking consumes minimal battery by pausing updates when map screen is not visible
- **SC-008**: App handles location permission denial gracefully without displaying error messages or crashes
- **SC-009**: All map functionality (viewing, panning, zooming, track import) remains fully operational when location permissions are denied
