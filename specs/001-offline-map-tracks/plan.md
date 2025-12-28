# Implementation Plan: Offline Map & Track Log Viewer

**Branch**: `001-offline-map-tracks` | **Date**: 2025-12-28 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-offline-map-tracks/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Build a Flutter MVP app for offline map viewing and GPS track visualization. Primary requirements: (1) Cache OpenStreetMap tiles during browsing for full offline access, (2) Import and display GPS tracks from multiple formats (GPX priority), (3) Support multiple map styles (standard, satellite, terrain) with independent caching. 

**Technical Approach**: Use `flutter_map` library for OSM tile rendering with `flutter_map_cache` for offline storage. File-based cache organized by style/zoom/x/y. Track import via `file_picker` package with format-specific parsers (starting with `gpx` package for P2 MVP). StatefulWidget state management, no complex architectural patterns. See [research.md](./research.md) for detailed technology decisions.

**Recent Clarifications** (2025-12-28):
- Storage warning displayed at 80% capacity with user control
- Multiple imported tracks display simultaneously with different colors

## Technical Context

**Language/Version**: Dart 3.5.4+ / Flutter 3.5.4+ (SDK constraint from pubspec.yaml)  
**Primary Dependencies**: `flutter_map` (OSM tile display), `flutter_map_cache` (offline caching), `file_picker` (file import), `gpx` (GPX parsing for P2)  
**Storage**: Local file system for tile cache via `path_provider` (applicationDocumentsDirectory), organized by `{cacheDir}/{styleId}/{zoom}/{x}/{y}.png`  
**Testing**: flutter_test (SDK provided), widget tests for UI components when needed  
**Target Platform**: iOS and Android mobile (existing project has android/ and ios/ folders)  
**Project Type**: mobile (Flutter cross-platform)  
**Performance Goals**: 30+ FPS for map interaction, <2s track import for 1000 points, <1s map style switch (cached areas), <3s app launch  
**Constraints**: Fully offline-capable after caching, tile downloads during online browsing only, coordinate accuracy within 5m at zoom 16, storage warning at 80% capacity with user control  
**Scale/Scope**: Single-user mobile app, 50+ km² cache capacity at zoom 14, support 10k+ GPS points per track, 3 map styles minimum, unlimited simultaneous track display

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Initial Evaluation (Pre-Research)

- **MVP-First Development**: ✅ PASS - Feature spec defines P1 (map viewing + caching) as working end-to-end MVP. User can browse map online, tiles cache automatically, and view cached areas offline. Complete workflow without placeholders.

- **Minimal Viable Features**: ✅ PASS - P1 scope is minimum: standard OSM display, auto-cache on view, offline playback. P2 (GPX import) adds value independently. P3 (style switching) and P4 (additional formats) are explicit enhancements. Each priority level scoped to smallest useful increment.

- **Independent User Stories**: ✅ PASS - User Story 1 (map+cache) works standalone. User Story 2 (GPX) works independently (imports file, displays track on existing map). User Story 3 (styles) enhances map viewing without requiring tracks. User Story 4 extends import capability. Spec explicitly validates independence: "Can be fully tested by..." for each story.

- **Progressive Enhancement**: ✅ PASS - Plan starts with core map display using standard Flutter/Dart capabilities. File picker and map widget libraries justified by platform gaps (no native OSM tile renderer, no built-in GPX parser). Third-party dependencies evaluated in Phase 0 research. Advanced features (track statistics, POI search) explicitly out of scope.

- **Maintainability**: ✅ PASS - No premature complexity introduced. Starting with StatefulWidget per constitution. Simple data model (tiles, tracks, styles). Dependencies require justification in Phase 0. Performance goals are measurable (30 FPS, 2s import) not speculative optimizations.

**Complexity Justification**: None required at this stage. Standard Flutter mobile app with minimal scope. Will re-evaluate after Phase 1 design if architectural patterns emerge.

---

### Post-Design Evaluation (After Phase 1)

**Re-verification Date**: 2025-12-28

- **MVP-First Development**: ✅ PASS - Design maintains end-to-end MVP focus. Phase 1 implementation delivers complete map viewing with offline caching. No architectural scaffolding blocking user value delivery. Service interfaces are concrete and immediately implementable.

