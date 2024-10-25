import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/utils_functions.dart';

class ShowTakenStoryScreen extends StatefulWidget {
  final File image;

  const ShowTakenStoryScreen({super.key, required this.image});

  @override
  _ShowTakenStoryScreenState createState() => _ShowTakenStoryScreenState();
}

class _ShowTakenStoryScreenState extends State<ShowTakenStoryScreen> {
  final GlobalKey _signatureBoundaryKey  = GlobalKey();
  File? _imageFile;
  File? _originalImageFile; // Store the original image
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.red,
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _imageFile = widget.image;
    _originalImageFile = File(widget.image.path); // Save the original image
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _cropImage() async {
    try {
      if (_imageFile == null || !await _imageFile!.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image file not found.')),
        );
        return;
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPresetCustom(),
            ],
          ),
          WebUiSettings(context: context),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to crop image: $e')),
      );
    }
  }

  Future<ui.Image> _captureImage() async {
    // Find the RenderRepaintBoundary in the context
    final boundary = _signatureBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    return await boundary.toImage(pixelRatio: 3.0);
  }

  // Method to save the combined image
  Future<File> _saveCombinedImage() async {
    // Check if _imageFile is null
    if (_imageFile == null) {
      throw Exception("No image file found."); // Or handle as needed
    }

    ui.Image combinedImage = await _captureImage();
    ByteData? byteData = await combinedImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Get the temporary directory
    final directory = await getTemporaryDirectory();
    // Create a file to save the image
    final file = File('${directory.path}/combined_image.png');
    // Write the bytes to the file
    await file.writeAsBytes(pngBytes);

    return file; // Return the saved file
  }


  void _clearDrawing() {
    _controller.clear();
  }

  // Reset the image to the original image file
  void _discardChanges() {
    setState(() {
      _imageFile = _originalImageFile; // Revert to original image
    });
    _clearDrawing(); // Clear any drawings as well
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Pop the screen
          },
        ),
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _signatureBoundaryKey,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(_imageFile!),
                  fit: BoxFit.contain,
                ),
              ),
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Wrap(
                spacing: 10.0,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _cropImage,
                    icon: const Icon(Icons.crop),
                    label: const Text("Crop"),
                  ),
                  ElevatedButton.icon(
                    onPressed: _discardChanges,
                    icon: const Icon(Icons.clear),
                    label: const Text("Discard"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      File combinedImageFile = await _saveCombinedImage();
                      bool uploadResult = await uploadImage(combinedImageFile);
                      final snackBar = SnackBar(
                        content: Text(uploadResult
                            ? 'Story Posted Successfully'
                            : 'Failed to post Story'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      if (uploadResult) {
                        Future.delayed(const Duration(seconds: 2), () {
                          Navigator.of(context).pop();
                        });
                      }
                    },
                    icon: const Icon(Icons.send),
                    label: const Text("Post"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
