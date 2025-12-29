# UI Contract: TracklogListScreen

**Purpose**: Full-screen list view for managing tracklogs with show/hide, remove, rename, and color change operations.

**Implementation Path**: `lib/screens/tracklog_list_screen.dart`

---

## Screen Overview

### Purpose

Provide users with a centralized interface to view all added tracklogs and perform management operations (show/hide, remove, rename, change color). Tapping a tracklog navigates back to map and centers on that tracklog's location.

### Navigation

**Entry**: From MapScreen app bar button (icon: Icons.list or Icons.layers)

**Exit**: 
- Back button returns to MapScreen
- Tap tracklog item returns to MapScreen with selected tracklog ID (for map centering)

---

## Interface Definition

### Constructor

```dart
class TracklogListScreen extends StatefulWidget {
  final List<TracklogMetadata> tracklogs;
  final Function(String id) onTracklogTap;
  final Function(TracklogMetadata) onUpdateMetadata;
  final Function(String id) onDeleteTracklog;

  const TracklogListScreen({
    Key? key,
    required this.tracklogs,
    required this.onTracklogTap,
    required this.onUpdateMetadata,
    required this.onDeleteTracklog,
  }) : super(key: key);
}
```

### Parameters

| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| tracklogs | List<TracklogMetadata> | List of all tracklog metadata | Yes |
| onTracklogTap | Function(String) | Callback when tracklog tapped | Yes |
| onUpdateMetadata | Function(TracklogMetadata) | Callback for metadata updates | Yes |
| onDeleteTracklog | Function(String) | Callback for tracklog deletion | Yes |

### Return Value

**Navigation Result**: 
- `String`: Selected tracklog ID (when user taps tracklog to center map)
- `null`: User pressed back button without selection

---

## UI Structure

### Layout Hierarchy

```
Scaffold
├── AppBar
│   ├── leading: BackButton (auto)
│   ├── title: Text("Tracklogs")
│   └── actions: [Optional future actions]
│
└── body: _buildBody()
    ├── Empty State (if tracklogs.isEmpty)
    │   └── Center > Column
    │       ├── Icon (Icons.map_outlined, size: 64, grey)
    │       ├── SizedBox(height: 16)
    │       └── Text("No tracklogs added yet")
    │
    └── ListView.builder (if tracklogs.isNotEmpty)
        └── TracklogListTile (for each tracklog)
```

### TracklogListTile Structure

```
ListTile
├── leading: Icon
│   └── visible: Icons.visibility (blue)
│   └── hidden: Icons.visibility_off (grey)
│
├── title: Text(tracklog.name)
│   └── style: Theme.textTheme.bodyLarge
│
├── subtitle: Text (optional)
│   └── "Imported: {date}" or "{pointCount} points"
│
├── trailing: PopupMenuButton
│   └── icon: Icons.more_vert
│   └── items: [Show/Hide, Rename, Change Color, Divider, Remove]
│
└── onTap: () => Navigator.pop(context, tracklog.id)
```

### PopupMenuButton Items

```dart
PopupMenuButton<String>(
  icon: const Icon(Icons.more_vert),
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'toggle_visibility',
      child: Row(
        children: [
          Icon(tracklog.isVisible ? Icons.visibility_off : Icons.visibility),
          SizedBox(width: 8),
          Text(tracklog.isVisible ? 'Hide' : 'Show'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'rename',
      child: Row(
        children: [
          Icon(Icons.edit),
          SizedBox(width: 8),
          Text('Rename'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'change_color',
      child: Row(
        children: [
          Icon(Icons.palette),
          SizedBox(width: 8),
          Text('Change Color'),
        ],
      ),
    ),
    const PopupMenuDivider(),
    const PopupMenuItem(
      value: 'remove',
      child: Row(
        children: [
          Icon(Icons.delete, color: Colors.red),
          SizedBox(width: 8),
          Text('Remove', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
  ],
  onSelected: (value) => _handleMenuAction(value, tracklog),
)
```

---

## Behavior Specification

### Initial State

- Load with provided `tracklogs` list
- Sort by `importedAt` descending (newest first)
- Show empty state if list is empty
- Leading icon reflects initial visibility state

