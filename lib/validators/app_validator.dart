// lib/validators/app_validator.dart

class AppValidator {
  AppValidator._(); // prevent instantiation

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least 1 uppercase letter';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\\/]').hasMatch(value)) {
      return 'Password must contain at least 1 special character';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please re-enter your password';
    }
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? gender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your gender';
    }
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Returns list of unmet password requirements (for live feedback UI)
  static List<_PasswordRule> getPasswordRules(String password) {
    return [
      _PasswordRule('At least 6 characters', password.length >= 6),
      _PasswordRule('At least 1 uppercase letter', RegExp(r'[A-Z]').hasMatch(password)),
      _PasswordRule(
        'At least 1 special character',
        RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\\/]').hasMatch(password),
      ),
    ];
  }
}

class _PasswordRule {
  final String label;
  final bool met;
  const _PasswordRule(this.label, this.met);
}
