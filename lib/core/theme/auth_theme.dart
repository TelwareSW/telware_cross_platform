import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';

final authTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Palette.background,
  appBarTheme: const AppBarTheme(color: Palette.secondary, elevation: 0),
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