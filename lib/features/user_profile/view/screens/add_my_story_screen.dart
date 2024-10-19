import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../widget/choice_mode_in_camera_container.dart';
import '../widget/take_photo_row.dart';

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String _selectedMode = 'Photo';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      print('No cameras available');
      return;
    }
    final camera = cameras.first;
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller?.initialize().then((_) {
      _controller!.startVideoRecording();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
                // Camera preview takes the full screen
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
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Pops the current screen to go back
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
                          TakePhotoRow(selectedMode: _selectedMode),
                          SizedBox(
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
            return Center(child: CircularProgressIndicator());
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
        SizedBox(
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

