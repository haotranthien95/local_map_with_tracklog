import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:local_map_with_tracklog/features/map/models/marker.dart';

class MarkerStore {
  static const String _defaultKey = 'session_markers';

  Future<List<MapMarker>> loadMarkers({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _storageKey(userId);
    final jsonString = prefs.getString(key);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      return decoded.map((item) => MapMarker.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMarkers(List<MapMarker> markers, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _storageKey(userId);
    final jsonString = json.encode(markers.map((m) => m.toJson()).toList());
    await prefs.setString(key, jsonString);
  }

  String _storageKey(String? userId) {
    if (userId == null || userId.isEmpty) return _defaultKey;
    return 'user_${userId}_markers';
  }
}
