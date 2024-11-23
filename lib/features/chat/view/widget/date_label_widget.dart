import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class DateLabelWidget extends StatelessWidget {
  const DateLabelWidget({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            color: Palette.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Palette.primaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}