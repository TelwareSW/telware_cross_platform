import 'dart:io';
import 'dart:math';
import 'package:go_router/go_router.dart';
import 'package:typed_data/typed_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/server_constants.dart';
import '../../../../core/models/chat_model.dart';
import '../../../../core/models/message_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/token_provider.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/theme/palette.dart';
import '../../../../core/theme/sizes.dart';
import '../../../auth/view/widget/auth_floating_action_button.dart';
import '../../../chat/enum/chatting_enums.dart';
import '../../../chat/view/screens/chat_screen.dart';
import '../../../chat/view/widget/member_tile_widget.dart';
import '../../../chat/view_model/chatting_controller.dart';
import '../../../home/models/home_state.dart';
import '../../../home/view_model/home_view_model.dart';
import '../../../stories/utils/utils_functions.dart';

class SelectChannelMembers extends ConsumerStatefulWidget {
  static const String route = '/select-channel-members';

  final String channelName;
  final String channelDiscription;
  final String privacy;
  // final File? channelImage;

  const SelectChannelMembers({
    super.key,
    required this.channelName,
    required this.privacy,
    required this.channelDiscription,
    // required this.channelImage,
  });

  @override
  ConsumerState<SelectChannelMembers> createState() => _SelectChannelMembers();
}

class _SelectChannelMembers extends ConsumerState<SelectChannelMembers>
    with TickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  List<UserModel> usersGlobalSearchResults = [];

  int _numSelected = 0;
  final List<UserModel> _selectedUsers = <UserModel>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _toggleSelectUser(UserModel user) {
    if (_selectedUsers.contains(user)) {
      _selectedUsers.remove(user);
      _numSelected--;
    } else {
      _selectedUsers.add(user);
      _numSelected++;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<HomeState>(
      homeViewModelProvider,
      (_, state) {
        usersGlobalSearchResults = state.usersGlobalSearchResults;
        setState(() {});
      },
    );
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.secondary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop(); // Navigate back when pressed
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Subscribers',
              style: TextStyle(
                color: Palette.primaryText,
                fontSize: Sizes.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$_numSelected members',
              style: const TextStyle(
                color: Palette.accentText,
                fontSize: Sizes.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: TextField(
              controller: searchController,
              onSubmitted: (value) {
                _filterView(value);
              },
              decoration: const InputDecoration(
                hintText: 'Add contacts to your channel',
                hintStyle: TextStyle(color: Palette.accentText),
                prefixIcon: Icon(Icons.search, color: Palette.accentText),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              // To allow proper layout within parent widgets
              itemCount: usersGlobalSearchResults.length,
              itemBuilder: (context, index) {
                UserModel user = usersGlobalSearchResults[index];
                return MemberTileWidget(
                  text: '${user.screenFirstName} ${user.screenLastName}',
                  subtext: user.status,
                  imagePath: user.photo,
                  onTap: () => _toggleSelectUser(user),
                  showSelected: _selectedUsers.contains(user),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AuthFloatingActionButton(
        onSubmit: () async {
          print(
              'channel name ${widget.channelName} \n members ${_selectedUsers} \n privacy ${widget.privacy}');
          List<String> membersIds = _selectedUsers
              .where((user) => user.id != null)
              .map((user) => user.id!)
              .toList();
          await ref.read(chattingControllerProvider).createGroup(
                type: 'channel',
                name: widget.channelName,
                members: membersIds,
                onEventComplete: (res) async {
                  if (res['success'] == true) {
                    debugPrint('channel created successfully');
                    final members = res['data']['members'] as List;
                    List<String> userIds = members
                        .map((member) => member['user'] as String)
                        .toList();
                    // Uint8List? imageBytes;
                    // if (widget.channelImage != null) {
                    //   uploadChatImage(
                    //       widget.channelImage!,
                    //       '$API_URL/chats/picture/${res['data']['_id']}',
                    //       ref.read(tokenProvider) ?? '');
                    //   imageBytes = await widget.channelImage?.readAsBytes();
                    // }

                    final ChatModel chat = ChatModel(
                      title: res['data']['name'],
                      userIds: userIds,
                      type: res['data']['type'] == 'group'
                          ? ChatType.group
                          : ChatType.channel,
                      messages: [],
                      // photoBytes: imageBytes,
                      id: res['data']['_id'],
                    );
                    debugPrint('Opening Chat: $chat');
                    List<MessageModel> l=[];
                    context.push(ChatScreen.route, extra: [chat,l]);
                  } else {
                    debugPrint('Failed to create channel');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to create channel'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              );
        },
      ),
    );
  }

  void _getSearchResults(String query, List<String> searchSpace,
      String filterType, bool isGlobalSearch) async {
    ref
        .read(homeViewModelProvider.notifier)
        .fetchSearchResults(query, searchSpace, filterType, isGlobalSearch);
  }

  void _filterView(String query) {
    List<String> allSearchSpace = ['channels', 'groups', 'chats'];
    _getSearchResults(query, allSearchSpace, 'text', true);
  }

  String randomPrivacy() {
    List<String> privacyOptions = ['Everyone', 'Contacts', 'Nobody'];
    return privacyOptions[Random().nextInt(privacyOptions.length)];
  }

  Future<Uint8List?> loadAssetImageBytes(String path) async {
    try {
      ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (e) {
      return null; // Return null if image loading fails
    }
  }
}
