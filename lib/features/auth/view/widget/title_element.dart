import 'package:flutter/material.dart';

class TitleElement extends StatelessWidget {
  const TitleElement({
    super.key,
    required this.name,
    this.padding = const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
    required this.color,
    required this.fontSize,
    this.fontWeight,
    this.width,
    this.textAlign = TextAlign.center,
  });

  final String name;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double fontSize;
  final FontWeight? fontWeight;
  final double? width;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: padding,
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
        ),
        textAlign: textAlign,
      ),
    );
    return SizedBox(width: width, child: child);
  }
}
