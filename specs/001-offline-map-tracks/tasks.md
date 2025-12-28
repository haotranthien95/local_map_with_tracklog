# Tasks: Offline Map & Track Log Viewer

**Feature**: 001-offline-map-tracks  
**Input**: Design documents from `/specs/001-offline-map-tracks/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Implementation Strategy**: MVP-first delivery with incremental user story completion. Each phase represents a complete, independently testable increment.

**Tests**: Tests are NOT explicitly requested in the specification. Focus on functional implementation. Manual testing procedures documented in quickstart.md.

---

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1=P1, US2=P2, US3=P3, US4=P4)
- All file paths are relative to repository root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization with required dependencies

- [X] T001 Add dependencies to pubspec.yaml: flutter_map ^6.1.0, flutter_map_cache ^0.2.0, cached_network_image ^3.3.0, latlong2 ^0.9.0, path_provider ^2.1.0, file_picker ^6.1.0, gpx ^2.2.0
- [X] T002 Run flutter pub get to install dependencies
- [X] T003 [P] Create lib/models/ directory structure
- [X] T004 [P] Create lib/services/ directory structure
- [X] T005 [P] Create lib/widgets/ directory structure
- [X] T006 [P] Create lib/screens/ directory structure
- [X] T007 [P] Create test/fixtures/ directory for test GPX files

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core models and constants that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T008 [P] Create MapStyle model with predefined constants (standard, satellite, terrain) in lib/models/map_style.dart
- [X] T009 [P] Create TrackFormat enum in lib/models/track.dart
- [X] T010 Define LatLngBounds helper for coordinate bounds calculation in lib/models/track.dart

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - View and Cache Standard OpenStreetMap (Priority: P1) 🎯 MVP

**Goal**: Display interactive OpenStreetMap with automatic tile caching for offline viewing

**Independent Test**: Open app, browse map areas at different zoom levels, disable network, verify cached areas display without errors

### Implementation for User Story 1

- [X] T011 [P] [US1] Create MapTile model in lib/models/map_tile.dart with fields: styleId, zoom, x, y, imageData, cachedAt, fileSize
- [X] T012 [P] [US1] Create TileCacheService interface in lib/services/tile_cache_service.dart with methods: isTileCached, getTile, saveTile, getCacheInfo, clearCache, evictOldest, shouldShowStorageWarning
- [X] T013 [US1] Implement TileCacheServiceImpl using flutter_map_cache in lib/services/tile_cache_service.dart (depends on T012)
- [X] T014 [US1] Add cache directory setup with path_provider in lib/services/tile_cache_service.dart (depends on T013)
- [X] T015 [US1] Implement storage warning check at 80% threshold in lib/services/tile_cache_service.dart (depends on T013)
- [X] T016 [P] [US1] Create MapView widget with flutter_map integration in lib/widgets/map_view.dart
- [X] T017 [US1] Configure TileLayer with offline cache provider in lib/widgets/map_view.dart (depends on T013, T016)
- [X] T018 [US1] Add automatic tile caching on pan/zoom events in lib/widgets/map_view.dart (depends on T017)
- [X] T019 [US1] Add placeholder display for uncached tiles when offline in lib/widgets/map_view.dart (depends on T017)
- [X] T020 [P] [US1] Create HomeScreen with MapView integration in lib/screens/home_screen.dart
- [X] T021 [US1] Add storage warning dialog to HomeScreen in lib/screens/home_screen.dart (depends on T015, T020)
- [X] T022 [US1] Update main.dart to launch HomeScreen as initial route in lib/main.dart
- [ ] T023 [US1] Verify offline functionality: cache tiles, disable network, confirm cached areas display (manual test)
- [ ] T024 [US1] Verify storage warning appears at 80% capacity threshold (manual test)

**Checkpoint**: User Story 1 complete - App displays OSM map, caches tiles automatically, works fully offline, warns at 80% storage

---

## Phase 4: User Story 2 - Import and Display GPX Track Logs (Priority: P2)

**Goal**: Import GPX files and display tracks as colored lines overlaid on the map, with multiple tracks supported

**Independent Test**: Import sample GPX file, verify track displays as line, map auto-zooms to track extent, import second GPX file, verify both display with different colors

### Implementation for User Story 2

- [X] T025 [P] [US2] Create TrackPoint model in lib/models/track.dart with fields: latitude, longitude, elevation, timestamp, accuracy
- [X] T026 [P] [US2] Create Track model in lib/models/track.dart with fields: id, name, coordinates (List<TrackPoint>), importedFrom, format, importedAt, bounds, color, metadata
- [X] T027 [US2] Add bounds calculation method to Track model in lib/models/track.dart (depends on T026)
- [X] T028 [P] [US2] Create FilePickerService interface in lib/services/file_picker_service.dart with method: pickTrackFile(allowedExtensions)
- [X] T029 [US2] Implement FilePickerServiceImpl using file_picker package in lib/services/file_picker_service.dart (depends on T028)
- [X] T030 [P] [US2] Create TrackParserService interface in lib/services/track_parser_service.dart with methods: parseTrackFile, parseTrackBytes, detectFormat, validateTrack, simplifyTrack
- [X] T031 [US2] Implement GPX parsing using gpx package in lib/services/track_parser_service.dart (depends on T030)
- [X] T032 [US2] Add track validation logic in lib/services/track_parser_service.dart (depends on T031)
- [X] T033 [US2] Add error handling for invalid/corrupted GPX files in lib/services/track_parser_service.dart (depends on T031)
- [X] T034 [P] [US2] Create TrackOverlay widget for rendering polylines in lib/widgets/track_overlay.dart
- [X] T035 [US2] Implement multi-track rendering with color assignment in lib/widgets/track_overlay.dart (depends on T034)
- [X] T036 [US2] Add track list state management to HomeScreen in lib/screens/home_screen.dart (depends on T026)
- [X] T037 [US2] Add "Import Track" button to HomeScreen in lib/screens/home_screen.dart (depends on T036)
- [X] T038 [US2] Wire file picker to track parser in HomeScreen in lib/screens/home_screen.dart (depends on T029, T031, T037)
- [X] T039 [US2] Add auto-zoom to track bounds on import in lib/screens/home_screen.dart (depends on T027, T038)
- [X] T040 [US2] Add TrackOverlay to MapView in lib/widgets/map_view.dart (depends on T035)
- [X] T041 [US2] Create sample test GPX file in test/fixtures/sample_track.gpx
- [ ] T042 [US2] Verify single GPX import displays correctly on map (manual test with T041)
- [ ] T043 [US2] Verify multiple GPX imports display with different colors (manual test with T041)
- [ ] T044 [US2] Verify invalid GPX shows clear error message (manual test)

**Checkpoint**: User Story 2 complete - GPX files import, tracks display on map with auto-zoom, multiple tracks shown with distinct colors, errors handled gracefully

---

## Phase 5: User Story 3 - Switch Map Styles (Priority: P3)

**Goal**: Allow users to switch between standard, satellite, and terrain map styles with independent caching

**Independent Test**: Switch between map styles, verify each displays correctly, pan in each style, go offline, confirm cached tiles for all styles display

### Implementation for User Story 3

- [X] T045 [P] [US3] Create StyleSelector widget with style picker UI in lib/widgets/style_selector.dart
- [X] T046 [US3] Add active style state management to HomeScreen in lib/screens/home_screen.dart (depends on T008)
- [X] T047 [US3] Add StyleSelector to HomeScreen UI in lib/screens/home_screen.dart (depends on T045, T046)
- [X] T048 [US3] Update MapView to use active style from state in lib/widgets/map_view.dart (depends on T046)
- [X] T049 [US3] Configure satellite tile source (Esri ArcGIS) in MapView in lib/widgets/map_view.dart (depends on T048)
- [X] T050 [US3] Configure terrain tile source (OpenTopoMap) in MapView in lib/widgets/map_view.dart (depends on T048)
- [X] T051 [US3] Verify style-specific caching (tiles cached per style) in lib/services/tile_cache_service.dart (depends on T013)
- [ ] T052 [US3] Verify standard style displays and caches correctly (manual test)
- [ ] T053 [US3] Verify satellite style displays and caches correctly (manual test)
- [ ] T054 [US3] Verify terrain style displays and caches correctly (manual test)
- [ ] T055 [US3] Verify offline mode shows cached tiles for all styles independently (manual test)

**Checkpoint**: User Story 3 complete - Users can switch between 3 map styles, each caches independently, offline access works for all cached styles

---

## Phase 6: User Story 4 - Import Additional Track Formats (Priority: P4)

**Goal**: Support importing KML, KMZ, GeoJSON, FIT, TCX, CSV, NMEA track formats

**Independent Test**: Import sample files of each format type, verify all display as tracks on map

### Implementation for User Story 4

- [X] T056 [P] [US4] Implement KML parsing using xml package in lib/services/track_parser_service.dart
- [X] T057 [P] [US4] Implement KMZ parsing (unzip + KML parse) in lib/services/track_parser_service.dart
- [X] T058 [P] [US4] Implement GeoJSON parsing using dart:convert in lib/services/track_parser_service.dart
- [X] T059 [P] [US4] Implement FIT parsing (research fit_parser package or custom) in lib/services/track_parser_service.dart
- [X] T060 [P] [US4] Implement TCX parsing using xml package in lib/services/track_parser_service.dart
- [X] T061 [P] [US4] Implement CSV parsing with coordinate detection in lib/services/track_parser_service.dart
- [X] T062 [P] [US4] Implement NMEA sentence parsing in lib/services/track_parser_service.dart
- [X] T063 [US4] Update file picker allowed extensions to include all formats in lib/services/file_picker_service.dart (depends on T056-T062)
- [X] T064 [US4] Add format-specific error messages in lib/services/track_parser_service.dart (depends on T056-T062)
- [X] T065 [US4] Create test fixtures for each format in test/fixtures/ (kml, kmz, geojson, fit, tcx, csv, nmea)
- [ ] T066 [US4] Verify KML/KMZ import works correctly (manual test with T065)
- [ ] T067 [US4] Verify GeoJSON import works correctly (manual test with T065)
- [ ] T068 [US4] Verify FIT/TCX/CSV/NMEA import works correctly (manual test with T065)
- [ ] T069 [US4] Verify unsupported format shows clear error (manual test)

**Checkpoint**: User Story 4 complete - All specified GPS formats can be imported and displayed as tracks

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final refinements and edge case handling

- [X] T070 [P] Add track simplification for large files (>5000 points) using Douglas-Peucker algorithm in lib/services/track_parser_service.dart
- [X] T071 [P] Add cache size indicator to UI in lib/screens/home_screen.dart
- [X] T072 [P] Add manual cache clear option to UI in lib/screens/home_screen.dart
- [ ] T073 [P] Optimize tile loading performance (concurrent downloads, prioritization) in lib/services/tile_cache_service.dart
- [ ] T074 Verify app meets performance targets: <3s launch, 30+ FPS, <2s track import (manual performance test)
- [ ] T075 Verify app meets storage target: 50+ km² cacheable at zoom 14 (manual test)
- [ ] T076 Verify edge case: 10k+ GPS point track loads and displays (manual test with large file)
- [ ] T077 Verify edge case: interrupted downloads handled gracefully (manual test with network toggle)
- [ ] T078 Final integration test: Complete user journey across all user stories (manual test)

**Checkpoint**: All user stories complete, polished, and tested

---

## Dependencies & Execution Strategy

### User Story Independence

Each user story (US1, US2, US3, US4) can be implemented and tested independently after Phase 2 (Foundational) is complete:

- **US1** (P1 - MVP): No dependencies on other user stories
- **US2** (P2): No dependencies on US1 (tracks overlay any map, including default)
- **US3** (P3): Enhances US1 but doesn't require US2
- **US4** (P4): Extends US2 format support, independent of US1 and US3

### Suggested MVP Scope

**Minimal MVP** (deliver first): Phase 1 → Phase 2 → Phase 3 (US1 only)
- Result: Working offline map viewer with tile caching

**Extended MVP** (next iteration): Add Phase 4 (US2)
- Result: Map viewer + GPX track visualization

**Full P1-P2 Delivery**: Phase 1 → Phase 2 → Phase 3 → Phase 4
- Result: Offline maps + GPX tracks (covers 80% of user needs)

**Future Enhancements**: Phase 5 (US3), Phase 6 (US4), Phase 7 (Polish)

### Parallel Execution Opportunities

Within each phase, tasks marked **[P]** can be executed in parallel:

**Phase 1**: T003-T007 (all directory setup tasks)
**Phase 2**: T008-T010 (independent model definitions)
**Phase 3**: T011-T012, T016, T020 (independent file creation before wiring)
**Phase 4**: T025-T026, T028, T030, T034 (independent interfaces/models)
**Phase 5**: T045 (widget), parallel with T046 (state)
**Phase 6**: T056-T062 (all format parsers can be developed simultaneously)
**Phase 7**: T070-T073 (independent optimizations)

### Dependency Graph (User Story Completion Order)

```
Phase 1 (Setup)
    ↓
