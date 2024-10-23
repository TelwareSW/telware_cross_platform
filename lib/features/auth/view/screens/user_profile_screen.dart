import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/auth/view/widget/profile_header_widget.dart';
import 'package:telware_cross_platform/features/auth/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/auth/view/widget/settings_section.dart';

class UserProfileScreen extends StatefulWidget {
  static const String route = '/profile';

  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreen();
}

class _UserProfileScreen extends State<UserProfileScreen> {
  static const String fullName = "Moamen Hefny";

  static var user = {
    "phoneNumber": "+20 110 5035588",
    "username": "Moamen"
  };

  static List<Map<String, dynamic>> profileSections = [
    {"title": "Info", "options": [
      {"text": user["phoneNumber"], "subtext": "Tap to change phone number"},
      {"text": user["username"], "subtext": "Username"},
      {"text": "Bio", "subtext": "Add a few words about yourself", "routes": "/bio"}
    ]}
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
            leading: const Icon(Icons.arrow_back),
            actions: [
              IconButton(icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.pushNamed(context, "/bio")),
              const SizedBox(width: 16),
              const Icon(Icons.more_vert),
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
          SliverToBoxAdapter(
              child: Column(
                children: [
                  SettingsSection(
                    title: "Info",
                    settingsOptions: const [],
                    actions: [
                      SettingsOptionWidget(text: user["phoneNumber"] ?? "",
                        icon: null,
                        subtext: "Mobile",
                      ),
                      if (user["bio"] != null)
                        SettingsOptionWidget(icon: null,
                            text: user["bio"] ?? "",
                            subtext: "Bio"
                        ),
                      if (user["username"] != null)
                        SettingsOptionWidget(icon: null,
                            text: "@${user["username"]}",
                            subtext: "Username"
                        ),
                    ],
                  ),
                ],
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
    double factor = scrollOffset > 0 ? (maxExtent - scrollOffset) / maxExtent * 90.0 : 60.0;
    return factor.clamp(0, 90.0);
  }
}
