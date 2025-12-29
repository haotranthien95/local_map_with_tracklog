# UI Contract: Dialog Helpers

**Purpose**: Reusable dialog functions for user input and confirmation in tracklog management.

**Implementation Path**: `lib/widgets/tracklog_dialogs.dart` or inline in relevant screens

---

## showNameDialog

### Purpose

Display a modal dialog for entering/editing tracklog name with validation.

### Signature

```dart
/// Show dialog to input tracklog name
/// 
/// Parameters:
///   - context: BuildContext for dialog presentation
///   - initialValue: Optional existing name for rename operation
///   - title: Optional custom title (defaults based on initialValue)
/// 
/// Returns:
///   - String: User-entered name (trimmed, validated)
///   - null: User cancelled or closed dialog
/// 
/// Validation:
///   - Non-empty after trimming
///   - At least one non-whitespace character
///   - Max length 100 characters (enforced by TextField)
Future<String?> showNameDialog(
  BuildContext context, {
  String? initialValue,
  String? title,
});
```

### Behavior

**UI Structure**:
- AlertDialog with title, text field, Cancel/OK buttons
- Text field auto-focused for immediate typing
- OK button enables only when valid name entered

**Validation**:
- Real-time: OK button disabled if field empty or whitespace-only
- On submit: Trim whitespace, check non-empty
- Invalid input: Keep dialog open, show validation hint

**User Actions**:
- Cancel button: Return null, no changes
- OK button: Return trimmed name string
- Outside tap: Same as Cancel (dismissible dialog)
- Back button: Same as Cancel

### Implementation Example

```dart
Future<String?> showNameDialog(
  BuildContext context, {
  String? initialValue,
  String? title,
}) async {
  final controller = TextEditingController(text: initialValue ?? '');
  final formKey = GlobalKey<FormState>();

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title ?? (initialValue == null ? 'Name Tracklog' : 'Rename Tracklog')),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter tracklog name',
          ),
          autofocus: true,
          maxLength: 100,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Name cannot be empty';
            }
            return null;
          },
          onFieldSubmitted: (_) {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context, controller.text.trim());
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context, controller.text.trim());
            }
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

### Usage Scenarios

**Add New Tracklog**:
```dart
final name = await showNameDialog(context);
if (name != null) {
  // User entered name, proceed with import
  await importTrackWithName(file, name);
}
// User cancelled, don't import
```

**Rename Existing Tracklog**:
```dart
final newName = await showNameDialog(
  context,
  initialValue: currentTracklog.name,
  title: 'Rename Tracklog',
);
if (newName != null && newName != currentTracklog.name) {
  // Name changed, update
  await updateTracklogName(tracklogId, newName);
}
```

---

## showColorPickerDialog

### Purpose

Display a modal dialog for selecting tracklog display color with preview.

### Signature

```dart
/// Show dialog to select tracklog color
/// 
/// Parameters:
///   - context: BuildContext for dialog presentation
///   - currentColor: Current tracklog color (for preview)
/// 
/// Returns:
///   - Color: User-selected color
///   - null: User cancelled without selecting
/// 
/// Behavior:
///   - Shows color picker widget (block/material/sliding picker)
///   - Live preview as user selects
///   - Default picker: BlockPicker (simple, fast selection)
Future<Color?> showColorPickerDialog(
  BuildContext context,
  Color currentColor,
);
```

### Behavior

**UI Structure**:
- AlertDialog with color picker widget
- Title: "Select Color"
- Color picker: BlockPicker with predefined palette
- Cancel/OK buttons

**Color Selection**:
- Start with currentColor selected
- User taps color → selection updates
- Live preview in picker (selected color highlighted)

**User Actions**:
- Cancel: Return null, no change
- OK: Return selected color
- Outside tap: Same as Cancel

### Implementation Example

```dart
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

