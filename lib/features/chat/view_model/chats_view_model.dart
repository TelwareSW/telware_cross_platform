import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/mock/constants_mock.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';

import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';

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
    _chatsMap = <String, ChatModel>{for (var chat in state) chat.id!: chat};
  }

  void addChat(ChatModel chat) {
    _chatsMap[chat.id!] = chat;
    state = [chat, ...state];
  }

  Map<String, String> addSentMessage(
    MessageContent content,
    String chatID,
    MessageType msgType,
    MessageContentType msgContentType,
  ) {
    final chat = _chatsMap[chatID];
    // todo(ahmed): make sure that new chats are added to the map first
    // I mean, new chats from the backend

    final senderId = ref.read(userProvider)!.id!;
    final msgLocalId =
        senderId + DateTime.now().millisecondsSinceEpoch.toString();
    final MessageModel msg = MessageModel(
      senderId: senderId,
      timestamp: DateTime.now(),
      content: content,
      messageContentType: msgContentType,
      messageType: msgType,
      userStates: {},
      id: USE_MOCK_DATA ? getUniqueMessageId() : null,
      localId: msgLocalId,
    );


    chat!.messages.add(msg);
    _chatsMap[chatID] = chat;
    _moveChatToFront(chatID);

    return {'msgLocalId': msgLocalId, 'chatId': chatID};
  }

  void updateMsgId(String newMsgId, Map<String, String> identifiers) {
    String msgLocalId = identifiers['msgLocalId']!,
        chatId = identifiers['chatId']!;

    final chat = _chatsMap[chatId];
    if (chat != null) {
      debugPrint('### found the chat');

      final index =
          chat.messages.indexWhere((msg) => msg.localId == msgLocalId);

      if (index != -1) {
        final newMsg = chat.messages[index].copyWith(id: newMsgId);
        chat.messages[index] = newMsg;
        _chatsMap[chatId] = chat;
        final newState = state.map((chat2) => chat2.id == chat.id ? chat : chat2.copyWith()).toList();
        state = newState;
      }
    }
  }

  Future<void> addReceivedMessage(Map<String, dynamic> response) async {
    var chatID = response["chatId"] as String;
    var chat = _chatsMap[chatID];

    Map<String, MessageState> userStates = {};
    MessageContentType contentType =
        MessageContentType.getType(response['contentType'] ?? 'text');
    MessageContent? content;

    final Map<String, String> userStatesMap = response['userStates'] ?? {
      response['senderId']: 'read',
      ref.read(userProvider)!.id!: 'read'
    };

    for (var entry in userStatesMap.entries) {
      userStates[entry.key] = MessageState.getType(entry.value);
    }

    switch (contentType.content) {
      case 'text':
      case 'link':
        content = TextContent(response['content']);
        break;
      case 'image':
        content = ImageContent();
        break;
      case 'video':
        content = VideoContent();
        break;
      case 'audio':
        content = AudioContent();
        break;
      case 'document':
        content =
            DocumentContent(fileName: response['fileName'] ?? "UnknownFile");
        break;
      case 'sticker':
        content = StickerContent(
            stickerUrl: response['stickerUrl'] ?? "UnknownSticker");
        break;
      case 'gif':
        content = GIFContent(gifUrl: response['gifUrl'] ?? "UnknownGif");
        break;
      case 'emoji':
        content =
            EmojiContent(emojiUrl: response['emojiUrl'] ?? "UnknownEmoji");
        break;
      default:
        debugPrint('!!! Unknown content type: ${contentType.content}');
    }

    final msg = MessageModel(
      id: response['id'],
      senderId: response['senderId'],
      messageContentType: contentType,
      messageType: MessageType.getType(response['type'] ?? 'unknown'),
      content: content,
      timestamp: response['timestamp'] == null
          ? DateTime.parse(response['timestamp'])
          : DateTime.now(),
      userStates: userStates,
    );

    if (chat == null) {
      chat = await ref.read(chattingControllerProvider).getChat(chatID);
      _chatsMap[chatID] = chat;
      state.insert(0, chat);
    }

    chat.messages.add(msg);
    _chatsMap[chatID] = chat;
    _moveChatToFront(chatID);
  }

  void deleteMessage(String msgID, String chatID) {
    final chat = _chatsMap[chatID];
    final msgIndex = chat!.messages.indexWhere((msg) => msg.id == msgID);

    if (msgIndex != -1) {
      chat.messages.removeAt(msgIndex);
      state = [...state];
    }
  }

  void editMessage(String msgID, String chatID, MessageContent content) {
    final chat = _chatsMap[chatID];
    // Find the msg with the specified ID
    final msgIndex = chat!.messages.indexWhere((msg) => msg.id == msgID);

    if (msgIndex != -1) {
      chat.messages[msgIndex].copyWith(content: content);
    }

    // _moveChatToFront(chatID);
  }

  ChatModel? getChatById(String chatId) {
    return _chatsMap[chatId];
  }

  void _moveChatToFront(String id) {
    // Find the chat with the specified ID
    final chatIndex = state.indexWhere((chat) => chat.id == id);

    if (chatIndex != -1) {
      // Remove the chat from its current position
      final updatedState = List<ChatModel>.from(state)..removeAt(chatIndex);
      // Insert the chat at the front of the list
      final newChat = _chatsMap[id];
      state = [newChat!, ...updatedState];
      debugPrint('!!! List is update, a chat moved to front');
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
    _chatsMap[chatID] = chat;
    state = List.from(state);
  }

  void unmuteChat(String chatID) {
    final chat = _chatsMap[chatID];
    chat!.copyWith(isMuted: false, muteUntil: null);
    _chatsMap[chatID] = chat;
    state = List.from(state);
  }

  void updateDraft(String chatID, String draft) {
    final chat = _chatsMap[chatID];
    chat!.copyWith(draft: draft);
    _chatsMap[chatID] = chat;
    state = List.from(state);
  }

  ChatModel getChat(UserModel myInfo, UserModel otherInfo, ChatType private) {
    return state.firstWhere(
        (chat) =>
            chat.type == private &&
            chat.userIds.contains(myInfo.id) &&
            chat.userIds.contains(otherInfo.id),
        orElse: () => ChatModel(
          title: '${otherInfo.screenFirstName} ${otherInfo.screenLastName}',
          userIds: [myInfo.id!, otherInfo.id!],
          type: ChatType.private,
          messages: [],
          photo: otherInfo.photo,
        )
    );
  }
}
