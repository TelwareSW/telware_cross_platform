import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';

class SettingsSectionTrailingWidget extends StatelessWidget {
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;

  const SettingsSectionTrailingWidget({
    super.key,
    required this.actions,
    this.padding
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(Dimensions.optionsHorizontalPad, 13, Dimensions.optionsHorizontalPad, 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var action in actions)
            Align(
              alignment: Alignment.centerLeft,
              child: action,
            ),
        ],
      ),
    );
  }
}
