# Research: Tracklog Management System

**Feature**: Tracklog Management with Persistent Storage  
**Date**: December 29, 2025  
**Status**: Complete

## Research Tasks

### 1. Tracklog Persistence Strategy

**Unknown**: How should tracklogs be persisted across app sessions?

**Research Findings**:

**Decision**: shared_preferences for metadata + file system for track data (hybrid approach)

**Rationale**:
- **Metadata Storage**: Use `shared_preferences` package (already common in Flutter projects) to store tracklog metadata (id, name, color, visibility, file path, bounds, timestamps)
- **Track Data Storage**: Keep existing parsed track files in application documents directory
- **Hybrid Approach Benefits**:
  - Fast metadata loading: All tracklog info (names, colors, visibility) loads quickly from shared_preferences for list display
  - Efficient memory usage: Full coordinate data (thousands of points) only loaded when needed for map display
  - Simple implementation: No schema migrations, no database setup, leverages existing file storage
  - Proven pattern: Many Flutter apps use shared_preferences for configuration and file system for large data
- **Trade-offs Accepted**:
  - No complex queries (acceptable: simple list operations sufficient)
  - Manual consistency management between prefs and files (acceptable: simple CRUD operations)

**Alternatives Considered**:
- **SQLite (sqflite package)**: Rejected - Overkill for simple list of tracklogs. Would require schema definition, migrations, more complex code. Constitution favors simpler solutions.
- **Hive (hive package)**: Rejected - Additional dependency for minimal benefit. shared_preferences + file system achieves same goal with packages already standard in Flutter ecosystem.
- **JSON file**: Rejected - Slower to read/write all tracklogs for every metadata update. shared_preferences provides atomic key-value updates.

**Implementation Notes**:
- Store list of tracklog IDs in shared_preferences key: `tracklog_ids`
- Store each tracklog metadata in shared_preferences key: `tracklog_<id>`
- Store track coordinate data as serialized files in documents directory: `tracklogs/<id>.json`
- On app start: Load metadata from shared_preferences, load coordinates lazily when tracklog becomes visible

---

### 2. Name Dialog Implementation

**Unknown**: How should the name input dialog be implemented and validated?

**Research Findings**:

**Decision**: Standard Flutter AlertDialog with TextFormField and validation

**Rationale**:
- **Platform Native**: AlertDialog is the standard Flutter dialog widget (Material Design on Android, adapts to iOS with showCupertinoDialog)
- **Simple Validation**: TextFormField provides built-in validation (check non-empty, trim whitespace)
- **User Experience**: Standard pattern users expect, modal dialog prevents accidental interactions, clear OK/Cancel buttons
- **No Dependencies**: Pure Flutter SDK, no additional packages needed
- **Reusable**: Same dialog pattern can be used for rename operation

**Implementation Pattern**:
```dart
Future<String?> showNameDialog(BuildContext context, {String? initialValue}) async {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(initialValue == null ? 'Name Tracklog' : 'Rename Tracklog'),
      content: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: 'Name'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) Navigator.pop(context, name);
          },
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

**Alternatives Considered**:
- **Bottom sheet input**: Rejected - AlertDialog is more appropriate for blocking action (must provide name before proceeding)
- **Custom dialog widget**: Rejected - Standard AlertDialog sufficient, no need for custom styling or complex layout
- **Inline editing**: Rejected - Requires more UI complexity, dialog provides clear context and validation step

---

### 3. Color Picker Implementation

**Unknown**: Which color picker widget/package should be used for tracklog color selection?

**Research Findings**:

**Decision**: `flutter_colorpicker` package with standard color picker dialog

**Rationale**:
- **Popular Package**: 300k+ downloads, well-maintained, active development
- **Material Design**: Follows Flutter/Material Design patterns, consistent with app UI
- **Multiple Picker Types**: Provides block picker, sliding picker, material picker - can use simple block picker for fast selection
- **Preview Support**: Built-in color preview as specified in requirements
- **Small Footprint**: Minimal dependencies, pure Flutter widgets
- **Dialog Integration**: Easy to wrap in AlertDialog for modal presentation

**Implementation Pattern**:
```dart
Future<Color?> showColorPickerDialog(BuildContext context, Color currentColor) async {
  Color selectedColor = currentColor;
  return showDialog<Color>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Color'),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: currentColor,
          onColorChanged: (color) => selectedColor = color,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selectedColor),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

**Alternatives Considered**:
- **Custom color picker**: Rejected - Building from scratch increases complexity and testing burden
- **Predefined palette only**: Considered but decided against - Color picker provides better user control without much added complexity
- **flex_color_picker**: Rejected - More feature-rich but heavier package, block picker sufficient for use case

---

### 4. Tracklog List UI Pattern

**Unknown**: How should the full-screen tracklog list be structured for efficient display and interaction?

**Research Findings**:

**Decision**: Standard Flutter ListView with ListTile and PopupMenuButton

**Rationale**:
- **Performance**: ListView.builder for efficient rendering of large lists (handles 50+ tracklogs smoothly)
- **Standard Pattern**: ListTile is the Flutter-recommended widget for list items with title, subtitle, trailing actions
- **PopupMenuButton**: Standard Material Design dropdown menu widget, perfect for show/hide/remove/rename/color actions
- **Navigation**: Scaffold provides standard app bar, back button, familiar navigation
- **Simple State**: StatefulWidget with List<TracklogMetadata> - no complex state management needed

**UI Structure**:
```
Scaffold
└── AppBar (title: "Tracklogs", back button)
    └── ListView.builder
        └── ListTile (for each tracklog)
            ├── leading: Icon (visibility indicator: visible/hidden)
            ├── title: Text (tracklog name)
            ├── subtitle: Text (import date, optional stats)
            ├── trailing: PopupMenuButton
            │   └── PopupMenuItem (Show/Hide, Remove, Rename, Change Color)
            └── onTap: Navigate back to map + center on tracklog
```