Future<Color?> showColorPickerDialog(
  BuildContext context,
  Color currentColor,
) async {
  Color selectedColor = currentColor;

  return showDialog<Color>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Color'),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: currentColor,
          onColorChanged: (color) => selectedColor = color,
          availableColors: const [
            Colors.red,
            Colors.pink,
            Colors.purple,
            Colors.deepPurple,
            Colors.indigo,
            Colors.blue,
            Colors.lightBlue,
            Colors.cyan,
            Colors.teal,
            Colors.green,
            Colors.lightGreen,
            Colors.lime,
            Colors.yellow,
            Colors.amber,
            Colors.orange,
            Colors.deepOrange,
            Colors.brown,
            Colors.grey,
          ],
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

### Usage Scenario

```dart
final newColor = await showColorPickerDialog(context, tracklog.color);
if (newColor != null && newColor != tracklog.color) {
  // Color changed, update tracklog
  await updateTracklogColor(tracklogId, newColor);
  // Refresh map to show new color
}
```

---

## showDeleteConfirmation

### Purpose

Display a confirmation dialog before permanently deleting a tracklog.

### Signature

```dart
/// Show confirmation dialog for tracklog deletion
/// 
/// Parameters:
///   - context: BuildContext for dialog presentation
///   - tracklogName: Name of tracklog to delete (shown in message)
/// 
/// Returns:
///   - true: User confirmed deletion
///   - false: User cancelled or dismissed dialog
/// 
/// Behavior:
///   - Clear warning that action is permanent
///   - Delete button styled as destructive (red color)
///   - No default action (user must explicitly choose)
Future<bool> showDeleteConfirmation(
  BuildContext context,
  String tracklogName,
);
```

### Behavior

**UI Structure**:
- AlertDialog with warning title
- Content: Clear message with tracklog name
- Cancel button: Standard style, left position
- Delete/Remove button: Red color (destructive), right position

**Warning Message**:
- Include tracklog name for clarity
- State action is permanent and cannot be undone
- Use "Remove" or "Delete" (consistent with UI)

**User Actions**:
- Cancel: Return false
- Delete/Remove: Return true
- Outside tap: Same as Cancel (return false)
- Back button: Same as Cancel

### Implementation Example

```dart
Future<bool> showDeleteConfirmation(
  BuildContext context,
  String tracklogName,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove Tracklog'),
      content: Text(
        'Are you sure you want to remove "$tracklogName"? '
        'This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  
  return result ?? false; // Treat null (dismissed) as false
}
```

### Usage Scenario

```dart
// User taps "Remove" in popup menu
final confirmed = await showDeleteConfirmation(context, tracklog.name);
if (confirmed) {
  // User confirmed, proceed with deletion
  await deleteTracklog(tracklogId);
  // Refresh UI
} else {
  // User cancelled, no action
}
```

---

## Design Principles

### Consistency

- All dialogs use AlertDialog for consistency
- Button order: Cancel (left), Primary action (right)
- Button labels: Clear action verbs (OK, Cancel, Remove)
- Destructive actions: Red color warning

### Accessibility

- Auto-focus on text input for keyboard users
- Clear button labels for screen readers
- Sufficient button touch targets (Material default)
- High contrast for destructive actions

### User Experience

- Dismissible by tapping outside (standard behavior)
- Back button support (Android)
- Immediate feedback (no loading states needed for dialogs)
- Validation hints for text input

### Error Handling

- Text validation prevents invalid input
- Null returns indicate cancellation (not errors)
- Caller handles null appropriately
- No exceptions thrown from dialog functions

---

## Testing Considerations

### Widget Tests

1. **Name Dialog**:
   - Renders with correct title
   - TextField auto-focused
   - OK button disabled when empty
   - Returns trimmed string on OK
   - Returns null on Cancel
   - Validates max length (100 chars)

2. **Color Picker**:
   - Renders with current color selected
   - Color selection updates preview
   - Returns selected color on OK
   - Returns null on Cancel

3. **Delete Confirmation**:
   - Shows tracklog name in message
   - Delete button is red (destructive)
   - Returns true on Delete
   - Returns false on Cancel
   - Returns false on dismiss

### Integration Tests

1. **Add Tracklog Flow**:
   - Import file → Name dialog appears → Enter name → Track added

2. **Rename Flow**:
   - Tap rename → Dialog with current name → Change name → Updated in list

3. **Color Change Flow**:
   - Tap change color → Picker shows → Select color → Map updates

4. **Delete Flow**:
   - Tap remove → Confirmation shows → Confirm → Track removed

---

## Dependencies

**Required Packages**:
- Flutter SDK (AlertDialog, TextFormField, etc.)
- `flutter_colorpicker: ^1.0.3` - For color picker widget

**No Additional Dependencies**: Dialogs use standard Flutter widgets

---

## Platform Considerations

### iOS vs Android

- AlertDialog adapts to platform (Material on Android, can use CupertinoAlertDialog on iOS)
- Consider platform-specific dialogs if needed:
  ```dart
  if (Platform.isIOS) {
    return showCupertinoDialog(...);
  } else {
    return showDialog(...);
  }
  ```

### Keyboard Behavior

- TextField auto-focus triggers keyboard
- Keyboard dismisses on dialog close
- Submit on Enter key (onFieldSubmitted)

### Screen Sizes

- SingleChildScrollView for color picker (handles small screens)
- AlertDialog automatically handles different screen sizes
- No special handling needed for tablets vs phones

---

## Future Enhancements

**Potential Additions** (not in current scope):
- Name suggestions based on filename
- Recently used colors palette
- Bulk operations (select multiple, delete all)
- Import date range selection

**Not Recommended**:
- Complex validation (e.g., unique names) - clarification session specified allow duplicates
- Advanced color picker modes - BlockPicker sufficient for MVP
- Undo/redo - Snackbar undo rejected per clarification session
