# Quickstart: Tracklog Management System

**Feature**: Tracklog Management with Persistent Storage  
**Branch**: `001-tracklog-management`  
**Date**: December 29, 2025

---

## Overview

This guide provides step-by-step instructions for implementing tracklog management functionality. The feature adds persistent storage, name dialog prompt, tracklog list UI, and management operations (show/hide, remove, rename, change color).

---

## Prerequisites

### Required Tools

- Flutter SDK 3.5.4+ installed
- Dart 3.5.4+
- iOS/Android development environment set up
- Git for version control

### Existing Project State

- Project already has track import functionality (FilePickerService, TrackParserService)
- MapScreen displays tracks in memory
- Track model defined with basic fields

### Verify Current Setup

```bash
# Check Flutter version
flutter --version

# Verify dependencies
flutter pub get

# Run existing app to confirm baseline
flutter run
```

---

## Project Setup

### 1. Add Dependencies

Update `pubspec.yaml` with new required packages:

```yaml
dependencies:
  # ... existing dependencies ...
  
  # Tracklog persistence (NEW)
  shared_preferences: ^2.2.0
  
  # Color picker for tracklog customization (NEW)
  flutter_colorpicker: ^1.0.3
```

Install new packages:

```bash
flutter pub get
```

### 2. Verify File Structure

Ensure directories exist:

```bash
lib/
├── models/          # ✓ Should exist
├── services/        # ✓ Should exist
├── screens/         # ✓ Should exist
└── widgets/         # ✓ Should exist (or create)
```

Create widgets directory if missing:

```bash
mkdir -p lib/widgets
```

---

## Development Workflow

Implementation follows prioritized user stories. Each priority (P1-P4) delivers independent value.

---

### Priority 1: Add Named Tracklog

**Objective**: Show dialog to enter tracklog name when importing a file.

**User Value**: Users can distinguish between multiple tracklogs with meaningful names.

#### Implementation Steps

**1. Add isVisible field to Track model**

File: `lib/models/track.dart`

```dart
class Track {
  final String id;
  final String name;
  final List<TrackPoint> coordinates;
  final String importedFrom;
  final TrackFormat format;
  final DateTime importedAt;
  final LatLngBounds bounds;
  final Color color;
  final bool isVisible;  // NEW FIELD
  final Map<String, dynamic> metadata;

  Track({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.importedFrom,
    required this.format,
    required this.importedAt,
    required this.color,
    this.isVisible = true,  // NEW FIELD with default
    Map<String, dynamic>? metadata,
  }) : bounds = LatLngBounds.fromPoints(coordinates),
       metadata = metadata ?? {};
}
```

**2. Create name dialog function**

File: `lib/widgets/tracklog_dialogs.dart` (NEW)

```dart
import 'package:flutter/material.dart';

/// Show dialog to input/edit tracklog name
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

**3. Update MapScreen import flow**

File: `lib/screens/map_screen.dart`

Modify the `_importTrack()` method:

```dart
import '../widgets/tracklog_dialogs.dart';  // ADD import

Future<void> _importTrack() async {
  try {
    // Pick a track file (existing code)
    final file = await _filePickerService.pickTrackFile([...]);
    if (file == null) return;

    // NEW: Show name dialog before parsing
    final name = await showNameDialog(context);
    if (name == null) {
      // User cancelled, don't import
      return;
    }

    // Show loading indicator (existing)
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Importing track...')),
    );

    // Parse the track file (existing)
    final track = await _trackParserService.parseTrackFile(file);

    // MODIFY: Create new track with user-entered name
    final namedTrack = Track(
      id: track.id,
      name: name,  // Use dialog name instead of parsed name
      coordinates: track.coordinates,
      importedFrom: track.importedFrom,
      format: track.format,
      importedAt: track.importedAt,
      color: const Color(0xFF2196F3),  // Default blue
      isVisible: true,  // NEW field
      metadata: track.metadata,
    );

    // Add to list and display (existing code continues)
    setState(() {
      _tracks.add(namedTrack);
    });

    _mapViewKey.currentState?.fitBounds(namedTrack.bounds);

    // Success message with custom name
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Track "$name" imported successfully'),
        // ... rest of snackbar code
      ),
    );
  } catch (e) {
    // Error handling (existing)
  }
}
```

#### Testing P1

1. Run app: `flutter run`
2. Tap "Import Track" button
3. Select a track file
4. **Verify**: Name dialog appears
5. Enter name "Test Track" and tap OK
6. **Verify**: Track appears on map with entered name
7. Import another track with different name
8. **Verify**: Both tracks visible, distinguishable by name
9. Cancel name dialog
10. **Verify**: Track not imported

**Success Criteria**: Can import tracklogs with custom names, names shown in success message.

---

### Priority 2: Persistent Tracklog Storage

**Objective**: Tracklogs persist across app restarts.

**User Value**: Users don't lose their work, can rely on app for long-term route planning.

#### Implementation Steps

**1. Create TracklogMetadata model**

File: `lib/models/tracklog_metadata.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'track.dart';

