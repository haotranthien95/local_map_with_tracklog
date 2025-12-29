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
  final String? userId; // T038: User ID for ownership tracking (null = guest)

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
    this.userId, // T038: Optional user ID for auth/guest tracking
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
      'userId': userId, // T038: Include userId in serialization
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
      userId: json['userId']
          as String?, // T038: Deserialize userId (nullable for backward compatibility)
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

  /// T038: Copy with updated fields (for migration)
  TracklogMetadata copyWith({
    String? id,
    String? name,
    Color? color,
    bool? isVisible,
    String? filePath,
    DateTime? importedAt,
    String? importedFrom,
    TrackFormat? format,
    double? boundsNorth,
    double? boundsSouth,
    double? boundsEast,
    double? boundsWest,
    String? userId,
  }) {
    return TracklogMetadata(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      isVisible: isVisible ?? this.isVisible,
      filePath: filePath ?? this.filePath,
      importedAt: importedAt ?? this.importedAt,
      importedFrom: importedFrom ?? this.importedFrom,
      format: format ?? this.format,
      boundsNorth: boundsNorth ?? this.boundsNorth,
      boundsSouth: boundsSouth ?? this.boundsSouth,
      boundsEast: boundsEast ?? this.boundsEast,
      boundsWest: boundsWest ?? this.boundsWest,
      userId: userId ?? this.userId,
    );
  }
}
