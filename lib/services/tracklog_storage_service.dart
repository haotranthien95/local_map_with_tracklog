import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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

  // T038: Migration support methods
  Future<List<TracklogMetadata>> loadGuestMetadata();
  Future<void> migrateTracklogOwnership(String tracklogId, String userId);

  // T094: Account deletion support
  Future<void> deleteAllUserTracklogs(String userId);
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

  // T038: Load guest tracklogs (tracklogs with no userId)
  @override
  Future<List<TracklogMetadata>> loadGuestMetadata() async {
    final allMetadata = await loadAllMetadata();
    return allMetadata.where((m) => m.userId == null).toList();
  }

  // T038: Migrate tracklog ownership from guest to authenticated user
  @override
  Future<void> migrateTracklogOwnership(String tracklogId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_metadataPrefix$tracklogId');

    if (jsonStr == null) {
      throw Exception('Tracklog metadata not found: $tracklogId');
    }

    // Load existing metadata
    final metadata = TracklogMetadata.fromJson(jsonDecode(jsonStr));

    // Update userId
    final updatedMetadata = metadata.copyWith(userId: userId);

    // Save updated metadata
    await updateMetadata(updatedMetadata);
  }

  // T094: Delete all tracklogs belonging to a user (for account deletion)
  @override
  Future<void> deleteAllUserTracklogs(String userId) async {
    final allMetadata = await loadAllMetadata();
    final userTracklogs = allMetadata.where((m) => m.userId == userId).toList();

    // Delete each tracklog owned by this user
    for (final metadata in userTracklogs) {
      await deleteTracklog(metadata.id);
    }
  }

  // Helper: Track to JSON
  Map<String, dynamic> _trackToJson(Track track) {
    return {
      'id': track.id,
      'name': track.name,
      'coordinates': track.coordinates
          .map((p) => {
                'latitude': p.latitude,
                'longitude': p.longitude,
                'elevation': p.elevation,
                'timestamp': p.timestamp?.toIso8601String(),
                'accuracy': p.accuracy,
              })
          .toList(),
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
      id: json['id'] as String,
      name: json['name'] as String,
      coordinates: (json['coordinates'] as List)
          .map((p) => TrackPoint(
                latitude: p['latitude'] as double,
                longitude: p['longitude'] as double,
                elevation: p['elevation'] as double?,
                timestamp: p['timestamp'] != null ? DateTime.parse(p['timestamp'] as String) : null,
                accuracy: p['accuracy'] as double?,
              ))
          .toList(),
      importedFrom: json['importedFrom'] as String,
      format: TrackFormat.values.firstWhere((e) => e.name == json['format']),
      importedAt: DateTime.parse(json['importedAt'] as String),
      color: Color(json['color'] as int),
      isVisible: json['isVisible'] as bool? ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}
