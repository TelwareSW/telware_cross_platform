import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

Future<Uint8List?> downloadImage(String? url) async {
  if (url == null) {
    return null;
  }
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

Future<bool> uploadImage(File imageFile) async {
  String uploadUrl = "http://192.168.1.2:3000/upload";
  var uri = Uri.parse(uploadUrl);
  var request = http.MultipartRequest('POST', uri);
  var multipartFile = await http.MultipartFile.fromPath(
    'image',
    imageFile.path,
    contentType: MediaType('image', 'jpeg'),
  );
  request.files.add(multipartFile);
  try {
    await request.send();
    return true;
  } catch (e) {
    if (kDebugMode) {
      print('Error occurred: $e');
    }
    return false;
  }
}