import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/auth/view/widget/title_element.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/view/widget/call_overlay_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_tile_widget.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:telware_cross_platform/features/home/models/home_state.dart';
import 'package:telware_cross_platform/features/home/view_model/home_view_model.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
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
  List<ChatModel> globalSearchResults = [];
  List<ChatModel> localSearchResultsChats = [];
  List<MessageModel> localSearchResultsMessages = [];
  List<List<MapEntry<int, int>>> localSearchResultsChatTitleMatches = [];
  List<List<MapEntry<int, int>>> localSearchResultsChatMessagesMatches = [];
  List<ChatModel> remoteSearchResults = [];
  late TabController _tabController;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  Future<List<UserModel>> _usersFuture = Future.value(<UserModel>[]);
  bool _isUserContentSet = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 7);
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
    debugPrint('Opening Chat: $chat');
    context.push(ChatScreen.route, extra: chat);
  }

  Widget sectionName(String name) {
    final dynamic section = {
      "trailingFontSize": 13.0,
      "padding": const EdgeInsets.fromLTRB(25, 12, 9, 7),
      "lineHeight": 1.2,
      "options": <Map<String, dynamic>>[],
      "trailingColor": Palette.background,
      "trailing": name,
    };
    final title = section["title"] ?? "";
    final trailingFontSize = section["trailingFontSize"];
    final lineHeight = section["lineHeight"];
    final padding = section["padding"];
    final options = section["options"];
    final trailing = section["trailing"] ?? "";
    final titleFontSize = section["titleFontSize"];
    final trailingColor = section["trailingColor"];
    return SettingsSection(
      title: title,
      titleFontSize: titleFontSize,
      padding: padding,
      trailingFontSize: trailingFontSize,
      trailingLineHeight: lineHeight,
      settingsOptions: options,
      trailing: trailing,
      trailingColor: trailingColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<HomeState>(
      homeViewModelProvider,
      (_, state) {
        globalSearchResults = state.globalSearchResults;
        localSearchResultsChats = state.localSearchResultsChats;
        localSearchResultsMessages = state.localSearchResultsMessages;
        localSearchResultsChatTitleMatches =
            state.localSearchResultsChatTitleMatches;
        localSearchResultsChatMessagesMatches =
            state.localSearchResultsChatMessagesMatches;
        remoteSearchResults = state.searchResults;
        setState(() {});
      },
    );

    ChatKeys.resetChatTilePrefixSubvalue();
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
          dividerHeight: 0,
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
            Tab(text: 'Users'),
            Tab(text: 'Chats'),
            Tab(text: 'Channels'),
            Tab(text: 'Media'),
            Tab(text: 'Files'),
            Tab(text: 'Music'),
            Tab(text: 'Voice'),
          ],
        ),
      ),
      body: Column(
        children: [
          const CallOverlay(),
          Expanded(
            child: FutureBuilder<List<UserModel>>(
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
                    children: List.generate(7, (index) {
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
                        if (globalSearchResults.isEmpty &&
                            localSearchResultsChats.isEmpty &&
                            localSearchResultsMessages.isEmpty &&
                            remoteSearchResults.isEmpty) {
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
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              if (globalSearchResults.isNotEmpty) ...[
                                sectionName('Global Search'),
                                ..._generateChatsList(globalSearchResults),
                              ],
                              if (localSearchResultsMessages.isNotEmpty ||
                                  localSearchResultsChats.isNotEmpty ||
                                  remoteSearchResults.isNotEmpty) ...[
                                sectionName('Messages'),
                                ..._generateChatTiles(
                                  localSearchResultsChats,
                                  localSearchResultsMessages,
                                  localSearchResultsChatTitleMatches,
                                  localSearchResultsChatMessagesMatches,
                                ),
                                ..._generateChatsList(remoteSearchResults),
                              ],
                            ],
                          ),
                        );
                      }
                    }),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _generateChatsList(List<ChatModel> chats) {
    List<Widget> chatTiles = [];
    int index = 0;
    for (final chat in chats) {
      final Random random = Random();
      DateTime currentDate = DateTime.now().subtract(const Duration(days: 7));
      final MessageModel fakeMessage = MessageModel(
        senderId: ref.read(userProvider)!.id ?? '1234',
        messageType: MessageType.normal,
        messageContentType: MessageContentType.text,
        content: TextContent("Hello! This is a fake message."),
        timestamp: currentDate.add(Duration(
          hours: random.nextInt(24),
          minutes: random.nextInt(60),
        )),
        userStates: {},
      );
      final message =
          chat.messages.isNotEmpty ? chat.messages.last : fakeMessage;

      chatTiles.add(
        ChatTileWidget(
          key: ValueKey(ChatKeys.chatTilePrefix.value +
              ChatKeys.chatTilePrefixSubvalue +
              index.toString()),
          chatModel: chat,
          displayMessage: message,
          sentByUser: message.senderId == ref.read(userProvider)!.id,
          senderID: message.senderId,
          onChatSelected: (_){},
        ),
      );
      index++;
    }
    return chatTiles;
  }

  void _getSearchResults(String query, List<String> searchSpace,
      String filterType, bool isGlobalSearch) async {
    ref
        .read(homeViewModelProvider.notifier)
        .fetchSearchResults(query, searchSpace, filterType, isGlobalSearch);
  }

  List<Widget> _generateChatTiles(
      List<ChatModel> localSearchResultsChats,
      List<MessageModel> localSearchResultsMessages,
      List<List<MapEntry<int, int>>> localSearchResultsChatTitleMatches,
      List<List<MapEntry<int, int>>> localSearchResultsChatMessagesMatches) {
    List<Widget> chatTiles = [];
    int index = 0;
    for (final message in localSearchResultsMessages) {
      final ChatModel chat = localSearchResultsChats[index];
      final List<MapEntry<int, int>> chatTitleMatches =
          localSearchResultsChatTitleMatches[index];
      final List<MapEntry<int, int>> chatMessagesMatches =
          localSearchResultsChatMessagesMatches[index];
      chatTiles.add(
        ChatTileWidget(
          key: ValueKey(ChatKeys.chatTilePrefix.value +
              ChatKeys.chatTilePrefixSubvalue +
              index.toString()),
          chatModel: chat,
          displayMessage: message,
          sentByUser: message.senderId == ref.read(userProvider)!.id,
          senderID: message.senderId,
          highlights: chatMessagesMatches,
          titleHighlights: chatTitleMatches,
          onChatSelected: (_){},
        ),
      );
      index++;
    }
    return chatTiles;
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
    int currentTabIndex = _tabController.index; // Get the current tab index
    List<String> allSearchSpace = ['channels', 'groups', 'chats'];
    switch (currentTabIndex) {
      case 1:
        _getSearchResults(query, allSearchSpace, 'text', true);
        break;
      case 2:
        // channels
        _getSearchResults(query, ['channels', 'groups'], 'text', true);
        break;
      case 3:
        // media
        _getSearchResults(query, allSearchSpace, 'images/videos', false);
        break;
      case 4:
        // files
        _getSearchResults(query, allSearchSpace, 'files', false);
        break;
      case 5:
        // music
        _getSearchResults(query, allSearchSpace, 'music', false);
        break;
      case 6:
        // voice
        _getSearchResults(query, allSearchSpace, 'voice', false);
        break;
      default:
        break;
    }
  }

  void filterUserChats(String query) {
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

  void search(String query) {
    if (query.isNotEmpty) {
      _getSearchResults(query, ['channels'], 'channel', true);
    }
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
