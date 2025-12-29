# Implementation Plan: Bottom Navigation and Live Location Tracking

**Branch**: `002-navigation-location-ui` | **Date**: December 29, 2025 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-navigation-location-ui/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

This feature adds a bottom navigation bar with three tabs (Dashboard, Map, Settings) and implements live device location tracking with visual indicators on the map. The implementation renames the existing home_screen.dart to map_screen.dart, creates a new home_screen.dart with bottom navigation, adds a location service using the existing geolocator package, and enhances the map with a "center on location" button and real-time map information display. The technical approach uses Flutter's built-in BottomNavigationBar widget, StreamSubscription for location updates, and custom map overlays for the location indicator and info display.

## Technical Context

**Language/Version**: Dart 3.5.4+ with Flutter SDK 3.5.4+  
**Primary Dependencies**: flutter_map (6.1.0) for map rendering, geolocator (10.1.0) for location services, latlong2 (0.9.0) for coordinate handling  
**Storage**: Local file system via path_provider (for tile cache) - no changes needed for this feature  
**Testing**: flutter_test (manual testing for P1 stories, widget tests when complexity warrants)  
**Target Platform**: iOS 13+ and Android 8+ (mobile platforms)  
**Project Type**: Mobile (Flutter cross-platform)  
**Performance Goals**: 60 FPS map rendering during location updates, <100ms tab switching, <1s location indicator updates  
**Constraints**: Location updates only when app in foreground, battery-efficient location tracking (balanced accuracy mode), readable UI on devices from 4" to 7" screens  
**Scale/Scope**: Single-user mobile app, adding 3 new screens (dashboard, settings placeholders + new home with nav), 1 new service (location), ~5-7 new files

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Verify alignment with constitution principles:

- **MVP-First Development**: ✅ YES - Feature delivers working end-to-end navigation and location tracking in first iteration. P1 stories (navigation structure + location indicator) create immediately usable functionality.
  
- **Minimal Viable Features**: ✅ YES - Scope limited to essential elements: bottom nav with 3 tabs, location indicator (blue/gray dot), center button, and info display. No unnecessary features like location history, compass, speed tracking, or custom accuracy settings. Dashboard and Settings are intentionally placeholders.
  
- **Independent User Stories**: ✅ YES - Each user story can be implemented independently:
  - P1 (Navigation): Can implement bottom nav without location features
  - P1 (Location Indicator): Can add indicator without center button or info display
  - P2 (Center Button): Works independently once location tracking exists
  - P3 (Map Info): Pure UI enhancement, no dependencies on other stories
  
- **Progressive Enhancement**: ✅ YES - Plan starts with Flutter's standard BottomNavigationBar widget and existing geolocator package (already in dependencies). No new external libraries needed. Uses StatefulWidget with setState for state management (no complex state solutions). Custom overlays use standard Flutter painting techniques.
  
- **Maintainability**: ✅ YES - Simple, straightforward implementation:
  - Bottom nav: Standard Flutter widget with integer index
  - Location service: Single class wrapping geolocator with StreamSubscription
  - Location indicator: Custom painter or simple marker overlay
  - No complex patterns, factories, or abstractions introduced
  - Direct function calls, explicit code over clever abstractions

**Complexity Justification**: None required - feature uses standard Flutter patterns and existing dependencies. No repositories, state management frameworks, or design patterns beyond basic OOP.

## Project Structure

### Documentation (this feature)

```text
specs/002-navigation-location-ui/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── location-service.md
│   └── map-controller.md
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── main.dart                           # Update: Change MaterialApp home to new HomeScreen
├── screens/
│   ├── home_screen.dart                # NEW: Bottom navigation container
│   ├── map_screen.dart                 # RENAMED FROM: home_screen.dart
│   ├── dashboard_screen.dart           # NEW: Placeholder for dashboard tab
│   └── settings_screen.dart            # NEW: Placeholder for settings tab
├── services/
│   ├── location_service.dart           # NEW: Device location tracking service
│   ├── file_picker_service.dart        # EXISTING: No changes
│   ├── tile_cache_service.dart         # EXISTING: No changes
│   └── track_parser_service.dart       # EXISTING: No changes
├── widgets/
│   ├── map_view.dart                   # UPDATE: Add location indicator overlay, map info display
│   └── location_indicator.dart         # NEW: Custom painter for blue/gray dot
├── models/
│   ├── map_style.dart                  # EXISTING: No changes
│   ├── map_tile.dart                   # EXISTING: No changes
│   ├── track.dart                      # EXISTING: No changes
│   └── device_location.dart            # NEW: Location data model
└── features/                           # EXISTING: No changes to feature modules
    └── show_current_location/          # Related to this work but not modified

test/
├── widget_test.dart                    # EXISTING: May need updates
└── fixtures/                           # EXISTING: No changes

android/
└── app/src/main/AndroidManifest.xml    # UPDATE: Add location permissions
    
ios/
└── Runner/Info.plist                   # UPDATE: Add location usage descriptions
```