### User Interactions

#### 1. Tap Tracklog Item

**Action**: User taps anywhere on ListTile (except trailing menu)

**Behavior**:
1. Call `onTracklogTap(tracklog.id)`
2. Navigate back to map screen: `Navigator.pop(context, tracklog.id)`
3. MapScreen receives ID and centers map on tracklog bounds

**Visual Feedback**: Standard Material ripple effect

#### 2. Toggle Visibility (Show/Hide)

**Action**: User selects "Show" or "Hide" from popup menu

**Behavior**:
1. Update `tracklog.isVisible = !tracklog.isVisible`
2. Call `onUpdateMetadata(updatedTracklog)`
3. Update leading icon immediately (visibility ↔ visibility_off)
4. Show brief SnackBar: "Tracklog {shown/hidden}"

**No Confirmation**: Toggle is non-destructive, immediate feedback

#### 3. Rename

**Action**: User selects "Rename" from popup menu

**Behavior**:
1. Show `showNameDialog(context, initialValue: tracklog.name)`
2. If user enters new name:
   - Update `tracklog.name = newName`
   - Call `onUpdateMetadata(updatedTracklog)`
   - Update title text immediately
   - Show SnackBar: "Tracklog renamed"
3. If user cancels: No changes

#### 4. Change Color

**Action**: User selects "Change Color" from popup menu

**Behavior**:
1. Show `showColorPickerDialog(context, tracklog.color)`
2. If user selects new color:
   - Update `tracklog.color = newColor`
   - Call `onUpdateMetadata(updatedTracklog)`
   - Show SnackBar: "Color updated"
3. If user cancels: No changes

**Note**: Color change visible in list item's leading icon color

#### 5. Remove

**Action**: User selects "Remove" from popup menu

**Behavior**:
1. Show `showDeleteConfirmation(context, tracklog.name)`
2. If user confirms:
   - Call `onDeleteTracklog(tracklog.id)`
   - Remove item from list with animation
   - Show SnackBar: "Tracklog removed" with optional Undo (future enhancement)
3. If user cancels: No changes

**Confirmation Required**: Prevents accidental deletion

### State Management

**Local State** (StatefulWidget):
- `List<TracklogMetadata> _tracklogs` - Copy of input list for mutations
- `_isLoading` - Optional loading indicator during operations

**Updates Propagate**:
- All updates call parent callbacks immediately
- Parent (MapScreen) handles persistence
- UI updates optimistically (assume success)

### Error Handling

