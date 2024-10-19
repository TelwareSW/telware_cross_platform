import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class AuthPhoneNumber extends StatelessWidget {
  const AuthPhoneNumber({
    super.key,
    required this.name,
    required this.shakeKey,
    required this.focusNode,
    required this.isFocused,
    this.padding = const EdgeInsets.only(
      bottom: Dimensions.inputPaddingBottom,
      left: Dimensions.inputPaddingLeft,
      right: Dimensions.inputPaddingRight,
    ),
    required this.controller,
  });

  final GlobalKey<ShakeWidgetState> shakeKey;
  final String name;
  final EdgeInsetsGeometry padding;
  final FocusNode focusNode;
  final bool isFocused;
  final PhoneController controller;

  @override
  Widget build(BuildContext context) {
    return ShakeMe(
      key: shakeKey,
      shakeCount: 3,
      shakeOffset: 10,
      shakeDuration: const Duration(milliseconds: 500),
      child: Padding(
        padding: padding,
        child: PhoneFormField(
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: isFocused ? '' : name,
            labelText: !(isFocused) ? '' : name,
            hintStyle: const TextStyle(
              color: Palette.accentText,
              fontWeight: FontWeight.normal,
            ),
            labelStyle: const TextStyle(
              color: Palette.accent,
              fontWeight: FontWeight.normal,
            ),
          ),
          controller: controller,
          cursorColor: Palette.accent,
          validator:
              PhoneValidator.compose([PhoneValidator.validMobile(context)]),
          countrySelectorNavigator: const CountrySelectorNavigator.page(
            subtitleStyle: TextStyle(
              color: Palette.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          enabled: true,
          isCountrySelectionEnabled: true,
          isCountryButtonPersistent: true,
          countryButtonStyle: const CountryButtonStyle(
            showDialCode: true,
            showIsoCode: false,
            showFlag: true,
            flagSize: 16,
          ),
        ),
      ),
    );
  }
}
