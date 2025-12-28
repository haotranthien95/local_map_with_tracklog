import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Track file format types
enum TrackFormat {
  gpx,
  kml,
  kmz,
  geojson,
  fit,
  tcx,
  csv,
  nmea;

  /// Get file extensions for each format
  List<String> get extensions {
    switch (this) {
      case TrackFormat.gpx:
        return ['gpx'];
      case TrackFormat.kml:
        return ['kml'];
      case TrackFormat.kmz:
        return ['kmz'];
      case TrackFormat.geojson:
        return ['geojson', 'json'];
      case TrackFormat.fit:
        return ['fit'];
      case TrackFormat.tcx:
        return ['tcx'];
      case TrackFormat.csv:
        return ['csv'];
      case TrackFormat.nmea:
        return ['nmea', 'txt'];
    }
  }
}

/// Represents a single GPS coordinate point in a track
class TrackPoint {
  final double latitude;
  final double longitude;
  final double? elevation;
  final DateTime? timestamp;
  final double? accuracy;

  const TrackPoint({
    required this.latitude,
    required this.longitude,
    this.elevation,
    this.timestamp,
    this.accuracy,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// Represents geographic bounds (bounding box)
class LatLngBounds {
  final double north;
  final double south;
  final double east;
  final double west;

  const LatLngBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  /// Calculate bounds from a list of points
  factory LatLngBounds.fromPoints(List<TrackPoint> points) {
    if (points.isEmpty) {
      return const LatLngBounds(north: 0, south: 0, east: 0, west: 0);
    }

    double north = points.first.latitude;
    double south = points.first.latitude;
    double east = points.first.longitude;
    double west = points.first.longitude;

    for (final point in points) {
      if (point.latitude > north) north = point.latitude;
      if (point.latitude < south) south = point.latitude;
      if (point.longitude > east) east = point.longitude;
      if (point.longitude < west) west = point.longitude;
    }

    return LatLngBounds(north: north, south: south, east: east, west: west);
  }

  /// Get the center point of the bounds
  LatLng get center {
    return LatLng(
      (north + south) / 2,
      (east + west) / 2,
    );
  }

  /// Get the span (width/height) of the bounds in degrees
  double get latitudeSpan => north - south;
  double get longitudeSpan => east - west;
}

/// Represents a GPS track with metadata
class Track {
  final String id;
  final String name;
  final List<TrackPoint> coordinates;
  final String importedFrom;
  final TrackFormat format;
  final DateTime importedAt;
  final LatLngBounds bounds;
  final Color color;
  final Map<String, dynamic> metadata;

  Track({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.importedFrom,
    required this.format,
    required this.importedAt,
    required this.color,
    Map<String, dynamic>? metadata,
  })  : bounds = LatLngBounds.fromPoints(coordinates),
        metadata = metadata ?? {};

  /// Calculate total distance of the track in meters
  double get totalDistance {
    if (coordinates.length < 2) return 0.0;

    double distance = 0.0;
    const Distance calculator = Distance();

    for (int i = 1; i < coordinates.length; i++) {
      distance += calculator.as(
        LengthUnit.Meter,
        coordinates[i - 1].toLatLng(),
        coordinates[i].toLatLng(),
      );
    }

    return distance;
  }
}