class TracklogMetadata {
  final String id;
  final String name;
  final Color color;
  final bool isVisible;
  final String filePath;
  final DateTime importedAt;
  final String importedFrom;
  final TrackFormat format;
  final double boundsNorth;
  final double boundsSouth;
  final double boundsEast;
  final double boundsWest;

  TracklogMetadata({
    required this.id,
    required this.name,
    required this.color,
    required this.isVisible,
    required this.filePath,
    required this.importedAt,
    required this.importedFrom,
    required this.format,
    required this.boundsNorth,
    required this.boundsSouth,
    required this.boundsEast,
    required this.boundsWest,
  });

  /// Create metadata from Track
  factory TracklogMetadata.fromTrack(Track track) {
    return TracklogMetadata(
      id: track.id,
      name: track.name,
      color: track.color,
      isVisible: track.isVisible,
      filePath: 'tracklogs/${track.id}.json',
      importedAt: track.importedAt,
      importedFrom: track.importedFrom,
      format: track.format,
      boundsNorth: track.bounds.north,
      boundsSouth: track.bounds.south,
      boundsEast: track.bounds.east,
      boundsWest: track.bounds.west,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'isVisible': isVisible,
      'filePath': filePath,
      'importedAt': importedAt.toIso8601String(),
      'importedFrom': importedFrom,
      'format': format.name,
      'boundsNorth': boundsNorth,
      'boundsSouth': boundsSouth,
      'boundsEast': boundsEast,
      'boundsWest': boundsWest,
    };
  }

  /// Deserialize from JSON
  factory TracklogMetadata.fromJson(Map<String, dynamic> json) {
    return TracklogMetadata(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
      isVisible: json['isVisible'],
      filePath: json['filePath'],
      importedAt: DateTime.parse(json['importedAt']),
      importedFrom: json['importedFrom'],
      format: TrackFormat.values.firstWhere((e) => e.name == json['format']),
      boundsNorth: json['boundsNorth'],
      boundsSouth: json['boundsSouth'],
      boundsEast: json['boundsEast'],
      boundsWest: json['boundsWest'],
    );
  }

  /// Get bounds as LatLngBounds
  LatLngBounds get bounds {
    return LatLngBounds(
      north: boundsNorth,
      south: boundsSouth,
      east: boundsEast,
      west: boundsWest,
    );
  }
}
```

**2. Create TracklogStorageService**

File: `lib/services/tracklog_storage_service.dart` (NEW)

```dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track.dart';
import '../models/tracklog_metadata.dart';

/// Service for persistent storage of tracklogs
abstract class TracklogStorageService {
  Future<void> saveTracklog(Track track);
  Future<List<TracklogMetadata>> loadAllMetadata();
  Future<Track> loadTrack(String id);
  Future<void> updateMetadata(TracklogMetadata metadata);
  Future<void> deleteTracklog(String id);
  Future<int> cleanupOrphanedFiles();
}

/// Implementation using shared_preferences + file system
class TracklogStorageServiceImpl implements TracklogStorageService {
  static const String _idsKey = 'tracklog_ids';
  static const String _metadataPrefix = 'tracklog_';

