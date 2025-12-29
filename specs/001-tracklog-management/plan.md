# Implementation Plan: Tracklog Management System

**Branch**: `001-tracklog-management` | **Date**: December 29, 2025 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-tracklog-management/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Add comprehensive tracklog management UI to the map screen with persistent storage. Users can name tracklogs during import via dialog prompt, manage tracklogs through a full-screen list interface (show/hide, remove, rename, change color), and navigate map to tracklog positions by tapping list items. All tracklogs and their configurations persist across app sessions.

## Technical Context

**Language/Version**: Dart 3.5.4+, Flutter 3.5.4+  
**Primary Dependencies**: flutter_map 6.1.0, geolocator 10.1.0, file_picker 6.1.0, gpx 2.2.0, xml 6.5.0, archive 3.4.0  
**Storage**: shared_preferences for tracklog metadata persistence, file system for tracklog data  
**Testing**: Flutter widget tests when explicitly required  
**Target Platform**: iOS and Android mobile  
**Project Type**: Mobile (standard Flutter project structure)  
**Performance Goals**: <2 second management operations, smooth list scrolling with 20+ tracklogs, <1 second visibility toggles  
**Constraints**: Must work offline, <30 second add workflow, minimal battery impact  
**Scale/Scope**: Support 20+ tracklogs simultaneously, track collections up to 5000 points each

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Verify alignment with constitution principles:

- **MVP-First Development**: ✅ PASS - P1 delivers complete add-with-name workflow end-to-end. User can import tracklog, assign name, see it on map immediately. P2 adds persistence, P3 adds list navigation, P4 adds management features. Each priority delivers working functionality.

