import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class SectionTitleWidget extends StatelessWidget {
  final String title;
  final double fontSize;

  const SectionTitleWidget({
    super.key,
    required this.title,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
            title,
            key: key,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Palette.primary,
            )
        )
      )
    );
  }
}