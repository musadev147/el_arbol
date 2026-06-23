class AppValidation {
  // 🔒 Private constructor
  AppValidation._internal();

  // 🌍 Singleton instance
  static final AppValidation _instance = AppValidation._internal();

  // 📦 Global access
  factory AppValidation() => _instance;

  // ✅ Email validation
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    const emailRegex =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailRegex).hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // 🔐 Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // 🧍 Name validation
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  // 📱 Phone validation
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    const phoneRegex = r'^[0-9]{10,15}$';
    if (!RegExp(phoneRegex).hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // 📝 Text field validation (generic)
  String? validateField(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  // 🔑 Confirm password validation
  String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // 💬 Message or description validation
  String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your message';
    }
    if (value.trim().length < 10) {
      return 'Message must be at least 10 characters';
    }
    return null;
  }
}
