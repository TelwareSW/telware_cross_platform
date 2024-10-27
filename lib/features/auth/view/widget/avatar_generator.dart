import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';

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
        _getInitials(name),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Extract the initials from the given name
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '';
    List<String> nameParts = name.trim().split(' ');
    String initials = nameParts
        .map((part) {
          String cleanedPart =
              part.replaceAll(RegExp(r'[^a-zA-Z\u0600-\u06FF]'), '');
          return cleanedPart.isNotEmpty ? cleanedPart[0] : '';
        })
        .take(2)
        .join();
    return initials.toUpperCase();
  }
}
