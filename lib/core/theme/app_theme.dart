import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';

final appTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Palette.background,
  snackBarTheme: const SnackBarThemeData(
      backgroundColor: Palette.secondary,
      contentTextStyle: TextStyle(color: Palette.primaryText)),
  appBarTheme: const AppBarTheme(color: Palette.trinary, elevation: 0),
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
  iconTheme: const IconThemeData(color: Palette.icons),
  listTileTheme: const ListTileThemeData(
    textColor: Palette.primaryText,
    iconColor: Palette.accentText,
    contentPadding: EdgeInsets.zero,
    dense: true,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: Dimensions.fontSizeP, color: Palette.accentText),
    bodySmall: TextStyle(fontSize: Dimensions.fontSizeSmall, color: Palette.accentText),
    labelMedium: TextStyle(fontSize: Dimensions.fontSizeSmall, color: Palette.primary),
    titleLarge: TextStyle(fontSize: Dimensions.fontSizeTitle, color: Palette.primary),
  ),
  dividerTheme: const DividerThemeData(
    thickness: 0.8,
    color: Palette.background,
    space: 0,
  ),
);
