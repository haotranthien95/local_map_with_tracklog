# Tasks: Bottom Navigation and Live Location Tracking

**Input**: Design documents from `/specs/002-navigation-location-ui/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Not explicitly requested in feature specification - manual testing per quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `- [ ] [ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Platform configuration and preparation for feature implementation

- [X] T001 [P] Add location permissions to android/app/src/main/AndroidManifest.xml (ACCESS_FINE_LOCATION and ACCESS_COARSE_LOCATION)
- [X] T002 [P] Add NSLocationWhenInUseUsageDescription to ios/Runner/Info.plist with usage description
- [X] T003 Verify geolocator (10.1.0), flutter_map (6.1.0), and latlong2 (0.9.0) in pubspec.yaml

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Rename lib/screens/home_screen.dart to lib/screens/map_screen.dart (update class name from HomeScreen to MapScreen)
- [X] T005 Update all imports of home_screen.dart to map_screen.dart throughout the codebase
- [X] T006 [P] Create lib/models/device_location.dart with DeviceLocation class (latitude, longitude, accuracy, timestamp, isActive)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Navigate Between App Sections (Priority: P1) 🎯 MVP

**Goal**: Implement bottom navigation bar with three tabs (Dashboard, Map, Settings) and preserve state when switching between tabs

**Independent Test**: Launch app, tap each tab in bottom navigation, verify correct screen displays and map state is preserved when switching tabs

### Implementation for User Story 1

- [X] T007 [P] [US1] Create lib/screens/dashboard_screen.dart as StatelessWidget with centered placeholder text "Dashboard - Coming Soon"
- [X] T008 [P] [US1] Create lib/screens/settings_screen.dart as StatelessWidget with placeholder text for profile and logout sections
- [X] T009 [US1] Create new lib/screens/home_screen.dart with StatefulWidget implementing BottomNavigationBar and IndexedStack
- [X] T010 [US1] Implement _selectedIndex state variable in home_screen.dart (default to 1 for Map tab)
- [X] T011 [US1] Add BottomNavigationBar with three items: Dashboard (Icons.dashboard), Map (Icons.map), Settings (Icons.settings)
- [X] T012 [US1] Add IndexedStack with children: [DashboardScreen(), MapScreen(), SettingsScreen()]
- [X] T013 [US1] Wire BottomNavigationBar onTap to update _selectedIndex via setState
- [X] T014 [US1] Update lib/main.dart to change MaterialApp home from HomeScreen to new HomeScreen (which contains navigation)
- [X] T015 [US1] Verify tab switching preserves MapScreen state (position, zoom, tracks)

**Checkpoint**: At this point, User Story 1 should be fully functional - three tabs working with state preservation

---

## Phase 4: User Story 2 - View Current Device Location on Map (Priority: P1) 🎯 MVP

**Goal**: Implement location tracking service and display blue/gray dot indicator on map showing device's current location

**Independent Test**: Grant location permissions, verify blue dot appears at current location; deny permissions or disable GPS, verify gray dot at last known position or no indicator if no location obtained

### Implementation for User Story 2

- [X] T016 [P] [US2] Create lib/services/location_service.dart with LocationService abstract class defining interface from contracts/location-service.md
- [X] T017 [US2] Implement LocationServiceImpl class in location_service.dart with requestPermission() method using Geolocator
- [X] T018 [US2] Implement locationStream getter using Geolocator.getPositionStream with LocationSettings (accuracy: high, distanceFilter: 10)
- [X] T019 [US2] Implement getCurrentLocation() method with 5-second timeout
- [X] T020 [US2] Implement hasPermission getter using Geolocator.checkPermission
- [X] T021 [US2] Implement dispose() method to cancel subscriptions and close stream controller
- [X] T022 [US2] Add _transformPositionToDeviceLocation helper to convert geolocator Position to DeviceLocation model
- [X] T023 [P] [US2] Update lib/widgets/map_view.dart to add optional DeviceLocation? currentLocation parameter
- [X] T024 [P] [US2] Update lib/widgets/map_view.dart to add bool showLocationIndicator parameter (default: true)
- [X] T025 [US2] Add MarkerLayer to FlutterMap in map_view.dart for location indicator (20x20 Container with blue/gray circle, white border)
- [X] T026 [US2] Implement location indicator color logic: blue if currentLocation.isActive, gray otherwise
- [X] T027 [US2] Hide location indicator if showLocationIndicator is false or currentLocation is null
- [X] T028 [US2] Update lib/screens/map_screen.dart to add LocationService instantiation and initialization
- [X] T029 [US2] Add StreamSubscription<DeviceLocation> to MapScreen state for location updates
- [X] T030 [US2] Call locationService.requestPermission() in MapScreen initState
- [X] T031 [US2] Subscribe to locationService.locationStream in MapScreen and update currentLocation state
- [X] T032 [US2] Pass currentLocation to MapView widget in MapScreen build method
- [X] T033 [US2] Cancel location subscription in MapScreen dispose method
- [X] T034 [US2] Test location indicator: blue dot with GPS active, gray dot when GPS lost, hidden when permissions denied

**Checkpoint**: At this point, User Stories 1 AND 2 should both work - navigation tabs + live location indicator

---

## Phase 5: User Story 3 - Center Map on Current Location (Priority: P2)

**Goal**: Add floating action button that animates map to center on device's current location

**Independent Test**: Pan map away from current location, tap "center on location" button, verify map animates smoothly to current position maintaining zoom level

### Implementation for User Story 3

- [X] T035 [US3] Add centerOnLocation(LatLng location) method to MapViewState in lib/widgets/map_view.dart
- [X] T036 [US3] Implement centerOnLocation using _mapController.move() with animated transition to new center, maintaining current zoom
- [X] T037 [US3] Update lib/screens/map_screen.dart to add FloatingActionButton with Icons.my_location in FAB Column
- [X] T038 [US3] Position "center on location" FAB above existing import track button with 16px spacing
- [X] T039 [US3] Implement FAB onPressed to call _mapViewKey.currentState?.centerOnLocation() with current device location
- [X] T040 [US3] Add conditional rendering: only show center location FAB if _currentLocation is not null
- [X] T041 [US3] Test center button: taps centers map, animation smooth, zoom preserved, button hidden when no location

**Checkpoint**: All P1 and P2 user stories functional - full navigation, location tracking, and centering capability

---

## Phase 6: User Story 4 - Monitor Map Information in Real-Time (Priority: P3)

**Goal**: Display real-time map information (type, zoom, coordinates) in bottom-left corner overlay

**Independent Test**: View map screen, verify text overlay shows map type, zoom level, and coordinates; pan/zoom map and verify values update in real-time

### Implementation for User Story 4

- [X] T042 [P] [US4] Add bool showMapInfo parameter to lib/widgets/map_view.dart constructor (default: true)
- [X] T043 [P] [US4] Add LatLng _currentCenter and double _currentZoom state variables to MapViewState
- [X] T044 [US4] Initialize _currentCenter and _currentZoom from widget.initialCenter and widget.initialZoom in initState
- [X] T045 [US4] Add onPositionChanged callback to FlutterMap MapOptions in map_view.dart
- [X] T046 [US4] Update _currentCenter and _currentZoom in onPositionChanged callback using setState
- [X] T047 [US4] Wrap FlutterMap in Stack widget in map_view.dart build method
- [X] T048 [US4] Add Positioned widget (left: 8, bottom: 8) with map info Container overlay
- [X] T049 [US4] Style Container with semi-transparent black background (opacity: 0.7), 4px border radius, 8px padding
- [X] T050 [US4] Add Text widget displaying: "Type: ${widget.mapStyle.name}\nZoom: ${_currentZoom.toStringAsFixed(1)}\nLat: ${_currentCenter.latitude.toStringAsFixed(4)}°\nLng: ${_currentCenter.longitude.toStringAsFixed(4)}°"
- [X] T051 [US4] Style Text with white color, 10px font size, monospace font family
- [X] T052 [US4] Add conditional rendering: only show Positioned overlay if widget.showMapInfo is true
- [X] T053 [US4] Test map info display: visible on launch, updates on pan/zoom/style change, readable on all map styles, doesn't overlap controls

**Checkpoint**: All user stories (P1, P2, P3) complete and independently functional

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final improvements and validation across all user stories

- [X] T054 [P] Add heroTag properties to all FloatingActionButtons in map_screen.dart to prevent hero animation conflicts
- [ ] T055 [P] Test edge case: location permissions denied then granted during active session (indicator should update)
- [ ] T056 [P] Test edge case: rapid location updates in moving vehicle (verify smooth updates without jitter)
- [ ] T057 [P] Test edge case: tab switching during location update (verify no crashes or state corruption)
- [ ] T058 [P] Test edge case: location services disabled at system level (verify graceful degradation)
- [ ] T059 [P] Test edge case: multiple rapid taps on center location button (verify no crashes or animation conflicts)
- [ ] T060 Test app lifecycle: background/foreground transitions with location tracking active
- [ ] T061 Verify 60 FPS map rendering during location updates using Flutter DevTools
- [ ] T062 Verify tab switching completes within 100ms (Success Criteria SC-001)
- [ ] T063 Verify location indicator appears within 2 seconds of GPS lock (Success Criteria SC-002)
- [ ] T064 Verify all 12 manual test procedures from quickstart.md pass
- [X] T065 Code review and cleanup: remove debug print statements, verify error handling
- [X] T066 Update widget_test.dart if needed to reflect new HomeScreen structure
- [X] T067 Run `flutter analyze` and resolve any warnings or errors
- [ ] T068 Final validation: Run quickstart.md manual testing checklist

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately (platform configuration)
- **Foundational (Phase 2)**: Depends on Setup - BLOCKS all user stories (file rename and base model)
- **User Story 1 (Phase 3)**: Depends on Foundational - Independent from US2, US3, US4
- **User Story 2 (Phase 4)**: Depends on Foundational - Independent from US1, US3, US4
- **User Story 3 (Phase 5)**: Depends on User Story 2 (needs location service) - Independent from US1, US4
- **User Story 4 (Phase 6)**: Depends on Foundational - Independent from US1, US2, US3
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1 - Navigation)**: Can start immediately after Foundational phase - No dependencies on other stories
- **User Story 2 (P1 - Location Indicator)**: Can start immediately after Foundational phase - No dependencies on other stories
- **User Story 3 (P2 - Center Button)**: Depends on US2 completion (needs LocationService and currentLocation state)
- **User Story 4 (P3 - Map Info)**: Can start immediately after Foundational phase - No dependencies on other stories

