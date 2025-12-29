// T015: User model with authentication data
// Represents an authenticated user in the system

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Authentication provider enum
enum AuthProvider {
  emailPassword,
  google,
  apple;

  String get displayName {
    switch (this) {
      case AuthProvider.emailPassword:
        return 'Email/Password';
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
    }
  }

  /// Convert Firebase provider ID to AuthProvider enum
  static AuthProvider fromProviderId(String providerId) {
    switch (providerId) {
      case 'password':
        return AuthProvider.emailPassword;
      case 'google.com':
        return AuthProvider.google;
      case 'apple.com':
        return AuthProvider.apple;
      default:
        return AuthProvider.emailPassword;
    }
  }

  String toProviderId() {
    switch (this) {
      case AuthProvider.emailPassword:
        return 'password';
      case AuthProvider.google:
        return 'google.com';
      case AuthProvider.apple:
        return 'apple.com';
    }
  }
}

/// User Account model
class User {
  final String userId;
  final String email;
  final bool emailVerified;
  final String? displayName;
  final AuthProvider authProvider;
  final DateTime createdAt;
  final DateTime lastSignInAt;
  final String? photoUrl;

  const User({
    required this.userId,
    required this.email,
    required this.emailVerified,
    this.displayName,
    required this.authProvider,
    required this.createdAt,
    required this.lastSignInAt,
    this.photoUrl,
  });

  /// Create User from Firebase User
  factory User.fromFirebaseUser(firebase_auth.User firebaseUser) {
    // Determine auth provider from user's provider data
    AuthProvider provider = AuthProvider.emailPassword;
    if (firebaseUser.providerData.isNotEmpty) {
      final providerId = firebaseUser.providerData.first.providerId;
      provider = AuthProvider.fromProviderId(providerId);
    }

    return User(
      userId: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      emailVerified: firebaseUser.emailVerified,
      displayName: firebaseUser.displayName,
      authProvider: provider,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastSignInAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
      photoUrl: firebaseUser.photoURL,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'emailVerified': emailVerified,
      'displayName': displayName,
      'authProvider': authProvider.name,
      'createdAt': createdAt.toIso8601String(),
      'lastSignInAt': lastSignInAt.toIso8601String(),
      'photoUrl': photoUrl,
    };
  }

  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      email: json['email'] as String,
      emailVerified: json['emailVerified'] as bool,
      displayName: json['displayName'] as String?,
      authProvider: AuthProvider.values.firstWhere(
        (e) => e.name == json['authProvider'],
        orElse: () => AuthProvider.emailPassword,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSignInAt: DateTime.parse(json['lastSignInAt'] as String),
      photoUrl: json['photoUrl'] as String?,
    );
  }

  /// Create a copy with updated fields
  User copyWith({
    String? userId,
    String? email,
    bool? emailVerified,
    String? displayName,
    AuthProvider? authProvider,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    String? photoUrl,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      displayName: displayName ?? this.displayName,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  String toString() {
    return 'User(userId: $userId, email: $email, provider: ${authProvider.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
