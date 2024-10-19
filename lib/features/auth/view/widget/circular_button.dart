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
    this.formKey,
    this.handelClick,
  });

  final IconData icon;
  final double iconSize;
  final double paddingTop;
  final double paddingBottom;
  final double paddingLeft;
  final double paddingRight;
  final double radius;
  final GlobalKey<FormState>? formKey;
  final Function? handelClick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: paddingRight, top: paddingTop),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ElevatedButton(
          onPressed: () {
            if (formKey != null) {
              if (!(formKey!.currentState?.validate() ?? false)) {
                // handle the case when the form is invalid
                debugPrint('Form is invalid!');
                return;
              }
            }
            // As a general widget if we passed a handelClick function
            // we will call it only if no formKey is passed or
            // when a formKey is passed and the form is valid
            handelClick != null ? handelClick!() : null;
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
