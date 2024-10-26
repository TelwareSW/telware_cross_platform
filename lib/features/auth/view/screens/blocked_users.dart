import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/features/auth/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/auth/view/widget/toolbar_widget.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class BlockedUsersScreen extends StatefulWidget {
  static const String route = '/blocked-users';

  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _PrivacySettingsScreen();
}

class _PrivacySettingsScreen extends State<BlockedUsersScreen> {
  static const List<Map<String, dynamic>> blockSection = [
    {
      "title": "",
      "options": [
        {
          "icon": Icons.person_add_alt_outlined,
          "iconColor": Palette.primary,
          "color": Palette.primary,
          "fontSize": 15.5,
          "text": 'Block user'
        }
      ],
      "trailing":
          "Blocked users can't send you messages or add you to groups. They will not see your profile photos, stories, online and last    seen status."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ToolbarWidget(
        title: "Blocked Users",
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Column(
            children: [
              SettingsSection(
                padding: const EdgeInsets.fromLTRB(25, 12, 9, 7),
                fontSize: 13,
                trailingLineHeight: 1.2,
                settingsOptions: blockSection[0]["options"],
                trailing: blockSection[0]["trailing"],
              ),
              const SizedBox(height: Dimensions.sectionGaps),
            ],
          ),
        ],
      )),
    );
  }
}
