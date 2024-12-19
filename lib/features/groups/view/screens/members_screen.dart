import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';

import '../../../../core/constants/keys.dart';
import '../../../../core/models/chat_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/palette.dart';
import '../../../../core/theme/sizes.dart';
import 'add_members_screen.dart';
import '../widget/member_tile_with_options.dart';
import '../../../user/view/widget/settings_option_widget.dart';
import '../../../chat/view_model/chats_view_model.dart';
import '../../../chat/view/widget/member_tile_widget.dart';

class MembersScreen extends ConsumerStatefulWidget {
  static const String route = '/members-screen';
  final ChatModel chatModel;
  const MembersScreen({super.key, required this.chatModel});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  late final Future<List<UserModel?>> usersInfoFuture;

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
    usersInfoFuture = getUsersInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.secondary,
        title: const Text(
          'Members',
          style: TextStyle(
            color: Palette.primaryText,
            fontSize: Sizes.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // make the logic
              context.pop();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsOptionWidget(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMembersScreen(
                    chatId: widget.chatModel.id??'',
                  ),
                ),
              );
            },
            icon: Icons.person_add_outlined,
            iconColor: Palette.primary,
            text: "Add Member",
            color: Palette.primary,
            showDivider: true,
          ),
          SettingsOptionWidget(
            onTap: () async {},
            icon: Icons.link,
            iconColor: Palette.primary,
            text: "Invite via Link",
            color: Palette.primary,
            showDivider: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'Contacts in this group',
              style: TextStyle(fontSize: 13),
            ),
          ),
          FutureBuilder(
            future: usersInfoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final List<UserModel?> users =
                    snapshot.data as List<UserModel?>;
                return Column(
                  children: [
                    for (final UserModel? user in users) ...[
                      user == null
                          ? const SizedBox.shrink()
                          : Container(
                              color: Palette.secondary,
                              child: MemberTileWithOptions(
                                showMenu: user.id != ref.read(userProvider)?.id
                                    ? true
                                    : false,
                                imagePath: user.photo,
                                text:
                                    '${user.screenFirstName} ${user.screenLastName}',
                                subtext: user.status,
                                showDivider: false,
                                onTap: () {
                                  context.push(Routes.userProfile,
                                      extra: user.id);
                                },
                                userId: user.id ?? '',
                                chatId: widget.chatModel.id ?? "", context: context,
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
    );
  }
}
