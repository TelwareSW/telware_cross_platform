import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/auth/view/widget/profile_section.dart';
import 'package:telware_cross_platform/features/auth/view/widget/settings_section.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  static const String route = '/profile';

  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  static const String fullName = "Moamen Hefny";
  static const List<Map<String, dynamic>> profileSections = [
    {"title": "Settings", "options": [
      {"icon": Icons.chat_bubble_outline, "text": 'Chat Settings'},
      {"icon": Icons.lock_outline_rounded, "text": 'Privacy and Security'},
      {"icon": Icons.notifications_none, "text": 'Notifications and Sounds'},
      {"icon": Icons.pie_chart_outline, "text": 'Data and Storage'},
      {"icon": Icons.battery_saver_outlined, "text": 'Power Saving'},
      {"icon": Icons.folder_outlined, "text": 'Chat Folders'},
      {"icon": Icons.devices, "text": 'Devices'},
      {"icon": Icons.language_rounded, "text": 'Language', "trailing": 'English'},
    ]},
    {"options": [
      {"icon": Icons.star_border_purple500_rounded, "text": 'TelWare Premium'},
      {"icon": Icons.star_border_rounded, "text": 'My Stars'},
      {"icon": Icons.storefront, "text": 'TelWare Business'},
      {"icon": Icons.card_giftcard, "text": 'Send a Gift'},
    ]},
    {"title": "Help", "options": [
      {"icon": Icons.chat, "text": 'Ask a Question'},
      {"icon": Icons.question_mark, "text": 'TelWare FAQ'},
      {"icon": Icons.verified_user_outlined, "text": 'Privacy Policy'},
    ], "trailing": "TalWare for Android v11.2.0 (5299) store bundled arm64-v8a"},
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