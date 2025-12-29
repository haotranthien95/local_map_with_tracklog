// T019: GuestDataTracker model for tracking guest user data before migration

/// Tracks guest user data for migration to authenticated account
class GuestDataTracker {
  final bool hasGuestData;
  final List<String> guestTracklogIds;
  final DateTime createdAt;

  const GuestDataTracker({
    required this.hasGuestData,
    required this.guestTracklogIds,
    required this.createdAt,
  });

  /// Create empty tracker (no guest data)
  factory GuestDataTracker.empty() {
    return GuestDataTracker(
      hasGuestData: false,
      guestTracklogIds: const [],
      createdAt: DateTime.now(),
    );
  }

  /// Create tracker with guest data
  factory GuestDataTracker.withData(List<String> tracklogIds) {
    return GuestDataTracker(
      hasGuestData: tracklogIds.isNotEmpty,
      guestTracklogIds: tracklogIds,
      createdAt: DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'hasGuestData': hasGuestData,
      'guestTracklogIds': guestTracklogIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory GuestDataTracker.fromJson(Map<String, dynamic> json) {
    return GuestDataTracker(
      hasGuestData: json['hasGuestData'] as bool? ?? false,
      guestTracklogIds:
          (json['guestTracklogIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }

  /// Check if there is guest data to migrate
  bool get shouldMigrate => hasGuestData && guestTracklogIds.isNotEmpty;

  @override
  String toString() {
    return 'GuestDataTracker(hasData: $hasGuestData, tracklogCount: ${guestTracklogIds.length})';
  }
}
