// T017: AuthenticationSession model for active user sessions

/// Represents an active authentication session with tokens
class AuthenticationSession {
  final String sessionToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String userId;
  final String? deviceInfo;
  final DateTime lastActivity;

  const AuthenticationSession({
    required this.sessionToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userId,
    this.deviceInfo,
    required this.lastActivity,
  });

  /// Check if session is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if session is valid (not expired)
  bool get isValid => !isExpired;

  /// Check if session needs refresh (expires in less than 5 minutes)
  bool get needsRefresh {
    final now = DateTime.now();
    final fiveMinutesFromNow = now.add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionToken': sessionToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'userId': userId,
      'deviceInfo': deviceInfo,
      'lastActivity': lastActivity.toIso8601String(),
    };
  }

  /// Create from JSON
  factory AuthenticationSession.fromJson(Map<String, dynamic> json) {
    return AuthenticationSession(
      sessionToken: json['sessionToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      userId: json['userId'] as String,
      deviceInfo: json['deviceInfo'] as String?,
      lastActivity: DateTime.parse(json['lastActivity'] as String),
    );
  }

  /// Create a copy with updated fields
  AuthenticationSession copyWith({
    String? sessionToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? userId,
    String? deviceInfo,
    DateTime? lastActivity,
  }) {
    return AuthenticationSession(
      sessionToken: sessionToken ?? this.sessionToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      userId: userId ?? this.userId,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  @override
  String toString() {
    return 'AuthenticationSession(userId: $userId, expires: $expiresAt, valid: $isValid)';
  }
}
