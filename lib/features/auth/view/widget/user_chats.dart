import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/features/auth/view/widget/settings_section.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class UserChats extends StatelessWidget {
  final List<Map<String, dynamic>> chatSections;

  const UserChats({super.key, required this.chatSections});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(
          chatSections.length,
          (index) {
            final section = chatSections[index];
            final title = section["title"] ?? "";
            final trailingFontSize = section["trailingFontSize"];
            final lineHeight = section["lineHeight"];
            final padding = section["padding"];
            final options = section["options"];
            final trailing = section["trailing"] ?? "";
            final titleFontSize = section["titleFontSize"];
            return Column(
              children: [
                SettingsSection(
                  titleFontSize: titleFontSize,
                  title: title,
                  padding: padding,
                  trailingFontSize: trailingFontSize,
                  trailingLineHeight: lineHeight,
                  settingsOptions: options,
                  trailing: trailing,
                ),
                const SizedBox(height: Dimensions.sectionGaps),
              ],
            );
          },
        ),
      ],
    );
  }
}
