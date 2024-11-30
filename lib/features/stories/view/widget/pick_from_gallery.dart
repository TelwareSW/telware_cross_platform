import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telware_cross_platform/features/stories/view/screens/show_taken_image_screen.dart';

class PickFromGallery extends StatefulWidget {
  final String destination;
  const PickFromGallery({super.key, required this.destination});

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
        debugPrint("No image selected.");
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ShowTakenImageScreen(
                      destination: widget.destination,
                      image: _image!,
                    ),
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
