import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';

import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_state.dart';
import 'package:telware_cross_platform/features/auth/view_model/auth_view_model.dart';
import 'package:telware_cross_platform/features/stories/view/screens/add_my_image_screen.dart';
import 'package:telware_cross_platform/features/user/repository/user_local_repository.dart';
import 'package:telware_cross_platform/features/user/view/screens/change_number_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/change_username_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/profile_info_screen.dart';
import 'package:telware_cross_platform/features/user/view/widget/profile_header_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  static const String route = '/settings';

  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends ConsumerState<SettingsScreen> {
  final List<Map<String, dynamic>> profileSections = [
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
        {"icon": Icons.devices, "text": 'Devices', "routes": '/devices'},
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
        {
          "icon": Icons.star_border_rounded,
          "text": 'My Stars',
          "routes": "locked"
        },
        {
          "icon": Icons.storefront,
          "text": 'TelWare Business',
          "routes": "locked"
        },
        {
          "icon": Icons.card_giftcard,
          "text": 'Send a Gift',
          "routes": "locked"
        },
      ]
    },
    const {
      "title": "Help",
      "options": [
        {"icon": Icons.chat, "text": 'Ask a Question', "routes": "locked"},
        {
          "icon": Icons.question_mark,
          "text": 'TelWare FAQ',
          "routes": "locked"
        },
        {
          "icon": Icons.verified_user_outlined,
          "text": 'Privacy Policy',
          "routes": "locked"
        },
      ],
      "trailing": "TalWare for Android v11.2.0 (5299) store bundled arm64-v8a"
    }
  ];

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (_, state) {
      if (state.type == AuthStateType.fail) {
        showToastMessage(state.message!);
      } else if (state.type == AuthStateType.unauthenticated) {
        context.push(Routes.home);
      }
    });

    final user = ref.watch(userProvider)!;

    bool isLoading =
        ref.watch(authViewModelProvider).type == AuthStateType.loading;
    debugPrint('isLoading: $isLoading');

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 145.0,
                  toolbarHeight: 80,
                  floating: false,
                  pinned: true,
                  leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop()),
                  actions: [
                    const Icon(Icons.search),
                    const SizedBox(width: 16),
                    IconButton(
                        onPressed: () {
                          ref.read(authViewModelProvider.notifier).logOut();
                          context.go(Routes.logIn);
                        },
                        icon: const Icon(Icons.more_vert)),
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
                      settingsOptions: const [],
                      actions: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AddMyImageScreen(
                                    destination: 'profile'),
                              ),
                            );
                          },
                          child: const SettingsOptionWidget(
                            key: ValueKey("set-profile-photo-option"),
                            icon: Icons.camera_alt_outlined,
                            iconColor: Palette.primary,
                            text: "Set Profile Photo",
                            color: Palette.primary,
                            showDivider: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: Dimensions.sectionGaps),
                      SettingsSection(
                        title: "Account",
                        settingsOptions: [
                          {
                            "key": "change-number-option",
                            "text": user.phone,
                            "subtext": "Tap to change phone number",
                            "routes": ChangeNumberScreen.route,
                          },
                          {
                            "text": (user.phone != "" ? "@${user.username}" : "None"),
                            "subtext": "Username",
                            "routes": ChangeUsernameScreen.route,
                          },
                          {
                            "key": "bio-option",
                            "text": user.bio != "" ? user.bio : "Bio",
                            "subtext":
                            user.bio != "" ? "Bio" : "Add a few words about yourself",
                            "routes": ProfileInfoScreen.route,
                          }
                        ],
                      ),
                    ],
                  )
                ),
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
