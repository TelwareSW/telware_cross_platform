import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/auth/view/widget/profile_header_widget.dart';
import 'package:telware_cross_platform/features/auth/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/auth/view/widget/settings_section.dart';

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
          "text": user["phoneNumber"],
          "subtext": "Tap to change phone number",
          "routes": "/change-number"
        },
        {"text": user["username"], "subtext": "Username"},
        {
          "text": "Bio",
          "subtext": "Add a few words about yourself",
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
          "routes": '/chat-settings'
        },
        {
          "icon": Icons.lock_outline_rounded,
          "text": 'Privacy and Security',
          "routes": '/privacy'
        },
        {
          "icon": Icons.notifications_none,
          "text": 'Notifications and Sounds',
          "routes": '/notifications'
        },
        {
          "icon": Icons.pie_chart_outline,
          "text": 'Data and Storage',
          "routes": '/data-storage'
        },
        {
          "icon": Icons.battery_saver_outlined,
          "text": 'Power Saving',
          "routes": '/power-saving'
        },
        {
          "icon": Icons.folder_outlined,
          "text": 'Chat Folders',
          "routes": '/chat-folders'
        },
        {"icon": Icons.devices, "text": 'Devices', "routes": '/devices'},
        {
          "icon": Icons.language_rounded,
          "text": 'Language',
          "trailing": 'English',
          "routes": '/language'
        },
      ]
    },
    const {
      "options": [
        {
          "icon": Icons.star_border_purple500_rounded,
          "text": 'TelWare Premium'
        },
        {"icon": Icons.star_border_rounded, "text": 'My Stars'},
        {"icon": Icons.storefront, "text": 'TelWare Business'},
        {"icon": Icons.card_giftcard, "text": 'Send a Gift'},
      ]
    },
    const {
      "title": "Help",
      "options": [
        {"icon": Icons.chat, "text": 'Ask a Question'},
        {"icon": Icons.question_mark, "text": 'TelWare FAQ'},
        {"icon": Icons.verified_user_outlined, "text": 'Privacy Policy'},
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
                onPressed: () => Navigator.pushNamed(context, "/profile")),
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
