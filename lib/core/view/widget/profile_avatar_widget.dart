import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/user/view/widget/avatar_generator.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final String? imagePath;
  final Uint8List? imageMemory;
  final double imageWidth;
  final double imageHeight;
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final double radius;
  final VoidCallback? onTap;

  const ProfileAvatarWidget({
    super.key,
    required this.text,
    this.imagePath,
    this.imageMemory,
    this.imageWidth = 50,
    this.imageHeight = 50,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.radius = 50,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image.network(
                imagePath!,
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return AvatarGenerator(
                    name: text,
                    backgroundColor: getRandomColor(text),
                    size: imageWidth,
                  );
                },
              ),
            )
          : AvatarGenerator(
              name: text,
              backgroundColor: getRandomColor(text),
              size: imageWidth,
            ),
    );
  }
}