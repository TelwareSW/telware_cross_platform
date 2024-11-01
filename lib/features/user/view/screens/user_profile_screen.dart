import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/stories/view/screens/add_my_image_screen.dart';
import 'package:telware_cross_platform/features/user/view/widget/profile_header_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';

class UserProfileScreen extends StatefulWidget {
  static const String route = '/profile';

  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreen();
}

class _UserProfileScreen extends State<UserProfileScreen> {
  static var user = {
    "phoneNumber": "+20 110 5035588",
    "username": "Moamen",
    "bio": "test",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 145.0,
                toolbarHeight: 80,
                floating: false,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => context.push(Routes.profileInfo),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.more_vert),
                ],
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    double factor = _calculateFactor(constraints);
                    return FlexibleSpaceBar(
                      title: ProfileHeader(factor: factor),
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
                        SettingsOptionWidget(
                          text: user["phoneNumber"] ?? "",
                          icon: null,
                          subtext: "Mobile",
                        ),
                        if (user["bio"] != null)
                          SettingsOptionWidget(
                            icon: null,
                            text: user["bio"] ?? "",
                            subtext: "Bio",
                          ),
                        if (user["username"] != null)
                          SettingsOptionWidget(
                            icon: null,
                            text: "@${user["username"]}",
                            subtext: "Username",
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
          Positioned(
            top: 140,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const AddMyImageScreen(destination: 'profile'),
                  ),
                );
              },
              shape: const CircleBorder(),
              backgroundColor: Palette.primary,
              child: const Icon(Icons.add),
            ),
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