  @override
  Future<void> saveTracklog(Track track) async {
    final prefs = await SharedPreferences.getInstance();
    final metadata = TracklogMetadata.fromTrack(track);

    // Save metadata to shared_preferences
    await prefs.setString(
      '$_metadataPrefix${track.id}',
      jsonEncode(metadata.toJson()),
    );

    // Add to IDs list
    final ids = prefs.getStringList(_idsKey) ?? [];
    if (!ids.contains(track.id)) {
      ids.insert(0, track.id); // Newest first
      await prefs.setStringList(_idsKey, ids);
    }

    // Save coordinates to file
    final dir = await getApplicationDocumentsDirectory();
    final tracklogsDir = Directory('${dir.path}/tracklogs');
    if (!await tracklogsDir.exists()) {
      await tracklogsDir.create(recursive: true);
    }

    final file = File('${tracklogsDir.path}/${track.id}.json');
    final trackJson = _trackToJson(track);
    await file.writeAsString(jsonEncode(trackJson));
  }

  @override
  Future<List<TracklogMetadata>> loadAllMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_idsKey) ?? [];

    final metadataList = <TracklogMetadata>[];
    for (final id in ids) {
      final jsonStr = prefs.getString('$_metadataPrefix$id');
      if (jsonStr != null) {
        try {
          final metadata = TracklogMetadata.fromJson(jsonDecode(jsonStr));
          
          // Validate file exists
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/${metadata.filePath}');
          if (await file.exists()) {
            metadataList.add(metadata);
          }
        } catch (e) {
          // Skip corrupted metadata
          print('Error loading metadata for $id: $e');
        }
      }
    }

    return metadataList;
  }

  @override
  Future<Track> loadTrack(String id) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/tracklogs/$id.json');
    
    if (!await file.exists()) {
      throw Exception('Track file not found: $id');
    }

    final jsonStr = await file.readAsString();
    final json = jsonDecode(jsonStr);
    return _trackFromJson(json);
  }

  @override
  Future<void> updateMetadata(TracklogMetadata metadata) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_metadataPrefix${metadata.id}',
      jsonEncode(metadata.toJson()),
    );
  }

  @override
  Future<void> deleteTracklog(String id) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove metadata
    await prefs.remove('$_metadataPrefix$id');

    // Remove from IDs list
    final ids = prefs.getStringList(_idsKey) ?? [];
    ids.remove(id);
    await prefs.setStringList(_idsKey, ids);

    // Delete file
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/tracklogs/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<int> cleanupOrphanedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_idsKey) ?? [];

    final dir = await getApplicationDocumentsDirectory();
    final tracklogsDir = Directory('${dir.path}/tracklogs');
    
    if (!await tracklogsDir.exists()) {
      return 0;
    }

    int deleted = 0;
    await for (final entity in tracklogsDir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        final filename = entity.path.split('/').last;
        final id = filename.replaceAll('.json', '');
        
        if (!ids.contains(id)) {
          await entity.delete();
          deleted++;
        }
      }
    }

    return deleted;
  }

  // Helper: Track to JSON
  Map<String, dynamic> _trackToJson(Track track) {
    return {
      'id': track.id,
      'name': track.name,
      'coordinates': track.coordinates.map((p) => {
        'latitude': p.latitude,
        'longitude': p.longitude,
        'elevation': p.elevation,
        'timestamp': p.timestamp?.toIso8601String(),
        'accuracy': p.accuracy,
      }).toList(),
      'importedFrom': track.importedFrom,
      'format': track.format.name,
      'importedAt': track.importedAt.toIso8601String(),
      'color': track.color.value,
      'isVisible': track.isVisible,
      'metadata': track.metadata,
    };
  }

  // Helper: JSON to Track
  Track _trackFromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      name: json['name'],
      coordinates: (json['coordinates'] as List).map((p) => TrackPoint(
        latitude: p['latitude'],
        longitude: p['longitude'],
        elevation: p['elevation'],
        timestamp: p['timestamp'] != null ? DateTime.parse(p['timestamp']) : null,
        accuracy: p['accuracy'],
      )).toList(),
      importedFrom: json['importedFrom'],
      format: TrackFormat.values.firstWhere((e) => e.name == json['format']),
      importedAt: DateTime.parse(json['importedAt']),
      color: Color(json['color']),
      isVisible: json['isVisible'] ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}
```

**3. Update MapScreen to use storage**

File: `lib/screens/map_screen.dart`

Add storage service and metadata tracking:

```dart
import '../services/tracklog_storage_service.dart';
import '../models/tracklog_metadata.dart';

class _MapScreenState extends State<MapScreen> {
  // ... existing fields ...
  
  final TracklogStorageService _storageService = TracklogStorageServiceImpl();
  List<TracklogMetadata> _tracklogMetadata = [];

