// T024: TokenStorageService for secure token storage using flutter_secure_storage

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for secure token storage (iOS Keychain / Android Keystore)
class TokenStorageService {
  static final TokenStorageService _instance = TokenStorageService._internal();
  factory TokenStorageService() => _instance;
  TokenStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Storage keys
  static const String _sessionTokenKey = 'session_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _tokenExpiryKey = 'token_expiry';

  /// Store session token securely
  Future<void> storeSessionToken(String token) async {
    await _secureStorage.write(key: _sessionTokenKey, value: token);
  }

  /// Retrieve session token
  Future<String?> getSessionToken() async {
    return await _secureStorage.read(key: _sessionTokenKey);
  }

  /// Store refresh token securely
  Future<void> storeRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Store user ID
  Future<void> storeUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  /// Retrieve user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Store token expiry time
  Future<void> storeTokenExpiry(DateTime expiry) async {
    await _secureStorage.write(
      key: _tokenExpiryKey,
      value: expiry.toIso8601String(),
    );
  }

  /// Retrieve token expiry time
  Future<DateTime?> getTokenExpiry() async {
    final expiryStr = await _secureStorage.read(key: _tokenExpiryKey);
    if (expiryStr == null) return null;
    return DateTime.tryParse(expiryStr);
  }

  /// Clear all stored tokens (on logout or account deletion)
  Future<void> clearAllTokens() async {
    await _secureStorage.delete(key: _sessionTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _tokenExpiryKey);
  }

  /// Check if tokens exist
  Future<bool> hasStoredTokens() async {
    final sessionToken = await getSessionToken();
    return sessionToken != null && sessionToken.isNotEmpty;
  }

  /// Clear all data (for complete reset)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