**Failed Operation**:
```dart
try {
  await onDeleteTracklog(tracklogId);
  // Success - item already removed from list
} catch (e) {
  // Restore item to list
  // Show error SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to remove tracklog: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

---

## Visual Design

### Color Scheme

- **Visible Icon**: Colors.blue (tracklog color tint optional)
- **Hidden Icon**: Colors.grey[400]
- **Remove Action**: Colors.red (destructive)
- **List Background**: Theme background color
- **Divider**: Standard Material divider

### Typography

- **Title**: Theme.textTheme.bodyLarge (tracklog name)
- **Subtitle**: Theme.textTheme.bodyMedium with grey color
- **Empty State**: Theme.textTheme.titleMedium with grey color

### Spacing

- ListTile: Material default padding (16px horizontal, 8px vertical)
- Empty state icon: 64px size, 16px spacing to text
- Popup menu items: 8px horizontal spacing between icon and text

### Animations

- **List Item Removal**: 
  ```dart
  AnimatedList or ListView with removeItem animation
  Duration: 300ms, Curve: easeInOut
  ```
- **Visibility Toggle**: Icon crossfade (200ms)
- **Standard Material**: Ripple effects, menu slide-in

---

## Performance Considerations

### List Rendering

**Optimization**: Use `ListView.builder` for efficient rendering
- Only renders visible items
- Handles scrolling efficiently
- Supports 50+ tracklogs without lag

**Sorting**: Pre-sort list on build, not on every frame

### Menu Actions

**Debouncing**: Not needed - actions are user-initiated and infrequent

**Optimistic Updates**: Update UI immediately, handle failures async

### Memory

**Metadata Only**: List displays TracklogMetadata (lightweight)
- No coordinate data loaded (thousands of points not needed)
- Each metadata ~1KB, 50 tracklogs = ~50KB
- Negligible memory footprint

---

## Accessibility

### Screen Reader Support

- ListTile title announces tracklog name
- Leading icon has semantic label: "Visible" or "Hidden"
- PopupMenuButton announced as "More options"
- Each menu item announces action clearly

### Touch Targets

- ListTile: Full width, minimum 48px height
- PopupMenuButton: 48x48 touch target
- Menu items: Minimum 48px height

### Keyboard Navigation

- Tab through list items
- Space/Enter to activate item or menu
- Arrow keys to navigate menu

---

## Testing Requirements

### Widget Tests

1. **Rendering**:
   - Empty state displays when list empty
   - List displays all provided tracklogs
   - Each item shows correct name, visibility icon

2. **Interactions**:
   - Tap item calls onTracklogTap with correct ID
   - Menu opens on trailing button tap
   - Each menu action triggers correct callback

3. **State Updates**:
   - Toggle visibility updates icon immediately
   - Rename updates title text
   - Remove removes item from list

### Integration Tests

1. **Full Workflows**:
   - Add tracklog → appears in list → tap to center map
   - Toggle visibility → icon changes → map updates
   - Rename → dialog → confirm → list updates
   - Change color → picker → confirm → color updates
   - Remove → confirm → list updates → tracklog deleted

2. **Error Scenarios**:
   - Failed delete → item restored → error shown
   - Cancel operations → no changes applied

### Performance Tests

1. **Large Lists**: Render 50 tracklogs → verify smooth scrolling
2. **Rapid Actions**: Toggle visibility 10 times rapidly → no lag
3. **Memory**: Load list → no memory leaks

---

## Usage Example

### In MapScreen

```dart
// In MapScreen app bar
IconButton(
  icon: const Icon(Icons.list),
  onPressed: _openTracklogList,
)

Future<void> _openTracklogList() async {
  final selectedId = await Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (context) => TracklogListScreen(
        tracklogs: _tracklogMetadataList,
        onTracklogTap: (id) {
          // Will be handled by Navigator.pop return value
        },
        onUpdateMetadata: (metadata) async {
          await _storageService.updateMetadata(metadata);
          setState(() {
            // Update local list
            final index = _tracklogMetadataList.indexWhere((m) => m.id == metadata.id);
            if (index != -1) {
              _tracklogMetadataList[index] = metadata;
            }
            // Update tracks if visibility changed
            if (metadata.isVisible && !_tracks.any((t) => t.id == metadata.id)) {
              _loadTrack(metadata.id);
            } else if (!metadata.isVisible) {
              _tracks.removeWhere((t) => t.id == metadata.id);
            }
          });
        },
        onDeleteTracklog: (id) async {
          await _storageService.deleteTracklog(id);
          setState(() {
            _tracklogMetadataList.removeWhere((m) => m.id == id);
            _tracks.removeWhere((t) => t.id == id);
          });
        },
      ),
    ),
  );

  // User tapped a tracklog to center on it
  if (selected Id != null) {
    final track = _tracks.firstWhere((t) => t.id == selectedId);
    _mapViewKey.currentState?.fitBounds(track.bounds);
  }
}
```

---

## Dependencies

**Required**:
- Flutter SDK (Scaffold, ListView, ListTile, PopupMenuButton, etc.)
- [dialog_helpers.md](./dialog_helpers.md) - Name and color dialogs
- [tracklog_storage_service.md](./tracklog_storage_service.md) - TracklogMetadata type

**No Additional Packages**: Uses standard Flutter widgets

---

## Future Enhancements

**Potential Additions** (not in current scope):
- Search/filter tracklogs by name
- Sort options (name, date, format)
- Bulk operations (select multiple, show/hide all)
- Tracklog statistics (distance, duration, points)
- Swipe actions (swipe to delete, swipe to hide)
- Export tracklog to file

**Not Planned**:
- Inline editing (dialog pattern is clearer)
- Drag-to-reorder (import date order sufficient)
- Preview map (too complex for list item)
