import 'dart:math';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';
import 'package:typed_data/typed_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/features/chat/view/screens/chat_info_screen.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/theme/palette.dart';
import '../../../../core/theme/sizes.dart';
import '../../../../core/view/widget/lottie_viewer.dart';
import '../../../auth/view/widget/auth_floating_action_button.dart';
import '../../../chat/view/widget/member_tile_widget.dart';
import '../../../home/models/home_state.dart';
import '../../../home/view_model/home_view_model.dart';
import '../../../stories/utils/utils_functions.dart';
import '../../../user/view_model/user_view_model.dart';

class AddMembersScreen extends ConsumerStatefulWidget {
  static const String route = '/create-group';
  final String chatId;
  const AddMembersScreen({
    super.key,
    required this.chatId,
  });

  @override
  ConsumerState<AddMembersScreen> createState() => _AddMembersScreen();
}

class _AddMembersScreen extends ConsumerState<AddMembersScreen>
    with TickerProviderStateMixin {
  final List<UserModel> fullUserChats = [];
  late List<UserModel> userChats;
  final TextEditingController searchController = TextEditingController();
  List<UserModel> usersGlobalSearchResults = [];

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
    } else {
      _selectedUsers.add(user);
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Members',
              style: TextStyle(
                color: Palette.primaryText,
                fontSize: Sizes.primaryText,
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
                hintText: 'Search for people',
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
        onSubmit: () {
          print(_selectedUsers);
          List<String> userIds = [];
          for (var user in _selectedUsers) {
            userIds.add(user.id ?? '');
          }
          print(widget.chatId);
          ref.read(chattingControllerProvider).addMembers(
                chatId: widget.chatId,
                members: userIds,
                onEventComplete: (res) async {
                  if (res['success'] == true) {
                    ref.read(chattingControllerProvider).getUserChats();
                    Navigator.pop(context);
                  } else {
                    debugPrint('Failed to add members to group');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to add members to group'),
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
