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


  late Future<List<UserModel>> _usersFuture;
  bool _isUserContentSet = false;
  final List<UserModel> _selectedUsers = <UserModel>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _usersFuture = ref.read(userViewModelProvider.notifier).fetchUsers();
      });
    });
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
              onChanged: _filterView,
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
            child: FutureBuilder<List<UserModel>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading users: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: LottieViewer(
                      path: 'assets/tgs/EasterDuck.tgs',
                      width: 100,
                      height: 100,
                    ),
                  );
                } else {
                  if (!_isUserContentSet) {
                    userChats = _generateUsersList(snapshot.data!);
                    _isUserContentSet = true;
                  }
                  return ListView.builder(
                    shrinkWrap:
                        true, // To allow proper layout within parent widgets
                    itemCount: userChats.length,
                    itemBuilder: (context, index) {
                      UserModel user = userChats[index];
                      return MemberTileWidget(
                        text: '${user.screenFirstName} ${user.screenLastName}',
                        subtext: user.status,
                        imagePath: user.photo,
                        onTap: () => _toggleSelectUser(user),
                        showSelected: _selectedUsers.contains(user),
                      );
                    },
                  );
                }
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

  List<UserModel> _generateUsersList(List<UserModel> users) {
    UserModel myUser = ref.read(userProvider)!;
    return users.where((user) => user.id != myUser.id).toList();
  }

  void _filterView(String query) {
    List<UserModel> filteredChats = [];
    if (query.isEmpty) {
      filteredChats = List.from(fullUserChats);
    } else {
      filteredChats = fullUserChats.where((user) {
        String text =
            '${user.screenFirstName} ${user.screenLastName}'.toLowerCase();
        return text.contains(query.toLowerCase());
      }).toList();
    }
    setState(() {
      userChats = filteredChats;
    });
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
