import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../screens/show_taken_story_screen.dart';


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
      setState(() {
        _image = File(pickedImage.path);
      });

    } else {
      if (kDebugMode) {
        print("No image selected.");
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowTakenStoryScreen(image: _image!),
                  ),
                );
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