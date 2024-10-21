import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<Uint8List?> downloadImage(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes; // Return image as bytes
    } else {
      if (kDebugMode) {
        print('Failed to download image. Status code: ${response.statusCode}');
      }
      return null;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error downloading image: $e');
    }
    return null;
  }
}