  @override
  void initState() {
    super.initState();
    _loadPersistedTracklogs();  // NEW
    _checkStorageWarning();
    // ... rest of initState
  }

  /// Load tracklogs from persistent storage
  Future<void> _loadPersistedTracklogs() async {
    try {
      // Load metadata
      _tracklogMetadata = await _storageService.loadAllMetadata();

      // Load visible tracks
      for (final metadata in _tracklogMetadata.where((m) => m.isVisible)) {
        final track = await _storageService.loadTrack(metadata.id);
        setState(() {
          _tracks.add(track);
        });
      }
    } catch (e) {
      print('Error loading tracklogs: $e');
    }
  }

  /// Update import method to save tracklog
  Future<void> _importTrack() async {
    try {
      final file = await _filePickerService.pickTrackFile([...]);
      if (file == null) return;

      final name = await showNameDialog(context);
      if (name == null) return;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importing track...')),
      );

      final track = await _trackParserService.parseTrackFile(file);

      final namedTrack = Track(
        id: track.id,
        name: name,
        coordinates: track.coordinates,
        importedFrom: track.importedFrom,
        format: track.format,
        importedAt: track.importedAt,
        color: const Color(0xFF2196F3),
        isVisible: true,
        metadata: track.metadata,
      );

      // NEW: Save to persistent storage
      await _storageService.saveTracklog(namedTrack);

      // Add to lists
      setState(() {
        _tracks.add(namedTrack);
        _tracklogMetadata.add(TracklogMetadata.fromTrack(namedTrack));
      });

      _mapViewKey.currentState?.fitBounds(namedTrack.bounds);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Track "$name" imported successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import track: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

#### Testing P2

1. Run app: `flutter run`
2. Import 2-3 tracklogs with different names
3. **Verify**: All tracklogs visible on map
4. Close app completely (hot restart won't test persistence)
5. Reopen app: `flutter run`
6. **Verify**: All previously imported tracklogs appear on map
7. Check with device file explorer (optional): Verify files in `tracklogs/` directory

**Success Criteria**: 100% of imported tracklogs persist across app restarts.

---

### Priority 3: View and Navigate Tracklog List

**Objective**: Access list of tracklogs from app bar, tap to center map.

**User Value**: Quick navigation to specific tracklogs, overview of all added routes.

#### Implementation Steps

**1. Create TracklogListScreen** (basic version)

File: `lib/screens/tracklog_list_screen.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import '../models/tracklog_metadata.dart';

class TracklogListScreen extends StatefulWidget {
  final List<TracklogMetadata> tracklogs;

  const TracklogListScreen({
    Key? key,
    required this.tracklogs,
  }) : super(key: key);

  @override
  State<TracklogListScreen> createState() => _TracklogListScreenState();
}

class _TracklogListScreenState extends State<TracklogListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracklogs'),
      ),
      body: widget.tracklogs.isEmpty
          ? _buildEmptyState()
          : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tracklogs added yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: widget.tracklogs.length,
      itemBuilder: (context, index) {
        final tracklog = widget.tracklogs[index];
        return ListTile(
          leading: Icon(
            tracklog.isVisible ? Icons.visibility : Icons.visibility_off,
            color: tracklog.isVisible ? Colors.blue : Colors.grey,
          ),
          title: Text(tracklog.name),
          subtitle: Text('Imported: ${_formatDate(tracklog.importedAt)}'),
          onTap: () => Navigator.pop(context, tracklog.id),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

**2. Add list button to MapScreen app bar**

File: `lib/screens/map_screen.dart`

Modify the AppBar actions:

```dart
import 'tracklog_list_screen.dart';  // ADD import

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Map'),
      actions: [
        // NEW: Tracklog list button
        IconButton(
          icon: const Icon(Icons.list),
          onPressed: _openTracklogList,
        ),
        // ... existing buttons (map style, storage info)
      ],
    ),
    // ... rest of build method
  );
}

