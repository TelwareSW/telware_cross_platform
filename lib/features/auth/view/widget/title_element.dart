import 'package:flutter/material.dart';

class TitleElement extends StatelessWidget {
  const TitleElement({
    super.key,
    required this.name,
    required this.paddingBottom,
    required this.color,
    required this.fontSize,
    this.fontWeight,
    this.width,
  });

  final String name;
  final double paddingBottom;
  final Color color;
  final double fontSize;
  final FontWeight? fontWeight;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: EdgeInsets.only(bottom: paddingBottom),
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
    return width != null ? SizedBox(width: width, child: child) : child;
  }
}
