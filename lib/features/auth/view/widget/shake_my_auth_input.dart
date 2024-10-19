import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_input_field.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';

class ShakeMyAuthInput extends StatelessWidget {
  const ShakeMyAuthInput({
    super.key,
    required this.name,
    required this.shakeKey,
    required this.isFocused,
    required this.focusNode,
    this.padding = const EdgeInsets.only(
      bottom: Dimensions.inputPaddingBottom,
      left: Dimensions.inputPaddingLeft,
      right: Dimensions.inputPaddingRight,
    ),
    this.obscure = false,
    required this.controller,
    this.validator,
  });

  final GlobalKey<ShakeWidgetState> shakeKey;
  final String name;
  final EdgeInsetsGeometry padding;
  final bool obscure;
  final bool isFocused;
  final FocusNode focusNode;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return ShakeMe(
      key: shakeKey,
      shakeCount: 3,
      shakeOffset: 10,
      shakeDuration: const Duration(milliseconds: 500),
      child: AuthInputField(
        name: name,
        padding: padding,
        isFocused: isFocused,
        focusNode: focusNode,
        validator: validator,
        controller: controller,
        obscure: obscure,
      ),
    );
  }
}
