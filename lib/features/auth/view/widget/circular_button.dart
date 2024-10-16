import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class CircularButton extends StatelessWidget {
  const CircularButton({
    super.key,
    required this.icon,
    required this.iconSize,
    this.paddingTop = 0,
    this.paddingBottom = 0,
    this.paddingLeft = 0,
    this.paddingRight = 0,
    required this.radius,
  });

  final IconData icon;
  final double iconSize;
  final double paddingTop;
  final double paddingBottom;
  final double paddingLeft;
  final double paddingRight;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: paddingRight, top: paddingTop),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ElevatedButton(
          onPressed: () {
            // Button action
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.all(radius),
            backgroundColor: Palette.primary, // Button color
          ),
          child: Icon(
            icon,
            color: Palette.icons,
            size: iconSize, // Icon size
          ),
        )
      ]),
    );
  }
}
