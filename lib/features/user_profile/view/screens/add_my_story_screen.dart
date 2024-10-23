import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import '../widget/choice_mode_in_camera_container.dart';
import '../widget/take_photo_row.dart';

class AddMyStoryScreen extends StatefulWidget {
  const AddMyStoryScreen({super.key});

  @override
  _AddMyStoryScreenState createState() => _AddMyStoryScreenState();
}

class _AddMyStoryScreenState extends State<AddMyStoryScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String _selectedMode = 'Photo';
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (kDebugMode) {
        print('No cameras available');
      }
      return;
    }
    _initializeController(cameras[_currentCameraIndex]);
  }

  Future<void> _initializeController(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller?.initialize().then((_) {
      setState(() {});
    });
  }

  void _toggleCamera() async {
    final cameras = await availableCameras();
    if (cameras.length > 1) {
      _currentCameraIndex = (_currentCameraIndex + 1) % cameras.length;
      await _controller?.dispose();
      _initializeController(cameras[_currentCameraIndex]);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _captureImage() async {
    try {
      // Ensure the controller is initialized before capturing an image
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      Uint8List imageBytes = await image.readAsBytes();
      await _uploadImage(imageBytes);
    } catch (e) {
      if (kDebugMode) {
        print('Error capturing image: $e');
      }
    }
  }

  Future<void> _uploadImage(Uint8List imageBytes) async {
    String uploadUrl = "http://192.168.1.6:3000/upload";
    var uri = Uri.parse(uploadUrl);
    var request = http.MultipartRequest('POST', uri);

    // Create a multipart file from the byte data
    var multipartFile = http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: 'image.jpeg', // Optional: Specify a filename
      contentType: MediaType('image', 'jpeg'),
    );

    request.files.add(multipartFile);

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Image uploaded successfully');
        }
      } else {
        if (kDebugMode) {
          print('Server responded with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during upload: $e');
      }
    }
  }


  void _toggleMode(String pressedButton) {
    if (pressedButton != _selectedMode) {
      setState(() {
        _selectedMode = _selectedMode == 'Photo' ? 'Video' : 'Photo';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_controller!),
                ),
                // Transparent AppBar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TakePhotoRow(selectedMode: _selectedMode, onCapture: _captureImage, onToggle:  _toggleCamera,),
                          const SizedBox(
                            height: 25,
                          ),
                          buildCameraModeRow(constraints),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Row buildCameraModeRow(BoxConstraints constraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: constraints.maxWidth / 2 - 28,
        ),
        GestureDetector(
          child: ChoiceModeInCameraContainer(
            text: _selectedMode,
          ),
          onTap: () {
            _toggleMode(_selectedMode);
          },
        ),
        const SizedBox(
          width: 16,
        ),
        GestureDetector(
          child: ChoiceModeInCameraContainer(
            text: _selectedMode == 'Photo' ? 'Video' : 'Photo',
          ),
          onTap: () {
            _toggleMode(_selectedMode == 'Photo' ? 'Video' : 'Photo');
          },
        )
      ],
    );
  }
}