Phase 2 (Foundational) ← BLOCKING: Must complete before any US
    ↓
    ├─→ Phase 3 (US1 - P1) ← MVP
    ├─→ Phase 4 (US2 - P2) ← Independently testable
    ├─→ Phase 5 (US3 - P3) ← Independently testable
    └─→ Phase 6 (US4 - P4) ← Independently testable
            ↓
        Phase 7 (Polish)
```

**Critical Path**: Phase 1 → Phase 2 → Phase 3 (US1) [MVP delivery]
**Parallel Paths After Phase 2**: US2, US3, US4 can be developed simultaneously by different developers

---

## Task Count Summary

- **Phase 1 (Setup)**: 7 tasks
- **Phase 2 (Foundational)**: 3 tasks
- **Phase 3 (US1 - P1)**: 14 tasks
- **Phase 4 (US2 - P2)**: 20 tasks
- **Phase 5 (US3 - P3)**: 11 tasks
- **Phase 6 (US4 - P4)**: 14 tasks
- **Phase 7 (Polish)**: 9 tasks

**Total**: 78 tasks

**Parallelizable**: 29 tasks marked [P] (37%)

**MVP Path** (Phase 1+2+3): 24 tasks
**Extended MVP** (add Phase 4): 44 tasks
**Full Feature** (all phases): 78 tasks

---

## Implementation Notes

### Constitution Compliance

All tasks maintain alignment with constitution principles:
- **MVP-First**: Phase 3 delivers working end-to-end map viewer
- **Minimal Viable**: Each user story is scoped to essential functionality only
- **Independent Stories**: Each phase 3-6 can be completed and tested independently
- **Progressive Enhancement**: Core functionality (US1) first, enhancements (US2-4) incremental
- **Maintainability**: No complex patterns, simple StatefulWidget state management

### Testing Strategy

Per specification, tests are NOT explicitly requested. Manual testing procedures documented in quickstart.md cover:
- Functional acceptance criteria for each user story
- Performance benchmarks (FPS, load times)
- Storage capacity verification
- Edge case validation

### File Structure After Implementation

```
lib/
├── main.dart                        # T022
├── models/
│   ├── map_style.dart              # T008
│   ├── map_tile.dart               # T011
│   └── track.dart                   # T009, T010, T025, T026, T027
├── services/
│   ├── tile_cache_service.dart     # T012, T013, T014, T015, T051
│   ├── track_parser_service.dart   # T030, T031, T032, T033, T056-T062, T064, T070
│   └── file_picker_service.dart    # T028, T029, T063
├── widgets/
│   ├── map_view.dart               # T016, T017, T018, T019, T040, T048, T049, T050
│   ├── track_overlay.dart          # T034, T035
│   └── style_selector.dart         # T045
└── screens/
    └── home_screen.dart            # T020, T021, T036, T037, T038, T039, T046, T047, T071, T072

