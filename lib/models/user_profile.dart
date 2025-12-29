// T018: UserProfile model for editable user information

/// User profile with editable information (separate from authentication data)
class UserProfile {
  final String userId;
  final String? displayName;
  final Map<String, dynamic>? preferences;
  final bool guestDataMigrated;
  final bool migrationPending;

  const UserProfile({
    required this.userId,
    this.displayName,
    this.preferences,
    required this.guestDataMigrated,
    required this.migrationPending,
  });

  /// Create default profile for new user
  factory UserProfile.defaultProfile(String userId) {
    return UserProfile(
      userId: userId,
      displayName: null,
      preferences: {},
      guestDataMigrated: false,
      migrationPending: false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'preferences': preferences,
      'guestDataMigrated': guestDataMigrated,
      'migrationPending': migrationPending,
    };
  }

  /// Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      guestDataMigrated: json['guestDataMigrated'] as bool? ?? false,
      migrationPending: json['migrationPending'] as bool? ?? false,
    );
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? userId,
    String? displayName,
    Map<String, dynamic>? preferences,
    bool? guestDataMigrated,
    bool? migrationPending,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      preferences: preferences ?? this.preferences,
      guestDataMigrated: guestDataMigrated ?? this.guestDataMigrated,
      migrationPending: migrationPending ?? this.migrationPending,
    );
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, displayName: $displayName, migrated: $guestDataMigrated)';
  }
}
