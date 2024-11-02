// common utility functions are added here
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/classes/telware_toast.dart';

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

// Password validator to ensure at least 8 characters and contains both letters and digits
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  } else if (value.length < 8) {
    return 'Password must be at least 8 characters long';
  } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d._@&-]{8,}$')
      .hasMatch(value)) {
    return 'Must contain letters and digits and can contain . _ @ & -';
  }
  return null;
}

// todo(ahmed): update this function to handle more cases
String? confirmPasswordValidation(String? password, String? confirmedPassword) {
  if (password!.isEmpty || confirmedPassword!.isEmpty) return null;
  if (password != confirmedPassword) return 'Passwords do not match.';
  return null;
}

bool isKeyboardOpen(BuildContext context) {
  return MediaQuery.of(context).viewInsets.bottom != 0;
}

void showSnackBarMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Center(
          child: Text(message),
        ),
      ),
    );
}

void showToastMessage(String message) async {
  await TelwareToast.cancel();
  TelwareToast.showToast(msg: message);
}

String formatPhoneNumber(String phoneNumber) {
  // remove all spaces
  phoneNumber = phoneNumber.replaceAll(" ", "");

  if (!phoneNumber.startsWith("+20")) {
    phoneNumber = "+20${phoneNumber.substring(1)}";
  }
  if (phoneNumber.length == 13) {
    return "${phoneNumber.substring(0, 3)} " // +20
        "${phoneNumber.substring(3, 6)} " // 109
        "${phoneNumber.substring(6)}"; // 3401932
  }
  return phoneNumber; // Return the original if it doesn't match the format.
}

// Helper function to generate random pastel-like colors
Color getRandomColor() {
  final Random random = Random();
  return Color.fromARGB(
    255,
    50 + random.nextInt(100), // Red (200-255)
    50 + random.nextInt(100), // Green (200-255)
    50 + random.nextInt(100), // Blue (200-255)
  );
}

String toKebabCase(String input) {
  // Convert to lowercase and replace spaces with hyphens
  String kebabCased = input.toLowerCase().replaceAll(RegExp(r'[\s]+'), '-');

  // Replace any non-alphanumeric characters with hyphens
  kebabCased = kebabCased.replaceAll(RegExp(r'[^a-z0-9-]+'), '-');

  // Remove leading or trailing hyphens
  return kebabCased.replaceAll(RegExp(r'^-+|-+$'), '');
}

String getInitials(String name) {
  if (name.isEmpty) {
    return "NN";
  }
  List<String> nameParts = name.split(' ');
  String initials = "";
  if (nameParts.isNotEmpty) {
    initials = nameParts[0][0];
    if (nameParts.length > 1) {
      initials += nameParts[1][0];
    }
  }
  return initials.toUpperCase();
}

String capitalizeEachWord(String sentence) {
  if (sentence.isEmpty) return sentence;

  return sentence
      .split(' ')
      .map((word) => word.isNotEmpty
      ? word[0].toUpperCase() + word.substring(1).toLowerCase()
      : word)
      .join(' ');
}