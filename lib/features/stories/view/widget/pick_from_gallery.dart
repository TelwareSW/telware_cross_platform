import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:telware_cross_platform/core/routes/routes.dart';

class PickFromGallery extends StatefulWidget {
  const PickFromGallery({super.key});

  @override
  State<PickFromGallery> createState() => _PickFromGalleryState();
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
                context.push(Routes.showTakenStory, extra: _image!);
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