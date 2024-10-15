import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

final authTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Palette.background,
  appBarTheme: const AppBarTheme(color: Palette.background),
  inputDecorationTheme: InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.all(14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 1, color: Palette.accentText),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 2, color: Palette.accent),
      )),
);
