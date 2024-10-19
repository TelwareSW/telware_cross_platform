import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/auth/view/widget/section_title_widget.dart';
import 'package:telware_cross_platform/features/auth/view/widget/settings_input_widget.dart';
import 'package:telware_cross_platform/features/auth/view/widget/settings_option_widget.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> settingsOptions;
  final String trailing;
  final List<Widget>? actions;


  const SettingsSection({
    super.key,
    this.title = "",
    required this.settingsOptions,
    this.trailing = "",
    this.actions
  });

  void _navigateTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Container(
              color: Palette.secondary,
              child: Column(
                children: [
                  if (title != "")
                    SectionTitleWidget(title: title),
                    Consumer(
                      builder: (context, ref, _) {
                        return Column(
                          children: [
                            ...List.generate(
                            settingsOptions.length,
                                (index) {
                              final option = settingsOptions[index];
                              final type = option["type"] ?? "";
                              final route = option["routes"] ?? "";
                              final onTap = route != "" ? () => _navigateTo(context, route) :
                              null;
                              return SettingsOptionWidget(
                                icon: option["icon"],
                                text: option["text"],
                                subtext: option["subtext"] ?? "",
                                trailing: option["trailing"] ?? "",
                                showDivider: index != settingsOptions.length - 1,
                                onTap: onTap,
                              );
                            },
                          ),
                          ...?actions,
                        ]
                        );
                      },
                    ),
                ],
              )
          ),
          if (trailing != "")
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 16, 11, 7),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(trailing, style: const TextStyle(fontSize: 11, color: Palette.accentText)),
              ),
            )
        ],
    );
  }
}