- **Minimal Viable Features**: ✅ PASS - Scope narrowly focused on tracklog management only:
  - P1: Add named tracklog (minimal user value: distinguish tracklogs)
  - P2: Persistence (minimal addition: don't lose data)
  - P3: List navigation (minimal addition: find tracklogs quickly)
  - P4: Management operations (minimal addition: control visibility/appearance)
  - No search, filtering, sorting, batch operations, export, or sharing in initial scope

- **Independent User Stories**: ✅ PASS - Each priority is independently testable:
  - P1 alone: Can add and view single named tracklog (functional MVP)
  - P2 builds on P1: Add persistence without breaking P1
  - P3 builds on P1+P2: Add list view without changing add/persist
  - P4 builds on all: Add management without breaking viewing
  - Can ship P1 only and deliver user value (distinguish between multiple tracklogs)

- **Progressive Enhancement**: ✅ PASS - Uses existing platform capabilities:
  - Builds on existing TrackParserService, FilePickerService (no changes)
  - Name dialog: standard Flutter AlertDialog (platform native)
  - Color picker: Flutter color picker widget (standard library)
  - Storage: shared_preferences (official Flutter package, minimal)
  - Full screen list: standard ListView (no custom animations)
  - No custom state management, no complex UI patterns, no third-party UI libraries

- **Maintainability**: ✅ PASS - Simple, straightforward additions:
  - One new service: TracklogStorageService (load/save/update/delete operations)
  - One new screen: TracklogListScreen (standard ListView)
  - Two new dialogs: NameDialog, ColorPickerDialog (standard Flutter patterns)
  - Extends existing Track model with isVisible field (boolean, simple)
  - No repository pattern, no complex state management, no architectural patterns

**Complexity Justification**: No additional complexity introduced beyond existing project patterns. Feature uses standard Flutter widgets, official packages already in project (shared_preferences commonly used for preferences), and maintains simple service-based architecture established in prior features.

### Post-Phase 1 Re-evaluation (Design Complete)

After completing Phase 0 research, Phase 1 data model, and Phase 1 contracts, all principles still pass:

- **MVP-First**: ✅ Confirmed - Design maintains incremental delivery. P1 (name dialog + display) works independently. P2 (persistence) adds value without breaking P1. P3 (list UI) navigable without P4 management. No "big bang" integration required.

- **Minimal Features**: ✅ Confirmed - No feature creep in design phase. Research eliminated complex options (no SQLite, no Hive, no Isar). Contracts specify only required operations (6 storage methods, 3 dialogs, 5 list interactions). Rejected: search/filter, batch operations, import/export, custom UI animations.

- **Independent Stories**: ✅ Confirmed - Data model separates concerns: TracklogMetadata for list display (lightweight), Track for map display (full data), TracklogStorageService isolates persistence. Each component testable independently. Contracts show P1 works without P2-P4 dependencies.

- **Progressive Enhancement**: ✅ Confirmed - Design uses standard patterns throughout:
  - shared_preferences: Official Flutter package, no custom storage layer
  - flutter_colorpicker: Standard color picker library, no custom color UI
  - StatefulWidget + setState: Standard Flutter state (no Redux/BLoC/Riverpod)
  - ListView + ListTile: Platform widgets (no custom scrolling, no virtualization)
  - AlertDialog: Native dialogs (no custom dialog framework)

- **Maintainability**: ✅ Confirmed - Implementation straightforward:
  - TracklogStorageService: 6 methods, clear contracts, synchronous interface with Future return
  - Dialog functions: 3 functions returning Future<T?>, standard Flutter async patterns
  - TracklogListScreen: Standard StatefulWidget, 1 screen = 1 file
  - No new architectural patterns, no abstractions beyond storage service interface

**Design Complexity Audit**: Zero unjustified complexity found. All decisions use simplest viable approach confirmed through research.md. Hybrid storage (shared_preferences + files) justified by performance targets (metadata <1KB needs quick access, coordinates >100KB needs file storage). Color picker library justified by avoiding 200+ lines custom color UI code. No other libraries added beyond these two minimal dependencies.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
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
├── models/
│   ├── track.dart                    # MODIFIED: Add isVisible field to Track class
│   └── tracklog_metadata.dart        # NEW: Lightweight metadata for list display
├── services/
│   ├── file_picker_service.dart      # EXISTING: No changes
│   ├── track_parser_service.dart     # EXISTING: No changes
│   ├── location_service.dart         # EXISTING: No changes
│   ├── tile_cache_service.dart       # EXISTING: No changes
│   └── tracklog_storage_service.dart # NEW: Persistence service (CRUD operations)
├── screens/
│   ├── map_screen.dart               # MODIFIED: Add tracklog list button, storage integration, callbacks
│   ├── tracklog_list_screen.dart     # NEW: Full-screen list with management operations
│   ├── dashboard_screen.dart         # EXISTING: No changes
│   ├── settings_screen.dart          # EXISTING: No changes
│   └── home_screen.dart              # EXISTING: No changes
├── widgets/
│   ├── map_view.dart                 # EXISTING: No changes
│   └── tracklog_dialogs.dart         # NEW: Name, color picker, confirmation dialogs
└── main.dart                         # EXISTING: No changes

test/
├── widget_test.dart                  # EXISTING: Update if needed
└── fixtures/                         # EXISTING: Test data

specs/001-tracklog-management/
├── spec.md                           # Feature specification
├── plan.md                           # This file
├── research.md                       # Technology decisions
├── data-model.md                     # Entity definitions
├── quickstart.md                     # Implementation guide
└── contracts/                        # Service/UI contracts
    ├── tracklog_storage_service.md   # Storage service contract
    ├── dialog_helpers.md             # Dialog function contracts
    ├── tracklog_list_screen.md       # List screen UI contract
    └── README.md                     # Contracts index
```

**Structure Decision**: Standard Flutter mobile app structure. New files are added to existing directories following established patterns:

- **Models**: Add `tracklog_metadata.dart` for lightweight list entities, modify `track.dart` to add `isVisible` field
- **Services**: Add `tracklog_storage_service.dart` implementing persistence layer with shared_preferences + file system
- **Screens**: Add `tracklog_list_screen.dart` for tracklog management UI, modify `map_screen.dart` for integration
- **Widgets**: Add `tracklog_dialogs.dart` containing 3 dialog functions (name, color picker, confirmation)
- **No new directories**: Feature follows existing architecture without introducing new layers

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
