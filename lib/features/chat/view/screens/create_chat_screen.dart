import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:telware_cross_platform/features/user/view/widget/user_chats.dart';
import 'package:telware_cross_platform/features/user/view_model/user_view_model.dart';

import 'chat_screen.dart';

class CreateChatScreen extends ConsumerStatefulWidget {
  static const String route = '/create-chat';
  final List<MessageModel>? forwardedMessages;

  const CreateChatScreen({super.key, this.forwardedMessages = const []});

  @override
  ConsumerState<CreateChatScreen> createState() => _CreateChatScreen();
}

class _CreateChatScreen extends ConsumerState<CreateChatScreen>
    with TickerProviderStateMixin {
  late List<Map<String, dynamic>> fullUserChats;
  late List<Map<String, dynamic>> userChats;
  late List<Map<String, dynamic>> channelChats;
  late TabController _tabController;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  late Future<List<UserModel>> _usersFuture;
  bool _isUserContentSet = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 9);
    fullUserChats = <Map<String, dynamic>>[
      {"options": <Map<String, dynamic>>[]}
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _usersFuture = ref.read(userViewModelProvider.notifier).fetchUsers();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _createNewChat(UserModel userInfo) {
    final myUser = ref.read(userProvider)!;
    // Check if a chat already exists between the two users
    final ChatModel chat = ref
        .read(chatsViewModelProvider.notifier)
        .getChat(myUser, userInfo, ChatType.private);
    print('existingChat: $chat');
    context.push(ChatScreen.route, extra: chat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.secondary,
      appBar: AppBar(
        backgroundColor: Palette.secondary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop(); // Navigate back when pressed
          },
        ),
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Palette.accentText),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          cursorColor: Palette.accent,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Palette.primaryText),
          onChanged: filterView,
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          indicator: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
            border: Border(
              top: BorderSide(
                color: Palette.primary,
                width: 4.0,
              ),
            ),
          ),
          indicatorPadding: const EdgeInsets.only(top: 44),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Palette.primary,
          ),
          unselectedLabelColor: Palette.accentText,
          physics: const BouncingScrollPhysics(),
          labelPadding:
              const EdgeInsets.only(left: 18.0, right: 18.0, top: 2.0),
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Channels'),
            Tab(text: 'Apps'),
            Tab(text: 'Media'),
            Tab(text: 'Downloads'),
            Tab(text: 'Links'),
            Tab(text: 'Files'),
            Tab(text: 'Music'),
            Tab(text: 'Voice'),
          ],
        ),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(), // Show a loading indicator while data is loading
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
            return TabBarView(
              controller: _tabController,
              children: List.generate(9, (index) {
                if (index == 0 && userChats[0]["options"].isEmpty) {
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
                        name: 'No results',
                        color: Palette.primaryText,
                        fontSize: Sizes.primaryText - 2,
                        fontWeight: FontWeight.bold,
                        padding: EdgeInsets.only(bottom: 0, top: 10),
                      ),
                    ],
                  );
                } else if (index == 0) {
                  return SingleChildScrollView(
                    child: UserChats(chatSections: userChats),
                  );
                } else {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        LottieViewer(
                          path: 'assets/tgs/EasterDuck.tgs',
                          width: 100,
                          height: 100,
                        ),
                        TitleElement(
                          name: 'No results',
                          color: Palette.primaryText,
                          fontSize: Sizes.primaryText - 2,
                          fontWeight: FontWeight.bold,
                          padding: EdgeInsets.only(bottom: 0, top: 10),
                        ),
                      ],
                    ),
                  );
                }
              }),
            );
          }
        },
      ),
    );
  }

  List<Map<String, dynamic>> _generateUsersList(List<UserModel> users) {
    UserModel myUser = ref.read(userProvider)!;
    for (UserModel user in users) {
      if (user.id == myUser.id) continue;
      var option = <String, dynamic>{
        "avatar": true,
        "text": '${user.screenFirstName} ${user.screenLastName}',
        "imagePath": null,
        "subtext": "last seen Nov 23 at 6:40 PM",
        "trailingFontSize": 13.0,
        "trailingPadding": const EdgeInsets.only(bottom: 20.0),
        "trailingColor": Palette.accentText,
        "color": Palette.primaryText,
        "fontSize": 18.0,
        "subtextFontSize": 14.0,
        "fontWeight": FontWeight.w500,
        "imageWidth": 55.0,
        "imageHeight": 55.0,
        "onTap": () => _createNewChat(user),
      };
      fullUserChats[0]["options"].add(option);
      userChats = fullUserChats;
    }
    return userChats;
  }

  void filterView(String query) {
    var filteredChats = <Map<String, dynamic>>[
      {"options": <Map<String, dynamic>>[]}
    ];
    if (query.isEmpty) {
      filteredChats = List.from(fullUserChats);
    } else {
      filteredChats[0]["options"] = fullUserChats[0]["options"].where((option) {
        String text = option["text"].toLowerCase();
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