### Suggested Implementation Order

**MVP (Minimum Viable Product) - Implement These First**:
1. Phase 1: Setup (T001-T003)
2. Phase 2: Foundational (T004-T006)
3. Phase 3: User Story 1 - Navigation (T007-T015)
4. Phase 4: User Story 2 - Location (T016-T034)

**At this point, you have a fully functional MVP**: Bottom navigation + Live location tracking

**Enhanced Features - Implement After MVP**:
5. Phase 5: User Story 3 - Center Button (T035-T041)
6. Phase 6: User Story 4 - Map Info (T042-T053)
7. Phase 7: Polish (T054-T068)

### Within Each User Story

**User Story 1 (Navigation)**:
- Placeholder screens (T007, T008) can be done in parallel
- Home screen with navigation (T009-T013) must be sequential
- Main.dart update (T014) depends on home screen completion
- Testing (T015) last

**User Story 2 (Location)**:
- Service interface and implementation (T016-T022) must be sequential
- MapView updates (T023-T027) can be done in parallel with service after T016
- MapScreen integration (T028-T033) depends on both service and MapView updates
- Testing (T034) last

**User Story 3 (Center Button)**:
- MapView method (T035-T036) and FAB addition (T037-T040) must be sequential
- Testing (T041) last

**User Story 4 (Map Info)**:
- State variables and callbacks (T042-T046) sequential
- UI implementation (T047-T052) sequential
- Testing (T053) last

