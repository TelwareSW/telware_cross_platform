import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/auth/view/widget/auth_floating_action_button.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/features/chat/view/widget/member_tile_widget.dart';
import 'package:telware_cross_platform/features/groups/view/screens/group_creation_details.dart';
import 'package:telware_cross_platform/features/user/view_model/user_view_model.dart';

import '../../../../core/routes/routes.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String route = '/create-group';
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreen();
}

class _CreateGroupScreen extends ConsumerState<CreateGroupScreen>
    with TickerProviderStateMixin {
  final List<UserModel> fullUserChats = [];
  late List<UserModel> userChats;
  final TextEditingController searchController = TextEditingController();

  late Future<List<UserModel>> _usersFuture;
  bool _isUserContentSet = false;
  int _numSelected = 0;
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
      _numSelected--;
    } else {
      _selectedUsers.add(user);
      _numSelected++;
    }
    setState(() {});
  }

  void _createNewGroup() {
    // TODO: Implement group creation
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Group',
              style: TextStyle(
                color: Palette.primaryText,
                fontSize: Sizes.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _numSelected == 0 ? 'up to 200000 members'
                  : '$_numSelected of 200000 selected',
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
              onChanged: _filterView,
              decoration: const InputDecoration(
                hintText: 'Who would you like to add?',
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
                    shrinkWrap: true, // To allow proper layout within parent widgets
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
          print('fdsafas');
          print(_selectedUsers);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GroupCreationDetails(members:_selectedUsers,)),
          );
          // context.push(GroupCreationDetails.route);
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
        String text = '${user.screenFirstName} ${user.screenLastName}'.toLowerCase();
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
