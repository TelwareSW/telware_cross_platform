import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/utils.dart';

class AvatarGenerator extends StatelessWidget {
  final String? name;
  final Color backgroundColor;
  final double size;

  const AvatarGenerator({
    super.key,
    this.name,
    required this.backgroundColor,
    this.size = 100.0, // Default size of the avatar
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: LinearGradient(
          colors: [
            Color.lerp(backgroundColor, Colors.white, 0.3) ?? Colors.black,
            backgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        getInitials(name),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
