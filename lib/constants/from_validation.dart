class InputValidator {
  InputValidator._();
  // Validate Email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Validate Password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateConfirmPass(String? value, String? pass) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Confirm password';
    }
    if (pass != value) {
      return 'Password not match';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Validate Username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'name must be at least 3 characters long';
    }
    return null;
  } // Validate phone

  static String? validateCustom(String? value, String? hintText) {
    if (value == null || value.isEmpty) {
      return hintText;
    }
    // if (value.length < 2) {
    //   return 'name must be at least 3 characters long';
    // }
    return null;
  }




  static String? validateCustomWord(String? value, String? hintText) {
    if (value == null || value.isEmpty) {
      return hintText;
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters long';
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Only one word allowed (letters only, no spaces)';
    }
    return null;
  }


  static String? validatenumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Phone';
    }
    if (value.length <= 9) {
      return 'Phone must be at least 11 characters long';
    }
    return null;
  }

  static String? validateaddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your address';
    }
    return null;
  }

  static String? validatefiled(String? value) {
    if (value == null || value.isEmpty) {
      return 'Filed Are Required';
    }
    return null;
  }
}
