/*String? validateEmail(String value) {
  if (value.isEmpty) {
    return 'Email is required';
  } else if (!value.contains('@')) {
    return 'Invalid email';
  }
  return null;
}*/

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  // Use regex for email validation
  if (!RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}

String? validateText(String? value, String message) {
  if (value == null || value.isEmpty) {
    return message;
  }
  /* // Use regex for email validation
  if (value.length < 3 || value.length > 10) {
    return 'Text length must be between 3 and 10 characters';
  }*/
  return null;
}

// Common function for password validation
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  // Check if the password length is at least 6 characters
  if (value.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  // You can add additional password complexity rules here
  return null;
}

// Common function for password validation
String? validateConfirmPassword(String? password, String? confirmPassword) {
  if (confirmPassword == null || confirmPassword.isEmpty) {
    return 'Please confirm your password';
  }
  if (password != confirmPassword) {
    return 'Passwords do not match';
  }
  return null;
}

// Common function for password validation
String validateIndiaPhoneNumber(String value) {
  if (value.isEmpty) {
    return 'Please enter a phone number';
  }
  // Regular expression to validate phone number
  String pattern = r'^(?:[+0]9)?[0-9]{10}$';
  RegExp regExp = RegExp(pattern);
  if (!regExp.hasMatch(value)) {
    return 'Please enter a valid phone number';
  }
  return '';
}

String validatePhoneNumber(String phoneNumber) {
  // Define the minimum and maximum length for a valid phone number
  const int minDigits = 7; // Minimum number of digits
  const int maxDigits = 15; // Maximum number of digits

  // Remove non-numeric characters from the phone number
  String numericPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

  // Check if the length falls within the valid range
  int phoneNumberLength = numericPhoneNumber.length;
  if (phoneNumberLength < minDigits) {
    return 'Phone number is too short';
  } else if (phoneNumberLength > maxDigits) {
    return 'Phone number is too long';
  }

  // The phone number is considered valid
  return '';
}