### Parallel Opportunities

**Within Setup (Phase 1)**: All three tasks (T001, T002, T003) can run in parallel on different platforms

**Within Foundational (Phase 2)**: T006 (create model) can run in parallel with T004-T005 (file rename)

**Between User Stories** (after Foundational phase):
- US1 (Navigation) and US2 (Location) can be developed completely in parallel by different developers
- US4 (Map Info) can be developed in parallel with US1 and US2
- Only US3 (Center Button) must wait for US2 to complete

**Within User Story 2**: T023-T024 (MapView parameters) can be done in parallel with T016-T022 (LocationService implementation)

**Within Phase 7 (Polish)**: Most testing tasks (T054-T059, T061-T064) can run in parallel

---

## Parallel Execution Example: MVP Implementation

If you have 2 developers, split work as follows:

**Developer 1 - Navigation Track**:
```bash
# Day 1
- Complete T001 (Android permissions)
- Complete T004-T005 (File rename)
- Complete T007-T015 (User Story 1 - Navigation)

# Result: Bottom navigation working
```

**Developer 2 - Location Track**:
```bash
# Day 1
- Complete T002 (iOS permissions)
- Complete T003, T006 (Verify deps, create model)
- Complete T016-T027 (LocationService + MapView updates)

# Day 2
- Complete T028-T034 (MapScreen integration + testing)

# Result: Location tracking working
```

