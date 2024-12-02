import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/mock/constants_mock.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';

import 'package:telware_cross_platform/features/chat/classes/message_content.dart';

import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/utils/chat_utils.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';

part 'chats_view_model.g.dart';

@Riverpod(keepAlive: true)
class ChatsViewModel extends _$ChatsViewModel {
  /// The state of the class, respembels a sorted list

  /// of chats, based on the timestamp of the latest msg

  /// in them

  Map<String, ChatModel> _chatsMap = <String, ChatModel>{};
  Map<String, UserModel> _otherUsers = <String, UserModel>{};

  @override
  List<ChatModel> build() {
    return [];
  }

  void setOtherUsers(Map<String, UserModel> otherUsers) {
    _otherUsers = otherUsers;
  }

  Future<UserModel?> getUser(String ID) async {
    if (ID == ref.read(userProvider)!.id) {
      return ref.read(userProvider);
    }

    var user = _otherUsers[ID];
    if (user == null) {
      if (USE_MOCK_DATA) {
        debugPrint('!!!** can\'t find a mocked user: $ID');
      }
      user = await ref.read(chattingControllerProvider).getOtherUser(ID);
      if (user == null) {
        return null;
      }
      _otherUsers[ID] = user;
      // todo: ask the controller to restore the other users map in the local storage
      ref.read(chattingControllerProvider).restoreOtherUsers(_otherUsers);
    }

    return user;
  }

  void setChats(List<ChatModel> chats) {
    state = updateMessagesFilePath(chats);
    _chatsMap.clear();
    _chatsMap = <String, ChatModel>{for (var chat in chats) chat.id!: chat};
  }

  void addChat(ChatModel chat) {
    state.insert(0, chat);
    _chatsMap[chat.id!] = chat;
  }

  void addSentMessage(MessageContent content, String chatID,
      MessageType msgType, MessageContentType msgContentType) {
    final chat = _chatsMap[chatID];
    // todo(ahmed): make sure that new chats are added to the map first
    // I mean, new chats from the backend

    final MessageModel msg = MessageModel(
      senderId: ref.read(userProvider)!.id!,
      timestamp: DateTime.now(),
      content: content,
      messageContentType: msgContentType,
      messageType: msgType,
      userStates: {},
      id: USE_MOCK_DATA ? getUniqueMessageId() : null,
    );

    chat!.messages.add(msg);
    _moveChatToFront(chatID);
  }

  Future<void> addReceivedMessage(String chatID, MessageModel msg) async {
    var chat = _chatsMap[chatID];

    if (chat == null) {
      chat = await ref.read(chattingControllerProvider).getChat(chatID);
      _chatsMap[chatID] = chat;
      state.insert(0, chat);
    }

    chat.messages.insert(0, msg);
    _moveChatToFront(chatID);
  }

  void deleteMessage(String msgID, String chatID) {
    final chat = _chatsMap[chatID];
    // todo: check if msg is really deleted or just not showed
    // Find the msg with the specified ID
    final msgIndex = chat!.messages.indexWhere((msg) => msg.id == msgID);

    if (msgIndex != -1) {
      chat.messages.removeAt(msgIndex);
    }
  }

  void editMessage(String msgID, String chatID, MessageContent content) {
    final chat = _chatsMap[chatID];
    // Find the msg with the specified ID
    final msgIndex = chat!.messages.indexWhere((msg) => msg.id == msgID);

    if (msgIndex != -1) {
      chat.messages[msgIndex].copyWith(content: content);
    }
  }

  ChatModel? getChatById(String chatId) {
    return _chatsMap[chatId];
  }

  void _moveChatToFront(String id) {
    // Find the chat with the specified ID
    final chatIndex = state.indexWhere((chat) => chat.id == id);

    if (chatIndex != -1) {
      // Remove the chat from its current position
      final chat = state.removeAt(chatIndex);

      // Insert the chat at the front of the list
      state.insert(0, chat);
    }
  }

  void updateMessageFilePath(String chatID, String msgID, String filePath) {
    final chat = _chatsMap[chatID];
    // Find the msg with the specified ID
    final msgIndex = chat!.messages.indexWhere((msg) => msg.id == msgID);

    if (msgIndex != -1) {
      MessageContent? content = chat.messages[msgIndex].content;
      if (content == null ||
          chat.messages[msgIndex].messageContentType ==
              MessageContentType.text) {
        return;
      }
      final message = chat.messages[msgIndex];
      debugPrint("Updating the file path to $filePath");
      switch (message.messageContentType) {
        case MessageContentType.image:
          content = (content as ImageContent).copyWith(filePath: filePath);
          break;

        case MessageContentType.video:
          content = (content as VideoContent).copyWith(filePath: filePath);
          break;

        case MessageContentType.audio:
          content = (content as AudioContent).copyWith(filePath: filePath);
          break;

        case MessageContentType.file:
          content = (content as DocumentContent).copyWith(filePath: filePath);
          break;
        default:
          break;
      }
      chat.messages[msgIndex] =
          chat.messages[msgIndex].copyWith(content: content);
      debugPrint(
          "hmmmmmm  ${chat.messages[msgIndex].content?.toJson()["filePath"]}");
      _chatsMap[chatID] = chat;
      state = List.from(state); // Update the state to trigger a rebuild
    }
  }

  void muteChat(String chatID, int muteUntilSeconds) {
    final chat = _chatsMap[chatID];
    DateTime muteUntil = muteUntilSeconds == -1
        ? DateTime.now().add(const Duration(days: 365 * 100))
        : DateTime.now().add(Duration(seconds: muteUntilSeconds));
    chat!.copyWith(isMuted: true, muteUntil: muteUntil);
  }

  void unmuteChat(String chatID) {
    final chat = _chatsMap[chatID];
    chat!.copyWith(isMuted: false, muteUntil: null);
  }
}
