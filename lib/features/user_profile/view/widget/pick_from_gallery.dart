import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
class PickFromGallery extends StatefulWidget {
  const PickFromGallery({super.key});

  @override
  _PickFromGalleryState createState() => _PickFromGalleryState();
}

class _PickFromGalleryState extends State<PickFromGallery> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      if (kDebugMode) {
        print(pickedImage);
      }
      setState(() {
        _image = File(pickedImage.path);
      });
    } else {
      if (kDebugMode) {
        print("No image selected.");
      }
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    String uploadUrl = "http://192.168.1.6:3000/upload";
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
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              await _pickImage();
              if (_image != null) {
                await _uploadImage(_image!);
              }
            },
            child: const Icon(
              Icons.image,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
