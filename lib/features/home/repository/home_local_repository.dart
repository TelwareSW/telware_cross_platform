import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';

part 'home_local_repository.g.dart';

@Riverpod(keepAlive: true)
HomeLocalRepository homeLocalRepository(HomeLocalRepositoryRef ref) {
  return HomeLocalRepository(ref: ref);
}

class HomeLocalRepository {
  final ProviderRef<HomeLocalRepository> _ref;

  HomeLocalRepository({
    required ProviderRef<HomeLocalRepository> ref,
  }) : _ref = ref;

  ({
    List<List<MapEntry<int, int>>> searchResultsChatMessagesMatches,
    List<List<MapEntry<int, int>>> searchResultsChatTitleMatches,
    List<ChatModel> searchResultsChats,
    List<MessageModel> searchResultsMessages,
  }) searchLocally(
    String query,
    String filterType,
  ) {
    List<ChatModel> privateChats =
        _ref.read(chatsViewModelProvider.notifier).getPrivateChats();
    List<ChatModel> searchResultsChats = [];
    List<MessageModel> searchResultsMessages = [];
    List<List<MapEntry<int, int>>> searchResultsChatTitleMatches = [];
    List<List<MapEntry<int, int>>> searchResultsChatMessagesMatches = [];

    for (ChatModel chat in privateChats) {
      List<MessageModel> messages = chat.messages;
      bool hasMatch = false;
      for (MessageModel message in messages) {
        if (message.content != null) {
          String contentType = message.messageContentType.content;
          MessageContent content = message.content as MessageContent;
          if (contentType == "audio") {
            AudioContent audioContent = content as AudioContent;
            if (audioContent.isMusic == true) {
              contentType = "music";
            } else {
              contentType = "voice";
            }
          }

          if (filterType.split(',').contains(contentType)) {
            List<MapEntry<int, int>> matches =
                shiftHighlights(contentType, kmp(content.getContent(), query));
            if (matches.isNotEmpty) {
              hasMatch = true;
              List<MapEntry<int, int>> chatTitleMatches =
                  kmp(chat.title, query);
              searchResultsChats.add(chat);
              searchResultsMessages.add(message);
              searchResultsChatMessagesMatches.add(matches);
              if (chatTitleMatches.isNotEmpty) {
                searchResultsChatTitleMatches.add(chatTitleMatches);
              }
            }
          }
        }
      }
      if (!hasMatch && filterType.split(',').contains('text')) {
        List<MapEntry<int, int>> chatTitleMatches = kmp(chat.title, query);
        if (chatTitleMatches.isNotEmpty) {
          searchResultsChats.add(chat);
          searchResultsMessages.add(chat.messages.isNotEmpty
              ? chat.messages.last
              : createFakeMessage(chat));
          searchResultsChatMessagesMatches.add([]);
          searchResultsChatTitleMatches.add(chatTitleMatches);
        }
      }
    }
    return (
      searchResultsChats: searchResultsChats,
      searchResultsMessages: searchResultsMessages,
      searchResultsChatTitleMatches: searchResultsChatTitleMatches,
      searchResultsChatMessagesMatches: searchResultsChatMessagesMatches
    );
  }
}

MessageModel createFakeMessage(ChatModel chat) {
  final Random random = Random();
  DateTime currentDate = DateTime.now().subtract(const Duration(days: 7));
  final MessageModel fakeMessage = MessageModel(
    senderId: "fake",
    messageType: MessageType.normal,
    messageContentType: MessageContentType.text,
    content: TextContent('Last seen recently'),
    timestamp: currentDate.add(Duration(
      hours: random.nextInt(24),
      minutes: random.nextInt(60),
    )),
    userStates: {},
  );
  return fakeMessage;
}