/// Open tracklog list screen
Future<void> _openTracklogList() async {
  final selectedId = await Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (context) => TracklogListScreen(
        tracklogs: _tracklogMetadata,
      ),
    ),
  );

  // User tapped a tracklog - center map on it
  if (selectedId != null && mounted) {
    final track = _tracks.firstWhere(
      (t) => t.id == selectedId,
      orElse: () async {
        // Track not loaded yet, load it
        final track = await _storageService.loadTrack(selectedId);
        setState(() {
          _tracks.add(track);
        });
        return track;
      }(),
    );

    // Center map on tracklog bounds
    _mapViewKey.currentState?.fitBounds(track.bounds);
  }
}
```

#### Testing P3

1. Run app with persisted tracklogs
2. Tap list button in app bar (Icons.list)
3. **Verify**: Full screen list of tracklogs appears
4. **Verify**: Each item shows name, import date
5. **Verify**: Visibility icon (blue eye) shows for visible tracks
6. Tap a tracklog item
7. **Verify**: Returns to map, map centers on selected tracklog
8. Test with empty state: Delete all tracklogs
9. **Verify**: "No tracklogs added yet" message displays

**Success Criteria**: Can navigate to any tracklog in under 5 seconds.

---

### Priority 4: Manage Individual Tracklogs

**Objective**: Add show/hide, remove, rename, change color operations via popup menu.

**User Value**: Full control over tracklog presentation and organization.

#### Implementation Steps

**1. Add remaining dialog functions**

File: `lib/widgets/tracklog_dialogs.dart`

Add color picker and confirmation dialogs:

```dart
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Show dialog to select tracklog color
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

/// Show confirmation dialog for tracklog deletion
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
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  
  return result ?? false;
}
```

**2. Update TracklogListScreen with popup menu**

File: `lib/screens/tracklog_list_screen.dart`

Add callbacks and popup menu:

```dart
import '../widgets/tracklog_dialogs.dart';

class TracklogListScreen extends StatefulWidget {
  final List<TracklogMetadata> tracklogs;
  final Function(TracklogMetadata) onUpdateMetadata;
  final Function(String) onDeleteTracklog;

  const TracklogListScreen({
    Key? key,
    required this.tracklogs,
    required this.onUpdateMetadata,
    required this.onDeleteTracklog,
  }) : super(key: key);
  
  // ... rest of class
}

class _TracklogListScreenState extends State<TracklogListScreen> {
  late List<TracklogMetadata> _tracklogs;

  @override
  void initState() {
    super.initState();
    _tracklogs = List.from(widget.tracklogs);
  }

  // ... build methods ...

  Widget _buildList() {
    return ListView.builder(
      itemCount: _tracklogs.length,
      itemBuilder: (context, index) {
        final tracklog = _tracklogs[index];
        return ListTile(
          leading: Icon(
            tracklog.isVisible ? Icons.visibility : Icons.visibility_off,
            color: tracklog.isVisible ? tracklog.color : Colors.grey,
          ),
          title: Text(tracklog.name),
          subtitle: Text('Imported: ${_formatDate(tracklog.importedAt)}'),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_visibility',
                child: Row(
                  children: [
                    Icon(tracklog.isVisible ? Icons.visibility_off : Icons.visibility),
                    const SizedBox(width: 8),
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
          ),
          onTap: () => Navigator.pop(context, tracklog.id),
        );
      },
    );
  }

  Future<void> _handleMenuAction(String action, TracklogMetadata tracklog) async {
    switch (action) {
      case 'toggle_visibility':
        await _toggleVisibility(tracklog);
        break;
      case 'rename':
        await _renameTracklog(tracklog);
        break;
      case 'change_color':
        await _changeColor(tracklog);
        break;
      case 'remove':
        await _removeTracklog(tracklog);
        break;
    }
  }

  Future<void> _toggleVisibility(TracklogMetadata tracklog) async {
    final updated = TracklogMetadata(
      id: tracklog.id,
      name: tracklog.name,
      color: tracklog.color,
      isVisible: !tracklog.isVisible,
      filePath: tracklog.filePath,
      importedAt: tracklog.importedAt,
      importedFrom: tracklog.importedFrom,
      format: tracklog.format,
      boundsNorth: tracklog.boundsNorth,
      boundsSouth: tracklog.boundsSouth,
      boundsEast: tracklog.boundsEast,
      boundsWest: tracklog.boundsWest,
    );

    await widget.onUpdateMetadata(updated);

    setState(() {
      final index = _tracklogs.indexWhere((t) => t.id == tracklog.id);
      _tracklogs[index] = updated;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tracklog ${updated.isVisible ? "shown" : "hidden"}'),
        ),
      );
    }
  }

