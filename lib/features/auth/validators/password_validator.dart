// T022: Password validator with security requirements

/// Password validation utility
/// Requirements: min 8 chars, at least one uppercase, one lowercase, one number
class PasswordValidator {
  static const int minLength = 8;
  static const int maxLength = 128;

  // Regex patterns for password requirements
  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _numberRegex = RegExp(r'[0-9]');

  /// Validate password meets all requirements
  /// Returns true if password is valid, false otherwise
  static bool isValidPassword(String password) {
    if (password.isEmpty) {
      return false;
    }

    // Check length
    if (password.length < minLength || password.length > maxLength) {
      return false;
    }

    // Check for uppercase
    if (!_uppercaseRegex.hasMatch(password)) {
      return false;
    }

    // Check for lowercase
    if (!_lowercaseRegex.hasMatch(password)) {
      return false;
    }

    // Check for number
    if (!_numberRegex.hasMatch(password)) {
      return false;
    }

    return true;
  }

  /// Get validation error message for invalid password
  /// Returns null if password is valid
  static String? getValidationError(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (password.length > maxLength) {
      return 'Password is too long (max $maxLength characters)';
    }

    if (!_uppercaseRegex.hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!_lowercaseRegex.hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!_numberRegex.hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Check password strength
  /// Returns strength level: 'weak', 'medium', 'strong'
  static String getPasswordStrength(String password) {
    if (!isValidPassword(password)) {
      return 'weak';
    }

    int strengthScore = 0;

    // Length bonus
    if (password.length >= 12)
      strengthScore += 2;
    else if (password.length >= 10) strengthScore += 1;

    // Character variety bonus
    if (_uppercaseRegex.hasMatch(password)) strengthScore += 1;
    if (_lowercaseRegex.hasMatch(password)) strengthScore += 1;
    if (_numberRegex.hasMatch(password)) strengthScore += 1;

    // Special characters bonus
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strengthScore += 2;
    }

    // Evaluate strength
    if (strengthScore >= 6) return 'strong';
    if (strengthScore >= 4) return 'medium';
    return 'weak';
  }

  /// Get list of requirements that the password doesn't meet
  static List<String> getUnmetRequirements(String password) {
    final List<String> unmet = [];

    if (password.length < minLength) {
      unmet.add('At least $minLength characters');
    }

    if (!_uppercaseRegex.hasMatch(password)) {
      unmet.add('One uppercase letter');
    }

    if (!_lowercaseRegex.hasMatch(password)) {
      unmet.add('One lowercase letter');
    }

    if (!_numberRegex.hasMatch(password)) {
      unmet.add('One number');
    }

    return unmet;
  }
}
