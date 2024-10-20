import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/features/auth/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/auth/view/widget/toolbar_widget.dart';

class PrivacySettingsScreen extends StatefulWidget {
  static const String route = '/privacy';

  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreen();
}

class _PrivacySettingsScreen extends State<PrivacySettingsScreen> {
  static const List<Map<String, dynamic>> profileSections = [
    {"title": "Security", "options": [
      {"icon": Icons.key_outlined, "text": 'Two-Step Verification', "trailing": "Off"},
      {"icon": Icons.timelapse, "text": 'Auto-Delete Messages', "trailing": "Off"},
      {"icon": Icons.lock_outline_rounded, "text": 'Passcode Lock', "trailing": "Off"},
      {"icon": Icons.email_outlined, "text": 'Login Email', "trailing": "moamen.hefny@TelWare.com"},
      {"icon": Icons.front_hand_outlined, "text": 'Blocked Users', "trailing": "None"},
      {"icon": Icons.devices, "text": 'Devices', "trailing": "1"},
    ], "trailing": "Review the list of devices where you are logged in to your TelWare account."},
    {"title": "Privacy", "options": [
      {"text": 'Phone Number', "trailing": "My Contacts"},
      {"text": 'Last Seen & Online', "trailing": "Everybody"},
      {"text": 'Profile Photos', "trailing": "Everybody"},
      {"text": 'Forwarded Messages', "trailing": "EveryBody"},
      {"text": 'Calls', "trailing": "EveryBody"},
      {"text": 'Voice Messages', "trailing": "EveryBody"},
      {"text": 'Messages', "trailing": "EveryBody"},
      {"text": 'Date of Birth', "trailing": "My Contacts"},
      {"text": 'Invites', "trailing": "Everybody"},
    ], "trailing": "You can restrict which users are allowed to add you to groups and channels."},
    {"title": "Delete my account", "options": [
      {"text": 'If away for', "trailing": "18 months"},
    ], "trailing": "If you do not come online at least once within this period,"
        " your account will be deleted along with all messages and contacts."},
    {"title": "Bots and websites", "options": [
      {"text": 'Clear Payment and Shipping Info'},
    ]},
    {"title": "Contacts", "options": [
      {"text": 'Delete Synced Contacts'},
      {"text": 'Sync Contacts'},
      {"text": 'Suggest Frequent Contacts'},
    ], "trailing": "Display people you message frequently at the top of the "
        "search section for quick access."},
    {"title": "Secret Chats", "options": [
      {"text": 'Map Preview Provider', "trailing": "No Previews"},
      {"text": 'Link Previews'},
    ], "trailing": "Link previews will be generated on TelWare servers. We "
        "do not store any data about the links you send."}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ToolbarWidget(
        title: "Privacy and Security",
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              ...List.generate(
                  profileSections.length,
                      (index) {
                    final section = profileSections[index];
                    final title = section["title"] ?? "";
                    final options = section["options"];
                    final trailing = section["trailing"] ?? "";
                    return  Column(
                      children: [
                        SettingsSection(title: title, settingsOptions: options, trailing: trailing,),
                        const SizedBox(height: Dimensions.sectionGaps),
                      ],
                    );
                  }
              ),
            ],
          )
      ),
    );
  }
}