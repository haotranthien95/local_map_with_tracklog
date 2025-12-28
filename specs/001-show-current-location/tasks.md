---
description: "Task list for Show Current Location or Default feature"
---

# Tasks: Show Current Location or Default

**Input**: Design documents from `/specs/001-show-current-location/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Organization**: Tasks are organized by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1)
- Include exact file paths in descriptions

## Path Conventions

- **Mobile app**: `lib/` at repository root
- Paths shown assume Flutter standard structure

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and dependency setup

- [ ] T001 Add flutter_map dependency to pubspec.yaml (version ^6.0.0)
- [ ] T002 Add geolocator dependency to pubspec.yaml (version ^10.0.0)
- [ ] T003 Add latlong2 dependency to pubspec.yaml (for coordinate handling)
- [ ] T004 Run flutter pub get to install dependencies
- [ ] T005 [P] Configure iOS location permissions in ios/Runner/Info.plist (NSLocationWhenInUseUsageDescription)
- [ ] T006 [P] Configure Android location permissions in android/app/src/main/AndroidManifest.xml (ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core models and services that MUST be complete before user story implementation

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T007 Create lib/features/show_current_location/ directory structure
- [ ] T008 [P] Create LocationData model in lib/features/show_current_location/models/location_data.dart
- [ ] T009 [P] Create LocationType enum in lib/features/show_current_location/models/location_type.dart (current, lastKnown, default)
- [ ] T010 Create LocationService in lib/features/show_current_location/services/location_service.dart with methods for permission check, get current location, get last known location
- [ ] T011 Create DefaultLocationConstants in lib/features/show_current_location/constants/default_location.dart (Ho Chi Minh City coordinates: 10.7769, 106.7009)

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Show User Location or Default (Priority: P1) 🎯 MVP

**Goal**: Display user's current location or default Ho Chi Minh City on map open, with appropriate visual indicators

**Independent Test**: Open app with location permission granted (shows user location with blue marker) and denied (shows Ho Chi Minh City with red marker), verify markers and banners display correctly

### Implementation for User Story 1

- [ ] T012 [US1] Create ShowCurrentLocationScreen widget in lib/features/show_current_location/show_current_location_screen.dart
- [ ] T013 [US1] Implement map display using flutter_map in ShowCurrentLocationScreen
- [ ] T014 [US1] Implement permission request logic on screen initialization in ShowCurrentLocationScreen
- [ ] T015 [US1] Implement location fetch logic: request current location if permission granted in ShowCurrentLocationScreen
- [ ] T016 [US1] Implement fallback to last known location if current location unavailable in ShowCurrentLocationScreen
- [ ] T017 [US1] Implement fallback to default Ho Chi Minh City if no location available in ShowCurrentLocationScreen
- [ ] T018 [US1] Add blue marker for user/last known location on map in ShowCurrentLocationScreen
- [ ] T019 [US1] Add red marker for default location on map in ShowCurrentLocationScreen
- [ ] T020 [US1] Create LocationBanner widget in lib/features/show_current_location/widgets/location_banner.dart
- [ ] T021 [US1] Display LocationBanner at bottom with "Your location" for current location
- [ ] T022 [US1] Display LocationBanner with "Last known location" for cached location
- [ ] T023 [US1] Display LocationBanner with "Default location: Ho Chi Minh City" for fallback
- [ ] T024 [US1] Center map on determined location (user, last known, or default)
- [ ] T025 [US1] Set appropriate zoom level for map (e.g., zoom 14 for city view)
- [ ] T026 [US1] Implement permission change listener to update map when permission status changes
- [ ] T027 [US1] Handle rapid permission toggles with debouncing or state management
- [ ] T028 [US1] Add error handling for location service failures
- [ ] T029 [US1] Update main.dart to use ShowCurrentLocationScreen as home screen

**Checkpoint**: User Story 1 complete - app shows location with appropriate markers and banners

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Final touches and edge case handling

- [ ] T030 Add loading indicator while fetching location
- [ ] T031 Improve banner styling (background color, padding, text style)
- [ ] T032 Add smooth map animation when location updates
- [ ] T033 Test app behavior on iOS simulator/device with permission scenarios
- [ ] T034 Test app behavior on Android emulator/device with permission scenarios
- [ ] T035 Test GPS off scenario (airplane mode)
- [ ] T036 Test rapid permission toggle scenario
- [ ] T037 Verify 2-second performance target for location display

---

## Dependencies

### Story Completion Order
1. Phase 1: Setup → Phase 2: Foundational → Phase 3: User Story 1 → Phase 4: Polish

### Within User Story 1
- T012-T014 (screen setup) must complete before marker/banner tasks
- T010 (LocationService) must complete before T015-T017 (location fetch logic)
- T020 (LocationBanner widget) must complete before T021-T023 (banner display)

---

## Parallel Execution Opportunities

### Phase 1: Setup
```bash
# Run in parallel (different files):
Task T005: Configure iOS permissions
Task T006: Configure Android permissions
```

### Phase 2: Foundational
```bash
# Run in parallel (different files):
Task T008: Create LocationData model
Task T009: Create LocationType enum
```

### Phase 3: User Story 1 (after screen created)
```bash
# Run in parallel (different widgets/files):
Task T018: Add blue marker implementation
Task T019: Add red marker implementation
Task T020: Create LocationBanner widget
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (dependencies and permissions)
2. Complete Phase 2: Foundational (models and services)
3. Complete Phase 3: User Story 1 (location display with markers and banners)
4. **STOP and VALIDATE**: Test all permission scenarios independently
5. Deploy/demo if ready

### Validation Checklist

Before marking Phase 3 complete, verify:
- [ ] Permission granted → shows user location with blue marker and "Your location" banner
- [ ] Permission denied → shows Ho Chi Minh City with red marker and "Default location" banner
- [ ] GPS off + permission granted → shows last known location (if available) with blue marker and "Last known location" banner
- [ ] GPS off + no last known → shows Ho Chi Minh City with red marker and "Default location" banner
- [ ] Permission toggle while app open → map updates correctly
- [ ] App loads in under 2 seconds

---

## Notes

- [P] tasks = different files, no dependencies
- [US1] label maps all tasks to User Story 1 (single story feature)
- Each task includes specific file path for clarity
- LocationService (T010) is foundational as all location logic depends on it
- Banner widget (T020) is created early to enable parallel banner message implementation
- Permission configuration (T005, T006) is critical for app to work on devices
- Avoid: vague tasks, same file conflicts, unhandled edge cases

---

## Summary

**Total Tasks**: 37
**Task Count by Phase**:
- Phase 1 (Setup): 6 tasks
- Phase 2 (Foundational): 5 tasks
- Phase 3 (User Story 1): 18 tasks
- Phase 4 (Polish): 8 tasks

**Parallel Opportunities**: 6 tasks can run in parallel (marked with [P] or grouped in parallel execution section)

**Independent Test Criteria**: User Story 1 can be fully tested by verifying all 4 location scenarios (current, last known, default with permission, default without permission) display correct markers and banners

**Suggested MVP Scope**: Complete Phases 1-3 for full MVP (all 29 tasks through User Story 1)
