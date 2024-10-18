import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';

class AuthSubTextButton extends StatelessWidget {
  const AuthSubTextButton({
    super.key, required this.onPressed, required this.label,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: TitleElement(
        name: label,
        color: Palette.accent,
        fontSize: Sizes.infoText,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
