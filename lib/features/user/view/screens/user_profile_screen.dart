import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/user/view/widget/profile_header_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/repository/user_local_repository.dart';

import '../../../stories/view/screens/add_my_image_screen.dart';
import '../../view_model/user_view_model.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  static const String route = '/profile';

  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreen();
}

class _UserProfileScreen extends ConsumerState<UserProfileScreen> {
  late final UserModel _user;

  @override
  void initState() {
    super.initState();

    _user = ref.read(userLocalRepositoryProvider).getUser()!;
  }

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
                      onPressed: () => context.push(Routes.profileInfo)),
                  const SizedBox(width: 16),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    color: Palette.secondary,
                    icon: const Icon(
                        Icons.more_vert),
                    onSelected: (String result) {
                      if (result == 'delete') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title:
                              const Text("Confirm Deletion"),
                              content: const Text(
                                  "Are you sure you want to delete this?"),
                              actions: [
                                TextButton(
                                  onPressed: (){
                                    Navigator.pop(
                                        context);
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref.read(userViewModelProvider.notifier).deleteProfilePicture();
                                    Navigator.pop(
                                        context);
                                  },
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  )
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
                          text: _user.phone,
                          icon: null,
                          subtext: "Mobile",
                        ),
                        if (_user.bio != "")
                          SettingsOptionWidget(
                              icon: null, text: _user.bio, subtext: "Bio"),
                        if (_user.username != "")
                          SettingsOptionWidget(
                              icon: null,
                              text: "@${_user.username}",
                              subtext: "Username"),
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
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 155.0, right: 16.0),
              child: FloatingActionButton(
                backgroundColor: Palette.primary,
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddMyImageScreen(
                          destination: 'profile'),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
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
