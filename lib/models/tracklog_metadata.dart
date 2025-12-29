import 'package:flutter/material.dart';
import 'track.dart';

/// Lightweight representation of a tracklog for list display and persistence
/// Stored in shared_preferences for fast loading
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

  /// Serialize to JSON for shared_preferences storage
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
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(json['color'] as int),
      isVisible: json['isVisible'] as bool,
      filePath: json['filePath'] as String,
      importedAt: DateTime.parse(json['importedAt'] as String),
      importedFrom: json['importedFrom'] as String,
      format: TrackFormat.values.firstWhere(
        (e) => e.name == json['format'],
      ),
      boundsNorth: json['boundsNorth'] as double,
      boundsSouth: json['boundsSouth'] as double,
      boundsEast: json['boundsEast'] as double,
      boundsWest: json['boundsWest'] as double,
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
