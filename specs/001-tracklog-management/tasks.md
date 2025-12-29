# Tasks: Tracklog Management System

**Feature Branch**: `001-tracklog-management`  
**Input**: Design documents from `/specs/001-tracklog-management/`  
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/)

**Note**: Tests are NOT included as they were not explicitly requested in the feature specification.

---

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add new dependencies required for tracklog management

- [X] T001 Add shared_preferences ^2.2.0 dependency to pubspec.yaml
- [X] T002 Add flutter_colorpicker ^1.0.3 dependency to pubspec.yaml
- [X] T003 Run flutter pub get to install new packages

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core models and widgets that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Add isVisible field (bool, default true) to Track class in lib/models/track.dart
- [X] T005 [P] Create TracklogMetadata model class in lib/models/tracklog_metadata.dart with 12 fields (id, name, color, isVisible, filePath, importedAt, importedFrom, format, boundsNorth, boundsSouth, boundsEast, boundsWest)
- [X] T006 [P] Add toJson() method to TracklogMetadata for serialization in lib/models/tracklog_metadata.dart
- [X] T007 [P] Add fromJson() factory constructor to TracklogMetadata for deserialization in lib/models/tracklog_metadata.dart
- [X] T008 [P] Add fromTrack() factory constructor to TracklogMetadata in lib/models/tracklog_metadata.dart
- [X] T009 [P] Add bounds getter to TracklogMetadata returning LatLngBounds in lib/models/tracklog_metadata.dart

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Add Named Tracklog (Priority: P1) 🎯 MVP

**Goal**: Users can import tracklogs with custom names via dialog prompt and see them displayed on map

**Independent Test**: Import a GPX file, enter name "Test Track" in dialog, verify track appears on map with entered name

### Implementation for User Story 1

