import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';

class CaptionScreen extends ConsumerStatefulWidget {
  static const String route = '/caption-screen';
  final String filePath;
  final void Function({required String caption, required String filePath})
      sendCaptionMedia;

  const CaptionScreen({
    super.key,
    required this.filePath,
    required this.sendCaptionMedia,
  });

  @override
  ConsumerState<CaptionScreen> createState() => _CaptionScreenState();
}

class _CaptionScreenState extends ConsumerState<CaptionScreen> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set device orientation to portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  final boxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    gradient: LinearGradient(
      colors: [
        Color.lerp(
                const Color.fromRGBO(112, 109, 109, 1.0), Colors.black, 0.3) ??
            Colors.black,
        const Color.fromRGBO(112, 109, 109, 1.0),
        Color.lerp(
                const Color.fromRGBO(112, 109, 109, 1.0), Colors.black, 0.3) ??
            Colors.black,
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            left: 0,
            child: _buildImagePreview(),
          ),

          // Caption input field and send button fixed at the bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: boxDecoration,
                  child: SizedBox(
                    height: 40, // Set your desired height here
                    child: TextField(
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.center,
                      controller: _captionController,
                      decoration: const InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: TextStyle(color: Colors.white, fontSize: 13),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                      ),
                      cursorColor: Colors.white,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: IconButton(
                      key: GlobalKeyCategoryManager.addKey(
                          'sendMediaWithCaption'),
                      onPressed: _sendCaption,
                      color: Colors.white,
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Image.file(
      File(widget.filePath),
      fit: BoxFit.cover, // This will make the image cover the entire space
      width: double.infinity,
      height: double.infinity,
    );
  }

  void _sendCaption() {
    String caption = _captionController.text.trim();
    widget.sendCaptionMedia(
      caption: caption,
      filePath: widget.filePath,
    );
    context.pop();
  }
}
