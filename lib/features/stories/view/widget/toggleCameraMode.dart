import 'package:flutter/material.dart';

import 'choice_mode_in_camera_container.dart';

class ToggleCameraMode extends StatefulWidget {
  String selectedMode;
  final BoxConstraints constraints; // Added constraints parameter

  ToggleCameraMode({
    super.key,
    required this.selectedMode,
    required this.constraints, // Accept constraints
  });

  @override
  State<ToggleCameraMode> createState() => _ToggleCameraModeState();
}

class _ToggleCameraModeState extends State<ToggleCameraMode> {
  void _toggleMode(String pressedButton) {
    if (pressedButton != widget.selectedMode) {
      setState(() {
        widget.selectedMode = widget.selectedMode == 'Photo' ? 'Video' : 'Photo';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: widget.constraints.maxWidth / 2 - 28, // Calculate width dynamically
        ),
        GestureDetector(
          child: ChoiceModeInCameraContainer(
            text: widget.selectedMode,
          ),
          onTap: () {
          },
        ),
        const SizedBox(width: 16),
        GestureDetector(
          child: ChoiceModeInCameraContainer(
            text: widget.selectedMode == 'Photo' ? 'Video' : 'Photo',
          ),
          onTap: () {
            _toggleMode(widget.selectedMode == 'Photo' ? 'Video' : 'Photo');
          },
        ),
      ],
    );
  }
}