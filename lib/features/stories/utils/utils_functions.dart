import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';

Future<Uint8List?> downloadImage(String? url) async {
  if (url == null || url.isEmpty) {
    return null;
  }
  if (!url.startsWith('https')) {
    url='$API_URL_PICTURES/$url';
  }
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes; // Return image as bytes
    } else {
      if (kDebugMode) {
        debugPrint(
            'Failed to download image. Status code: ${response.statusCode}');
      }
      return null;
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Error downloading image: $e');
    }
    return null;
  }
}

Future<bool> uploadImage(File imageFile, String uploadUrl) async {
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
      debugPrint('Error occurred: $e');
    }
    return false;
  }
}


Future<bool> uploadChatImage(File imageFile, String uploadUrl, String sessionToken) async {
  var uri = Uri.parse(uploadUrl);
  var request = http.MultipartRequest('PATCH', uri)
    ..headers['X-Session-Token'] = sessionToken;
  var multipartFile = await http.MultipartFile.fromPath(
    'file',
    imageFile.path,
    contentType: MediaType('image', 'jpeg'),
  );
  request.files.add(multipartFile);

  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print(response.body);
    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint('Failed to upload image: ${response.statusCode}, ${response.body}');
      return false;
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Error occurred: $e');
    }
    return false;
  }
}