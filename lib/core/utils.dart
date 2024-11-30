// common utility functions are added here
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/classes/telware_toast.dart';
import 'package:intl/intl.dart';

import 'models/message_model.dart';

String? emailValidator(String? value) {
  const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  final RegExp regex = RegExp(emailPattern);

  if (value == null || value.isEmpty) {
    return null;
  } else if (value.length > 254) {
    return 'Email can\'t be longer than 254 characters';
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
  } else if (value.length > 128) {
    return 'Password can\'t be longer than 128 characters';
  }
  return null;
}

// todo(ahmed): update this function to handle more cases
String? confirmPasswordValidation(String? password, String? confirmedPassword) {
  if (password == null || confirmedPassword == null) return null;
  if (password.isEmpty || confirmedPassword.isEmpty) return null;
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
  // assume if no code is provided, it's an Egyptian number
  // remove all spaces
  phoneNumber = phoneNumber.replaceAll(" ", "");

  if (phoneNumber.length < 8) {
    return phoneNumber;
  }

  if (!phoneNumber.startsWith("+")) {
    phoneNumber = "+20${phoneNumber.substring(1)}";
  }

  if (phoneNumber.length > 15) {
    return phoneNumber;
  }

  if (phoneNumber.length <= 13) {
    return "${phoneNumber.substring(0, 3)} " // +20
        "${phoneNumber.substring(3, 6)} " // 109
        "${phoneNumber.substring(6)}"; // 3401932
  } else {
    return "${phoneNumber.substring(0, 4)} " // +966
        "${phoneNumber.substring(4, 7)} " // 109
        "${phoneNumber.substring(7)}"; // 3401932
  }
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

String getInitials(String? name) {
  if (name == null || name.isEmpty) return 'NN';
  List<String> nameParts = name.trim().split(' ');
  String initials = nameParts
      .map((part) {
        String cleanedPart =
            part.replaceAll(RegExp(r'[^a-zA-Z\u0600-\u06FF]'), '');
        return cleanedPart.isNotEmpty ? cleanedPart[0] : '';
      })
      .take(2)
      .join();
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

String formatTime(int seconds,
    {bool singleDigit = false, bool showHours = false}) {
  // if singleDigit is true, the function will return the time in the format "H" or "M" or "S"
  // if showHours is true, the function will return hours if the time is more than an hour
  if (singleDigit) {
    return (showHours && seconds >= 3600)
        ? '${seconds ~/ (3600)} hours'
        : (seconds >= 60)
            ? '${(seconds ~/ 60)} minutes'
            : '$seconds seconds';
  }
  final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
  if (showHours) {
    seconds %= 3600; // get the remaining seconds after calculating hours
  }
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final secs = (seconds % 60).toString().padLeft(2, '0');
  return showHours ? '$hours:$minutes:$secs' : '$minutes:$secs';
}

String formatTimestamp(DateTime timestamp) {
  // Current date to check for today's or yesterday's date
  final now = DateTime.now();
  final diff = now.difference(timestamp).inDays;

  // If the message is today
  if (diff == 0) {
    return DateFormat('hh:mm a').format(timestamp); // 12:53 AM
  }

  // If the message is within the last 7 days, show the weekday (Mon, Tue, etc.)
  if (diff <= 7) {
    return DateFormat('E').format(timestamp); // Mon, Tue, etc.
  }

  // If the message is older than 7 days, show the full date
  if (diff <= 365) {
    return DateFormat('MMM dd').format(timestamp); // Nov 03
  }

  // For another format like "30.09.21", use 'dd.MM.yy'
  return DateFormat('dd.MM.yy').format(timestamp);
}

IconData getMessageStateIcon(MessageModel message) {
  if (message.isReadByAll()) {
    return Icons.done_all;
  }
  return Icons.check;
}