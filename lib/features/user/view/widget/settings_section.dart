import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/user/view/widget/section_title_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';

class SettingsSection extends StatelessWidget {
  final double? trailingFontSize;
  final double? trailingLineHeight;
  final double? titleFontSize;
  final EdgeInsetsGeometry? padding;
  final String title;
  final List<Map<String, dynamic>> settingsOptions;
  final String trailing;
  final List<Widget>? actions;

  const SettingsSection(
      {super.key,
      this.padding,
      this.trailingFontSize,
      this.trailingLineHeight,
      this.titleFontSize,
      this.title = "",
      required this.settingsOptions,
      this.trailing = "",
      this.actions});

  void _navigateTo(BuildContext context, String route) {
    // todo(moamen): use GoRouter instead of Navigator
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Widget Options: $settingsOptions');

    return Column(
      children: [
        Container(
            key: title != "" ? ValueKey("${toKebabCase(title)}-section") : null,
            color: Palette.secondary,
            child: Column(
              children: [
                if (title != "")
                  SectionTitleWidget(
                    key: title != ""
                        ? ValueKey("${toKebabCase(title)}-section-title")
                        : null,
                    title: title,
                    fontSize: titleFontSize ?? 14,
                  ),
                Consumer(
                  builder: (context, ref, _) {
                    return Column(children: [
                      ...List.generate(
                        settingsOptions.length,
                        (index) {
                          final option = settingsOptions[index];
                          final type = option["type"] ?? "";
                          final key = option["key"] != null
                              ? ValueKey("${option["key"]}")
                              : null;
                          final String route = option["routes"] ?? "";
                          final bool lockedRoute = route == 'locked';
                          final onTap = lockedRoute
                              ? () => showToastMessage("Coming Soon...")
                              : route != ""
                                  ? () => _navigateTo(context, route)
                                  : option["onTap"];
                          return SettingsOptionWidget(
                            key: key,
                            icon: option["icon"],
                            trailingIconKey: option["iconKey"],
                            imagePath: option["imagePath"],
                            imageMemory: option["imageMemory"],
                            avatar: option["avatar"],
                            imageHeight: option["imageHeight"] ?? 45,
                            imageWidth: option["imageWidth"] ?? 45,
                            imageRadius: option["imageRadius"] ?? 25,
                            trailingIcon: option["trailingIcon"],
                            trailingColor: option["trailingColor"],
                            trailingIconAction: option["trailingIconAction"],
                            text: option["text"],
                            subtext: option["subtext"] ?? "",
                            trailing: option["trailing"] ?? "",
                            fontSize: option["fontSize"] ?? 14,
                            fontWeight: option["fontWeight"],
                            subtextFontSize: option["subtextFontSize"],
                            trailingFontSize: option["trailingFontSize"],
                            trailingPadding: option["trailingPadding"],
                            iconColor:
                                option["iconColor"] ?? Palette.accentText,
                            color: option["color"] ?? Palette.primaryText,
                            showDivider: index != settingsOptions.length - 1,
                            onTap: onTap,
                          );
                        },
                      ),
                      ...?actions,
                    ]);
                  },
                ),
              ],
            )),
        if (trailing != "")
          Padding(
            padding: padding ?? const EdgeInsets.fromLTRB(11, 16, 11, 7),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(trailing,
                  style: TextStyle(
                      height: trailingLineHeight,
                      fontSize: trailingFontSize ?? 14,
                      color: Palette.accentText)),
            ),
          )
      ],
    );
  }
}
