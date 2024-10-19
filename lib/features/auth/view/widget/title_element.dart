import 'package:flutter/material.dart';

class TitleElement extends StatelessWidget {
  const TitleElement({
    super.key,
    required this.name,
    this.padding = const EdgeInsets.all(0),
    required this.color,
    required this.fontSize,
    this.fontWeight,
    this.width,
  });

  final String name;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double fontSize;
  final FontWeight? fontWeight;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: padding,
      child: Center(
        child: Text(
          name,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight ?? FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
    return SizedBox(width: width, child: child);
  }
}
