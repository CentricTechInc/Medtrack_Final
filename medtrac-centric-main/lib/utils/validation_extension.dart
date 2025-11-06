extension StringValidators on String {
  // Check if the field is empty and return an error message
  String? validateNotEmpty(
      {String errorMessage = "This field cannot be empty"}) {
    return trim().isEmpty ? errorMessage : null;
  }

  // Check if the string is a valid email
  String? validateEmail({String errorMessage = "Please enter a valid email"}) {
    return RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
            .hasMatch(this)
        ? null
        : errorMessage;
  }

  // Check if the string is a strong password
  String? validateStrongPassword() {
    if (length < 8) {
      return "Password must be at least 8 characters long";
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(this)) {
      return "Password must contain at least one lowercase letter";
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(this)) {
      return "Password must contain at least one uppercase letter";
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(this)) {
      return "Password must contain at least one number";
    }
    return null;
  }

  // Check if the string is a valid phone number
  String? validatePhoneNumber(
      {String errorMessage = "Please enter a valid phone number"}) {
    return RegExp(r"^(?:[+0]9)?[0-9]{10}$").hasMatch(this)
        ? null
        : errorMessage;
  }

  // Check if the string has a minimum length
  String? validateMinLength(int minLength, {String? errorMessage}) {
    return length >= minLength
        ? null
        : (errorMessage ?? "Minimum $minLength characters required");
  }

  // Check if the string matches an exact length
  String? validateExactLength(int exactLength, {String? errorMessage}) {
    return length == exactLength
        ? null
        : (errorMessage ?? "Must be exactly $exactLength characters long");
  }

  // Check if the string matches another string (for password confirmation)
  String? validateMatch(String other,
      {String errorMessage = "Entries do not match"}) {
    return this == other ? null : errorMessage;
  }

  // Check if the string contains no spaces
  String? validateNoSpaces({String errorMessage = "Spaces are not allowed"}) {
    return contains(' ') ? errorMessage : null;
  }

  // Check if the string contains at least one special character
  String? validateHasSpecialChar(
      {String errorMessage = "Must contain at least one special character"}) {
    return RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(this)
        ? null
        : errorMessage;
  }

  // Validate username (alphanumeric with underscores, 3-20 characters)
  String? validateUsername(
      {String errorMessage =
          "Username must be 3-20 characters with only letters, numbers, and underscores"}) {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(this) ? null : errorMessage;
  }

  // Check if the string is valid OTP (digits only, default 4-6 digits)
  String? validateOTP({int min = 4, int max = 6, String? errorMessage}) {
    if (RegExp(r'^\d+$').hasMatch(this) && length >= min && length <= max) {
      return null;
    }
    return errorMessage ?? "Please enter a valid $min-$max digit code";
  }

  // Extension getter to check if string is a valid email
  bool get isValidEmail =>
      RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(this);

  // Extension getter to check if string is a valid password
  bool get isValidPassword =>
      length >= 8 &&
      RegExp(r'(?=.*[a-z])').hasMatch(this) &&
      RegExp(r'(?=.*[A-Z])').hasMatch(this) &&
      RegExp(r'(?=.*\d)').hasMatch(this);

  // Extension getter to check if string is a valid username
  bool get isValidUsername => RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(this);
}
