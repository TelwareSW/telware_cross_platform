import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/auth/view/widget/profile_section.dart';
import 'package:telware_cross_platform/features/auth/view/widget/settings_section.dart';

class SettingsScreen extends StatefulWidget {
  static const String route = '/profile';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  static const String fullName = "Moamen Hefny";
  static var user = {
    "phoneNumber": "+20 110 5035588",
    "username": "Moamen",
  };

  static List<Map<String, dynamic>> profileSections = [
    {"title": "Account", "options": [
      {"text": user["phoneNumber"], "subtext": "Tap to change phone number"},
      {"text": user["username"], "subtext": "Username"},
      {"text": "Bio", "subtext": "Add a few words about yourself", "routes": "/bio"}
    ]},
    const {"title": "Settings", "options": [
      {"icon": Icons.chat_bubble_outline, "text": 'Chat Settings', "route": '/chat-settings'},
      {"icon": Icons.lock_outline_rounded, "text": 'Privacy and Security', "routes": '/privacy'},
      {"icon": Icons.notifications_none, "text": 'Notifications and Sounds', "routes": '/notifications'},
      {"icon": Icons.pie_chart_outline, "text": 'Data and Storage', "routes": '/data-storage'},
      {"icon": Icons.battery_saver_outlined, "text": 'Power Saving', "routes": '/power-saving'},
      {"icon": Icons.folder_outlined, "text": 'Chat Folders', "routes": '/chat-folders'},
      {"icon": Icons.devices, "text": 'Devices', "routes": '/devices'},
      {"icon": Icons.language_rounded, "text": 'Language', "trailing": 'English', "routes": '/language'},
    ]},
    const {"options": [
      {"icon": Icons.star_border_purple500_rounded, "text": 'TelWare Premium'},
      {"icon": Icons.star_border_rounded, "text": 'My Stars'},
      {"icon": Icons.storefront, "text": 'TelWare Business'},
      {"icon": Icons.card_giftcard, "text": 'Send a Gift'},
    ]},
    const {"title": "Help", "options": [
      {"icon": Icons.chat, "text": 'Ask a Question'},
      {"icon": Icons.question_mark, "text": 'TelWare FAQ'},
      {"icon": Icons.verified_user_outlined, "text": 'Privacy Policy'},
    ], "trailing": "TalWare for Android v11.2.0 (5299) store bundled arm64-v8a"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: const Text(fullName),
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 16),
          Icon(Icons.more_vert),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const ProfileSection(),
            ...List.generate(
              profileSections.length,
                (index) {
                  final section = profileSections[index];
                  final title = section["title"] ?? "";
                  final options = section["options"];
                  final trailing = section["trailing"] ?? "";
                  return  Column(
                    children: [
                        const SizedBox(height: 20),
                        SettingsSection(title: title, settingsOptions: options, trailing: trailing,)
                    ],
                  );
                }
            ),
            const SizedBox(height: 20),
          ],
        )
      ),
    );
  }
}