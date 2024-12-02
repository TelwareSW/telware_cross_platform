import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/server_constants.dart';
import 'package:flutter/foundation.dart';

Future<String?> downloadAndSaveFile(String? url) async {
  if (url == null || url.isEmpty) {
    return null;
  }

  // Ensure URL is complete
  if (!url.startsWith('https')) {
    url = '$API_URL_PICTURES/$url';
  }

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Get the bytes from the response
      Uint8List fileBytes = response.bodyBytes;

      // Determine the local path to save the file
      final Directory directory = await getApplicationDocumentsDirectory();
      final String fileName = url.split('/').last; // Extract file name from URL
      final String filePath = '${directory.path}/$fileName';

      // Save the file locally
      File file = File(filePath);
      await file.writeAsBytes(fileBytes);

      debugPrint('File saved at: $filePath');
      return filePath; // Return the saved file path
    } else {
      debugPrint(
          'Failed to download file. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    debugPrint('Error downloading file: $e');
    return null;
  }
}
