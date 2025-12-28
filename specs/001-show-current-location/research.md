# Research: Show Current Location or Default

## Unknowns & Clarifications

- Which map plugin is best for showing a marker and centering on user/default location? (flutter_map, google_maps_flutter, mapbox_gl)
- How to handle permission requests and state changes in Flutter? (geolocator, permission_handler)
- How to visually indicate to the user which location is being shown?
- What is the best practice for handling device location unavailable (e.g., GPS off, airplane mode)?

## Research Tasks

1. Research best Flutter map plugin for showing marker and centering on user/default location
2. Research best practice for requesting and handling location permission in Flutter
3. Research UI/UX patterns for indicating "showing your location" vs. "showing default location"
4. Research error handling for device location unavailable

## Findings

### 1. Best Flutter Map Plugin
- **flutter_map**: Open source, supports OSM, easy to use, good for custom markers and overlays
- **google_maps_flutter**: Official Google plugin, more complex, requires API key, not OSM by default
- **mapbox_gl**: Advanced, requires Mapbox account, more setup
- **Decision**: Use **flutter_map** for OSM and simplicity

### 2. Location Permission Handling
- **geolocator**: Most popular for location and permission, handles permission request, state, and device location
- **permission_handler**: Useful for fine-grained control, but geolocator is sufficient for this use case
- **Decision**: Use **geolocator** for both permission and location

### 3. UI/UX for Location Indicator
- Use a marker with a distinct color for user location (e.g., blue dot)
- Use a different marker or label for default location (e.g., red pin, "Default location" label)
- Show a banner notification at bottom to inform user which location is shown
- **Decision**: Use blue marker for user location, red marker for default, plus banner notification at bottom with appropriate messages:
  - "Your location" for current GPS location
  - "Last known location" for cached location when GPS unavailable
  - "Default location: Ho Chi Minh City" for fallback when no location available

### 4. Device Location Unavailable
- If device location is unavailable (GPS off, airplane mode), check for last known location
- If last known location exists, show that with appropriate banner
- If no last known location, fallback to default Ho Chi Minh City
- **Decision**: Use last known location if available, otherwise default, with clear banner messages for each case

## Alternatives Considered
- google_maps_flutter: More complex, not OSM by default
- permission_handler: Not needed for this simple use case
- mapbox_gl: Overkill for MVP

## Final Decisions
- Use **flutter_map** for map display
- Use **geolocator** for permission and location
- Use blue marker for user, red marker for default, and banner for default case
- Fallback to default if device location unavailable
