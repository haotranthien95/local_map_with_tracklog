# Service Contract: TrackParserService

**Purpose**: Parse GPS track files in various formats and convert to internal Track representation.

**Implementation Path**: `lib/services/track_parser_service.dart`

---

## Interface Definition

```dart
/// Service for parsing GPS track files
abstract class TrackParserService {
  /// Parse track file and return Track entity
  /// 
  /// Parameters:
  ///   - filePath: Absolute path to track file
  ///   - format: Track format (auto-detected if null)
  /// 
  /// Returns: Parsed Track entity
  /// 
  /// Throws: TrackParseException if file invalid or format unsupported
  Future<Track> parseTrackFile(String filePath, {TrackFormat? format});

  /// Parse track data from bytes
  /// 
  /// Parameters:
  ///   - data: Raw file bytes
  ///   - format: Track format (required)
  ///   - fileName: Optional original filename for metadata
  /// 
  /// Returns: Parsed Track entity
  /// 
  /// Throws: TrackParseException if data invalid
  Future<Track> parseTrackBytes(Uint8List data, TrackFormat format, {String? fileName});

  /// Detect track format from file extension
  /// 
  /// Parameters:
  ///   - fileName: File name or path with extension
  /// 
  /// Returns: Detected TrackFormat or null if unknown
  TrackFormat? detectFormat(String fileName);

  /// Validate track data
  /// 
  /// Parameters:
  ///   - track: Track to validate
  /// 
  /// Returns: ValidationResult with issues found
  ValidationResult validateTrack(Track track);

  /// Simplify track by reducing point count
  /// 
  /// Parameters:
  ///   - track: Original track
  ///   - maxPoints: Maximum points in simplified track
  ///   - epsilon: Douglas-Peucker tolerance (meters), higher = more simplification
  /// 
  /// Returns: Simplified Track with fewer points
  Track simplifyTrack(Track track, {int? maxPoints, double epsilon = 10.0});
}

/// Track validation result
class ValidationResult {
  final bool isValid;
  final List<String> warnings;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    this.warnings = const [],
    this.errors = const [],
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

/// Exception thrown during track parsing
class TrackParseException implements Exception {
  final String message;
  final TrackFormat? format;
  final dynamic cause;

  TrackParseException(this.message, {this.format, this.cause});

  @override
  String toString() => 'TrackParseException: $message${format != null ? ' (format: $format)' : ''}${cause != null ? ' - $cause' : ''}';
}
```

---

## Behavior Requirements

### parseTrackFile
- **Preconditions**: File exists, format supported
- **Postconditions**: Returns valid Track with >= 2 coordinates
- **Error Handling**: Throws TrackParseException with specific error message
- **Format Detection**: If format null, detect from file extension
- **Side Effects**: Reads file from disk

### parseTrackBytes
- **Preconditions**: Valid data bytes, format specified
- **Postconditions**: Returns Track entity, sets importedFrom to fileName if provided
- **Error Handling**: Throws TrackParseException if data corrupted or invalid
- **Memory**: Should handle files up to 50MB

### detectFormat
- **Preconditions**: None
- **Postconditions**: Returns format or null (no exceptions)
- **Detection Logic**:
  - `.gpx` → TrackFormat.gpx
  - `.kml` → TrackFormat.kml
  - `.kmz` → TrackFormat.kmz
  - `.geojson` or `.json` → TrackFormat.geojson
  - `.fit` → TrackFormat.fit
  - `.tcx` → TrackFormat.tcx
  - `.csv` → TrackFormat.csv
  - `.nmea` or `.txt` → TrackFormat.nmea
  - Unknown → null

### validateTrack
- **Preconditions**: Track object exists
- **Postconditions**: Returns ValidationResult, never throws
- **Validation Checks**:
  - **Errors** (isValid = false):
    - Less than 2 coordinates
    - Any coordinate with invalid lat/lng (out of range)
    - Duplicate track ID collision
  - **Warnings** (isValid = true but issues):
    - More than 10,000 coordinates (performance warning)
    - Consecutive duplicate coordinates
    - Timestamps not monotonically increasing
    - Missing elevation data
    - Track bounds span >180° longitude (date line issue)

### simplifyTrack
- **Preconditions**: Track has > maxPoints or epsilon > 0
- **Postconditions**: Returns Track with fewer points, preserving shape
- **Algorithm**: Douglas-Peucker line simplification
- **Error Handling**: Returns original track if simplification fails
- **Side Effects**: None (creates new Track, doesn't modify original)

---

## Format-Specific Parsing

### GPX Format (P2 - MVP)
```xml
<!-- Example input -->
<gpx version="1.1">
  <trk>
    <name>Morning Hike</name>
    <trkseg>
      <trkpt lat="37.7749" lon="-122.4194">
        <ele>15.2</ele>
        <time>2025-01-01T08:00:00Z</time>
      </trkpt>
      ...
    </trkseg>
  </trk>
</gpx>
```
- **Library**: `gpx` package
- **Parsing**: Use `GpxReader.fromString()`, extract first track
- **Mapping**: `<trkpt>` → TrackPoint, `<name>` → Track.name
- **Edge Cases**: Handle multi-track files (take first), missing elevation/time

### KML Format (P4)
```xml
<!-- Example input -->
<kml>
  <Document>
    <Placemark>
      <LineString>
        <coordinates>-122.4194,37.7749,0 -122.4195,37.7750,10</coordinates>
      </LineString>
    </Placemark>
  </Document>
</kml>
```
- **Library**: `xml` package + custom parser
- **Parsing**: Extract `<coordinates>`, split by space, then by comma
- **Mapping**: `lon,lat,ele` tuple → TrackPoint (note: KML uses lon,lat order)
- **Edge Cases**: Handle KMZ (unzip first), multiple LineStrings

### GeoJSON Format (P4)
```json
{
  "type": "Feature",
  "geometry": {
    "type": "LineString",
    "coordinates": [[-122.4194, 37.7749], [-122.4195, 37.7750]]
  }
}
```
- **Library**: `dart:convert`
- **Parsing**: JSON decode, extract geometry.coordinates
- **Mapping**: `[lon, lat]` array → TrackPoint
- **Edge Cases**: Handle MultiLineString, Feature vs FeatureCollection

### Other Formats (P4 - Future)
- **FIT**: Binary format, use `fit_parser` package or custom decoder
- **TCX**: XML format similar to GPX, parse with `xml` package
- **CSV**: Text format, detect column mapping (lat,lon or lon,lat), use `dart:csv`
- **NMEA**: Text sentences, parse `$GPGGA` and `$GPRMC` sentences line-by-line

---

## Implementation Notes

**P2 (MVP)**: Implement GPX parsing only using `gpx` package

**P4 (Future)**: Add format parsers incrementally based on user demand

**Error Messages**: Should be user-friendly:
- "Invalid GPX file: missing required track data"
- "File too large: 15MB (maximum 10MB supported)"
- "Unsupported file format: .abc (supported: GPX, KML, GeoJSON)"

**Performance**: 
- Parse 1000 points in <500ms
- Simplification should reduce 10k points to <2k in <1s
- Use streaming parsers for large files when possible

**Testing**: Provide sample files for each format in `test/fixtures/`
