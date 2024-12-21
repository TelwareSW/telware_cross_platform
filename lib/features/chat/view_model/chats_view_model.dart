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
import 'package:telware_cross_platform/features/chat/services/encryption_service.dart';
import 'package:telware_cross_platform/features/chat/utils/chat_utils.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';

part 'chats_view_model.g.dart';

@Riverpod(keepAlive: true)
class ChatsViewModel extends _$ChatsViewModel {
  /// The state of the class, resembles a sorted list
  /// of chats, based on the timestamp of the latest msg
  /// in them

  Map<String, UserModel> _otherUsers = <String, UserModel>{};

  @override
  List<ChatModel> build() {
    return [];
  }

  void clear() {
    state = [];
    _otherUsers = {};
  }

  void setOtherUsers(Map<String, UserModel> otherUsers) {
    _otherUsers = otherUsers;
  }

  Map<String, UserModel> getOtherUsers() {
    return _otherUsers;
  }

  List<ChatModel> getGroupChats() {
    return state.where((chat) => chat.type == ChatType.group).toList();
  }

  List<ChatModel> getPrivateChats() {
    return state.where((chat) => chat.type == ChatType.private).toList();
  }

  List<UserModel?> getChatUsers(String chatId) {
    return state
        .firstWhere((chat) => chat.id == chatId)
        .userIds
        .map((userId) => _otherUsers[userId])
        .toList();
  }

  Future<UserModel?> getUser(String id) async {
    // debugPrint('!!!** called');
    if (id == ref.read(userProvider)!.id) {
      // debugPrint('!!!** returning the current user');
      return ref.read(userProvider);
    }

    var user = _otherUsers[id];
    if (user == null) {
      if (USE_MOCK_DATA) {
        debugPrint('!!!** can\'t find a mocked user: $id');
      }
      user = await ref.read(chattingControllerProvider).getOtherUser(id);
      if (user == null) {
        return null;
      }
      _otherUsers[id] = user;
      // todo: ask the controller to restore the other users map in the local storage
      ref.read(chattingControllerProvider).restoreOtherUsers(_otherUsers);
    }

    // debugPrint('!!!** returning a user from the other users map: $user');
    return user;
  }

  void setChats(List<ChatModel> chats) {
    state = updateMessagesFilePath(chats);
  }

  void addChat(ChatModel chat) {
    state = [chat, ...state];
  }

  ({
    String msgLocalId,
    String chatId,
  }) addSentMessage({
    required MessageContent content,
    required String chatId,
    required MessageType msgType,
    required MessageContentType msgContentType,
    required String? parentMessageId,
  }) {
    final chatIndex = getChatIndex(chatId);
    final chat = state[chatIndex];
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
        parentMessage: parentMessageId);

    chat.messages.add(msg);

    _moveChatToFront(chatIndex, chat);

