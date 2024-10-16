import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class InfoTextWidget extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final String subText;
  final double subFontSize;
  final Color subColor;

  const InfoTextWidget({
    super.key,
    required this.text,
    required this.subText,
    this.fontSize = 16,
    this.subFontSize = 12,
    this.color = Palette.primaryText,
    this.subColor = Palette.accentText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          text,
          style: TextStyle(fontSize: fontSize, color: color),
        ),
        const SizedBox(height: 10),
        Text(
          subText,
          style: TextStyle(fontSize: subFontSize, color: subColor),
        ),
      ]
    );
  }
}