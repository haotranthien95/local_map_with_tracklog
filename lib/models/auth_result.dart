// T016: AuthResult model for authentication operation results

import 'user.dart';

/// Result of an authentication operation
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final String? errorCode;
  final bool? needAction;

  const AuthResult({
    required this.success,
    this.user,
    this.error,
    this.errorCode,
    this.needAction,
  });

  /// Create a successful result
  factory AuthResult.success(User user) {
    return AuthResult(
      success: true,
      user: user,
    );
  }

  factory AuthResult.require() {
    return const AuthResult(
      success: false,
      needAction: true,
    );
  }

  /// Create a failure result
  factory AuthResult.failure(String error, {String? errorCode}) {
    return AuthResult(
      success: false,
      error: error,
      errorCode: errorCode,
    );
  }

  /// Check if result has an error
  bool get hasError => !success && error != null;

  /// Check if result has a user
  bool get hasUser => success && user != null;

  @override
  String toString() {
    if (success) {
      return 'AuthResult.success(user: ${user?.email})';
    } else {
      return 'AuthResult.failure(error: $error, code: $errorCode)';
    }
  }
}
