// T025, T035-T036: GuestMigrationService for guest data migration

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/guest_data_tracker.dart';
import '../models/user_profile.dart';
import 'tracklog_storage_service.dart';

/// Service for migrating guest data to authenticated accounts
class GuestMigrationService {
  static final GuestMigrationService _instance = GuestMigrationService._internal();
  factory GuestMigrationService() => _instance;
  GuestMigrationService._internal();

  static const String _guestTrackerKey = 'guest_data_tracker';
  static const String _userProfilePrefix = 'user_profile_';

  /// Get guest data tracker from local storage
  Future<GuestDataTracker> getGuestDataTracker() async {
    final prefs = await SharedPreferences.getInstance();
    final trackerJson = prefs.getString(_guestTrackerKey);

    if (trackerJson == null || trackerJson.isEmpty) {
      return GuestDataTracker.empty();
    }

    try {
      final Map<String, dynamic> json = jsonDecode(trackerJson);
      return GuestDataTracker.fromJson(json);
    } catch (e) {
      return GuestDataTracker.empty();
    }
  }

  /// Save guest data tracker to local storage
  Future<void> saveGuestDataTracker(GuestDataTracker tracker) async {
    final prefs = await SharedPreferences.getInstance();
    final json = tracker.toJson();
    await prefs.setString(_guestTrackerKey, jsonEncode(json));
  }

  /// T035: Migrate guest data to authenticated user account
  Future<bool> migrateGuestData(String userId) async {
    try {
      // 1. Get guest tracklog IDs from tracker
      final tracker = await getGuestDataTracker();
      if (!tracker.shouldMigrate) {
        return true; // No data to migrate
      }

      // 2. Get tracklog storage service (T038)
      final tracklogService = TracklogStorageServiceImpl();

      // 3. Migrate each guest tracklog to user context (T038)
      // Update ownership metadata for each tracklog from guest (userId=null) to authenticated user
      for (final tracklogId in tracker.guestTracklogIds) {
        await tracklogService.migrateTracklogOwnership(tracklogId, userId);
      }

      // 4. Mark migration as complete in user profile
      await _updateUserProfile(userId, guestDataMigrated: true, migrationPending: false);

      // 5. Clear guest data tracker
      await clearGuestData();

      return true;
    } catch (e) {
      // Migration failed, will be retried
      await setMigrationPending(userId, true);
      return false;
    }
  }

  /// T059: Discard guest data (for existing users signing in)
  Future<void> discardGuestData() async {
    try {
      // 1. Clear guest tracker
      await clearGuestData();

      // 2. Guest tracklogs remain as orphaned files (userId=null)
      // They can be cleaned up later with cleanupOrphanedFiles if needed
      // For now, we just clear the tracker so they won't be migrated
    } catch (e) {
      // Non-blocking, fail silently
    }
  }

  /// Check if there is guest data to migrate
  Future<bool> hasGuestData() async {
    final tracker = await getGuestDataTracker();
    return tracker.shouldMigrate;
  }

  /// T036: Set migration pending flag (for retry logic)
  Future<void> setMigrationPending(String userId, bool pending) async {
    await _updateUserProfile(userId, migrationPending: pending);
  }

  /// Clear guest data tracker
  Future<void> clearGuestData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestTrackerKey);
  }

  /// Helper: Update user profile with migration flags
  Future<void> _updateUserProfile(
    String userId, {
    bool? guestDataMigrated,
    bool? migrationPending,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final profileKey = '$_userProfilePrefix$userId';
    final profileJson = prefs.getString(profileKey);

    UserProfile profile;
    if (profileJson != null) {
      profile = UserProfile.fromJson(jsonDecode(profileJson));
    } else {
      profile = UserProfile.defaultProfile(userId);
    }

    // Update fields
    profile = profile.copyWith(
      guestDataMigrated: guestDataMigrated ?? profile.guestDataMigrated,
      migrationPending: migrationPending ?? profile.migrationPending,
    );

    // Save updated profile
    await prefs.setString(profileKey, jsonEncode(profile.toJson()));
  }
}