test/fixtures/
├── sample_track.gpx                # T041
└── [various format samples]        # T065
```

### Storage Warning Flow (US1)

```dart
// T015, T021 implementation pattern
final shouldWarn = await tileCacheService.shouldShowStorageWarning();
if (shouldWarn) {
  final continue = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Storage Warning'),
      content: Text('Cache has reached 80% of available storage. Continue caching?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Stop')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Continue')),
      ],
    ),
  );
  if (continue != true) return; // Stop caching
}
```

### Multiple Track Color Assignment (US2)

```dart
// T035, T036 implementation pattern
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Track> tracks = [];
  final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
  
  void _onImportTrack(Track track) {
    setState(() {
      tracks.add(track.copyWith(color: colors[tracks.length % colors.length]));
    });
  }
}
```

---

## Next Steps

1. **Start with MVP**: Execute Phase 1 → Phase 2 → Phase 3 for quickest user value delivery
2. **Validate Assumptions**: Test MVP with real users before proceeding to Phase 4+
3. **Iterate**: Add US2 (GPX), US3 (styles), US4 (formats) based on user feedback and priorities
4. **Polish Last**: Phase 7 optimizations only after core functionality validated

**Estimated MVP Delivery**: 24 tasks × average task complexity = implementation timeline TBD based on team capacity

---

## Related Documentation

- [Feature Specification](./spec.md) - User stories and acceptance criteria
- [Implementation Plan](./plan.md) - Technical decisions and architecture
- [Data Model](./data-model.md) - Entity definitions and relationships
- [Service Contracts](./contracts/) - Interface specifications
- [Research](./research.md) - Technology evaluation and rationale
- [Quickstart Guide](./quickstart.md) - Development setup and manual testing procedures
