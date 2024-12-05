import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/popup_menu_widget.dart';
import 'package:telware_cross_platform/core/view/widget/popup_menu_item_widget.dart';

class SettingsToggleSwitchWidget extends StatelessWidget {
  final String text;
  final String? subtext;
  final bool isChecked;
  final ValueChanged<bool> onToggle;
  final onTap;
  final bool oneFunction;
  final bool showDivider;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeToggleColor;
  final Color inactiveToggleColor;
  final Icon? activeIcon;
  final Icon? inactiveIcon;
  final Color? switchBorderColor;

  const SettingsToggleSwitchWidget({
    super.key,
    required this.text,
    this.subtext,
    required this.isChecked,
    required this.onToggle,
    this.onTap,
    this.oneFunction = true,
    this.showDivider = true,
    this.activeColor = Palette.primary,
    this.inactiveColor = Palette.inactiveSwitch,
    this.activeToggleColor = Palette.secondary,
    this.inactiveToggleColor = Palette.secondary,
    this.activeIcon,
    this.inactiveIcon,
    this.switchBorderColor,
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
            onTap: () => oneFunction ? onToggle(!isChecked) : onTap(context),
              child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  const SizedBox(width: 8,),
                  if (!oneFunction)
                  const SizedBox(
                    height: 30, // Define the height
                    child: VerticalDivider(
                      color: Palette.secondary,
                      thickness: 2,
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 35.0,
                        height: 15.0,
                        decoration: BoxDecoration(
                          color: isChecked ? activeColor : inactiveColor,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(color: isChecked ? activeColor : inactiveColor),
                        ),
                      ),
                      FlutterSwitch(
                        width: 44.0,
                        height: 24.0,
                        toggleSize: 24.0,
                        value: isChecked,
                        borderRadius: 30.0,
                        padding: 1.5,
                        activeColor: Colors.transparent,
                        inactiveColor: Colors.transparent,
                        activeToggleColor: activeToggleColor,
                        inactiveToggleColor: inactiveToggleColor,
                        activeIcon: activeIcon,
                        inactiveIcon: inactiveIcon,
                        onToggle: onToggle,
                        toggleBorder: Border.all(
                          color: isChecked ? activeColor : inactiveColor,
                          width: 3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (showDivider) const Divider(),
        ],
      ),
    );
  }
}
