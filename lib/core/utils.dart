// common utility functions are added here

String? emailValidator(String? value) {
  const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  final RegExp regex = RegExp(emailPattern);

  if (value == null || value.isEmpty) {
    return null;
  } else if (!regex.hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? confirmPasswordValidation(String? password, String? confirmedPassword) {
  if (password!.isEmpty || confirmedPassword!.isEmpty) return null;
  if (password != confirmedPassword) return 'Passwords do not match.';
  return null;
}