- **Minimal Viable Features**: ✅ PASS - Data model defines only entities needed for MVP (MapTile, MapStyle, Track, TrackPoint). No speculative features added. Service contracts cover only required operations: tile cache management, file picking, track parsing. Each service has single clear responsibility. Clarifications added features with clear user value (storage warnings, multiple track display).

- **Independent User Stories**: ✅ PASS - Service contracts maintain story independence:
  - TileCacheService works standalone (P1: map viewing)
  - FilePickerService + TrackParserService work independently (P2: track import)
  - No dependencies between track and tile caching systems
  - Style switching reuses existing tile cache (P3)
  - Multiple track display is additive (no breaking changes to single track flow)

- **Progressive Enhancement**: ✅ PASS - Technology choices validated in research.md:
  - `flutter_map`: Mature OSM library, proven in production
  - `gpx` package: P2 priority only, other formats deferred to P4
  - `file_picker`: Official Flutter Community package
  - All choices favor standard solutions over custom implementations
  - No premature abstraction: direct service calls, StatefulWidget state
  - Storage warning is reactive UI, not complex monitoring system

- **Maintainability**: ✅ PASS - Design remains simple:
  - 3 services with clear interfaces (8 methods total across all services)
  - 4 data entities (MapTile, Track, MapStyle, Cache) with straightforward fields
  - No repository pattern, no complex state management, no dependency injection framework
  - File-based cache (not database) for simplicity
  - In-memory track storage for MVP (persistence deferred)
  - Multiple track display uses List<Track> + color assignment (no complex state)

**Complexity Introduced**: None beyond justifiable libraries
- `flutter_map` + plugins: Required for OSM tile display (no native alternative)
- `gpx` package: Standard parser for most common GPS format
- `file_picker`: Native file dialogs (no reasonable alternative)

**Architecture Simplicity**:
- Models: Plain Dart classes with fields
- Services: Abstract interfaces with concrete implementations
- Widgets: Standard Flutter StatefulWidgets
- State: Widget state only (no Provider, Bloc, Riverpod, etc.)
- Storage: File system directly (no Hive, SQLite, etc. for MVP)

**Deferred Complexity** (correctly postponed):
- Track persistence: Deferred to post-MVP (in-memory sufficient for single-session use)
- Advanced state management: Not needed until state sharing becomes problematic
- Multiple track management UI: Simple list iteration sufficient for MVP
- Offline geocoding, route planning: Explicitly out of scope

**Verdict**: ✅ **ALL GATES PASS** - Design adheres to all constitution principles. No unjustified complexity. Clarifications maintain MVP focus. Ready to proceed to Phase 2 (task breakdown via /speckit.tasks command).

## Project Structure

### Documentation (this feature)

```text
specs/001-offline-map-tracks/
├── spec.md              # Feature specification (exists)
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── main.dart                    # App entry point (exists)
├── models/                      # Data entities
│   ├── map_tile.dart           # Tile cache entry model
│   ├── track.dart              # GPS track data model
│   └── map_style.dart          # Map style configuration
├── services/                    # Business logic
│   ├── tile_cache_service.dart # Tile download/storage
│   ├── track_parser_service.dart # GPX/KML/etc parsing
│   └── file_picker_service.dart # File import handling
├── widgets/                     # UI components
│   ├── map_view.dart           # Main map display widget
│   ├── track_overlay.dart      # Track line rendering
│   └── style_selector.dart     # Map style picker
└── screens/                     # Full pages
    └── home_screen.dart        # Main app screen

test/
├── models/                      # Model unit tests (if needed)
├── services/                    # Service unit tests (if needed)
└── widgets/                     # Widget tests (if needed)

android/                         # Android platform (exists)
ios/                            # iOS platform (exists)
```

**Structure Decision**: Mobile project using standard Flutter feature-based organization. lib/ contains app code organized by layer (models, services, widgets, screens). Platform-specific code remains in android/ and ios/ folders. Tests mirror source structure when added. No complex module separation needed for MVP scope.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations - all complexity is justified per Constitution Check above.

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