  Future<void> _renameTracklog(TracklogMetadata tracklog) async {
    final newName = await showNameDialog(
      context,
      initialValue: tracklog.name,
      title: 'Rename Tracklog',
    );

    if (newName == null || newName == tracklog.name) return;

    final updated = TracklogMetadata(
      id: tracklog.id,
      name: newName,
      color: tracklog.color,
      isVisible: tracklog.isVisible,
      filePath: tracklog.filePath,
      importedAt: tracklog.importedAt,
      importedFrom: tracklog.importedFrom,
      format: tracklog.format,
      boundsNorth: tracklog.boundsNorth,
      boundsSouth: tracklog.boundsSouth,
      boundsEast: tracklog.boundsEast,
      boundsWest: tracklog.boundsWest,
    );

    await widget.onUpdateMetadata(updated);

    setState(() {
      final index = _tracklogs.indexWhere((t) => t.id == tracklog.id);
      _tracklogs[index] = updated;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tracklog renamed')),
      );
    }
  }

  Future<void> _changeColor(TracklogMetadata tracklog) async {
    final newColor = await showColorPickerDialog(context, tracklog.color);

    if (newColor == null || newColor == tracklog.color) return;

    final updated = TracklogMetadata(
      id: tracklog.id,
      name: tracklog.name,
      color: newColor,
      isVisible: tracklog.isVisible,
      filePath: tracklog.filePath,
      importedAt: tracklog.importedAt,
      importedFrom: tracklog.importedFrom,
      format: tracklog.format,
      boundsNorth: tracklog.boundsNorth,
      boundsSouth: tracklog.boundsSouth,
      boundsEast: tracklog.boundsEast,
      boundsWest: tracklog.boundsWest,
    );

    await widget.onUpdateMetadata(updated);

    setState(() {
      final index = _tracklogs.indexWhere((t) => t.id == tracklog.id);
      _tracklogs[index] = updated;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Color updated')),
      );
    }
  }

