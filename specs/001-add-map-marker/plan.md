# Implementation Plan: Add Map Marker

**Branch**: `001-add-map-marker` | **Date**: 2025-12-30 | **Spec**: specs/001-add-map-marker/spec.md
**Input**: Feature specification from specs/001-add-map-marker/spec.md

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Enable users to long-press on the map, launch a bottom-sheet guided flow (Add marker → choose icon → choose color → name → create), and persist the marker locally per user/session using existing Flutter map and storage dependencies. The plan favors minimal additions: reuse `flutter_map` for gestures/rendering and `shared_preferences` for lightweight local persistence, keeping state in simple widgets without new state-management packages.

## Technical Context

**Language/Version**: Dart 3.5.4 (Flutter SDK 3.5.4+)  
**Primary Dependencies**: flutter_map (map rendering/gestures), latlong2 (coords), shared_preferences (local persistence), flutter_colorpicker (color selection UI)  
**Storage**: Local key-value via shared_preferences (JSON-serialized marker list scoped to user/session)  
**Testing**: Manual validation for the flow; optional widget test via flutter_test for bottom sheet navigation/validation  
**Target Platform**: iOS and Android mobile  
**Project Type**: Mobile app (single Flutter project)  
**Performance Goals**: Maintain 60 fps map interactions; marker load/display under 200 ms on app launch for typical marker counts (<200)  
**Constraints**: Offline-friendly (local storage), minimal new dependencies, keep flow operable without network  
**Scale/Scope**: Single map screen flow; limited to user-local markers (no sync in this iteration)

## Constitution Check

- **MVP-First Development**: Yes — delivers end-to-end marker creation and persistence in first iteration.
- **Minimal Viable Features**: Yes — focuses on single-marker creation flow with basic icon/color selection and local storage only.
- **Independent User Stories**: Yes — P1 (basic create) stands alone; P2 (customization) and P3 (back/cancel) layered without blocking P1.
- **Progressive Enhancement**: Yes — relies on platform-standard widgets and existing dependencies; no advanced state management.
- **Maintainability**: Yes — simple models and shared_preferences; no new patterns unless proven necessary.

**Complexity Justification**: None required.

## Project Structure

### Documentation (this feature)

```text
specs/001-add-map-marker/
├── plan.md              # This file (/speckit.plan output)
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── features/
│   ├── map/
│   │   ├── data/        # marker_store.dart (local persistence)
│   │   ├── models/      # marker.dart, marker_style.dart
│   │   └── widgets/     # map_view.dart, marker_bottom_sheet.dart
├── services/
└── widgets/

assets/
├── icons/
└── images/

specs/001-add-map-marker/ (feature docs)
```

**Structure Decision**: Use existing single Flutter app structure under lib with feature folder for map flow; add data/models/widgets in lib/features/map to keep marker logic localized.

## Complexity Tracking

None.
