import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/core/view/widget/tab_bar_widget.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/providers/call_provider.dart';
import 'package:telware_cross_platform/features/chat/view/screens/chat_screen.dart';
import 'package:telware_cross_platform/features/chat/view/widget/call_overlay_widget.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:telware_cross_platform/features/user/view/widget/profile_header_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/repository/user_local_repository.dart';

import '../../../stories/view/screens/add_my_image_screen.dart';
import '../../view_model/user_view_model.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  static const String route = '/user-profile';
  final String? userId;

  const UserProfileScreen({super.key, this.userId});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreen();
}

class _UserProfileScreen extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late UserModel _user;
  late final bool _isCurrentUser;
  late final TabController _tabController;

  @override
  void initState() {
    _isCurrentUser = widget.userId == null ||
        widget.userId == ref.read(userLocalRepositoryProvider).getUser()!.id;
    _tabController = TabController(length: _isCurrentUser ? 2 : 5, vsync: this);
    _user = !_isCurrentUser
        ? ref.read(chatsViewModelProvider.notifier).getOtherUsers()[widget.userId]!
    : ref.read(userLocalRepositoryProvider).getUser()!;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.userId != null) {
        _user = (await ref.read(chatsViewModelProvider.notifier).getUser(widget.userId!))!;
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _createChat() {
    UserModel myUser = ref.read(userLocalRepositoryProvider).getUser()!;
    // Check if a chat already exists between the two users
    final ChatModel chat = ref.read(chatsViewModelProvider.notifier).getChat(
        myUser, _user, ChatType.private);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(Routes.home);
      context.push(ChatScreen.route, extra: chat);
    });
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
                leading: const BackButton(),
                actions: [
                  if (_isCurrentUser) ...[
                    IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => context.push(Routes.profileInfo)),
                  ]
                  else ...[
                    IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () {
                        ref.read(callStateProvider.notifier).startCall();
                        debugPrint("Sending user: $_user");
                        context.push(Routes.callScreen, extra: _user);
                      },
                    )
                  ],
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
                    return FlexibleSpaceBar(
                      title: ProfileHeader(
                        constraints: constraints,
                        photoBytes: _user.photoBytes,
                        displayName: '${_user.screenFirstName} ${_user.screenLastName}',
                        substring: _user.status,
                      ),
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
                          showDivider: _user.bio.isNotEmpty || _user.username.isNotEmpty,
                        ),
                        if (_user.bio.isNotEmpty)
                          SettingsOptionWidget(
                              icon: null,
                              text: _user.bio,
                              subtext: "Bio",
                              showDivider: _user.username.isNotEmpty
                          ),
                        if (_user.username.isNotEmpty)
                          SettingsOptionWidget(
                              icon: null,
                              text: "@${_user.username}",
                              subtext: "Username",
                              showDivider: false
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: Dimensions.sectionGaps),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Palette.secondary,
                  child: Column(
                    children: [
                      TabBarWidget(
                        controller: _tabController,
                        tabs: _isCurrentUser ?
                        const [
                          Tab(text: "Posts",),
                          Tab(text: "Archived Posts",),
                        ] :
                        const [
                          Tab(text: "Media",),
                          Tab(text: "Files",),
                          Tab(text: "Voice",),
                          Tab(text: "GIFs",),
                          Tab(text: "Groups",),
                        ],
                        isScrollable: !_isCurrentUser,
                      ),
                      const CallOverlay(showDetails: false,),
                    ],
                  ),
                )
              ),
              SliverFillRemaining(
                child: Container(
                  color: Palette.secondary,
                  child: TabBarView(
                      controller: _tabController,
                      children: List.generate(_isCurrentUser ? 2 : 5, (index) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            LottieViewer(
                              path: 'assets/tgs/EasterDuck.tgs',
                              width: 100,
                              height: 100,
                            ),
                            TitleElement(
                              name: 'To be implemented',
                              color: Palette.primaryText,
                              fontSize: Sizes.primaryText - 2,
                              fontWeight: FontWeight.bold,
                              padding: EdgeInsets.only(bottom: 0, top: 10),
                            ),
                          ],
                        );
                      }
                      )
                  ),
                ),
              )
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
                  _isCurrentUser ?
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddMyImageScreen(
                          destination: 'user-profile'),
                    ),
                  ) :
                  _createChat();
                },
                child: Icon(_isCurrentUser ? Icons.add : Icons.chat_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
