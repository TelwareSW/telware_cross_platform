import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TakePhotoRow extends StatelessWidget {
  const TakePhotoRow({
    super.key,
    required String selectedMode,
  }) : _selectedMode = selectedMode;

  final String _selectedMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: ClipOval(
            child: Container(
              color: Colors.grey.shade900.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: PickFromGallery(),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            print('Button Pressed');
          },
          child: Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4.0),
            ),
            child: Center(
              child: Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  color: _selectedMode == 'Photo' ? Colors.white : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 40.0),
          child: GestureDetector(
            onTap: (){

            },
            child: ClipOval(
                child: Container(
                    color: Colors.grey.shade900.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.cached,
                        size: 35,
                      ),
                    ))),
          ),
        ),
      ],
    );
  }
}

class PickFromGallery extends StatefulWidget {
  const PickFromGallery({super.key});

  @override
  _PickFromGalleryState createState() => _PickFromGalleryState();
}

class _PickFromGalleryState extends State<PickFromGallery> {
  File? _image; // To store the selected image
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path); // Save the selected image
      });
    } else {
      print("No image selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Icon(
              Icons.image,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
