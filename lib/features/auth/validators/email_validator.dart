// T021: Email validator with regex-based validation

/// Email validation utility
class EmailValidator {
  // RFC 5322 compliant email regex (simplified)
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );

  /// Validate email format
  /// Returns true if email is valid, false otherwise
  static bool isValidEmail(String email) {
    if (email.isEmpty) {
      return false;
    }

    // Trim whitespace
    final trimmedEmail = email.trim();

    // Check basic format
    if (!_emailRegex.hasMatch(trimmedEmail)) {
      return false;
    }

    // Check length constraints
    if (trimmedEmail.length > 254) {
      return false;
    }

    // Check local part length (before @)
    final parts = trimmedEmail.split('@');
    if (parts.length != 2) {
      return false;
    }

    final localPart = parts[0];
    if (localPart.length > 64) {
      return false;
    }

    return true;
  }

  /// Get validation error message for invalid email
  /// Returns null if email is valid
  static String? getValidationError(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }

    final trimmedEmail = email.trim();

    if (trimmedEmail.length > 254) {
      return 'Email is too long (max 254 characters)';
    }

    if (!_emailRegex.hasMatch(trimmedEmail)) {
      return 'Please enter a valid email address';
    }

    final parts = trimmedEmail.split('@');
    if (parts.length != 2 || parts[0].length > 64) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate and return normalized email (trimmed, lowercase)
  /// Returns null if invalid
  static String? normalizeEmail(String email) {
    if (!isValidEmail(email)) {
      return null;
    }
    return email.trim().toLowerCase();
  }
}
