import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/tab_bar_widget.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/core/view/widget/popup_menu_widget.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/features/chat/providers/call_provider.dart';
import 'package:telware_cross_platform/features/chat/view/widget/member_tile_widget.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';
import 'package:telware_cross_platform/features/groups/view/screens/add_members_screen.dart';
import 'package:telware_cross_platform/features/groups/view/screens/edit_group.dart';
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
  bool showAutoDeleteOptions = false;

  Future<List<UserModel?>> getUsersInfo() async {
    final ChatModel chat = widget.chatModel;
    final List<UserModel?> users = [];
    for (final String userId in chat.userIds) {
      final UserModel? user =
          await ref.read(chatsViewModelProvider.notifier).getUser(userId);
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
      ref.read(chattingControllerProvider).muteChat(chat, null).then((_) => {
            setState(() {
              chat = chat.copyWith(isMuted: true, muteUntil: null);
            })
          });
    } else {
      ref.read(chattingControllerProvider).unmuteChat(chat).then((_) => {
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
      ref.read(chattingControllerProvider).muteChat(chat, muteUntil).then((_) {
        setState(() {
          chat = chat.copyWith(isMuted: true, muteUntil: muteUntil);
        });
      });
    }
  }

  void _confirmDelete(BuildContext context) {
    bool isChecked = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              backgroundColor: Palette.secondary,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.chatModel.photoBytes != null
                        ? MemoryImage(widget.chatModel.photoBytes!)
                        : null,
                    backgroundColor: widget.chatModel.photoBytes == null
                        ? getRandomColor(chat.title)
                        : null,
                    child: widget.chatModel.photoBytes == null
                        ? Text(
                            getInitials(chat.title),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Palette.primaryText,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Delete group',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Palette.primaryText,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Are you sure you want to delete and leave this group?",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "Delete the group for all members",
                          style: TextStyle(color: Palette.primaryText),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Palette.primary),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    _callSockets(isChecked);
                  },
                  child: const Text(
                    "Delete Group",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _callSockets(bool isChecked) async {
    if (isChecked) {
      await ref.read(chattingControllerProvider).deleteGroup(
            chatId: chat.id ?? '',
            onEventComplete: (res) async {
              if (res['success'] == true) {
                debugPrint('Group deleted successfully');
              } else {
                debugPrint('Failed to delete group try again later');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete group try again later'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          );
    } else {
      await ref.read(chattingControllerProvider).leaveGroup(
            chatId: chat.id ?? '',
            onEventComplete: (res) async {
              if (res['success'] == true) {
                debugPrint('Group deleted successfully');
              } else {
                debugPrint('Failed to leave group try again later');
                // Show a SnackBar if group creation failed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to leave group try again later'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          );
    }
  }


  void _showMoreSettings() {
    var items = [];
    if (showAutoDeleteOptions) {
      items.addAll([
        {'icon': Icons.arrow_back, 'text': 'Back', 'value': 'no-close'},
        {'icon': Icons.timer_sharp, 'text': '1 day', 'value': 'auto-1d'},
        {'icon': Icons.access_time_rounded, 'text': '1 week', 'value': 'auto-1w'},
        {'icon': Icons.share_arrival_time_outlined, 'text': '1 month', 'value': 'auto-1m'},
        {'icon': Icons.tune_outlined, 'text': 'Customize', 'value': 'customize'},
        {'icon': Icons.do_disturb_alt, 'text': 'Disable', 'value': 'disable-auto', 'color': Palette.error},
      ]);
    } else {
      items.addAll([
        {'icon': Icons.more_time, 'text': 'Auto-Delete', 'value': 'no-close',
          'trailing': const Icon(Icons.arrow_forward_ios, color: Palette.inactiveSwitch, size: 16)},
        {'icon': Icons.voice_chat_outlined, 'text': 'Start Video chat', 'value': 'video-call'},
        {'icon': Icons.search, 'text': 'Search Members', 'value': 'search'},
        {'icon': Icons.logout_outlined, 'text': 'Delete and Leave Group', 'value': 'delete-group'},
        {'icon': Icons.add_home_outlined, 'text': 'Add to Home Screen', 'value': 'add-home'},
      ]);
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final position = Offset(renderBox.size.width, -350);

    PopupMenuWidget.showPopupMenu(
        context: context,
        position: position,
        items: items,
        onSelected: _handlePopupMenuSelection
    );
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
        onSelected: _handlePopupMenuSelection
    );
  }

  void _handlePopupMenuSelection(dynamic value) {
    switch (value) {
      case 'no-close':
        showAutoDeleteOptions = !showAutoDeleteOptions;
        break;
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
      case 'delete-group':
        _confirmDelete(context);
        break;
      case 'video-call':
        _createGroupCall();
        break;
      default:
        showToastMessage('Coming soon');
    }
  }

  void _createGroupCall() {
    if (ref.read(callStateProvider).voiceCallId == null) {
      ref.read(callStateProvider.notifier).setCaller(true);
      context.push(Routes.callScreen, extra: {
        'chatId': chat.id,
      });
    } else {
      showToastMessage('You are already in a call');
    }
  }

  void _addMembers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMembersScreen(
          chatId: chat.id??'',
        ),
      ),
    );
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
                    if(chat.admins!.contains(ref.read(userProvider)?.id)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditGroup(
                                  chatModel: widget.chatModel,
                                )),
                      );
                    }
                    else{
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Access Denied'),
                            content: const Text('You do not have the necessary permissions to edit this group.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    // context.push(
                    //   Routes.editGroupScreen,
                    //   extra: widget.chatModel,
                    // );
                  }),
              const SizedBox(width: 16),
              IconButton(
                  onPressed: _showMoreSettings,
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
              subtext: 'Custom', // TODO: Update this to be dynamic
              isChecked: !chat.isMuted,
              onToggle: _toggleMute,
              onTap: _showNotificationSettings,
              oneFunction: false,
              showDivider: false,
            ),
          )),
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
                  chat.admins!.contains(ref.read(userProvider)?.id)
                      ? Padding(
                          padding: const EdgeInsets.only(left: 22, top: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person_add_outlined,
                              color: Palette.primary,
                            ),
                            title: const Text('Add Members',
                                style: TextStyle(
                                  color: Palette.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                )),
                            onTap: _addMembers,
                          ),
                        )
                      : SizedBox(),
                  FutureBuilder(
                    future: usersInfoFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        final List<UserModel?> users =
                            snapshot.data as List<UserModel?>;
                        return Column(
                          children: [

                            for (int index = 0; index < users.length; index++) ...[
                              users[index] == null ?
                              const SizedBox.shrink() :
                              Container(
                                color: Palette.secondary,
                                child: MemberTileWidget(
                                  key: ValueKey('${WidgetKeys.memberTilePrefix}$index'),
                                  imagePath: users[index]!.photo,
                                  text: '${users[index]!.screenFirstName} ${users[index]!.screenLastName}',
                                  subtext: users[index]!.status,
                                  showDivider: false,
                                  onTap: () {
                                    context.push(Routes.userProfile, extra: users[index]!.id);
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
            child: Column(children: [
              TabBarWidget(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Media'),
                  Tab(text: 'Voice'),
                ],
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(2, (index) {
                    return const Column(
                      mainAxisSize: MainAxisSize.min,
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
                  }),
                ),
              )
            ]),
          )),
        ],
      ),
    );
  }
}
