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
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_toggle_switch_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';

class DataAndStorageScreen extends ConsumerStatefulWidget {
  static const String route = '/data-and-storage';

  const DataAndStorageScreen({super.key});

  @override
  ConsumerState<DataAndStorageScreen> createState() =>
      _DataAndStorageScreen();
}

class _DataAndStorageScreen extends ConsumerState<DataAndStorageScreen> {
  final List<Map<String, dynamic>> profileSections = [
    {
      "title": "Disk and network usage",
      "options": [
        {
          "icon": Icons.data_usage,
          "text": 'Storage Usage',
          "trailing": "62.4 MB",
        },
        {
          "icon": Icons.analytics_outlined,
          "text": 'Data Usage',
          "trailing": "854.1 MB",
        },
      ],
    }
  ];
  bool mobileMedia = true;
  bool wifiMedia = true;
  bool roamingMedia = true;
  bool privateChats = false;
  bool groups = false;
  bool channels = false;
  bool streamVideos = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ToolbarWidget(
        title: "Data and Storage",
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
              SettingsSection(
                title: "Automatic media download",
                settingsOptions: [],
                actions: [
                  SettingsToggleSwitchWidget(
                    text: 'When using mobile data',
                    subtext: mobileMedia ? 'Photos, Videos (10 MB), Files (1 MB)' : 'Disabled',
                    isChecked: mobileMedia,
                    onToggle: (value) => setState(() {
                      mobileMedia = value;
                    }),
                    onTap: (_) => showToastMessage("Coming soon"),
                    oneFunction: false,
                  ),
                  SettingsToggleSwitchWidget(
                    text: 'When connected to Wi-Fi',
                    subtext: wifiMedia ? 'Photos, Videos (15 MB), Files (3 MB)' : 'Disabled',
                    isChecked: wifiMedia,
                    onToggle: (value) => setState(() {
                      wifiMedia = value;
                    }),                       // TODO: Marwan
                    onTap: (_) => context.push(Routes.wifiMediaScreen),
                    oneFunction: false,
                  ),
                  SettingsToggleSwitchWidget(
                    text: 'When roaming',
                    subtext: roamingMedia ? 'Photos' : 'Disabled',
                    isChecked: roamingMedia,
                    onToggle: (value) => setState(() {
                      roamingMedia = value;
                    }),
                    onTap: (_) => showToastMessage("coming soon"),
                    oneFunction: false,
                  ),
                  const SettingsOptionWidget(
                    text: 'Reset Auto-Download Settings',
                    color: Palette.error,
                    showDivider: false,
                  )
                ],
              ),
              const SizedBox(height: Dimensions.sectionGaps),
              SettingsSection(
                title: "Save to Gallery",
                settingsOptions: [],
                actions: [
                  SettingsToggleSwitchWidget(
                    text: 'Private Chats',
                    subtext: privateChats ? 'On' : 'Off',
                    isChecked: privateChats,
                    onToggle: (value) => setState(() {
                      privateChats = value;
                    }),
                    onTap: (_) => showToastMessage("Coming soon"),
                    oneFunction: false,
                  ),
                  SettingsToggleSwitchWidget(
                    text: 'Groups',
                    subtext: groups ? 'On' : 'Off',
                    isChecked: groups,
                    onToggle: (value) => setState(() {
                      groups = value;
                    }),
                    onTap: (_) => showToastMessage("Coming soon"),
                    oneFunction: false,
                  ),
                  SettingsToggleSwitchWidget(
                    text: 'Channels',
                    subtext: channels ? 'On' : 'Off',
                    isChecked: channels,
                    onToggle: (value) => setState(() {
                      channels = value;
                    }),
                    onTap: (_) => showToastMessage("Coming soon"),
                    oneFunction: false,
                    showDivider: false,
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.sectionGaps),
              SettingsSection(
                title: "Streaming",
                settingsOptions: [],
                actions: [
                  SettingsToggleSwitchWidget(
                    text: 'Stream Videos and Audio Files',
                    isChecked: streamVideos,
                    onToggle: (value) => setState(() {
                      streamVideos = value;
                    }),
                    oneFunction: true,
                    showDivider: false,
                  ),
                ],
                trailing: "When possible, TelWare will start playing videos and music right away, without"
                    " waiting for the files to fully download.",
              ),
              const SizedBox(height: Dimensions.sectionGaps),
              const SettingsSection(
                title: "Calls",
                settingsOptions: [{
                  "text": 'Use Less Data for Calls',
                  "trailing": "Never"
                }],
              ),
              const SizedBox(height: Dimensions.sectionGaps),
              const SettingsSection(
                title: "Proxy",
                settingsOptions: [{
                  "text": 'Proxy Settings',
                }],
              ),
              const SizedBox(height: Dimensions.sectionGaps),
              const SettingsSection(
                settingsOptions: [{
                  "text": 'Delete All Cloud Drafts',
                }],
              ),
            ],
          )),
    );
  }
}
