
# Feature Specification: Show Current Location or Default

**Feature Branch**: `001-show-current-location`  
**Created**: 2025-12-28  
**Status**: Draft  
**Input**: User description: "When open map it need to show current user location, if user not grant permission, it will show default location is hochiminh city"

## Clarifications

### Session 2025-12-28

- Q: How should the app visually indicate which location is being shown (user location vs. default)? → A: Different marker colors plus banner notification at bottom
- Q: When device location is unavailable (GPS off, airplane mode), what should the app display? → A: Show last known location if available, otherwise default

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->


### User Story 1 - Show User Location or Default (Priority: P1)

When the user opens the map, the app requests location permission. If granted, the map centers on the user's current location and displays a marker. If permission is denied or not granted, the map centers on a default location (Ho Chi Minh City) and displays a marker there instead. The user is visually informed which location is being shown.

**Why this priority**: This is a core usability feature for any map app. Users expect to see their current location by default, but the app must remain functional and clear even if permission is denied.

**Independent Test**: Can be fully tested by opening the app with location permission granted (shows user location) and denied (shows Ho Chi Minh City), verifying correct marker and map center in both cases.

**Acceptance Scenarios**:

1. **Given** the app is opened and location permission is granted, **When** the map loads, **Then** the map centers on the user's current location and displays a marker there
2. **Given** the app is opened and location permission is denied or not granted, **When** the map loads, **Then** the map centers on Ho Chi Minh City and displays a marker there
3. **Given** the map is showing the default location, **When** the user later grants location permission, **Then** the map updates to show the user's current location
4. **Given** the map is showing the user's location, **When** the user revokes permission, **Then** the map reverts to showing Ho Chi Minh City

---



### Edge Cases

- How does the app handle rapid permission changes (user toggles permission while app is open)?


## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->


### Functional Requirements

- **FR-001**: App MUST request location permission on map open
- **FR-002**: App MUST center map on user's current location if permission is granted
- **FR-003**: App MUST center map on Ho Chi Minh City if permission is denied or not granted
- **FR-004**: App MUST display a marker at the shown location (user or default) with blue color for user location and red color for default location
- **FR-005**: App MUST update map center and marker if permission status changes while app is open
- **FR-006**: App MUST show a banner notification at the bottom of the screen indicating whether the shown location is the user's current location or the default Ho Chi Minh City location
- **FR-007**: App MUST handle device location unavailable (GPS off, airplane mode) by showing last known location if available, otherwise fallback to default Ho Chi Minh City location
- **FR-008**: App MUST display appropriate banner messages for each location type: "Your location" for current, "Last known location" for cached, "Default location: Ho Chi Minh City" for fallback


### Key Entities

- **User Location**: The current latitude/longitude of the device, as provided by the OS location service
- **Last Known Location**: The most recent cached latitude/longitude from a previous successful location query
- **Default Location**: The fixed latitude/longitude for Ho Chi Minh City (10.7769° N, 106.7009° E)
- **Permission Status**: The current state of location permission (granted, denied, not determined)

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->


### Measurable Outcomes

- **SC-001**: 95% of users see their current location or Ho Chi Minh City within 2 seconds of map open
- **SC-002**: 100% of users without location permission see Ho Chi Minh City as default
- **SC-003**: 100% of users with permission granted see their actual location (if device location available)
- **SC-004**: Visual indicator of which location is shown is present in 100% of cases
- **SC-005**: No app crashes or unhandled errors when permission is toggled or device location is unavailable
