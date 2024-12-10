import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/auth/view/widget/confirmation_dialog.dart';
import 'package:telware_cross_platform/features/user/view/screens/invites_permissions_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/blocked_users.dart';
import 'package:telware_cross_platform/features/user/view/screens/last_seen_privacy_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/phone_privacy_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/profile_photo_privacy_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/self_destruct_screen.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  static const String route = '/privacy';

  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreen();
}

class _PrivacySettingsScreen extends ConsumerState<PrivacySettingsScreen> {
  late List<Map<String, dynamic>> profileSections;

  @override
  void initState() {
    super.initState();
  }

  String _formatPrivacy(String privacy) {
    return privacy == "contacts"
        ? "My Contacts"
        : privacy == "everyone"
            ? "Everybody"
            : capitalizeEachWord(privacy);
  }

  void updateEmailConfirmationDialog(String email) {
    showConfirmationDialog(
      context: context,
      title: email,
      titleFontWeight: FontWeight.bold,
      titleColor: Palette.primaryText,
      titleFontSize: 18.0,
      subtitle:
          'This email address will be used every time you log in to your Telegram account from a new device.',
      subtitleFontWeight: FontWeight.normal,
      subtitleFontSize: 16.0,
      contentGap: 20.0,
      confirmText: 'Change Email',
      confirmColor: const Color.fromRGBO(100, 181, 239, 1),
      confirmPadding: const EdgeInsets.only(left: 40.0),
      cancelText: 'Cancel',
      cancelColor: const Color.fromRGBO(100, 181, 239, 1),
      onConfirm: () => {
        context.pop(),
        // Close the dialog
        context.push(Routes.changeEmail),
        // Return to Blocked Users screen which is the previous screen.
      },
      onCancel: () => {context.pop()},
      actionsAlignment: MainAxisAlignment.end,
    );
  }

  void _updateDependencies(UserModel? user) {
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
            "trailing": "Off",
            "routes": SelfDestructScreen.route
          },
          {
            "icon": Icons.lock_outline_rounded,
            "text": 'Passcode Lock',
            "trailing": "Off"
          },
          {
            "icon": Icons.email_outlined,
            "text": 'Login Email',
            "trailing": user?.email ?? "moamen.hefny@TelWare.com",
            "onTap": () => updateEmailConfirmationDialog(
                user?.email ?? "moamen.hefny@TelWare.com")
          },
          {
            "key": "blocked-users-option",
            "icon": Icons.front_hand_outlined,
            "text": 'Blocked Users',
            "routes": BlockedUsersScreen.route,
            "trailing": "${user?.blockedUsers?.length ?? 0}"
          },
          {"icon": Icons.devices, "text": 'Devices', "trailing": "1"},
        ],
        "trailing":
            "Review the list of devices where you are logged in to your TelWare account."
      },
      {
        "title": "Privacy",
        "options": [
          {
            "text": 'Phone Number',
            "trailing": "My Contacts",
            "routes": PhonePrivacyScreen.route
          },
          {
            "text": 'Last Seen & Online',
            "trailing": _formatPrivacy(user?.lastSeenPrivacy ?? "everyone"),
            "routes": LastSeenPrivacyScreen.route
          },
          {
            "text": 'Profile Photos',
            "trailing": _formatPrivacy(user?.picturePrivacy ?? "everyone"),
            "routes": ProfilePhotoPrivacyScreen.route
          },
          {
            "text": 'Forwarded Messages',
            "trailing": "EveryBody",
            "routes": "locked"
          },
          {"text": 'Calls', "trailing": "EveryBody", "routes": "locked"},
          {
            "text": 'Voice Messages',
            "trailing": "EveryBody",
            "routes": "locked"
          },
          {"text": 'Messages', "trailing": "EveryBody", "routes": "locked"},
          {
            "text": 'Date of Birth',
            "trailing": "My Contacts",
            "routes": "locked"
          },
          {
            "text": 'Invites',
            "trailing":
                _formatPrivacy(user?.invitePermissionsPrivacy ?? "everyone"),
            "routes": InvitesPermissionScreen.route
          },
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