  Future<void> _removeTracklog(TracklogMetadata tracklog) async {
    final confirmed = await showDeleteConfirmation(context, tracklog.name);

    if (!confirmed) return;

    await widget.onDeleteTracklog(tracklog.id);

    setState(() {
      _tracklogs.removeWhere((t) => t.id == tracklog.id);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tracklog removed')),
      );
    }
  }
}
```

**3. Update MapScreen to handle callbacks**

File: `lib/screens/map_screen.dart`

Update `_openTracklogList` method:

```dart
Future<void> _openTracklogList() async {
  final selectedId = await Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (context) => TracklogListScreen(
        tracklogs: _tracklogMetadata,
        onUpdateMetadata: (metadata) async {
          // Update storage
          await _storageService.updateMetadata(metadata);

          // Update local list
          setState(() {
            final index = _tracklogMetadata.indexWhere((m) => m.id == metadata.id);
            if (index != -1) {
              _tracklogMetadata[index] = metadata;
            }

            // Update track visibility
            if (metadata.isVisible) {
              // Load track if not already loaded
              if (!_tracks.any((t) => t.id == metadata.id)) {
                _storageService.loadTrack(metadata.id).then((track) {
                  setState(() {
                    _tracks.add(track);
                  });
                });
              } else {
                // Update existing track color if changed
                final index = _tracks.indexWhere((t) => t.id == metadata.id);
                if (index != -1) {
                  final track = _tracks[index];
                  _tracks[index] = Track(
                    id: track.id,
                    name: metadata.name,
                    coordinates: track.coordinates,
                    importedFrom: track.importedFrom,
                    format: track.format,
                    importedAt: track.importedAt,
                    color: metadata.color,
                    isVisible: metadata.isVisible,
                    metadata: track.metadata,
                  );
                }
              }
            } else {
              // Hide track
              _tracks.removeWhere((t) => t.id == metadata.id);
            }
          });
        },
        onDeleteTracklog: (id) async {
          // Delete from storage
          await _storageService.deleteTracklog(id);

          // Update local lists
          setState(() {
            _tracklogMetadata.removeWhere((m) => m.id == id);
            _tracks.removeWhere((t) => t.id == id);
          });
        },
      ),
    ),
  );

  // Handle tracklog selection (center map)
  if (selectedId != null && mounted) {
    Track track;
    
    if (_tracks.any((t) => t.id == selectedId)) {
      track = _tracks.firstWhere((t) => t.id == selectedId);
    } else {
      // Load track if not in memory
      track = await _storageService.loadTrack(selectedId);
      setState(() {
        _tracks.add(track);
      });
    }

    _mapViewKey.currentState?.fitBounds(track.bounds);
  }
}
```

#### Testing P4

1. Run app with multiple tracklogs
2. Open tracklog list
3. **Test Toggle Visibility**:
   - Tap menu → Hide
   - **Verify**: Icon changes to grey visibility_off
   - Return to map: **Verify**: Tracklog removed from map
   - Back to list → menu → Show
   - **Verify**: Icon back to blue visibility
   - Return to map: **Verify**: Tracklog reappears

4. **Test Rename**:
   - Tap menu → Rename
   - **Verify**: Dialog with current name
   - Enter new name → OK
   - **Verify**: List updates with new name

5. **Test Change Color**:
   - Tap menu → Change Color
   - **Verify**: Color picker dialog
   - Select red → OK
   - **Verify**: Icon color changes
   - Return to map: **Verify**: Tracklog displays in red

6. **Test Remove**:
   - Tap menu → Remove
   - **Verify**: Confirmation dialog with tracklog name
   - Cancel: **Verify**: No changes
   - Tap menu → Remove → Confirm
   - **Verify**: Tracklog removed from list
   - Return to map: **Verify**: Tracklog removed from map
   - Restart app: **Verify**: Tracklog stays deleted

**Success Criteria**: All management operations complete within 2 seconds with visible confirmation.

---

## Verification

### Complete Feature Test

1. **Fresh Start**: Uninstall and reinstall app
2. **Import 3 tracklogs**: Name them "Track A", "Track B", "Track C"
3. **Restart app**: Verify all 3 appear
4. **Open list**: Verify all 3 listed with names
5. **Hide "Track B"**: Verify disappears from map
6. **Rename "Track A"** to "Morning Run": Verify updates everywhere
7. **Change "Track C" color** to green: Verify map updates
8. **Tap "Morning Run"**: Verify map centers
9. **Remove "Track B"**: Verify deleted everywhere
10. **Restart app**: Verify "Morning Run" (renamed) and "Track C" (green) persist
11. **Verify "Track B" gone**: Confirm deletion persisted

---

## Troubleshooting

### Common Issues

**Issue**: Name dialog doesn't show  
**Solution**: Check import in map_screen.dart, verify `showNameDialog` is called

**Issue**: Tracklogs don't persist  
**Solution**: Check `_storageService.saveTracklog()` is called after parse, verify shared_preferences dependency installed

**Issue**: List button not visible  
**Solution**: Check IconButton in MapScreen AppBar actions array

**Issue**: Color picker shows error  
**Solution**: Verify `flutter_colorpicker` package installed, run `flutter pub get`

**Issue**: Map doesn't center on tracklog  
**Solution**: Check `fitBounds` method called with `track.bounds`, verify track loaded

---

## Performance Benchmarks

Target performance (measure on mid-range Android device):

| Operation | Target | How to Measure |
|-----------|--------|----------------|
| Add tracklog | <30s | File pick → name dialog → map display |
| Load tracklogs on start | <2s | App launch → all tracks visible |
| Open tracklog list | <500ms | Button tap → list appears |
| Toggle visibility | <1s | Menu tap → map updates |
| Rename tracklog | <2s | Dialog → enter name → list updates |
| Change color | <2s | Picker → select → map updates |
| Remove tracklog | <2s | Confirm → list updates |
| Scroll list (20 items) | 60fps | Smooth scrolling, no jank |

---

## Next Steps

After implementing P1-P4:

1. **Manual Testing**: Follow verification checklist above
2. **Create Tasks**: Run `/speckit.tasks` to generate detailed task breakdown
3. **Implementation**: Work through tasks systematically
4. **Testing**: Write widget/integration tests as needed
5. **Code Review**: Verify constitution compliance before merge

---

## Related Documentation

- [Spec](./spec.md): Feature requirements and user stories
- [Research](./research.md): Technology decisions and rationale
- [Data Model](./data-model.md): Entity definitions
- [Contracts](./contracts/): Service and UI interface specifications
- [Plan](./plan.md): Implementation plan and constitution check
