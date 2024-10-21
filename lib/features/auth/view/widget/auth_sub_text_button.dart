import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';

class AuthSubTextButton extends StatelessWidget {
  const AuthSubTextButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.padding = const EdgeInsets.all(0),
    this.fontSize = Sizes.infoText,
    this.buttonKey,
  });

  final VoidCallback onPressed;
  final GlobalKey<State>? buttonKey;
  final String label;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: buttonKey,
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: TitleElement(
        name: label,
        color: Palette.accent,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        padding: padding,
      ),
    );
  }
}
