# FIT File Format Note

The FIT (Flexible and Interoperable Data Transfer) format is a proprietary binary format created by Garmin. It's commonly used by Garmin fitness devices and other sports tracking equipment.

## Why No Sample FIT File?

FIT files are binary and require specialized encoding libraries to create properly. The format specification is complex and includes:
- Binary header with checksums
- Message definitions with field types
- Compressed timestamps
- CRC validation

## Current Implementation

The parser includes basic FIT header validation but cannot fully parse the binary message format without a specialized library. Users attempting to import FIT files will receive a helpful error message suggesting to convert their FIT files to GPX using tools like:

- GPSBabel: https://www.gpsbabel.org/
- Garmin Connect: Export as GPX
- Online converters: fitfiletools.com, etc.

## Future Enhancement

For full FIT support, consider integrating one of these packages:
- fit_tool (Dart package if available)
- GPSBabel command-line tool integration
- Garmin FIT SDK (C/C++ with FFI bindings)

## Testing

To test FIT file handling:
1. Download a sample FIT file from a Garmin device or fitness platform
2. Import it into the app
3. Verify the error message is clear and actionable
4. Convert the FIT file to GPX and verify it imports successfully