- [X] T010 [P] [US1] Create showNameDialog function in lib/widgets/tracklog_dialogs.dart with parameters (BuildContext context, String? initialValue, String? title)
- [X] T011 [P] [US1] Add Form with TextFormField for name input in showNameDialog in lib/widgets/tracklog_dialogs.dart
- [X] T012 [P] [US1] Add validation for non-empty name (trim check) in showNameDialog in lib/widgets/tracklog_dialogs.dart
- [X] T013 [P] [US1] Add Cancel and OK action buttons to showNameDialog in lib/widgets/tracklog_dialogs.dart
- [X] T014 [US1] Import tracklog_dialogs.dart in lib/screens/map_screen.dart
- [X] T015 [US1] Modify _importTrack method to call showNameDialog after file selection in lib/screens/map_screen.dart
- [X] T016 [US1] Handle dialog cancellation (return without importing) in _importTrack in lib/screens/map_screen.dart
- [X] T017 [US1] Update Track creation to use dialog name and default blue color (#2196F3) in _importTrack in lib/screens/map_screen.dart
- [X] T018 [US1] Update success SnackBar message to show custom name in _importTrack in lib/screens/map_screen.dart

**Checkpoint**: At this point, users can import tracklogs with custom names and see them on map (MVP functional)

---

## Phase 4: User Story 2 - Persistent Tracklog Storage (Priority: P2)

**Goal**: Tracklogs persist across app restarts with all metadata (name, color, visibility)

**Independent Test**: Import 2-3 tracklogs, close app completely, reopen app, verify all tracklogs reappear

### Implementation for User Story 2

- [X] T019 [P] [US2] Create TracklogStorageService abstract class interface in lib/services/tracklog_storage_service.dart with 6 methods (saveTracklog, loadAllMetadata, loadTrack, updateMetadata, deleteTracklog, cleanupOrphanedFiles)
- [X] T020 [US2] Implement TracklogStorageServiceImpl class in lib/services/tracklog_storage_service.dart
- [X] T021 [US2] Implement saveTracklog method: save metadata to shared_preferences and coordinates to JSON file in lib/services/tracklog_storage_service.dart
- [X] T022 [US2] Implement loadAllMetadata method: read from shared_preferences and validate files exist in lib/services/tracklog_storage_service.dart
- [X] T023 [US2] Implement loadTrack method: read JSON file and deserialize to Track in lib/services/tracklog_storage_service.dart
- [X] T024 [US2] Implement updateMetadata method: update specific metadata in shared_preferences in lib/services/tracklog_storage_service.dart
- [X] T025 [US2] Implement deleteTracklog method: remove from shared_preferences and delete JSON file in lib/services/tracklog_storage_service.dart
- [X] T026 [US2] Implement cleanupOrphanedFiles method: delete JSON files not referenced in shared_preferences in lib/services/tracklog_storage_service.dart
- [X] T027 [US2] Add _trackToJson helper method in TracklogStorageServiceImpl in lib/services/tracklog_storage_service.dart
- [X] T028 [US2] Add _trackFromJson helper method in TracklogStorageServiceImpl in lib/services/tracklog_storage_service.dart
- [X] T029 [US2] Add TracklogStorageService field (_storageService) to MapScreen state in lib/screens/map_screen.dart
- [X] T030 [US2] Add List<TracklogMetadata> field (_tracklogMetadata) to MapScreen state in lib/screens/map_screen.dart
- [X] T031 [US2] Create _loadPersistedTracklogs method in MapScreen to load metadata and visible tracks in lib/screens/map_screen.dart
- [X] T032 [US2] Call _loadPersistedTracklogs in initState of MapScreen in lib/screens/map_screen.dart
- [X] T033 [US2] Update _importTrack to call _storageService.saveTracklog after creating Track in lib/screens/map_screen.dart
- [X] T034 [US2] Update _importTrack to add TracklogMetadata to _tracklogMetadata list in lib/screens/map_screen.dart

**Checkpoint**: At this point, tracklogs persist and restore on app restart (P1+P2 both functional)

---

## Phase 5: User Story 3 - View and Navigate Tracklog List (Priority: P3)

**Goal**: Users can access tracklog list from app bar and tap items to center map on tracklog

**Independent Test**: Open tracklog list, verify all tracklogs shown with names, tap item, verify map centers on selected tracklog

### Implementation for User Story 3

- [X] T035 [P] [US3] Create TracklogListScreen StatefulWidget in lib/screens/tracklog_list_screen.dart
- [X] T036 [P] [US3] Add constructor parameters (tracklogs, onUpdateMetadata, onDeleteTracklog) to TracklogListScreen in lib/screens/tracklog_list_screen.dart
- [X] T037 [P] [US3] Implement build method with Scaffold and AppBar titled "Tracklogs" in lib/screens/tracklog_list_screen.dart
- [X] T038 [P] [US3] Create _buildEmptyState widget showing "No tracklogs added yet" message in lib/screens/tracklog_list_screen.dart
- [X] T039 [P] [US3] Create _buildList widget with ListView.builder in lib/screens/tracklog_list_screen.dart
- [X] T040 [US3] Add ListTile for each tracklog with leading icon (visibility/visibility_off), title (name), subtitle (import date) in lib/screens/tracklog_list_screen.dart
- [X] T041 [US3] Implement onTap to return tracklog ID via Navigator.pop in lib/screens/tracklog_list_screen.dart
- [X] T042 [US3] Add list button (Icons.list) to MapScreen AppBar actions in lib/screens/map_screen.dart
- [X] T043 [US3] Create _openTracklogList method in MapScreen in lib/screens/map_screen.dart
- [X] T044 [US3] Navigate to TracklogListScreen with _tracklogMetadata in _openTracklogList in lib/screens/map_screen.dart
- [X] T045 [US3] Handle returned tracklog ID to load track if needed in _openTracklogList in lib/screens/map_screen.dart
- [X] T046 [US3] Call mapView.fitBounds with selected track bounds in _openTracklogList in lib/screens/map_screen.dart

**Checkpoint**: At this point, users can view list and navigate to tracklogs (P1+P2+P3 all functional)

---

## Phase 6: User Story 4 - Manage Individual Tracklogs (Priority: P4)

**Goal**: Users can show/hide, remove, rename, and change color of tracklogs via popup menu

**Independent Test**: Open list, test each operation (toggle visibility, rename, change color, remove) independently

### Implementation for User Story 4

- [X] T047 [P] [US4] Create showColorPickerDialog function in lib/widgets/tracklog_dialogs.dart with parameters (BuildContext context, Color currentColor)
- [X] T048 [P] [US4] Add BlockPicker from flutter_colorpicker with 18 predefined colors in showColorPickerDialog in lib/widgets/tracklog_dialogs.dart
- [X] T049 [P] [US4] Add Cancel and OK action buttons to showColorPickerDialog in lib/widgets/tracklog_dialogs.dart
- [X] T050 [P] [US4] Create showDeleteConfirmation function in lib/widgets/tracklog_dialogs.dart with parameters (BuildContext context, String tracklogName)
- [X] T051 [P] [US4] Add warning message with tracklog name in showDeleteConfirmation in lib/widgets/tracklog_dialogs.dart
- [X] T052 [P] [US4] Add Cancel button and red Remove button to showDeleteConfirmation in lib/widgets/tracklog_dialogs.dart
- [X] T053 [US4] Add PopupMenuButton trailing widget to ListTile in TracklogListScreen in lib/screens/tracklog_list_screen.dart
- [X] T054 [US4] Add 4 PopupMenuItem options (toggle_visibility, rename, change_color, remove) to PopupMenuButton in lib/screens/tracklog_list_screen.dart
- [X] T055 [US4] Create _handleMenuAction method to route menu selections in TracklogListScreen in lib/screens/tracklog_list_screen.dart
- [X] T056 [US4] Implement _toggleVisibility method: create updated metadata with isVisible toggled in lib/screens/tracklog_list_screen.dart
- [X] T057 [US4] Call widget.onUpdateMetadata callback in _toggleVisibility in lib/screens/tracklog_list_screen.dart
- [X] T058 [US4] Update local _tracklogs list and setState in _toggleVisibility in lib/screens/tracklog_list_screen.dart
- [X] T059 [US4] Show SnackBar confirmation in _toggleVisibility in lib/screens/tracklog_list_screen.dart
- [X] T060 [US4] Implement _renameTracklog method: call showNameDialog with current name in lib/screens/tracklog_list_screen.dart
- [X] T061 [US4] Create updated metadata with new name if changed in _renameTracklog in lib/screens/tracklog_list_screen.dart
- [X] T062 [US4] Call widget.onUpdateMetadata, update list, setState, show SnackBar in _renameTracklog in lib/screens/tracklog_list_screen.dart
- [X] T063 [US4] Implement _changeColor method: call showColorPickerDialog with current color in lib/screens/tracklog_list_screen.dart
- [X] T064 [US4] Create updated metadata with new color if changed in _changeColor in lib/screens/tracklog_list_screen.dart
- [X] T065 [US4] Call widget.onUpdateMetadata, update list, setState, show SnackBar in _changeColor in lib/screens/tracklog_list_screen.dart
- [X] T066 [US4] Implement _removeTracklog method: call showDeleteConfirmation in lib/screens/tracklog_list_screen.dart
- [X] T067 [US4] Call widget.onDeleteTracklog if confirmed in _removeTracklog in lib/screens/tracklog_list_screen.dart
- [X] T068 [US4] Remove from _tracklogs list, setState, show SnackBar in _removeTracklog in lib/screens/tracklog_list_screen.dart
- [X] T069 [US4] Update _openTracklogList to pass onUpdateMetadata callback in MapScreen in lib/screens/map_screen.dart
- [X] T070 [US4] Implement onUpdateMetadata: call _storageService.updateMetadata in MapScreen in lib/screens/map_screen.dart
- [X] T071 [US4] Update _tracklogMetadata list in onUpdateMetadata in MapScreen in lib/screens/map_screen.dart
- [X] T072 [US4] Handle visibility toggle: load track if showing, remove from _tracks if hiding in onUpdateMetadata in lib/screens/map_screen.dart
- [X] T073 [US4] Handle color/name change: update existing Track in _tracks list in onUpdateMetadata in lib/screens/map_screen.dart
- [X] T074 [US4] Update _openTracklogList to pass onDeleteTracklog callback in MapScreen in lib/screens/map_screen.dart
- [X] T075 [US4] Implement onDeleteTracklog: call _storageService.deleteTracklog in MapScreen in lib/screens/map_screen.dart
- [X] T076 [US4] Remove from _tracklogMetadata and _tracks lists in onDeleteTracklog in MapScreen in lib/screens/map_screen.dart

**Checkpoint**: All user stories now complete - full tracklog management functionality delivered

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final improvements and validation

- [X] T077 [P] Add error handling for storage failures in MapScreen in lib/screens/map_screen.dart
- [X] T078 [P] Add error handling for file parsing errors in MapScreen in lib/screens/map_screen.dart
- [X] T079 [P] Add loading indicators for import operation in MapScreen in lib/screens/map_screen.dart
- [X] T080 [P] Verify all SnackBar messages are user-friendly in lib/screens/map_screen.dart
- [X] T081 Run flutter analyze to check for code issues
- [X] T082 Test complete workflow following quickstart.md verification checklist

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
  - Add dependencies to pubspec.yaml
  - Run pub get

- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
  - Create core models (Track extension, TracklogMetadata)
  - Must complete T004-T009 before any user story work

- **User Story 1 (Phase 3)**: Depends on Foundational phase completion
  - Can start immediately after Phase 2
  - Creates name dialog and integrates with import flow
  - Independent of other user stories

- **User Story 2 (Phase 4)**: Depends on Foundational phase and User Story 1 completion
  - Requires User Story 1 complete because it saves tracks created in import flow
  - Adds persistence layer to existing import functionality

- **User Story 3 (Phase 5)**: Depends on Foundational phase and User Story 2 completion
  - Requires User Story 2 because it displays persisted tracklogs
  - Could theoretically run in parallel with US4 if US2 is complete

- **User Story 4 (Phase 6)**: Depends on User Story 3 completion
  - Requires list screen (US3) to add management operations
  - Extends list with popup menu and management dialogs

- **Polish (Phase 7)**: Depends on all user stories being complete
  - Cross-cutting improvements and validation

### User Story Dependencies Summary

```
Setup (P1)
    ↓
Foundational (P2) [BLOCKS ALL]
    ↓
US1: Add Named Tracklog (P1) 🎯 MVP
    ↓
US2: Persistent Storage (P2)
    ↓
US3: View & Navigate List (P3)
    ↓
US4: Manage Tracklogs (P4)
    ↓
Polish
```

### Within Each User Story

**User Story 1 (Add Named Tracklog)**:
- T010-T013 (dialog creation) can run in parallel [P]
- T014 must complete before T015-T018
- T015-T018 are sequential (modify import flow)

**User Story 2 (Persistent Storage)**:
- T019-T020 (service interface and impl class structure) are sequential
- T021-T028 (service method implementations) are sequential within service
- T029-T030 (add MapScreen fields) can run in parallel [P] with T019-T028
- T031-T034 (integrate storage in MapScreen) are sequential, depend on T019-T030

**User Story 3 (View & Navigate List)**:
- T035-T041 (list screen creation) can run mostly in parallel [P]
- T042-T046 (MapScreen integration) are sequential, depend on T035-T041

**User Story 4 (Manage Tracklogs)**:
- T047-T052 (create dialogs) can run in parallel [P]
- T053-T068 (add management to list screen) are mostly sequential
- T069-T076 (MapScreen callbacks) are sequential, depend on T053-T068

### Parallel Opportunities

**Within Setup (Phase 1)**:
- T001, T002 can be done in one edit (add both dependencies together)
- T003 runs after both added

**Within Foundational (Phase 2)**:
- T005-T009 (TracklogMetadata methods) marked [P] - can work on in parallel after T005 completes

**Across User Stories** (if team capacity allows):
- After Phase 2 completes, US1 can start immediately
- US2 cannot start until US1 completes
- US3 cannot start until US2 completes  
- US4 cannot start until US3 completes
- **Sequential dependency chain means no user story parallelization possible**

**Within Individual User Stories**:
- US1: 4 dialog tasks marked [P] (T010-T013)
- US2: Multiple service methods can be implemented in parallel once interface defined
- US3: Multiple list screen widgets marked [P] (T035-T041)
- US4: 6 dialog tasks marked [P] (T047-T052)

---

## Parallel Example: User Story 1

**Scenario**: Developer 1 working alone

```bash
# Day 1: Create dialog (parallel-capable tasks, but single developer does sequentially)
- Implement showNameDialog structure (T010)
- Add Form and TextFormField (T011)
- Add validation logic (T012)
- Add action buttons (T013)

# Day 2: Integrate with MapScreen (sequential tasks)
- Import dialogs (T014)
- Modify _importTrack to call showNameDialog (T015)
- Handle cancellation (T016)
- Update Track creation (T017)
- Update SnackBar message (T018)
```

**Scenario**: Team of 2 developers

```bash
# Developer 1: Dialog widgets (parallel track)
Day 1: T010-T013 (name dialog creation)

# Developer 2: MapScreen integration (waits for dialog)
Day 2: T014-T018 (integrate dialog into import flow)
```

---

## Parallel Example: User Story 4

**Scenario**: Team of 2 developers

```bash
# Developer 1: Dialog widgets (parallel track)
Day 1-2: 
  - T047-T049 (color picker dialog)
  - T050-T052 (delete confirmation dialog)

# Developer 2: List screen enhancements (parallel track after dialogs ready)
Day 3-4:
  - T053-T068 (popup menu and management methods)

# Developer 1: MapScreen callbacks (after list screen ready)
Day 5:
  - T069-T076 (integrate callbacks with storage)
```

---

## Task Statistics

**Total Tasks**: 82

**By Phase**:
- Phase 1 (Setup): 3 tasks
- Phase 2 (Foundational): 6 tasks
- Phase 3 (US1): 9 tasks
- Phase 4 (US2): 16 tasks
- Phase 5 (US3): 12 tasks
- Phase 6 (US4): 30 tasks
- Phase 7 (Polish): 6 tasks

**By User Story**:
- US1 (Add Named Tracklog): 9 tasks
- US2 (Persistent Storage): 16 tasks
- US3 (View & Navigate List): 12 tasks
- US4 (Manage Tracklogs): 30 tasks

**Parallel Opportunities**: 23 tasks marked [P] can run in parallel (within constraints)

**Implementation Strategy**:
- **MVP First**: Complete US1 (9 tasks) for minimum viable feature
- **Progressive Enhancement**: Add US2 (16 tasks) for persistence, US3 (12 tasks) for navigation, US4 (30 tasks) for full management
- **Incremental Delivery**: Each user story delivers independent value and can be deployed separately

---

## Validation Checklist

Before marking feature complete:

- [ ] All 82 tasks completed and checked off
- [ ] Can import tracklog with custom name (US1)
- [ ] Tracklogs persist across app restarts (US2)
- [ ] Can navigate to tracklogs from list (US3)
- [ ] Can manage tracklogs (show/hide, rename, color, remove) (US4)
- [ ] All error cases handled gracefully
- [ ] All success criteria from spec.md verified:
  - [ ] SC-001: Add tracklog in <30 seconds
  - [ ] SC-002: 100% persistence rate
  - [ ] SC-003: Navigate to tracklog in <5 seconds
  - [ ] SC-004: Management operations in <2 seconds
  - [ ] SC-005: Handle 20+ tracklogs smoothly
  - [ ] SC-007: Visibility toggle in <1 second
  - [ ] SC-008: Map centering in <2 seconds
- [ ] Quickstart.md verification completed (T082)
- [ ] No analyzer warnings (T081)
