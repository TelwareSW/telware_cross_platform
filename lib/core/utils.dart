// common utility functions are added here
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:telware_cross_platform/core/classes/telware_toast.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

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

void showSnackBarMessage(BuildContext context, String message,
    {SnackBarAction? action}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Center(
          child: Text(message),
        ),
        action: action,
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
final Map<String, Color> _colorCache = {};
Color getRandomColor([String? key]) {
  // Check color cache for a color with the same key
  if (_colorCache.containsKey(key)) {
    return _colorCache[key]!;
  }

  final Random random = Random();
  final randomColor = Color.fromARGB(
    255,
    50 + random.nextInt(100), // Red (200-255)
    50 + random.nextInt(100), // Green (200-255)
    50 + random.nextInt(100), // Blue (200-255)
  );

  // Add the color to the cache
  if (key != null) _colorCache[key] = randomColor;
  return randomColor;
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
  if (message.id == null) {
    return Icons.access_time;
  }
  if (message.isReadByAll()) {
    return Icons.done_all;
  }
  return Icons.check;
}

List<double> generateDummyWaveform(int length) {
  return List<double>.generate(length, (i) {
    double randomValue =
        (Random().nextDouble() * 2 - 1); // Random value between -1 and 1
    return randomValue * 0.5; // Scale the random value
  });
}

Future<XFile> loadAssetAsXFile(String assetPath, String filename) async {
  // Load the asset as ByteData
  ByteData data = await rootBundle.load(assetPath);

  // Get the system's temporary directory
  Directory tempDir = await getTemporaryDirectory();

  // Create a temporary file
  File tempFile = File('${tempDir.path}/$filename');

  // Write the asset data to the file
  await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

  // Return the temporary file as an XFile
  return XFile(tempFile.path);
}

List<MapEntry<int, int>> kmp(String text, String pattern) {
  debugPrint(text);
  debugPrint(pattern);
  final int n = text.length;
  final int m = pattern.length;
  if (m == 0) return const [];
  List<int> lps = _computeLPSArray(pattern.toLowerCase());
  int i = 0; // index for text[]
  int j = 0; // index for pattern[]
  List<MapEntry<int, int>> matches = [];

  while (i < n) {
    if (text[i].toLowerCase() == pattern[j].toLowerCase()) {
      i++;
      j++;
    } else if (j == 0) {
      i++;
    } else {
      j = lps[j - 1];
    }
    if (j == m) {
      debugPrint("YES ${MapEntry(i - m, m)}");
      matches.add(MapEntry(i - m, m));
      j = lps[j - 1];
    }
  }
  debugPrint(matches.toString());
  return matches;
}

List<int> _computeLPSArray(String pattern) {
  final int m = pattern.length;
  int len = 0; // length of the previous longest prefix suffix
  int i = 1; // the loop variable
  List<int> lps = List.filled(m, 0);

  while (i < m) {
    if (pattern[i] == pattern[len]) {
      lps[i] = ++len;
      i++;
    } else if (len != 0) {
      len = lps[len - 1];
    } else {
      lps[i] = 0;
      i++;
    }
  }

  return lps;
}

String getRandomImagePath() {
  final Random random = Random();
  final List<String> paths = [
    'assets/imgs/marwan.jpg',
    'assets/imgs/ahmed.jpeg',
    'assets/imgs/bishoy.jpeg'
  ];
  return paths[random.nextInt(3)];
}

void vibrate() {
  Vibration.hasVibrator().then((hasVibrator) {
    if (hasVibrator ?? false) {
      Vibration.vibrate(duration: 50);
    }
  });
}

String getRandomLottieAnimation() {
  // List of Lottie animation paths
  List<String> lottieAnimations = [
    'assets/tgs/curious_pigeon.tgs',
    'assets/tgs/fruity_king.tgs',
    'assets/tgs/graceful_elmo.tgs',
    'assets/tgs/hello_anteater.tgs',
    'assets/tgs/hello_astronaut.tgs',
    'assets/tgs/hello_badger.tgs',
    'assets/tgs/hello_bee.tgs',
    'assets/tgs/hello_cat.tgs',
    'assets/tgs/hello_clouds.tgs',
    'assets/tgs/hello_duck.tgs',
    'assets/tgs/hello_elmo.tgs',
    'assets/tgs/hello_fish.tgs',
    'assets/tgs/hello_flower.tgs',
    'assets/tgs/hello_food.tgs',
    'assets/tgs/hello_fridge.tgs',
    'assets/tgs/hello_ghoul.tgs',
    'assets/tgs/hello_king.tgs',
    'assets/tgs/hello_lama.tgs',
    'assets/tgs/hello_monkey.tgs',
    'assets/tgs/hello_pigeon.tgs',
    'assets/tgs/hello_possum.tgs',
    'assets/tgs/hello_rat.tgs',
    'assets/tgs/hello_seal.tgs',
    'assets/tgs/hello_shawn_sheep.tgs',
    'assets/tgs/hello_snail_rabbit.tgs',
    'assets/tgs/hello_virus.tgs',
    'assets/tgs/hello_water_animal.tgs',
    'assets/tgs/hello_whales.tgs',
    'assets/tgs/muscles_wizard.tgs',
    'assets/tgs/plague_doctor.tgs',
    'assets/tgs/screaming_elmo.tgs',
    'assets/tgs/shy_elmo.tgs',
    'assets/tgs/sick_wizard.tgs',
    'assets/tgs/snowman.tgs',
    'assets/tgs/spinny_jelly.tgs',
    'assets/tgs/sus_moon.tgs',
    'assets/tgs/toiletpaper.tgs',
  ];

  // Generate a random index
  Random random = Random();
  int randomIndex =
  random.nextInt(lottieAnimations.length); // Gets a random index

  // Return the randomly chosen Lottie animation path
  return lottieAnimations[randomIndex];
}