**Integration** (Both developers):
```bash
# Day 2-3
- Merge both tracks
- Verify navigation + location work together
- Test state preservation when switching tabs
- Complete Phase 7 polish tasks
```

---

## Implementation Strategy

### MVP-First Approach

**Phase 1 Goal**: Working app with bottom navigation and live location (P1 stories)
- Users can switch between tabs
- Map shows current location with blue/gray indicator
- State preserved when switching tabs
- **Deliverable**: Functional MVP ready for user testing

**Phase 2 Goal**: Enhanced UX with convenience features (P2 story)
- "Center on location" button for quick navigation
- **Deliverable**: Improved user experience

**Phase 3 Goal**: Power user features (P3 story)
- Real-time map information display
- **Deliverable**: Complete feature set

### Testing Strategy

- Manual testing after each user story completion (checkpoints)
- Cross-platform testing (iOS and Android) for location features
- Edge case testing in Phase 7
- Performance validation (60 FPS, timing metrics) in Phase 7
- Full quickstart.md validation before feature sign-off

### Risk Mitigation

**High Risk Areas**:
1. **Location permissions**: Test on both platforms early (T001-T002)
2. **State preservation**: Validate IndexedStack approach in T015
3. **Performance**: Monitor during T061 (60 FPS requirement)

**Mitigation**:
- Complete foundational phase fully before splitting work
- Test location permissions on physical devices (emulators unreliable)
- Profile performance with Flutter DevTools throughout

---

## Task Summary

**Total Tasks**: 68 tasks
- Setup (Phase 1): 3 tasks
- Foundational (Phase 2): 3 tasks
- User Story 1 - Navigation (Phase 3): 9 tasks
- User Story 2 - Location (Phase 4): 19 tasks
- User Story 3 - Center Button (Phase 5): 7 tasks
- User Story 4 - Map Info (Phase 6): 12 tasks
- Polish (Phase 7): 15 tasks

**MVP Scope** (Phases 1-4): 34 tasks
**Enhanced Scope** (Phases 5-6): 19 tasks
**Polish Scope** (Phase 7): 15 tasks

**Estimated Effort** (single developer):
- MVP: 2-3 days
- Enhanced: 1 day
- Polish: 1 day
- **Total**: 4-5 days

**Parallel Opportunities**: 15+ tasks can run in parallel with proper team coordination

---

## Success Criteria Validation

After completing all tasks, verify these success criteria from spec.md:

- ✅ **SC-001**: Tab switching <100ms (verify in T062)
- ✅ **SC-002**: Location indicator appears <2s after GPS lock (verify in T063)
- ✅ **SC-003**: Location updates <1s of device movement (verify in T034, T064)
- ✅ **SC-004**: Center button animation <500ms (verify in T041)
- ✅ **SC-005**: Map info updates <100ms (verify in T053)
- ✅ **SC-006**: Map state preserved 100% (verify in T015, T064)
- ✅ **SC-007**: Minimal battery via foreground-only tracking (verify in T060)
- ✅ **SC-008**: Graceful permission denial handling (verify in T055, T058)
- ✅ **SC-009**: All map features work without location (verify in T064)

---

**Generated**: December 29, 2025  
**Feature**: 002-navigation-location-ui  
**Status**: Ready for implementation