    return (msgLocalId: msgLocalId, chatId: chatId);
  }

  void updateMsgId({
    required String newMsgId,
    required String msgLocalId,
    required String chatId,
  }) {
    final chatIndex = getChatIndex(chatId);
    final chat = chatIndex >= 0 ? state[chatIndex] : null;

    if (chat != null) {
      debugPrint('### found the chat');

      final msgIndex =
          chat.messages.indexWhere((msg) => msg.localId == msgLocalId);

      if (msgIndex != -1) {
        final newMsg = chat.messages[msgIndex].copyWith(id: newMsgId);
        chat.messages[msgIndex] = newMsg;

        _moveChatToFront(chatIndex, chat);
      }
    }
  }

  void editMessage({
    required String msgId,
    required String content,
    required String chatId,
  }) {
    final chatIndex = getChatIndex(chatId);
    final chat = chatIndex >= 0 ? state[chatIndex] : null;

    if (chat != null) {
      final msgIndex = chat.messages.indexWhere((msg) => msg.id == msgId);

      if (msgIndex != -1) {
        final newMsg = chat.messages[msgIndex].copyWith(
          content: (chat.messages[msgIndex].content as TextContent).copyWith(
            text: content,
          ),
          isEdited: true,
        );
        chat.messages[msgIndex] = newMsg;

        state = [
          ...state.sublist(0, chatIndex),
          chat.copyWith(),
          ...state.sublist(chatIndex + 1),
        ];
      }
    }
  }

  Future<void> addReceivedMessage(Map<String, dynamic> response) async {
    var chatId = response["chatId"] as String;
    final chatIndex = getChatIndex(chatId);
    var chat = chatIndex >= 0 ? state[chatIndex] : null;

    final msgId = response['id'] as String;

    if (chat == null) {
      chat = await ref.read(chattingControllerProvider).getChat(chatId);
      state.insert(0, chat);
    }

    final msgIndex = chat.messages.indexWhere((msg) => msg.id == msgId);
    if (msgIndex != -1) return;

    Map<String, MessageState> userStates = {
      ref.read(userProvider)!.id!: MessageState.read
    };
    MessageContent? content;
    MessageContentType contentType =
        MessageContentType.getType(response['contentType'] ?? 'text');

    final encryptionService = EncryptionService.instance;

    final text = encryptionService.decrypt(
      chatType: chat.type,
      msg: response['content'],
      encryptionKey: chat.encryptionKey,
      initializationVector: chat.initializationVector,
    );

    // todo: needs to be modified to match the response fields
    content = createMessageContent(
      contentType: contentType,
      text: text,
      fileName: response['content'],
      mediaUrl: response['media'],
    );

    final msg = MessageModel(
      id: msgId,
      senderId: response['senderId'],
      messageContentType: contentType,
      messageType: MessageType.getType(response['type'] ?? 'unknown'),
      content: content,
      timestamp: response['timestamp'] == null
          ? DateTime.parse(response['timestamp'])
          : DateTime.now(),
      userStates: userStates,
      parentMessage: response['parentMessageId'],
      isPinned: response['isPinned'],
      isForward: response['isForward'],
    );

    chat.messages.add(msg);

    _moveChatToFront(chatIndex, chat);
  }

  bool pinMessage(String msgId, String chatId) {
    final chatIndex = getChatIndex(chatId);
    final chat = chatIndex >= 0 ? state[chatIndex] : null;

    if (chat == null) return false;
    final msgIndex = chat.messages.indexWhere((msg) => msg.id == msgId);

    if (msgIndex != -1) {
      final newMsg = chat.messages[msgIndex]
          .copyWith(isPinned: !(chat.messages[msgIndex].isPinned));
      chat.messages[msgIndex] = newMsg;

      state = [
        ...state.sublist(0, chatIndex),
        chat.copyWith(),
        ...state.sublist(chatIndex + 1),
      ];
      return newMsg.isPinned;
    }

    return false;
  }

  void deleteMessage(String msgId, String chatId) {
    final chatIndex = getChatIndex(chatId);
    final chat = state[chatIndex];

    final msgIndex = chat.messages.indexWhere(
      (msg) => msg.id == msgId || msg.localId == msgId,
    );

    if (msgIndex != -1) {
      chat.messages.removeAt(msgIndex);
      state = [
        ...state.sublist(0, chatIndex),
        chat.copyWith(),
        ...state.sublist(chatIndex + 1),
      ];
    }
  }

  String? getMsgGlobalId(String msgLocalId, String chatId) {
    final chatIndex = getChatIndex(chatId);
    final chat = state[chatIndex];

    final msgIndex = chat.messages.indexWhere(
      (msg) => msg.id == msgLocalId || msg.localId == msgLocalId,
    );

    return msgIndex > -1 ? chat.messages[msgIndex].id : null;
  }

  ChatModel? getChatById(String chatId) {
    final chatIndex = getChatIndex(chatId);
    return chatIndex > 0 ? state[chatIndex] : null;
  }

  void _moveChatToFront(int chatIndex, ChatModel chat) {
    final updatedState = List<ChatModel>.from(state)..removeAt(chatIndex);
    state = [chat, ...updatedState];
    debugPrint('!!! List is update, a chat moved to front');
  }

  int getChatIndex(String chatId) =>
      state.indexWhere((chat) => chat.id == chatId);

  void updateMessageFilePath(
      String chatId, String messageLocalId, String filePath) {
    final chatIndex = getChatIndex(chatId);
    final chat = state[chatIndex];
    // Find the msg with the specified ID
    final msgIndex = chat.messages.indexWhere(
        (msg) => msg.localId == messageLocalId || msg.id == messageLocalId);

    if (msgIndex != -1) {
      MessageModel? message = chat.messages[msgIndex];

      debugPrint("Updating the file path to $filePath");
      message = updateMessageIfFileMissing(message, filePath);

      chat.messages[msgIndex] =
          chat.messages[msgIndex].copyWith(content: message.content);
      debugPrint(
          "hmmmmmm  ${chat.messages[msgIndex].content?.toJson()["filePath"]}");
      state = List.from(state); // Update the state to trigger a rebuild
    }
  }

  void muteChat(String chatId, int muteUntilSeconds) {
    final chatIndex = getChatIndex(chatId);
    final chat = state[chatIndex];
    DateTime? muteUntil = muteUntilSeconds == -1
        ? null
        : DateTime.now().add(Duration(seconds: muteUntilSeconds));

    chat.copyWith(isMuted: true, muteUntil: muteUntil);
    state = List.from(state);
  }

  void unmuteChat(String chatId) {
    final chatIndex = getChatIndex(chatId);
    final chat = state[chatIndex];
    chat.copyWith(isMuted: false, muteUntil: null);
    state = List.from(state);
  }

  void updateDraft(String chatId, String draft) {
    final chatIndex = getChatIndex(chatId);
    final chat = state[chatIndex];
    chat.copyWith(draft: draft);
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
      ),
    );
  }
}
