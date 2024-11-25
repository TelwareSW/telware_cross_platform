import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class CropImageScreen extends StatefulWidget {
  final String path;

  const CropImageScreen({
    Key? key,
    required this.path,
  }) : super(key: key);

  @override
  _CropImageScreenState createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  late CustomImageCropController controller;
  Color backGroundColor = Palette.secondary;
  CustomCropShape _currentShape = CustomCropShape.Circle;
  CustomImageFit _imageFit = CustomImageFit.fillCropSpace;
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();

  double _width = 16;
  double _height = 9;
  double _radius = 4;

  @override
  void initState() {
    super.initState();
    controller = CustomImageCropController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialRatio();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _setInitialRatio() {
    final size = MediaQuery.of(context).size;
    setState(() {
      _width = min(size.width, size.height);
      _height = max(size.width, size.height);
    });
  }

  void _changeCropShape(CustomCropShape newShape) {
    setState(() {
      _currentShape = newShape;
      if (newShape == CustomCropShape.Ratio) {
        _setInitialRatio();
      }
    });
  }

  void _updateRatio() {
    setState(() {
      if (_widthController.text.isNotEmpty) {
        _width = double.tryParse(_widthController.text) ?? 16;
      }
      if (_heightController.text.isNotEmpty) {
        _height = double.tryParse(_heightController.text) ?? 9;
      }
      if (_radiusController.text.isNotEmpty) {
        _radius = double.tryParse(_radiusController.text) ?? 4;
      }
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Cropping'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomImageCrop(
              backgroundColor: getRandomColor(),
              cropController: controller,
              image: FileImage(File(widget.path)),
              shape: _currentShape,
              ratio: _currentShape == CustomCropShape.Ratio
                  ? Ratio(width: _width, height: _height)
                  : null,
              canRotate: true,
              canMove: true,
              canScale: true,
              borderRadius:
                  _currentShape == CustomCropShape.Ratio ? _radius : 0,
              customProgressIndicator: const CircularProgressIndicator(),
              imageFit: _imageFit,
              pathPaint: Paint()
                ..color = Colors.red
                ..strokeWidth = 4.0
                ..style = PaintingStyle.stroke
                ..strokeJoin = StrokeJoin.round,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  icon: const Icon(Icons.refresh), onPressed: controller.reset),
              IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: () =>
                      controller.addTransition(CropImageData(scale: 1.33))),
              IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: () =>
                      controller.addTransition(CropImageData(scale: 0.75))),
              IconButton(
                  icon: const Icon(Icons.rotate_left),
                  onPressed: () =>
                      controller.addTransition(CropImageData(angle: -pi / 4))),
              IconButton(
                  icon: const Icon(Icons.rotate_right),
                  onPressed: () =>
                      controller.addTransition(CropImageData(angle: pi / 4))),
              PopupMenuButton(
                icon: const Icon(Icons.crop_original),
                onSelected: _changeCropShape,
                itemBuilder: (BuildContext context) {
                  return CustomCropShape.values.map(
                    (shape) {
                      return PopupMenuItem(
                        value: shape,
                        child: getShapeIcon(shape),
                      );
                    },
                  ).toList();
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.color_lens_sharp,
                ),
                onPressed: () async {
                  setState(() {
                    backGroundColor = getRandomColor();
                  });
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.crop,
                  color: Colors.green,
                ),
                onPressed: () async {
                  final croppedFile = await controller.onCropImage();
                  Directory root = await getTemporaryDirectory();
                  String directoryPath = '${root.path}/appName';
                  await Directory(directoryPath).create(recursive: true);

                  // Create a dynamic file name using a timestamp
                  String fileName =
                      'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
                  String filePath = '$directoryPath/$fileName';

                  // Write the file
                  final file =
                      await File(filePath).writeAsBytes(croppedFile!.bytes);

                  // Optional: Clean up old files to save space
                  final directory = Directory(directoryPath);
                  final List<FileSystemEntity> files = directory.listSync();
                  for (var fileEntity in files) {
                    if (fileEntity is File) {
                      final stat = await fileEntity.stat();
                      final lastModified = stat.modified;
                      final expirationDate =
                          DateTime.now().subtract(Duration(days: 7));
                      if (lastModified.isBefore(expirationDate)) {
                        await fileEntity.delete();
                      }
                    }
                  }
                  Navigator.pop(context, file);
                },
              ),
            ],
          ),
          if (_currentShape == CustomCropShape.Ratio) ...[
            SizedBox(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _widthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Width'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Height'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      controller: _radiusController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Radius'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _updateRatio,
                    child: const Text('Update Ratio'),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget getShapeIcon(CustomCropShape shape) {
    switch (shape) {
      case CustomCropShape.Circle:
        return const Icon(Icons.circle_outlined);
      case CustomCropShape.Square:
        return const Icon(Icons.square_outlined);
      case CustomCropShape.Ratio:
        return const Icon(Icons.crop_16_9_outlined);
    }
  }
}

Color getRandomColor() {
  final random = Random();
  return Color.fromRGBO(
    random.nextInt(256), // Red
    random.nextInt(256), // Green
    random.nextInt(256), // Blue
    1.0, // Opacity
  );
}
