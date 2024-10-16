import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';

final authTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Palette.background,
  appBarTheme: const AppBarTheme(color: Palette.background),
  inputDecorationTheme: InputDecorationTheme(
    floatingLabelBehavior: FloatingLabelBehavior.always,
    contentPadding: const EdgeInsets.all(Dimensions.inputContentPadding),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimensions.inputBorderRadius),
      borderSide: const BorderSide(
          width: Dimensions.inputBorderWidth, color: Palette.accentText),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimensions.inputBorderRadius),
      borderSide: const BorderSide(
          width: Dimensions.inputFocusBorderWidth, color: Palette.accent),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimensions.inputBorderRadius),
      borderSide: const BorderSide(
        width: Dimensions.inputBorderWidth,
        color: Palette.error,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimensions.inputBorderRadius),
      borderSide: const BorderSide(
        width: Dimensions.inputFocusBorderWidth,
        color: Palette.error,
      ),
    ),
    errorStyle: const TextStyle(
      color: Palette.error,
      fontWeight: FontWeight.bold,
    ),
  ),
);
