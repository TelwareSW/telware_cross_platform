import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/utils_functions.dart';
import '../../view_model/contact_view_model.dart';

class ShowTakenStoryScreen extends ConsumerStatefulWidget {
  final File image;

  const ShowTakenStoryScreen({super.key, required this.image});

  @override
  _ShowTakenStoryScreenState createState() => _ShowTakenStoryScreenState();
}

class _ShowTakenStoryScreenState extends ConsumerState<ShowTakenStoryScreen> {
  final GlobalKey _signatureBoundaryKey = GlobalKey();
  File? _imageFile;
  File? _originalImageFile; // Store the original image
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.red,
  );
  final TextEditingController _captionController = TextEditingController();

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    final boundary = _signatureBoundaryKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    return await boundary.toImage(pixelRatio: 3.0);
  }

  // Method to save the combined image
  Future<File> _saveCombinedImage() async {
    // Check if _imageFile is null
    if (_imageFile == null) {
      throw Exception("No image file found."); // Or handle as needed
    }

    ui.Image combinedImage = await _captureImage();
    ByteData? byteData =
        await combinedImage.toByteData(format: ui.ImageByteFormat.png);
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Remove focus from the TextField
        },
        child: Stack(
          children: [
            // Background Image
            RepaintBoundary(
              key: _signatureBoundaryKey,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(_imageFile!),
                    fit: BoxFit.cover, // Use cover to ensure it covers the whole container
                  ),
                ),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            // Overlay for TextField and buttons
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
                    // Text Field
                    Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: TextField(
                              controller: _captionController,
                              decoration: InputDecoration(
                                hintText: "Enter story caption",
                                filled: false,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                hintStyle: TextStyle(color: Colors.white54),
                                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Action Buttons
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
                        FocusScope.of(context).unfocus();
                        File combinedImageFile = await _saveCombinedImage();
                        String storyCaption = _captionController.text;
                        final contactViewModel = ref.read(usersViewModelProvider.notifier);
                        bool uploadResult = await contactViewModel.postStory(combinedImageFile, storyCaption);
                        print(uploadResult);
                        final snackBar = SnackBar(
                          content: Text(uploadResult ? 'Story Posted Successfully' : 'Failed to post Story'),
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
      ),
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
