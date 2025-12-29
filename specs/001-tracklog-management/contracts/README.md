# Contracts Index: Tracklog Management System

**Feature**: Tracklog Management with Persistent Storage  
**Date**: December 29, 2025

---

## Overview

This directory contains interface contracts and specifications for the tracklog management feature. Each contract defines the expected behavior, inputs, outputs, and error handling for a component.

---

## Service Contracts

### 1. [TracklogStorageService](./tracklog_storage_service.md)

**Purpose**: Persist and retrieve tracklog metadata and coordinate data

**Key Operations**:
- `saveTracklog(Track)` - Save new tracklog with full data
- `loadAllMetadata()` - Load lightweight metadata for list display
- `loadTrack(id)` - Load full coordinates for specific tracklog
- `updateMetadata(metadata)` - Update name, color, visibility
- `deleteTracklog(id)` - Permanently remove tracklog
- `cleanupOrphanedFiles()` - Maintenance operation

**Implementation**: `lib/services/tracklog_storage_service.dart`

**Dependencies**: shared_preferences, path_provider, dart:io, dart:convert

---

## UI Contracts

### 2. [Dialog Helpers](./dialog_helpers.md)

**Purpose**: Reusable dialog functions for user input and confirmations

**Functions**:
- `showNameDialog(context, initialValue)` - Input/edit tracklog name
- `showColorPickerDialog(context, currentColor)` - Select tracklog color  
- `showDeleteConfirmation(context, tracklogName)` - Confirm permanent deletion

**Implementation**: `lib/widgets/tracklog_dialogs.dart` or inline

**Dependencies**: flutter_colorpicker package

### 3. [TracklogListScreen](./tracklog_list_screen.md)

**Purpose**: Full-screen list view for tracklog management

**Features**:
- Display all tracklogs with metadata
- Show/hide visibility toggle
- Rename, change color, remove operations
- Tap to center map on tracklog
- Empty state handling

**Implementation**: `lib/screens/tracklog_list_screen.dart`

**Navigation**: From MapScreen app bar → Returns selected tracklog ID

---

## Data Contracts

### TracklogMetadata

Lightweight tracklog representation for list display and persistence.

**See**: [data-model.md](../data-model.md#entity-tracklogmetadata)

**Fields**: id, name, color, isVisible, filePath, importedAt, importedFrom, format, bounds

**Serialization**: JSON for shared_preferences storage

### Track (Extended)

Existing Track model with added `isVisible` field.

**See**: [data-model.md](../data-model.md#entity-track-extended)

**Modification**: Add `isVisible: bool` field with default `true`

---

## Integration Flow

### Add Tracklog with Name (P1)

```
User picks file (FilePickerService)
      ↓
Show name dialog (Dialog Helpers)
      ↓
Parse file (TrackParserService - existing)
      ↓
Create Track with name + default color
      ↓
Save tracklog (TracklogStorageService.saveTracklog)
      ↓
Display on map (MapScreen)
```

### Load Tracklogs on App Start (P2)

```
App startup
      ↓
Load metadata (TracklogStorageService.loadAllMetadata)
      ↓
For each visible tracklog:
  Load coordinates (TracklogStorageService.loadTrack)
      ↓
Render on map (MapScreen)
```

### Manage Tracklogs via List (P3, P4)

```
User taps list button (MapScreen app bar)
      ↓
Navigate to TracklogListScreen
      ↓
Display tracklogs with metadata
      ↓
User performs action (show/hide, rename, color, remove)
      ↓
Update metadata (TracklogStorageService.updateMetadata)
      ↓
Return to MapScreen (optional: with selected tracklog ID)
      ↓
Center map if tracklog selected
```

---

## API Design Principles

These contracts follow Flutter/Dart conventions:

1. **Async by default**: All I/O operations return `Future<T>`
2. **Named parameters**: Optional parameters use named syntax with defaults
3. **Null safety**: Explicit `?` for nullable returns
4. **Immutable data**: Metadata classes are immutable (final fields)
5. **Clear naming**: Method names describe action (save, load, update, delete)
6. **Single responsibility**: Each service has one clear purpose
7. **Standard patterns**: Use Flutter/Material Design UI patterns
8. **Error handling**: Specific exceptions for different failure modes

---

## Implementation Priority

**Phase 1 (P1 - Add Named Tracklog)**:
1. Dialog Helpers: `showNameDialog` function
2. TracklogStorageService: `saveTracklog`, `loadAllMetadata` methods
3. Track model: Add `isVisible` field

**Phase 2 (P2 - Persistence)**:
1. TracklogStorageService: `loadTrack` method
2. MapScreen: Load metadata on startup, load visible tracks

**Phase 3 (P3 - Tracklog List)**:
1. TracklogListScreen: Basic list display, tap navigation
2. MapScreen: Add app bar button, handle return with selected ID

**Phase 4 (P4 - Management Operations)**:
1. Dialog Helpers: `showColorPickerDialog`, `showDeleteConfirmation`
2. TracklogListScreen: Popup menu with all actions
3. TracklogStorageService: `updateMetadata`, `deleteTracklog` methods

---

## Testing Strategy

### Contract Tests

Each contract should have tests verifying:
- Interface compliance (all methods implemented)
- Input validation (null checks, range checks)
- Output format (correct types, non-null guarantees)
- Error handling (appropriate exceptions thrown)

### Integration Tests

Cross-contract tests verifying:
- Add tracklog → Persists → Survives app restart
- Update metadata → Storage updated → UI reflects changes
- Delete tracklog → File removed → List updated

### Mock Implementations

For testing other components:
- MockTracklogStorageService (in-memory, no I/O)
- Mock dialog results (return predefined values)

---

## Dependencies

**New Packages Required**:
```yaml
dependencies:
  shared_preferences: ^2.2.0  # TracklogStorageService
  flutter_colorpicker: ^1.0.3  # Dialog Helpers
```

**Existing Packages Used**:
- path_provider: ^2.1.0 (file system access)
- Flutter SDK (UI widgets, dart:io, dart:convert)

---

## Related Documentation

- [Data Model](../data-model.md): Entity definitions and relationships
- [Research](../research.md): Technology decisions and rationale
- [Quickstart](../quickstart.md): Setup and development instructions
- [Spec](../spec.md): Feature requirements and user stories

---

## Maintenance Notes

### Versioning

Contracts are versioned implicitly with the feature:
- **V1**: Current specification (P1-P4 implementation)
- **Future versions**: May add methods, should not break existing signatures

### Breaking Changes

If interface changes required:
1. Deprecate old method with `@deprecated` annotation
2. Add new method with different name
3. Maintain both for migration period
4. Remove deprecated method in major version bump

### Contract Updates

When updating contracts:
1. Update contract document
2. Update related implementation
3. Update tests to verify new behavior
4. Update quickstart guide if usage changes
