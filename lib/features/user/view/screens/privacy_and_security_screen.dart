import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/user/repository/user_local_repository.dart';
import 'package:telware_cross_platform/features/user/view/screens/invites_permissions_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/last_seen_privacy_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/phone_privacy_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/profile_photo_privacy_screen.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  static const String route = '/privacy';

  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() => _PrivacySettingsScreen();
}

class _PrivacySettingsScreen extends ConsumerState<PrivacySettingsScreen> {
  late final _user;
  late List<Map<String, dynamic>> profileSections;

  @override
  void initState() {
    super.initState();
  }

  String _formatPrivacy(String privacy) {
    return privacy == "contacts" ? "My Contacts"
        : privacy == "everyone" ? "Everybody"
        : capitalizeEachWord(privacy);
  }

  void _updateDependencies(user) {

    profileSections = [
      {
        "title": "Security",
        "options": [
          {
            "icon": Icons.key_outlined,
            "text": 'Two-Step Verification',
            "trailing": "Off"
          },
          {
            "icon": Icons.timelapse,
            "text": 'Auto-Delete Messages',
            "trailing": "Off"
          },
          {
            "icon": Icons.lock_outline_rounded,
            "text": 'Passcode Lock',
            "trailing": "Off"
          },
          {
            "icon": Icons.email_outlined,
            "text": 'Login Email',
            "trailing": "moamen.hefny@TelWare.com"
          },
          {
            "key": "blocked-users-option",
            "icon": Icons.front_hand_outlined,
            "text": 'Blocked Users',
            "routes": '/blocked-users',
            "trailing": "None"
          },
          {"icon": Icons.devices, "text": 'Devices', "trailing": "1"},
        ],
        "trailing":
        "Review the list of devices where you are logged in to your TelWare account."
      },
      {
        "title": "Privacy",
        "options": [
          {"text": 'Phone Number', "trailing": "My Contacts", "routes": PhonePrivacyScreen.route },
          {"text": 'Last Seen & Online', "trailing": _formatPrivacy(user.lastSeenPrivacy), "routes": LastSeenPrivacyScreen.route },
          {"text": 'Profile Photos', "trailing": _formatPrivacy(user.picturePrivacy), "routes": ProfilePhotoPrivacyScreen.route },
          {"text": 'Forwarded Messages', "trailing": "EveryBody"},
          {"text": 'Calls', "trailing": "EveryBody"},
          {"text": 'Voice Messages', "trailing": "EveryBody"},
          {"text": 'Messages', "trailing": "EveryBody"},
          {"text": 'Date of Birth', "trailing": "My Contacts"},
          {"text": 'Invites', "trailing": _formatPrivacy(user.invitePermissionsPrivacy), "routes": InvitesPermissionScreen.route },
        ],
        "trailing":
        "You can restrict which users are allowed to add you to groups and channels."
      },
      {
        "title": "Delete my account",
        "options": [
          {"text": 'If away for', "trailing": "18 months"},
        ],
        "trailing": "If you do not come online at least once within this period,"
            " your account will be deleted along with all messages and contacts."
      },
      {
        "title": "Bots and websites",
        "options": [
          {"text": 'Clear Payment and Shipping Info'},
        ]
      },
      {
        "title": "Contacts",
        "options": [
          {"text": 'Delete Synced Contacts'},
          {"text": 'Sync Contacts'},
          {"text": 'Suggest Frequent Contacts'},
        ],
        "trailing": "Display people you message frequently at the top of the "
            "search section for quick access."
      },
      {
        "title": "Secret Chats",
        "options": [
          {"text": 'Map Preview Provider', "trailing": "No Previews"},
          {"text": 'Link Previews'},
        ],
        "trailing": "Link previews will be generated on TelWare servers. We "
            "do not store any data about the links you send."
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    _updateDependencies(user);

    return Scaffold(
      appBar: const ToolbarWidget(
        title: "Privacy and Security",
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          ...List.generate(profileSections.length, (index) {
            final section = profileSections[index];
            final title = section["title"] ?? "";
            final options = section["options"];
            final trailing = section["trailing"] ?? "";
            return Column(
              children: [
                SettingsSection(
                  title: title,
                  settingsOptions: options,
                  trailing: trailing,
                ),
                const SizedBox(height: Dimensions.sectionGaps),
              ],
            );
          }),
        ],
      )),
    );
  }
}