**Alternatives Considered**:
- **Bottom sheet**: Rejected per user clarification - Full screen provides better space for list with many items
- **Side drawer**: Rejected per user clarification - Full screen overlay preferred
- **Dismissible items**: Rejected - Too easy to accidentally delete, PopupMenu with confirmation dialog safer
- **Expansion tiles**: Rejected - Adds complexity, simple list with menu sufficient

---

### 5. Confirmation Dialog Pattern

**Unknown**: What's the standard Flutter pattern for delete confirmation?

**Research Findings**:

**Decision**: AlertDialog with clear warning message and Cancel/Delete buttons

**Rationale**:
- **Platform Standard**: AlertDialog is the standard pattern for destructive action confirmations in Flutter
- **Clear Communication**: Dialog message clearly states action is permanent
- **Color Coding**: Delete button in red color (destructive action) following Material Design guidelines
- **User Safety**: Prevents accidental deletion, aligns with constitution's maintainability principle

**Implementation Pattern**:
```dart
Future<bool> showDeleteConfirmation(BuildContext context, String tracklogName) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove Tracklog'),
      content: Text('Are you sure you want to remove "$tracklogName"? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  return result ?? false;
}
```

**Alternatives Considered**:
- **Undo snackbar**: Rejected per user clarification - Explicit confirmation preferred over soft delete
- **No confirmation**: Rejected - Too risky for destructive action per user clarification
- **Bottom sheet confirmation**: Rejected - AlertDialog more appropriate for blocking confirmation

---

### 6. Map Centering Strategy

**Unknown**: How to center map on tracklog when user taps list item?

**Research Findings**:

**Decision**: Use existing LatLngBounds from Track model + flutter_map fitBounds method

**Rationale**:
- **Already Implemented**: Track model already has bounds calculation (LatLngBounds.fromPoints)
- **Existing Pattern**: map_screen.dart already uses fitBounds for auto-zoom after track import
- **No New Dependencies**: flutter_map's MapController.fitBounds() handles all centering logic
- **Smooth Animation**: flutter_map provides animated transition to bounds (can control animation duration)
- **Handles Edge Cases**: fitBounds automatically handles:
  - Single point tracks (reasonable zoom level)
  - Large geographic spans (fits entire track in view)
  - Invalid bounds (graceful degradation)

**Implementation Pattern**:
```dart
// In map_screen.dart
void centerOnTracklog(String tracklogId) {
  final track = _tracks.firstWhere((t) => t.id == tracklogId);
  _mapViewKey.currentState?.fitBounds(track.bounds);
}

// When returning from tracklog list:
Navigator.pop(context, selectedTracklogId).then((id) {
  if (id != null) centerOnTracklog(id);
});
```

**Alternatives Considered**:
- **Manual center calculation**: Rejected - Bounds already calculated, no need to recalculate
- **Custom animation**: Rejected - flutter_map's default animation is smooth and sufficient
- **Zoom to fixed level**: Rejected - fitBounds better handles varying track sizes

---

## Technology Stack Summary

**New Dependencies**:
```yaml
dependencies:
  shared_preferences: ^2.2.0  # Tracklog metadata persistence
  flutter_colorpicker: ^1.0.3  # Color picker dialog
```

**Existing Dependencies** (no changes needed):
- flutter_map: ^6.1.0 (map display, fitBounds)
- file_picker: ^6.1.0 (track file import)
- gpx/xml/archive: Parsing tracklogs
- path_provider: ^2.1.0 (file system access)

**No Additional Dependencies**:
- State management: StatefulWidget sufficient
- JSON serialization: dart:convert (built-in)
- Dialogs/UI: Flutter SDK widgets
- File I/O: dart:io (built-in)

---

## Implementation Approach

### Phase Breakdown

**Phase 0 (Research)**: ✅ Complete - All decisions made, no NEEDS CLARIFICATION items remain

**Phase 1 (Design)**:
1. Define TracklogMetadata model (id, name, color, isVisible, filePath, bounds, timestamps)
2. Define TracklogStorageService contract (CRUD operations)
3. Define dialog helper functions (name input, color picker, confirmation)
4. Update Track model with isVisible field
5. Design TracklogListScreen layout

**Phase 2 (Implementation)**: Follows tasks.md (generated by /speckit.tasks)

---

## Risk Mitigation

### Identified Risks

1. **shared_preferences size limits**: Android limit ~1MB
   - **Mitigation**: Store only metadata (~1KB per tracklog), support 500+ tracklogs safely
   - **Monitoring**: If user reports issues, add storage size check

2. **File system consistency**: Metadata/file sync could break
   - **Mitigation**: Validate file existence on load, cleanup orphaned files
   - **Recovery**: If file missing, show tracklog in list but disable map view (with error message)

3. **Memory usage with many tracklogs**: 20+ tracks with 5000 points each
   - **Mitigation**: Already handled by existing lazy loading (tracks load only when visible)
   - **Testing**: Test with 20 tracklogs to verify smooth scrolling and map rendering

### Non-Risks

- **Migration from current implementation**: MVP has no persistence, so no migration needed
- **Platform differences**: shared_preferences handles iOS/Android differences automatically
- **Offline functionality**: All persistence is local, no network dependencies

---

## Conclusion

All research complete. No NEEDS CLARIFICATION items remain. Technology choices leverage existing project patterns and official Flutter packages. Design follows Flutter/Material Design conventions. Ready to proceed to Phase 1 (Design).
