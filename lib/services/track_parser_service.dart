import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:convert';
import 'package:gpx/gpx.dart';
import 'package:xml/xml.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import '../models/track.dart' as model;

/// Service interface for parsing track files
abstract class TrackParserService {
  /// Parse a track file and return a Track object
  Future<model.Track> parseTrackFile(File file);

  /// Parse track data from bytes
  Future<model.Track> parseTrackBytes(Uint8List bytes, String filename);

  /// Detect the format of a track file
  model.TrackFormat detectFormat(String filename);

  /// Validate a track has valid data
  bool validateTrack(model.Track track);

  /// Simplify a track by reducing the number of points (optional)
  List<model.TrackPoint> simplifyTrack(List<model.TrackPoint> points, {double tolerance = 0.0001});
}

/// Implementation of TrackParserService with GPX support
class TrackParserServiceImpl implements TrackParserService {
  static final List<Color> _trackColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
  ];

  @override
  Future<model.Track> parseTrackFile(File file) async {
    final bytes = await file.readAsBytes();
    return parseTrackBytes(bytes, file.path.split('/').last);
  }

  @override
  Future<model.Track> parseTrackBytes(Uint8List bytes, String filename) async {
    final format = detectFormat(filename);

    switch (format) {
      case model.TrackFormat.gpx:
        return _parseGpx(bytes, filename);
      case model.TrackFormat.kml:
        return _parseKml(bytes, filename);
      case model.TrackFormat.kmz:
        return _parseKmz(bytes, filename);
      case model.TrackFormat.geojson:
        return _parseGeoJson(bytes, filename);
      case model.TrackFormat.csv:
        return _parseCsv(bytes, filename);
      case model.TrackFormat.tcx:
        return _parseTcx(bytes, filename);
      case model.TrackFormat.fit:
        return _parseFit(bytes, filename);
      case model.TrackFormat.nmea:
        return _parseNmea(bytes, filename);
      default:
        throw UnsupportedError('Format ${format.name} is not yet supported');
    }
  }

  @override
  model.TrackFormat detectFormat(String filename) {
    final extension = filename.split('.').last.toLowerCase();

    for (final format in model.TrackFormat.values) {
      if (format.extensions.contains(extension)) {
        return format;
      }
    }

    throw ArgumentError('Unknown file format: $extension');
  }

  @override
  bool validateTrack(model.Track track) {
    // Check if track has at least 2 points
    if (track.coordinates.length < 2) {
      return false;
    }

    // Check if all points have valid coordinates
    for (final point in track.coordinates) {
      if (point.latitude < -90 || point.latitude > 90) {
        return false;
      }
      if (point.longitude < -180 || point.longitude > 180) {
        return false;
      }
    }

    return true;
  }

  @override
  List<model.TrackPoint> simplifyTrack(
    List<model.TrackPoint> points, {
    double tolerance = 0.0001,
  }) {
    // Use Ramer-Douglas-Peucker algorithm for large tracks
    if (points.length <= 100) {
      return points;
    }

    // For very large tracks (>5000 points), use more aggressive simplification
    final effectiveTolerance = points.length > 5000 ? tolerance * 2 : tolerance;

    return _ramerDouglasPeucker(points, effectiveTolerance);
  }

  /// Ramer-Douglas-Peucker algorithm for line simplification
  List<model.TrackPoint> _ramerDouglasPeucker(
    List<model.TrackPoint> points,
    double tolerance,
  ) {
    if (points.length < 3) {
      return points;
    }

    // Find the point with maximum distance from the line segment
    double maxDistance = 0;
    int maxIndex = 0;

    final first = points.first;
    final last = points.last;

    for (int i = 1; i < points.length - 1; i++) {
      final distance = _perpendicularDistance(points[i], first, last);
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }

    // If max distance is greater than tolerance, recursively simplify
    if (maxDistance > tolerance) {
      final left = _ramerDouglasPeucker(
        points.sublist(0, maxIndex + 1),
        tolerance,
      );
      final right = _ramerDouglasPeucker(
        points.sublist(maxIndex),
        tolerance,
      );

      // Combine results (excluding duplicate middle point)
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      // All points between first and last can be discarded
      return [first, last];
    }
  }

  /// Calculate perpendicular distance from point to line segment
  double _perpendicularDistance(
    model.TrackPoint point,
    model.TrackPoint lineStart,
    model.TrackPoint lineEnd,
  ) {
    final x0 = point.latitude;
    final y0 = point.longitude;
    final x1 = lineStart.latitude;
    final y1 = lineStart.longitude;
    final x2 = lineEnd.latitude;
    final y2 = lineEnd.longitude;

    final numerator = ((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1).abs();
    final denominator = math.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1));

    return denominator == 0 ? 0 : numerator / denominator;
  }

  /// Parse GPX file format
  Future<model.Track> _parseGpx(Uint8List bytes, String filename) async {
    try {
      final xmlString = String.fromCharCodes(bytes);
      final gpx = GpxReader().fromString(xmlString);

      if (gpx.trks.isEmpty && gpx.rtes.isEmpty) {
        throw const FormatException('GPX file contains no tracks or routes');
      }

      // Extract track points from first track or route
      final List<model.TrackPoint> trackPoints = [];
      String trackName = filename.replaceAll('.gpx', '');

      if (gpx.trks.isNotEmpty) {
        final track = gpx.trks.first;
        trackName = track.name ?? trackName;

        for (final segment in track.trksegs) {
          for (final point in segment.trkpts) {
            if (point.lat != null && point.lon != null) {
              trackPoints.add(model.TrackPoint(
                latitude: point.lat!,
                longitude: point.lon!,
                elevation: point.ele,
                timestamp: point.time,
                accuracy: null,
              ));
            }
          }
        }
      } else if (gpx.rtes.isNotEmpty) {
        final route = gpx.rtes.first;
        trackName = route.name ?? trackName;

        for (final point in route.rtepts) {
          if (point.lat != null && point.lon != null) {
            trackPoints.add(model.TrackPoint(
              latitude: point.lat!,
              longitude: point.lon!,
              elevation: point.ele,
              timestamp: point.time,
              accuracy: null,
            ));
          }
        }
      }

      if (trackPoints.isEmpty) {
        throw const FormatException('GPX file contains no valid track points');
      }

      // Simplify large tracks automatically (>5000 points)
      final finalTrackPoints =
          trackPoints.length > 5000 ? simplifyTrack(trackPoints, tolerance: 0.0001) : trackPoints;
      final _trackIdCounter = DateTime.now().millisecondsSinceEpoch;

      // Generate unique ID and assign color
      final trackId = 'track_$_trackIdCounter';
      final color = _trackColors[_trackIdCounter % _trackColors.length];

      final track = model.Track(
        id: trackId,
        name: trackName,
        coordinates: finalTrackPoints,
        importedFrom: filename,
        format: model.TrackFormat.gpx,
        importedAt: DateTime.now(),
        color: color,
        metadata: {
          'creator': gpx.creator,
          'version': gpx.version,
          'pointCount': trackPoints.length,
          'simplifiedPointCount': finalTrackPoints.length,
          'wasSimplified': trackPoints.length != finalTrackPoints.length,
        },
      );

      // Validate the track
      if (!validateTrack(track)) {
        throw const FormatException(
            'Invalid track data: insufficient points or invalid coordinates');
      }

      return track;
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      throw FormatException('Failed to parse GPX file: $e');
    }
  }

  /// Parse KML file format
  Future<model.Track> _parseKml(Uint8List bytes, String filename) async {
    try {
      final xmlString = String.fromCharCodes(bytes);
      final document = XmlDocument.parse(xmlString);

      final trackPoints = <model.TrackPoint>[];
      String trackName = filename.replaceAll('.kml', '');

      // Find all Placemark elements with LineString coordinates
      final placemarks = document.findAllElements('Placemark');

      for (final placemark in placemarks) {
        final nameElement = placemark.findElements('name').firstOrNull;
        if (nameElement != null) {
          trackName = nameElement.innerText;
        }

        // Look for LineString coordinates
        final coordsElements = placemark.findAllElements('coordinates');
        for (final coordsElement in coordsElements) {
          final coordsText = coordsElement.innerText.trim();
          final lines = coordsText.split('\n');

          for (final line in lines) {
            final parts = line.trim().split(RegExp(r'[,\s]+'));
            if (parts.length >= 2) {
              final lon = double.tryParse(parts[0]);
              final lat = double.tryParse(parts[1]);
              final ele = parts.length > 2 ? double.tryParse(parts[2]) : null;

              if (lat != null && lon != null) {
                trackPoints.add(model.TrackPoint(
                  latitude: lat,
                  longitude: lon,
                  elevation: ele,
                  timestamp: null,
                  accuracy: null,
                ));
              }
            }
          }
        }
      }

      if (trackPoints.isEmpty) {
        throw const FormatException('KML file contains no valid track points');
      }

      return _createTrack(trackPoints, trackName, filename, model.TrackFormat.kml);
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      throw FormatException('Failed to parse KML file: $e');
    }
  }

  /// Parse GeoJSON file format
  Future<model.Track> _parseGeoJson(Uint8List bytes, String filename) async {
    try {
      final jsonString = String.fromCharCodes(bytes);
      final data = json.decode(jsonString) as Map<String, dynamic>;

      final trackPoints = <model.TrackPoint>[];
      String trackName = filename.replaceAll(RegExp(r'\.(geojson|json)$'), '');

      // Handle Feature or FeatureCollection
      if (data['type'] == 'FeatureCollection') {
        final features = data['features'] as List<dynamic>?;
        if (features != null && features.isNotEmpty) {
          final feature = features.first as Map<String, dynamic>;
          if (feature['properties']?['name'] != null) {
            trackName = feature['properties']['name'] as String;
          }
          _extractGeoJsonCoordinates(feature, trackPoints);
        }
      } else if (data['type'] == 'Feature') {
        if (data['properties']?['name'] != null) {
          trackName = data['properties']['name'] as String;
        }
        _extractGeoJsonCoordinates(data, trackPoints);
      }

      if (trackPoints.isEmpty) {
        throw const FormatException('GeoJSON file contains no valid track points');
      }

      return _createTrack(trackPoints, trackName, filename, model.TrackFormat.geojson);
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      throw FormatException('Failed to parse GeoJSON file: $e');
    }
  }

  /// Extract coordinates from GeoJSON feature
  void _extractGeoJsonCoordinates(
    Map<String, dynamic> feature,
    List<model.TrackPoint> trackPoints,
  ) {
    final geometry = feature['geometry'] as Map<String, dynamic>?;
    if (geometry == null) return;

    final type = geometry['type'] as String?;
    final coordinates = geometry['coordinates'] as List<dynamic>?;

    if (coordinates == null) return;

    if (type == 'LineString') {
      for (final coord in coordinates) {
        final point = coord as List<dynamic>;
        if (point.length >= 2) {
          trackPoints.add(model.TrackPoint(
            latitude: (point[1] as num).toDouble(),
            longitude: (point[0] as num).toDouble(),
            elevation: point.length > 2 ? (point[2] as num).toDouble() : null,
            timestamp: null,
            accuracy: null,
          ));
        }
      }
    } else if (type == 'MultiLineString') {
      for (final lineString in coordinates) {
        for (final coord in lineString as List<dynamic>) {
          final point = coord as List<dynamic>;
          if (point.length >= 2) {
            trackPoints.add(model.TrackPoint(
              latitude: (point[1] as num).toDouble(),
              longitude: (point[0] as num).toDouble(),
              elevation: point.length > 2 ? (point[2] as num).toDouble() : null,
              timestamp: null,
              accuracy: null,
            ));
          }
        }
      }
    }
  }

  /// Parse CSV file format (expects lat,lon or lat,lon,ele columns)
  Future<model.Track> _parseCsv(Uint8List bytes, String filename) async {
    try {
      final csvString = String.fromCharCodes(bytes);
      final lines = csvString.split('\n');

      final trackPoints = <model.TrackPoint>[];
      String trackName = filename.replaceAll('.csv', '');

      // Skip header if present (detect by checking if first line has non-numeric values)
      int startIndex = 0;
      if (lines.isNotEmpty) {
        final firstLine = lines[0].trim();
        if (firstLine.toLowerCase().contains('lat') || firstLine.toLowerCase().contains('lon')) {
          startIndex = 1;
        }
      }

      for (int i = startIndex; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final parts = line.split(RegExp(r'[,;\t]'));
        if (parts.length >= 2) {
          final lat = double.tryParse(parts[0].trim());
          final lon = double.tryParse(parts[1].trim());
          final ele = parts.length > 2 ? double.tryParse(parts[2].trim()) : null;

          if (lat != null && lon != null) {
            trackPoints.add(model.TrackPoint(
              latitude: lat,
              longitude: lon,
              elevation: ele,
              timestamp: null,
              accuracy: null,
            ));
          }
        }
      }

      if (trackPoints.isEmpty) {
        throw const FormatException('CSV file contains no valid track points');
      }

      return _createTrack(trackPoints, trackName, filename, model.TrackFormat.csv);
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      throw FormatException('Failed to parse CSV file: $e');
    }
  }

  /// Parse TCX (Training Center XML) file format
  Future<model.Track> _parseTcx(Uint8List bytes, String filename) async {
    try {
      final xmlString = String.fromCharCodes(bytes);
      final document = XmlDocument.parse(xmlString);

      final trackPoints = <model.TrackPoint>[];
      String trackName = filename.replaceAll('.tcx', '');

      // Find all Trackpoint elements
      final trackpointElements = document.findAllElements('Trackpoint');

      for (final trackpoint in trackpointElements) {
        final positionElement = trackpoint.findElements('Position').firstOrNull;
        if (positionElement != null) {
          final latElement = positionElement.findElements('LatitudeDegrees').firstOrNull;
          final lonElement = positionElement.findElements('LongitudeDegrees').firstOrNull;

          if (latElement != null && lonElement != null) {
            final lat = double.tryParse(latElement.innerText);
            final lon = double.tryParse(lonElement.innerText);

            if (lat != null && lon != null) {
              final altElement = trackpoint.findElements('AltitudeMeters').firstOrNull;
              final timeElement = trackpoint.findElements('Time').firstOrNull;

              trackPoints.add(model.TrackPoint(
                latitude: lat,
                longitude: lon,
                elevation: altElement != null ? double.tryParse(altElement.innerText) : null,
                timestamp: timeElement != null ? DateTime.tryParse(timeElement.innerText) : null,
                accuracy: null,
              ));
            }
          }
        }
      }

      if (trackPoints.isEmpty) {
        throw const FormatException('TCX file contains no valid track points');
      }

      return _createTrack(trackPoints, trackName, filename, model.TrackFormat.tcx);
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      throw FormatException('Failed to parse TCX file: $e');
    }
  }

  /// Helper method to create a track with common logic
  model.Track _createTrack(
    List<model.TrackPoint> trackPoints,
    String trackName,
    String filename,
    model.TrackFormat format,
  ) {
    final _trackIdCounter = DateTime.now().millisecondsSinceEpoch;
    // Simplify large tracks automatically (>5000 points)
    final finalTrackPoints =
        trackPoints.length > 5000 ? simplifyTrack(trackPoints, tolerance: 0.0001) : trackPoints;

    // Generate unique ID and assign color
    final trackId = 'track_$_trackIdCounter';
    final color = _trackColors[_trackIdCounter % _trackColors.length];

    final track = model.Track(
      id: trackId,
      name: trackName,
      coordinates: finalTrackPoints,
      importedFrom: filename,
      format: format,
      importedAt: DateTime.now(),
      color: color,
      metadata: {
        'pointCount': trackPoints.length,
        'simplifiedPointCount': finalTrackPoints.length,
        'wasSimplified': trackPoints.length != finalTrackPoints.length,
      },
    );

    // Validate the track
    if (!validateTrack(track)) {
      throw const FormatException('Invalid track data: insufficient points or invalid coordinates');
    }

    return track;
  }

  /// Parse KMZ file format (zipped KML)
  Future<model.Track> _parseKmz(Uint8List bytes, String filename) async {
    try {
      // Decompress the KMZ file
      final archive = ZipDecoder().decodeBytes(bytes);

      // Find the first .kml file in the archive
      ArchiveFile? kmlFile;
      for (final file in archive.files) {
        if (file.name.toLowerCase().endsWith('.kml') && !file.isFile) {
          continue;
        }
        if (file.name.toLowerCase().endsWith('.kml')) {
          kmlFile = file;
          break;
        }
      }

      if (kmlFile == null) {
        throw const FormatException('KMZ file does not contain a KML file');
      }

      // Extract and parse the KML content
      final kmlBytes = kmlFile.content as List<int>;
      return _parseKml(Uint8List.fromList(kmlBytes), filename.replaceAll('.kmz', '.kml'));
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      throw FormatException('Failed to parse KMZ file: $e');
    }
  }

  /// Parse FIT file format (binary format used by Garmin devices)
  /// Note: This is a simplified implementation for basic FIT files
  Future<model.Track> _parseFit(Uint8List bytes, String filename) async {
    try {
      // FIT is a binary format - this is a basic implementation
      // For production use, consider using a dedicated FIT parsing library

      // Check FIT file header (first 14 bytes)
      if (bytes.length < 14) {
        throw const FormatException('FIT file is too small to be valid');
      }

      // Header size should be 12 or 14
      final headerSize = bytes[0];
      if (headerSize != 12 && headerSize != 14) {
        throw const FormatException('Invalid FIT file header');
      }

      // Protocol version
      final protocolVersion = bytes[1];
      if (protocolVersion < 1 || protocolVersion > 20) {
        throw FormatException('Unsupported FIT protocol version: $protocolVersion');
      }

      // File type signature should be ".FIT"
      final signature = String.fromCharCodes(bytes.sublist(8, 12));
      if (signature != '.FIT') {
        throw FormatException('Invalid FIT file signature: $signature');
      }

      // For now, throw an error indicating full FIT parsing is not yet implemented
      // A complete implementation would require parsing the binary message format
      throw const FormatException(
        'FIT format parsing requires a specialized library. '
        'Consider converting your FIT file to GPX format using a tool like GPSBabel.',
      );
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      throw FormatException('Failed to parse FIT file: $e');
    }
  }

  /// Parse NMEA sentence format (GPS log format)
  Future<model.Track> _parseNmea(Uint8List bytes, String filename) async {
    try {
      final content = String.fromCharCodes(bytes);
      final lines = content.split('\n');

      final List<model.TrackPoint> trackPoints = [];
      String trackName = filename.replaceAll(RegExp(r'\.(nmea|txt)$'), '');

      for (final line in lines) {
        final trimmed = line.trim();

        // Skip empty lines and non-NMEA sentences
        if (trimmed.isEmpty || !trimmed.startsWith('\$')) {
          continue;
        }

        // Parse GPGGA sentences (Global Positioning System Fix Data)
        if (trimmed.startsWith('\$GPGGA') || trimmed.startsWith('\$GNGGA')) {
          final parts = trimmed.split(',');
          if (parts.length < 10) continue;

          try {
            // Time (hhmmss.ss)
            final timeStr = parts[1];
            DateTime? timestamp;
            if (timeStr.isNotEmpty) {
              final hours = int.tryParse(timeStr.substring(0, 2));
              final minutes = int.tryParse(timeStr.substring(2, 4));
              final seconds = double.tryParse(timeStr.substring(4));
              if (hours != null && minutes != null && seconds != null) {
                final now = DateTime.now();
                timestamp = DateTime(now.year, now.month, now.day, hours, minutes, seconds.toInt());
              }
            }

            // Latitude (ddmm.mmmm)
            final latStr = parts[2];
            final latDir = parts[3];
            if (latStr.isEmpty || latDir.isEmpty) continue;

            final latDeg = int.parse(latStr.substring(0, 2));
            final latMin = double.parse(latStr.substring(2));
            double latitude = latDeg + (latMin / 60.0);
            if (latDir == 'S') latitude = -latitude;

            // Longitude (dddmm.mmmm)
            final lonStr = parts[4];
            final lonDir = parts[5];
            if (lonStr.isEmpty || lonDir.isEmpty) continue;

            final lonDeg = int.parse(lonStr.substring(0, 3));
            final lonMin = double.parse(lonStr.substring(3));
            double longitude = lonDeg + (lonMin / 60.0);
            if (lonDir == 'W') longitude = -longitude;

            // Quality indicator (0 = invalid, 1+ = valid)
            final quality = int.tryParse(parts[6]) ?? 0;
            if (quality == 0) continue;

            // Altitude
            final altStr = parts[9];
            final altitude = altStr.isNotEmpty ? double.tryParse(altStr) : null;

            trackPoints.add(model.TrackPoint(
              latitude: latitude,
              longitude: longitude,
              elevation: altitude,
              timestamp: timestamp,
              accuracy: null,
            ));
          } catch (e) {
            // Skip malformed sentences
            continue;
          }
        }

        // Parse GPRMC sentences (Recommended Minimum Specific GPS/TRANSIT Data)
        else if (trimmed.startsWith('\$GPRMC') || trimmed.startsWith('\$GNRMC')) {
          final parts = trimmed.split(',');
          if (parts.length < 10) continue;

          try {
            // Status (A = active/valid, V = void/invalid)
            final status = parts[2];
            if (status != 'A') continue;

            // Latitude
            final latStr = parts[3];
            final latDir = parts[4];
            if (latStr.isEmpty || latDir.isEmpty) continue;

            final latDeg = int.parse(latStr.substring(0, 2));
            final latMin = double.parse(latStr.substring(2));
            double latitude = latDeg + (latMin / 60.0);
            if (latDir == 'S') latitude = -latitude;

            // Longitude
            final lonStr = parts[5];
            final lonDir = parts[6];
            if (lonStr.isEmpty || lonDir.isEmpty) continue;

            final lonDeg = int.parse(lonStr.substring(0, 3));
            final lonMin = double.parse(lonStr.substring(3));
            double longitude = lonDeg + (lonMin / 60.0);
            if (lonDir == 'W') longitude = -longitude;

            // Time and date
            final timeStr = parts[1];
            final dateStr = parts[9];
            DateTime? timestamp;
            if (timeStr.isNotEmpty && dateStr.isNotEmpty && dateStr.length == 6) {
              try {
                final hours = int.parse(timeStr.substring(0, 2));
                final minutes = int.parse(timeStr.substring(2, 4));
                final seconds = double.parse(timeStr.substring(4));
                final day = int.parse(dateStr.substring(0, 2));
                final month = int.parse(dateStr.substring(2, 4));
                final year = 2000 + int.parse(dateStr.substring(4, 6));
                timestamp = DateTime(year, month, day, hours, minutes, seconds.toInt());
              } catch (e) {
                // Ignore timestamp parsing errors
              }
            }

            // Avoid duplicates if we already have this point from GPGGA
            final isDuplicate = trackPoints.any((p) =>
                (p.latitude - latitude).abs() < 0.00001 &&
                (p.longitude - longitude).abs() < 0.00001 &&
                (timestamp == null ||
                    p.timestamp == null ||
                    (p.timestamp!.difference(timestamp).inSeconds.abs() < 2)));

            if (!isDuplicate) {
              trackPoints.add(model.TrackPoint(
                latitude: latitude,
                longitude: longitude,
                elevation: null,
                timestamp: timestamp,
                accuracy: null,
              ));
            }
          } catch (e) {
            // Skip malformed sentences
            continue;
          }
        }
      }

      if (trackPoints.isEmpty) {
        throw const FormatException('NMEA file contains no valid GPS coordinates');
      }

      return _createTrack(trackPoints, trackName, filename, model.TrackFormat.nmea);
    } catch (e) {
      if (e is FormatException) {
        rethrow;
      }
      throw FormatException('Failed to parse NMEA file: $e');
    }
  }
}
