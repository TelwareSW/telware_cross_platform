import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import '../widget/bottom_action_buttons_edit_taken_image.dart';
import '../widget/signature_pen.dart';
import '../widget/story_caption_text_field.dart';

class ShowTakenStoryScreen extends ConsumerStatefulWidget {
  static const String route = '/show-taken-story';
  final File image;

  const ShowTakenStoryScreen({super.key, required this.image});

  @override
  _ShowTakenStoryScreenState createState() => _ShowTakenStoryScreenState();
}

class _ShowTakenStoryScreenState extends ConsumerState<ShowTakenStoryScreen> {
  final GlobalKey _signatureBoundaryKey = GlobalKey();
  File? _imageFile;
  File? _originalImageFile;
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
    _originalImageFile = File(widget.image.path);
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
            toolbarColor: Palette.secondary,
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
    final boundary = _signatureBoundaryKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    return await boundary.toImage(pixelRatio: 3.0);
  }

  Future<File> _saveCombinedImage() async {
    if (_imageFile == null) {
      throw Exception("No image file found.");
    }
    ui.Image combinedImage = await _captureImage();
    ByteData? byteData =
        await combinedImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/combined_image.png');
    await file.writeAsBytes(pngBytes);
    return file;
  }

  void _discardChanges() {
    setState(() {
      _imageFile = _originalImageFile;
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            SignaturePen(
              signatureBoundaryKey: _signatureBoundaryKey,
              imageFile: _imageFile,
              controller: _controller,
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StoryCaptionField(controller: _captionController),
                    BottomActionButtonsEditTakenImage(
                      cropImage: _cropImage,
                      discardChanges: _discardChanges,
                      saveAndPostStory: _saveCombinedImage,
                      captionController: _captionController,
                      ref: ref,
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
