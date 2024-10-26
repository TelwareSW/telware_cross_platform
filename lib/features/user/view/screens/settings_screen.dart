import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/user/view/widget/profile_header_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';

class SettingsScreen extends StatefulWidget {
  static const String route = '/settings';

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
    {
      "title": "Account",
      "options": [
        {
          "key": "change-number-option",
          "text": user["phoneNumber"],
          "subtext": "Tap to change phone number",
          "routes": "/change-number"
        },
        {"text": "@${user["username"]}", "subtext": "Username"},
        {
          "key": "bio-option",
          "text": user["bio"] ?? "Bio",
          "subtext": user["bio"] != null ? "Bio" : "Add a few words about yourself",
          "routes": "/bio"
        }
      ]
    },
    const {
      "title": "Settings",
      "options": [
        {
          "icon": Icons.chat_bubble_outline,
          "text": 'Chat Settings',
          "routes": 'locked'
        },
        {
          "key": "privacy-option",
          "icon": Icons.lock_outline_rounded,
          "text": 'Privacy and Security',
          "routes": '/privacy'
        },
        {
          "icon": Icons.notifications_none,
          "text": 'Notifications and Sounds',
          "routes": 'locked'
        },
        {
          "icon": Icons.pie_chart_outline,
          "text": 'Data and Storage',
          "routes": 'locked'
        },
        {
          "icon": Icons.battery_saver_outlined,
          "text": 'Power Saving',
          "routes": 'locked'
        },
        {
          "icon": Icons.folder_outlined,
          "text": 'Chat Folders',
          "routes": 'locked'
        },
        {"icon": Icons.devices, "text": 'Devices', "routes": 'locked'},
        {
          "icon": Icons.language_rounded,
          "text": 'Language',
          "trailing": 'English',
          "routes": 'locked'
        },
      ]
    },
    const {
      "options": [
        {
          "icon": Icons.star_border_purple500_rounded,
          "text": 'TelWare Premium',
          "routes": "locked",
        },
        {"icon": Icons.star_border_rounded, "text": 'My Stars', "routes": "locked"},
        {"icon": Icons.storefront, "text": 'TelWare Business', "routes": "locked"},
        {"icon": Icons.card_giftcard, "text": 'Send a Gift', "routes": "locked"},
      ]
    },
    const {
      "title": "Help",
      "options": [
        {"icon": Icons.chat, "text": 'Ask a Question', "routes": "locked"},
        {"icon": Icons.question_mark, "text": 'TelWare FAQ', "routes": "locked"},
        {"icon": Icons.verified_user_outlined, "text": 'Privacy Policy', "routes": "locked"},
      ],
      "trailing": "TalWare for Android v11.2.0 (5299) store bundled arm64-v8a"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 145.0,
            toolbarHeight: 80,
            floating: false,
            pinned: true,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
            actions: const [
              Icon(Icons.search),
              SizedBox(width: 16),
              Icon(Icons.more_vert),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                double factor = _calculateFactor(constraints);
                return FlexibleSpaceBar(
                  title: ProfileHeader(fullName: fullName, factor: factor),
                  centerTitle: true,
                  background: Container(
                    alignment: Alignment.topLeft,
                    color: Palette.trinary,
                    padding: EdgeInsets.zero,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
              child: Column(
            children: [
              SettingsSection(
                settingsOptions: [],
                actions: [
                  SettingsOptionWidget(
                    key: ValueKey("set-profile-photo-option"),
                    icon: Icons.camera_alt_outlined,
                    iconColor: Palette.primary,
                    text: "Set Profile Photo",
                    color: Palette.primary,
                    showDivider: false,
                  )
                ],
              ),
            ],
          )),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final section = profileSections[index];
                final title = section["title"] ?? "";
                final options = section["options"];
                final trailing = section["trailing"] ?? "";
                return Column(
                  children: [
                    const SizedBox(height: Dimensions.sectionGaps),
                    SettingsSection(
                      title: title,
                      settingsOptions: options,
                      trailing: trailing,
                    ),
                  ],
                );
              },
              childCount: profileSections.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: Dimensions.sectionGaps),
          ),
        ],
      ),
    );
  }

  double _calculateFactor(BoxConstraints constraints) {
    double maxExtent = 130.0;
    double scrollOffset = constraints.maxHeight - kToolbarHeight;
    double factor =
        scrollOffset > 0 ? (maxExtent - scrollOffset) / maxExtent * 90.0 : 60.0;
    return factor.clamp(0, 90.0);
  }
}