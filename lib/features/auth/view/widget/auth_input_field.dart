import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class AuthInputField extends StatefulWidget {
  final String name;
  final EdgeInsetsGeometry padding;
  final bool isFocused;
  final bool obscure;
  final FocusNode focusNode;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;

  const AuthInputField({
    super.key,
    required this.name,
    this.padding = const EdgeInsets.all(0),
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
        padding: widget.padding,
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
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
