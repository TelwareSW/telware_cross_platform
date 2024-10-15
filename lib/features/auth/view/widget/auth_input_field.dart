import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.name,
    this.paddingTop = 0,
    this.paddingBottom = 0,
    this.paddingLeft = 0,
    this.paddingRight = 0,
    required this.isFocused,
    required this.focusNode,
  });

  final String name;
  final double paddingTop;
  final double paddingBottom;
  final double paddingLeft;
  final double paddingRight;
  final bool isFocused;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
            bottom: paddingBottom,
            left: paddingLeft,
            right: paddingRight,
            top: paddingTop),
        child: TextFormField(
          focusNode: focusNode,
          cursorColor: Palette.accent,
          decoration: InputDecoration(
              hintText: isFocused ? '' : name,
              labelText: !isFocused ? '' : name,
              hintStyle: const TextStyle(
                  color: Palette.accentText, fontWeight: FontWeight.normal),
              labelStyle: const TextStyle(
                  color: Palette.accent, fontWeight: FontWeight.normal)),
        ));
  }
}
