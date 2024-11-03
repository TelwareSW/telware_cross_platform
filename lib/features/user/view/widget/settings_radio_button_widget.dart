import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';

class SettingsRadioButtonWidget extends StatelessWidget {
  final String text;
  final String? subtext;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showDivider;

  const SettingsRadioButtonWidget({
    super.key,
    required this.text,
    this.subtext,
    required this.isSelected,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.optionsHorizontalPad,
        vertical: Dimensions.optionsVerticalPad,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalizeEachWord(text),
                        style: const TextStyle(
                          color: Palette.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtext != null && subtext!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            subtext!,
                            style: const TextStyle(
                              color: Palette.accentText,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Radio(
                  value: true,
                  groupValue: isSelected,
                  onChanged: (value) => onTap(),
                  activeColor: Palette.primary,
                ),
              ],
            ),
          ),
          if (showDivider) const Divider(),
        ],
      ),
    );
  }
}
