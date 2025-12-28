# Service Contract: FilePickerService

**Purpose**: Handle file selection from device storage for track import.

**Implementation Path**: `lib/services/file_picker_service.dart`

---

## Interface Definition

```dart
/// Service for picking files from device storage
abstract class FilePickerService {
  /// Pick a track file from device storage
  /// 
  /// Parameters:
  ///   - allowedExtensions: Optional list of file extensions to filter
  ///     (e.g., ['gpx', 'kml', 'geojson'])
  ///     If null, shows all files
  /// 
  /// Returns: FilePickResult with file path and metadata, or null if cancelled
  /// 
  /// Throws: FilePickerException if permission denied or system error
  Future<FilePickResult?> pickTrackFile({List<String>? allowedExtensions});

  /// Pick multiple track files
  /// 
  /// Parameters:
  ///   - allowedExtensions: Optional list of file extensions to filter
  /// 
  /// Returns: List of FilePickResult, empty if cancelled
  /// 
  /// Throws: FilePickerException if permission denied or system error
  Future<List<FilePickResult>> pickMultipleTrackFiles({List<String>? allowedExtensions});
}

/// Result from file picker
class FilePickResult {
  /// Absolute path to selected file
  final String path;
  
  /// Original file name with extension
  final String name;
  
  /// File size in bytes
  final int size;
  
  /// File extension (without dot, e.g., "gpx")
  final String extension;
  
  /// File bytes (only if loaded in memory, usually null for large files)
  final Uint8List? bytes;

  FilePickResult({
    required this.path,
    required this.name,
    required this.size,
    required this.extension,
    this.bytes,
  });
}

/// Exception thrown by file picker
class FilePickerException implements Exception {
  final String message;
  final dynamic cause;

  FilePickerException(this.message, [this.cause]);

  @override
  String toString() => 'FilePickerException: $message${cause != null ? ' ($cause)' : ''}';
}
```

---

## Behavior Requirements

### pickTrackFile
- **Preconditions**: None (handles permissions internally)
- **Postconditions**: Returns file result or null if user cancels
- **Error Handling**: 
  - Throws FilePickerException if permissions denied
  - Throws FilePickerException if file system error
  - Returns null if user cancels (NOT an error)
- **UI**: Opens native file picker dialog (iOS Files app, Android file manager)
- **Filtering**: If allowedExtensions provided, only shows matching files
- **Side Effects**: May request storage permissions on first use (Android)

### pickMultipleTrackFiles
- **Preconditions**: Platform supports multiple file selection
- **Postconditions**: Returns list of files or empty list if cancelled
- **Error Handling**: Same as pickTrackFile
- **UI**: Native multi-select file picker
- **Limitations**: Some Android versions may not support multi-select

---

## Default File Extensions

**P2 (MVP)**: GPX only
```dart
const defaultExtensions = ['gpx'];
```

**P3+**: All supported formats
```dart
const defaultExtensions = [
  'gpx',   // GPS Exchange Format
  'kml',   // Keyhole Markup Language
  'kmz',   // Compressed KML
  'geojson', 'json',  // GeoJSON
  'fit',   // Garmin FIT
  'tcx',   // Training Center XML
  'csv',   // CSV with coordinates
  'nmea', 'txt',  // NMEA sentences
];
```

---

## Platform-Specific Notes

### iOS
- Uses UIDocumentPickerViewController
- Requires no Info.plist changes (file picker handles permissions)
- Supports iCloud Drive and Files app locations
- Multi-select available iOS 11+

### Android
- Uses Storage Access Framework (SAF)
- No storage permissions needed (scoped storage)
- Supports internal storage, SD card, Google Drive, etc.
- Multi-select available Android 18+ (Jelly Bean)

---

## Implementation Notes

**Library**: Use `file_picker` package (version ^6.1.0)

**Example Usage**:
```dart
final service = FilePickerServiceImpl();

// Pick single GPX file
final result = await service.pickTrackFile(
  allowedExtensions: ['gpx'],
);

if (result != null) {
  print('Selected: ${result.name} (${result.size} bytes)');
  // Pass result.path to TrackParserService
}
```

**Error Messages**: Should be user-friendly:
- "Storage permission denied. Please enable in Settings."
- "Unable to access file. Please try again."
- "File selection cancelled."

**Performance**: File picker should open in <1 second

**Testing**: Use mock implementation for tests (no actual file system access needed)