**Structure Decision**: Standard Flutter mobile project structure with feature-based organization. New files follow existing patterns: screens in `/screens`, services in `/services`, widgets in `/widgets`, models in `/models`. The feature maintains separation of concerns with a dedicated location service, reusable location indicator widget, and updated map_view for new UI elements. Platform-specific permission configurations added to AndroidManifest.xml and Info.plist as required for location services.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations - feature adheres to all constitution principles. No complexity tracking required.

---

## Phase 0: Research & Outline

*Resolves all NEEDS CLARIFICATION items from Technical Context*

### Research Tasks

Based on Technical Context, the following areas require research:

1. **Location Services Implementation**: How to properly use geolocator package for foreground-only location tracking with lifecycle management
2. **Bottom Navigation Patterns**: Flutter best practices for BottomNavigationBar with state preservation across tabs
3. **Map Overlay Techniques**: Methods for adding custom overlays (location indicator, info display) to flutter_map
4. **Permission Handling**: Cross-platform approach for requesting and handling location permissions on iOS and Android
5. **Map Controller Access**: How to programmatically control map view (centering, getting current state) in flutter_map

All items will be researched and documented in `research.md`.

---

## Phase 1: Design & Contracts

*Prerequisites: research.md complete*

### Outputs

1. **data-model.md**: Define data structures for DeviceLocation, LocationIndicator state, NavigationTab, and MapInformation
2. **contracts/**: Service interfaces and widget contracts
   - `location-service.md`: LocationService interface with stream-based location updates
   - `map-controller.md`: MapView enhancement contract for location display and programmatic control
3. **quickstart.md**: Development setup, testing guide, and manual testing procedures for location features
4. **Agent context update**: Run `.specify/scripts/bash/update-agent-context.sh copilot` to add location tracking context

### Post-Design Constitution Re-check

After Phase 1 design, verify:
- No unnecessary complexity introduced in data models
- Service contracts remain simple and focused
- Design maintains independent testability of user stories

**RE-CHECK RESULTS** (December 29, 2025):

✅ **MVP-First Development**: Design delivers working end-to-end functionality. All P1 stories implementable in first iteration:
  - Bottom navigation with 3 tabs (functional immediately)
  - Location indicator with blue/gray dot (functional once LocationService added)
  - Both can be tested independently and deliver value

✅ **Minimal Viable Features**: Design remains minimal:
  - 4 data models (DeviceLocation, LocationIndicatorState, NavigationTab, MapInformation) - all necessary, no extras
  - 1 service (LocationService) - single responsibility, focused interface
  - Widget enhancements to MapView - minimal additions, backward compatible
  - No caching, no persistence, no complex state management

✅ **Independent User Stories**: Design maintains independence:
  - Bottom navigation: Can implement without touching location code
  - Location indicator: LocationService contract allows testing in isolation
  - Center button: Simple method call, no complex dependencies
  - Map info: Pure UI enhancement, no service dependencies

✅ **Progressive Enhancement**: Design uses standard patterns:
  - BottomNavigationBar + IndexedStack (Flutter built-ins)
  - StreamSubscription for location (standard Dart pattern)
  - MarkerLayer for indicator (flutter_map standard layer)
  - No custom state management, no complex patterns
  - All dependencies already in project (geolocator, flutter_map)

✅ **Maintainability**: Design is simple and straightforward:
  - Data models: Simple immutable classes with clear fields
  - LocationService: 5 methods, single responsibility, well-defined contract
  - MapView changes: Additive only, backward compatible, no breaking changes
  - No factories, no repositories, no abstract patterns beyond service interface
  - Direct function calls, explicit code

**VERDICT**: ✅ **DESIGN APPROVED** - All constitution principles satisfied. Proceed to Phase 2 (task generation).

---

**/speckit.plan command execution ends here. Phase 2 (/speckit.tasks) will generate tasks.md.**

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
