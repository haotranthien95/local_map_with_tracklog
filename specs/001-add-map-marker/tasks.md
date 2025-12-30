---

description: "Task list for feature implementation"
---

# Tasks: Add Map Marker

**Input**: Design documents from /specs/001-add-map-marker/
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Not explicitly requested; no test tasks included.
**Organization**: Tasks grouped by user story to keep each slice independently implementable/testable.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare folders and assets for the map marker feature

- [X] T001 Create feature directories for marker flow in lib/features/map/{models,data,widgets}
- [X] T002 Update asset registration in pubspec.yaml to include marker icons under assets/icons/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data and persistence required before user stories

- [X] T003 [P] Define Marker data model with JSON (de)serialization in lib/features/map/models/marker.dart
- [X] T004 [P] Define MarkerStyle catalog (icon/color options) in lib/features/map/models/marker_style.dart
- [X] T005 Implement shared_preferences-backed marker_store (load/save by user/session key) in lib/features/map/data/marker_store.dart
- [X] T006 Load markers from marker_store during app startup hook in lib/features/map/widgets/map_view.dart (data bootstrap only, no UI yet)

---

## Phase 3: User Story 1 - Create a basic marker (Priority: P1) 🎯 MVP

**Goal**: Long-press to add a named marker with default icon/color, render immediately, persist locally, and reload on restart.

**Independent Test**: From a blank map, long-press → Add marker → enter name → Create. Marker shows with default icon/color and remains after app restart.

### Implementation for User Story 1

- [X] T007 [P] [US1] Implement bottom sheet scaffold capturing long-press coordinate and default selections in lib/features/map/widgets/marker_bottom_sheet.dart
- [X] T008 [US1] Wire flutter_map long-press to open marker_bottom_sheet with captured LatLng in lib/features/map/widgets/map_view.dart
- [X] T009 [US1] Add naming step with inline validation; on Create persist marker via marker_store with default icon/color in lib/features/map/widgets/marker_bottom_sheet.dart
- [X] T010 [US1] Render markers from marker_store (initial load and after creation) on the map using flutter_map layers in lib/features/map/widgets/map_view.dart

**Checkpoint**: User Story 1 fully functional and independently testable.

---

## Phase 4: User Story 2 - Customize marker appearance (Priority: P2)

**Goal**: User chooses icon and color before naming, and created marker displays chosen appearance.

**Independent Test**: Start add flow, pick non-default icon/color, name marker, create; map shows chosen appearance and it persists on restart.

### Implementation for User Story 2

- [X] T011 [P] [US2] Add icon selection step using MarkerStyle catalog in lib/features/map/widgets/marker_bottom_sheet.dart
- [X] T012 [P] [US2] Add color selection step using predefined palette in lib/features/map/widgets/marker_bottom_sheet.dart
- [X] T013 [US2] Apply chosen icon/color to marker creation persistence and map rendering in lib/features/map/widgets/marker_bottom_sheet.dart and lib/features/map/widgets/map_view.dart

**Checkpoint**: User Stories 1 and 2 functional and independently testable.

---

## Phase 5: User Story 3 - Cancel or step back safely (Priority: P3)

**Goal**: Back/Cancel available at each step; no unintended markers are created.

**Independent Test**: Enter flow, move between steps, then cancel before creation; no marker appears. Back preserves current selections.

### Implementation for User Story 3

- [X] T014 [P] [US3] Implement Back navigation between steps preserving selections in lib/features/map/widgets/marker_bottom_sheet.dart
- [X] T015 [US3] Implement Cancel/close behavior that exits flow without saving and clears draft state in lib/features/map/widgets/marker_bottom_sheet.dart and lib/features/map/widgets/map_view.dart
- [X] T016 [US3] Add guard to prevent persistence when validation fails or when flow is canceled; ensure no marker stored in lib/features/map/widgets/marker_bottom_sheet.dart

**Checkpoint**: User Stories 1–3 independent and functional.

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Finishing touches affecting multiple stories

- [ ] T017 [P] Update quickstart with final icon/color defaults and flow notes in specs/001-add-map-marker/quickstart.md
- [ ] T018 Run manual quickstart walkthrough to confirm long-press flow, customization, and cancel/back behavior; note results in specs/001-add-map-marker/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies
- Setup (Phase 1) → Foundational (Phase 2) → User Stories (Phases 3–5) → Polish (Phase N)

### User Story Dependencies
- US1 (P1) depends on Foundational complete; no dependency on other stories.
- US2 (P2) depends on US1 data/render path; can proceed after US1 or in parallel once shared rendering hooks are stable.
- US3 (P3) depends on US1 flow scaffold; can layer after US1 (and after US2 if sharing step UI).

### Within Each User Story
- Models/catalog before store wiring in that scope.
- Open sheet → input validation → persistence → render.

## Parallel Opportunities
- Phase 1 tasks (T001–T002) can run in parallel.
- Phase 2 model/catalog (T003–T004) can run in parallel; marker_store (T005) can run alongside once model shape is defined.
- US1: T007 (sheet scaffold) and T008 (map hook) can start in parallel; T009 depends on T007; T010 depends on T008 + store.
- US2: T011 and T012 in parallel; T013 depends on both.
- US3: T014 and T015 in parallel; T016 depends on them.
- Polish tasks T017–T018 can run after all stories.

## Implementation Strategy

- **MVP first**: Deliver US1 end-to-end before layering customization/back-cancel polish.
- **Incremental**: Ship US1 → validate → add US2 → validate → add US3 → validate.
- **Parallel**: Different contributors can take US2 and US3 after US1 scaffolding is stable; foundational model/store tasks can be parallelized early.
