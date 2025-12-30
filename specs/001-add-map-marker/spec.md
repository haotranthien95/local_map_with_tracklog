# Feature Specification: Add Map Marker

**Feature Branch**: `001-add-map-marker`  
**Created**: 2025-12-30  
**Status**: Draft  
**Input**: User description: "Add a feature: User able to add a marker in map and naming it. Flow: Long press to map -> show bottom sheet with 2 option: Add marker, back, press to add marker, continue with choose icon, then continue to choose color, naming, the create. Every step user have option to back to revious step or cancel this feature. These data will store to local and map with user"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create a basic marker (Priority: P1)

A user long-presses the map, chooses Add marker, sets a name (with default icon and color available), and sees the marker appear on the map with details saved locally for their account/session.

**Why this priority**: This is the core value: enabling users to drop and label a point of interest.

**Independent Test**: From a blank map, long-press, add a marker with a name, confirm it appears and persists after app restart.

**Acceptance Scenarios**:

1. **Given** the map is visible and responsive, **When** the user long-presses and selects Add marker then enters a name and confirms, **Then** a marker appears at that coordinate with the provided name and chosen/default icon/color and is stored locally for the user.
2. **Given** a marker was added, **When** the app restarts, **Then** the marker reappears at the saved location with its saved properties.

---

### User Story 2 - Customize marker appearance (Priority: P2)

After choosing Add marker, the user selects a specific icon and color before naming, then creates the marker.

**Why this priority**: Custom appearance helps users distinguish markers quickly.

**Independent Test**: Start the add-marker flow, pick a non-default icon and color, name the marker, confirm map displays the selected appearance and that it persists.

**Acceptance Scenarios**:

1. **Given** the add-marker flow is open, **When** the user selects a custom icon and color and completes creation, **Then** the marker appears with that icon and color and the selections are saved locally.

---

### User Story 3 - Cancel or step back safely (Priority: P3)

During any step of the add-marker flow, the user chooses Back or Cancel and no unintended marker is created.

**Why this priority**: Prevents accidental map clutter and lets users revise choices.

**Independent Test**: Enter the flow, navigate forward and backward between steps, then cancel before creation and verify no new marker exists.

**Acceptance Scenarios**:

1. **Given** the user is in the add-marker flow with selections made, **When** they tap Back, **Then** the flow returns to the prior step with previous selections retained.
2. **Given** the user is in any step before final creation, **When** they tap Cancel or close the sheet, **Then** the flow exits without adding a marker or partially saved data.

---

### Edge Cases

- Long-press occurs while GPS fix is unavailable: show graceful prompt and allow retry without creating a marker.
- User tries to confirm without entering a name: block creation with inline guidance and keep selections intact.
- User adds multiple markers at close proximity: ensure taps/long-presses still target map, not newly placed markers, to avoid unintended edits.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The map MUST detect a long-press gesture and present a bottom sheet with options: Add marker and Back/Close.
- **FR-002**: Choosing Add marker MUST start a guided flow with sequential steps: icon selection, color selection, naming, review/create.
- **FR-003**: Each step MUST provide Back and Cancel controls; Back returns to the prior step preserving selections, Cancel exits the flow without saving.
- **FR-004**: The icon selection step MUST offer a default icon preselected and allow choosing from available icons.
- **FR-005**: The color selection step MUST offer a default color preselected and allow choosing from available colors.
- **FR-006**: The naming step MUST require a non-empty name, show inline validation feedback, and allow editing before creation.
- **FR-007**: On Create, the marker MUST be saved locally with location coordinates, icon, color, name, timestamp, and association to the current user/session.
- **FR-008**: Newly created markers MUST render on the map immediately at the selected coordinates with chosen icon/color and name visible on selection or hover state.
- **FR-009**: Locally saved markers MUST reload and display on subsequent app launches for the same user/session.
- **FR-010**: If the flow is canceled at any step, no marker data MUST be persisted.

### Key Entities *(include if feature involves data)*

- **Marker**: Contains id, coordinate (lat/long), name, icon choice, color choice, created/updated timestamps, and association to the current user/session. Stored locally for persistence across sessions.
- **MarkerStyle**: Represents selectable icon and color options (labels and swatches) available during the flow.

### Assumptions & Dependencies

- Users are authenticated or otherwise scoped so markers are associated to the active user/session.
- Base map tiles and location services are already available and responsive when the flow starts.
- Local storage is available for persisting marker data between launches.
- The catalog of icons and colors is predefined and accessible in the client.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% of users can create a named marker (from long-press to creation) in under 20 seconds on first attempt.
- **SC-002**: 95% of created markers reappear with correct name/icon/color after app restart for the same user/session.
- **SC-003**: 90% of users report that marker appearance choices are sufficient to distinguish their markers in a single session (via usability check or survey).
- **SC-004**: Cancel/back actions result in zero unintended marker creations during testing across 20 consecutive attempts.
