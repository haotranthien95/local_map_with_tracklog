import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_photo.dart';

class ProfilePhotoService {
  static const _pathKey = 'profile_photo.localPath';
  static const _updatedAtKey = 'profile_photo.updatedAt';

  const ProfilePhotoService();

  Future<ProfilePhoto?> getProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_pathKey);
    final updatedAtString = prefs.getString(_updatedAtKey);

    if (path == null || path.isEmpty) {
      return null;
    }

    final file = File(path);
    if (!await file.exists()) {
      await clear();
      return null;
    }

    DateTime updatedAt;
    if (updatedAtString != null) {
      updatedAt = DateTime.tryParse(updatedAtString) ?? DateTime.now();
    } else {
      updatedAt = DateTime.now();
    }

    return ProfilePhoto(
      localPath: path,
      updatedAt: updatedAt,
      source: ProfilePhotoSource.photoLibrary,
    );
  }

  Future<ProfilePhoto> saveFromFilePath(String sourceFilePath) async {
    final source = File(sourceFilePath);
    final ext = _inferExtension(sourceFilePath);

    final directory = await getApplicationSupportDirectory();
    final target = File('${directory.path}/profile_photo$ext');

    await directory.create(recursive: true);
    await source.copy(target.path);

    final updatedAt = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pathKey, target.path);
    await prefs.setString(_updatedAtKey, updatedAt.toIso8601String());

    return ProfilePhoto(
      localPath: target.path,
      updatedAt: updatedAt,
      source: ProfilePhotoSource.photoLibrary,
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final existingPath = prefs.getString(_pathKey);
    if (existingPath != null && existingPath.isNotEmpty) {
      final file = File(existingPath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {
          // Ignore delete failures; still clear prefs.
        }
      }
    }

    await prefs.remove(_pathKey);
    await prefs.remove(_updatedAtKey);
  }

  String _inferExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) {
      return '.jpg';
    }

    final ext = path.substring(dot);
    if (ext.length > 8) {
      return '.jpg';
    }

    return ext;
  }
}
