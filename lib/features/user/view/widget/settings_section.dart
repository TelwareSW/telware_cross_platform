import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/user/view/widget/section_title_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section_trailing.dart';

class SettingsSection extends StatelessWidget {
  final double? trailingFontSize;
  final double? trailingLineHeight;
  final double? titleFontSize;
  final EdgeInsetsGeometry? padding;
  final String title;
  final ValueKey<String>? containerKey;
  final List<Map<String, dynamic>> settingsOptions;
  final String trailing;
  final List<Widget>? actions;
  final Color trailingColor;

  const SettingsSection({
    super.key,
    this.containerKey,
    this.padding,
    this.trailingFontSize,
    this.trailingLineHeight,
    this.titleFontSize,
    this.title = "",
    required this.settingsOptions,
    this.trailing = "",
    this.actions,
    this.trailingColor = Colors.transparent,
  });

  void _navigateTo(BuildContext context, String route, Object? extra) {
    context.push(route, extra: extra);
  }

  @override
  Widget build(BuildContext context) {
    final ValueKey<String>? sectionKey = containerKey ??
        (title != ""
            ? ValueKey(
                "${toKebabCase(title)}${WidgetKeys.settingsSectionSuffix.value}")
            : null);
    return Column(
      children: [
        Container(
            key: sectionKey,
            color: Palette.secondary,
            child: Column(
              children: [
                if (title != "")
                  SectionTitleWidget(
                    key: sectionKey != null
                        ? ValueKey(
                            sectionKey.value + WidgetKeys.titleSuffix.value)
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
                          final key = option["key"] != null
                              ? ValueKey("${option["key"]}")
                              : null;
                          final String route = option["routes"] ?? "";
                          final Object? extra = option["extra"] ?? "";
                          final bool lockedRoute = route == 'locked';
                          final onTap = lockedRoute
                              ? () => showToastMessage("Coming Soon...")
                              : route != ""
                                  ? () => _navigateTo(context, route, extra)
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
                            subtextColor:
                                option["subtextColor"] ?? Palette.accentText,
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
          Container(
            color: trailingColor,
            child: SettingsSectionTrailingWidget(
              key: sectionKey != null
                  ? ValueKey(sectionKey.value + WidgetKeys.trailingSuffix.value)
                  : null,
              padding: padding,
              actions: [
                Text(trailing,
                    style: TextStyle(
                        height: trailingLineHeight,
                        fontSize: trailingFontSize ?? Dimensions.fontSizeSmall,
                        color: Palette.accentText)),
              ],
            ),
          ),
      ],
    );
  }
}
