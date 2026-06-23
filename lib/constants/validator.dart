/// Validates that the value is not empty.
String? requiredValidator(String? value,
    {String message = 'This field is required'}) {
  if (value == null || value.trim().isEmpty) {
    return message;
  }
  return null;
}

/// Validates that the value is a valid name.
String? nameValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your full name';
  }

  final name = value.trim();

  // Allow letters, spaces, and dot (.)
  final nameRegex = RegExp(r'^[a-zA-Z\s.]+$');

  if (!nameRegex.hasMatch(name)) {
    return 'Name can only contain letters, spaces, and dot (.)';
  }

  if (name.length < 3) {
    return 'Name must be at least 3 characters';
  }

  return null; // ✅ valid
}



String? descriptionValidator(String? value) {
  return requiredValidator(value, message: 'Please enter your description');
}

String? needValidator(String? value) {
  return requiredValidator(value, message: 'Please enter flied');
}

String? informationValidator(String? value) {
  return requiredValidator(value, message: 'Please enter your information');
}

/// Validates a proper email format.
String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
}

/// Validates a basic password (length ≥ 6).
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter Password';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

/// Validates a strong password with special character & number.
String? passwordValidatorSpecial(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!RegExp(r'\d').hasMatch(value)) {
    return 'Password must contain at least one number';
  }
  if (!RegExp(r'[!@#\$&*~%^()\-_=+{}[\]|;:<>,.?]').hasMatch(value)) {
    return 'Password must contain at least one special character';
  }
  return null;
}

/// Confirms the value matches the original password.




/// Validates phone number format.
String? validatePhoneNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Phone number is required';
  }

  // Remove spaces, dashes, and parentheses
  String cleanedValue = value.replaceAll(RegExp(r'[ \-\(\)]'), '');

  // Bangladeshi number example: +8801XXXXXXXXX or 01XXXXXXXXX
  final bdPattern = RegExp(r'^(?:\+8801|01)\d{8}$');

  // International: optional +, 10-15 digits
  final intlPattern = RegExp(r'^\+?\d{10,15}$');

  if (!bdPattern.hasMatch(cleanedValue) && !intlPattern.hasMatch(cleanedValue)) {
    return 'Enter a valid phone number';
  }

  return null; // Valid
}




String? passportNumberValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter a passport number';
  }

  // Adjust regex based on your country's format.
  final pattern = RegExp(r'^[A-Z0-9]{6,15}$');

  if (!pattern.hasMatch(value.trim())) {
    return 'Enter a valid passport number (6–15 characters, A-Z and 0-9)';
  }

  return null;
}

/// Validates a 4-digit numeric PIN code.
String? validate5DigitPinCode(String? value) {
  if (value == null || value.isEmpty) {
    return 'Enter the 5-digit code';
  }
  if (!RegExp(r'^\d{5}$').hasMatch(value)) {
    return '5-digit code is invalid';
  }
  return null;
}


/// Generic validator for any empty field.
String? emptyValidator(String? value) {
  return requiredValidator(value, message: 'Please fill the field');
}
// ...existing code...

String? budgetValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your budget';
  }
  final num? budget = num.tryParse(value);
  if (budget == null || budget <= 0) {
    return 'Enter a valid positive number';
  }
  return null;
}
// ...existing code...

String? daysValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter number of days';
  }
  final int? days = int.tryParse(value);
  if (days == null || days < 0) {
    return 'Enter a valid number of days';
  }
  return null;
}

String? hoursValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter number of hours';
  }
  final int? hours = int.tryParse(value);
  if (hours == null || hours < 0 || hours > 23) {
    return 'Enter a valid hour (0-23)';
  }
  return null;
}

String? minutesValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter number of minutes';
  }
  final int? minutes = int.tryParse(value);
  if (minutes == null || minutes < 0 || minutes > 59) {
    return 'Enter a valid minute (0-59)';
  }
  return null;
}

String? dateOfBirthValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your date of birth';
  }

  try {
    final parsedDate = DateTime.parse(value);
    final now = DateTime.now();

    if (parsedDate.isAfter(now)) {
      return 'Date of birth cannot be in the future';
    }

    // Optional: check minimum age (e.g. 13 years)
    final minAgeDate = DateTime(now.year - 13, now.month, now.day);
    if (parsedDate.isAfter(minAgeDate)) {
      return 'You must be at least 13 years old';
    }
  } catch (e) {
    return 'Enter date in a valid format (e.g. YYYY-MM-DD)';
  }

  return null;
}

String? noteValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null; // ✅ Allow empty (optional)
  }

  // Optional: Validate only if input is present
  if (value.trim().length < 5) {
    return 'Note must be at least 5 characters long';
  }

  return null; // ✅ Valid input
}


String? minPriceValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Min price is required';
  }
  final parsed = int.tryParse(value);
  if (parsed == null || parsed < 0) {
    return 'Enter a valid non-negative number';
  }
  return null; // valid
}

String? maxPriceValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Max price is required';
  }
  final parsed = int.tryParse(value);
  if (parsed == null || parsed < 0) {
    return 'Enter a valid non-negative number';
  }
  return null; // valid
}

String? aboutMeValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please write something about yourself';
  }
  if (value.length > 300) {
    return 'Maximum 300 characters allowed';
  }
  return null;
}
String? zipCodeValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Zip code is required';
  }

  // final zipRegExp = RegExp(r'^\d{5}(-\d{4})?$');
  // if (!zipRegExp.hasMatch(value.trim())) {
  //   return 'Enter a valid zip code';
  // }
  return null;
}
String? schoolNameValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter school name';
  }
  return null;
}
String? gradeValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter grade';
  }

  final grade = int.tryParse(value);
  if (grade == null) {
    return 'Grade must be a number';
  }

  if (grade < 1 || grade > 12) {
    return 'Grade must be between 1 and 12';
  }

  return null;
}

String? addressValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Please enter address';
  if (value.trim().length < 8) return 'Address should be at least 8 characters';
  return null;
}
String? companyNameValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Company name is required"; // now it will show error
  }
  if (value.length < 3) {
    return "Company name must be at least 3 characters";
  }
  return null;
}
 String? bedroomValidator(String? value) {
    if (value == null || value.trim().isEmpty) return "Number of bedrooms is required";
    if (int.tryParse(value.trim()) == null) return "Enter a valid number";
    return null;
  }

  String? bathroomValidator(String? value) {
    if (value == null || value.trim().isEmpty) return "Number of bathrooms is required";
    if (int.tryParse(value.trim()) == null) return "Enter a valid number";
    return null;
  }

  String? kitchenValidator(String? value) {
    if (value == null || value.trim().isEmpty) return "Number of kitchens is required";
    if (int.tryParse(value.trim()) == null) return "Enter a valid number";
    return null;
  }

  String? rentValidator(String? value) {
    if (value == null || value.trim().isEmpty) return "Rent price is required";
    if (double.tryParse(value.trim()) == null) return "Enter a valid price";
    return null;
  }

  String? descriptionValidator1(String? value) {
    if (value == null || value.trim().isEmpty) return "Please enter a description";
    if (value.trim().length < 10) return "Description must be at least 10 characters";
    return null;
  }



String? propertyTitleValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter property title';
  }

  final title = value.trim();

  // Allow letters, numbers, spaces and common punctuation
  final titleRegex = RegExp(r'^[a-zA-Z0-9\s.,&()\-]+$');

  if (!titleRegex.hasMatch(title)) {
    return 'Enter a valid property title';
  }

  if (title.length < 5) {
    return 'Title must be at least 5 characters';
  }

  return null; // ✅ valid
}
String? areaSizeValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter area size';
  }

  final area = double.tryParse(value.trim());

  if (area == null || area <= 0) {
    return 'Enter a valid area size';
  }

  return null; // ✅ valid
}
String? streetValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter street name';
  }

  final street = value.trim();

  final streetRegex = RegExp(r'^[a-zA-Z0-9\s.,\-]+$');

  if (!streetRegex.hasMatch(street)) {
    return 'Enter a valid street name';
  }

  if (street.length < 3) {
    return 'Street name is too short';
  }

  return null; // ✅ valid
}
String? zipCodeStrictValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter ZIP code';
  }

  final zip = value.trim();

  if (!RegExp(r'^\d{4,10}$').hasMatch(zip)) {
    return 'Enter a valid ZIP code';
  }

  return null; // ✅ valid
}






// ...existing code...

// ...existing code...