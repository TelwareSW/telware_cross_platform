import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/tab_bar_widget.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/core/view/widget/popup_menu_widget.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/features/chat/view/widget/member_tile_widget.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';
import 'package:telware_cross_platform/features/user/view/widget/avatar_generator.dart';
import 'package:telware_cross_platform/features/user/view/widget/profile_header_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_toggle_switch_widget.dart';

class ChatInfoScreen extends ConsumerStatefulWidget {
  static const String route = '/chat-info';
  final ChatModel chatModel;

  const ChatInfoScreen({super.key, required this.chatModel});

  @override
  ConsumerState<ChatInfoScreen> createState() => _ChatInfoScreen();
}

class _ChatInfoScreen extends ConsumerState<ChatInfoScreen>
    with SingleTickerProviderStateMixin {
  late final Future<List<UserModel?>> usersInfoFuture;
  late ChatModel chat = widget.chatModel;
  late TabController _tabController;

  Future<List<UserModel?>> getUsersInfo() async {
    final ChatModel chat = widget.chatModel;
    final List<UserModel?> users = [];
    for (final String userId in chat.userIds) {
      final UserModel? user = await ref.read(chatsViewModelProvider.notifier).getUser(userId);
      users.add(user);
    }
    return users;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    usersInfoFuture = getUsersInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleMute(bool isMuted) {
    if (!isMuted) {
      ref.read(chattingControllerProvider).muteChat(chat, null)
          .then((_) => {
        setState(() {
          chat = chat.copyWith(isMuted: true, muteUntil: null);
        })
      });
    } else {
      ref.read(chattingControllerProvider).unmuteChat(chat)
          .then((_) => {
        setState(() {
          chat = chat.copyWith(isMuted: false, muteUntil: null);
        })
      });
    }
  }

  void _setChatMute(bool mute, DateTime? muteUntil) async {
    if (!mute) {
      ref.read(chattingControllerProvider).unmuteChat(chat).then((_) {
        setState(() {
          chat = chat.copyWith(isMuted: false, muteUntil: null);
        });
      });
    } else {
      ref.read(chattingControllerProvider).muteChat(chat, muteUntil)
          .then((_) {
        setState(() {
          chat = chat.copyWith(isMuted: true, muteUntil: muteUntil);
        });
      });
    }
  }

  void _showNotificationSettings(BuildContext context) {
    var items = !chat.isMuted ? [
      {'icon': Icons.music_off_outlined, 'text': 'Disable sound', 'value': 'disable-sound'},
      {'icon': Icons.access_time_rounded, 'text': 'Mute for 30m', 'value': 'mute-30m'},
      {'icon': Icons.notifications_paused_outlined, 'text': 'Mute for...', 'value': 'mute-custom'},
      {'icon': Icons.tune_outlined, 'text': 'Customize', 'value': 'customize'},
      {'icon': Icons.volume_off_outlined, 'text': 'Mute Forever', 'value': 'mute-forever', 'color': Palette.error},
    ] : [
      {'icon': Icons.notifications_paused_outlined, 'text': 'Mute for...', 'value': 'mute-custom'},
      {'icon': Icons.tune_outlined, 'text': 'Customize', 'value': 'customize'},
      {'icon': Icons.volume_up_outlined, 'text': 'Unmute', 'value': 'unmute', 'color': Palette.valid},
    ];

    PopupMenuWidget.showPopupMenu(
        context: context,
        items: items,
        onSelected: (value) {
          switch (value) {
            case 'mute-30m':
              _setChatMute(true, DateTime.now().add(const Duration(minutes: 30)));
              break;
            case 'mute-custom':
              DatePicker.showDatePicker(
                context,
                pickerTheme: const DateTimePickerTheme(
                  backgroundColor: Palette.secondary,
                  itemTextStyle: TextStyle(
                    color: Palette.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  confirm: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Palette.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                pickerMode: DateTimePickerMode.time,
                minDateTime: DateTime.now(),
                maxDateTime: DateTime.now().add(const Duration(days: 365)),
                initialDateTime: DateTime.now(),
                dateFormat: 'dd-MMMM-yyyy',
                locale: DateTimePickerLocale.en_us,
                onConfirm: (date, time) {
                  _setChatMute(true, date);
                },
              );
              break;
            case 'mute-forever':
              _setChatMute(true, null);
              break;
            case 'unmute':
              _setChatMute(false, null);
              break;
            default:
              showToastMessage('Coming soon');
          }
        }
    );
  }

  void _addMembers() {
    // TODO: Implement this
    context.go('/add-members', extra: {'chatId': chat.id});
  }

  @override
  Widget build(BuildContext context) {
    print("Chat: $chat");
    return Scaffold(
      backgroundColor: Palette.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Palette.trinary,
            expandedHeight: 145.0,
            toolbarHeight: 80,
            floating: false,
            pinned: true,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop()),
            actions: [
              IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // context.push(
                    //   '/edit-chat',
                    //   extra: {'chatId': chat.id},
                    // );
                  }
              ),
              const SizedBox(width: 16),
              IconButton(
                  onPressed: () {
                    // Create popup menu and stuff
                  },
                  icon: const Icon(Icons.more_vert)),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return FlexibleSpaceBar(
                  title: ProfileHeader(
                    constraints: constraints,
                    photoBytes: chat.photoBytes,
                    displayName: chat.title,
                    substring: '${chat.userIds.length} members',
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
              child: Container(
                color: Palette.secondary,
                child: SettingsToggleSwitchWidget(
                  text: 'Notifications',
                  subtext: 'Custom',   // TODO: Update this to be dynamic
                  isChecked: !chat.isMuted,
                  onToggle: _toggleMute,
                  onTap: _showNotificationSettings,
                  oneFunction: false,
                  showDivider: false,
                ),
              )
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Palette.background,
              height: Dimensions.sectionGaps,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Palette.secondary,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 22, top: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.person_add_outlined,
                        color: Palette.primary,
                      ),
                      title: const Text(
                          'Add Members',
                          style: TextStyle(
                            color: Palette.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          )
                      ),
                      onTap: _addMembers,
                    ),
                  ),
                  FutureBuilder(
                    future: usersInfoFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        final List<UserModel?> users = snapshot.data as List<UserModel?>;
                        return Column(
                          children: [
                            for (final UserModel? user in users) ...[
                              Container(
                                color: Palette.secondary,
                                child: MemberTileWidget(
                                  imagePath: user!.photo,
                                  text: '${user.screenFirstName} ${user.screenLastName}',
                                  subtext: user.status,
                                  showDivider: false,
                                  onTap: () {
                                    context.push(Routes.userProfile, extra: user.id);
                                  },
                                ),
                              ),
                            ],
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Material(
              child: Container(
                color: Palette.background,
                height: Dimensions.sectionGaps,
              ),
            ),
          ),
          SliverToBoxAdapter(
              child: Container(
                color: Palette.secondary,
                child: Column(
                    children: [
                      TabBarWidget(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Media'),
                          Tab(text: 'Voice'),
                        ],

                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: TabBarView(
                          controller: _tabController,
                          children: List.generate(2, (index) {
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
                          ),
                        ),
                      )
                    ]
                ),
              )
          ),
        ],
      ),
    );
  }
}
