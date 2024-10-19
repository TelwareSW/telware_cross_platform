import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class AuthInputField extends StatefulWidget {
  final String name;
  final double paddingTop;
  final double paddingBottom;
  final double paddingLeft;
  final double paddingRight;
  final GlobalKey<FormFieldState>? formFieldKey;
  final bool isFocused;
  final bool obscure;
  final FocusNode focusNode;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;

  const AuthInputField({
    super.key,
    required this.name,
    this.paddingTop = 0,
    this.paddingBottom = 0,
    this.paddingLeft = 0,
    this.paddingRight = 0,
    this.formFieldKey,
    required this.isFocused,
    required this.focusNode,
    this.obscure = false,
    this.validator,
    this.controller,
  });

  @override
  AuthInputFieldState createState() => AuthInputFieldState();
}

class AuthInputFieldState extends State<AuthInputField> {
  late bool _obscure;
  late bool _allowVisibility;

  @override
  void initState() {
    super.initState();
    _allowVisibility = _obscure = widget.obscure;
  }

  void _toggleVisibility() {
    setState(() {
      _obscure = !_obscure;
    });
  }

  Widget visibilityEyeIcon() {
    if (_allowVisibility) {
      return IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off : Icons.visibility,
          color: Palette.accent,
        ),
        onPressed: _toggleVisibility,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
            bottom: widget.paddingBottom,
            left: widget.paddingLeft,
            right: widget.paddingRight,
            top: widget.paddingTop),
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          key: widget.formFieldKey,
          obscureText: _obscure,
          cursorColor: Palette.accent,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.isFocused ? '' : widget.name,
            labelText: !widget.isFocused ? '' : widget.name,
            hintStyle: const TextStyle(
                color: Palette.accentText, fontWeight: FontWeight.normal),
            labelStyle: const TextStyle(
                color: Palette.accent, fontWeight: FontWeight.normal),
            suffixIcon: visibilityEyeIcon(),
          ),
        ));
  }
}
