import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class AuthInputField extends ConsumerStatefulWidget {
  final String name;
  final double paddingTop;
  final double paddingBottom;
  final double paddingLeft;
  final double paddingRight;
  final bool isFocused;
  final bool obscure;
  final FocusNode focusNode;

  const AuthInputField({
    super.key,
    required this.name,
    this.paddingTop = 0,
    this.paddingBottom = 0,
    this.paddingLeft = 0,
    this.paddingRight = 0,
    required this.isFocused,
    required this.focusNode,
    this.obscure = false,
  });

  @override
  ConsumerState<AuthInputField> createState() => _AuthInputField();
}

class _AuthInputField extends ConsumerState<AuthInputField> {
  late bool _obscure;
  late bool _allowVisibility;

  @override
  void initState() {
    super.initState();
    _allowVisibility = _obscure = widget.obscure;
  }

  //getters
  double get paddingTop => widget.paddingTop;

  double get paddingBottom => widget.paddingBottom;

  double get paddingLeft => widget.paddingLeft;

  double get paddingRight => widget.paddingRight;

  String get name => widget.name;

  FocusNode get focusNode => widget.focusNode;

  bool get isFocused => widget.isFocused;

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
            bottom: paddingBottom,
            left: paddingLeft,
            right: paddingRight,
            top: paddingTop),
        child: TextFormField(
          focusNode: focusNode,
          obscureText: _obscure,
          cursorColor: Palette.accent,
          decoration: InputDecoration(
            hintText: isFocused ? '' : name,
            labelText: !isFocused ? '' : name,
            hintStyle: const TextStyle(
                color: Palette.accentText, fontWeight: FontWeight.normal),
            labelStyle: const TextStyle(
                color: Palette.accent, fontWeight: FontWeight.normal),
            suffixIcon: visibilityEyeIcon(),
          ),
        ));
  }
}
