import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';

part 'chats_view_model.g.dart';

@Riverpod(keepAlive: true)
class ChatsViewModel extends _$ChatsViewModel {
  /// The state of the class, respembels a sorted list
  /// of chats, based on the timesatmp of the latest msg
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

  Future<UserModel> getUser(String ID) async {
    var user = _otherUsers[ID];

    if (user == null) {
      user = await ref.read(chattingControllerProvider).getOtherUser(ID);
      _otherUsers[ID] = user;
      // todo: ask the controller to restore the other users map in the local storage
      ref.read(chattingControllerProvider).restoreOtherUsers(_otherUsers);
    }

    return user;
  }

  void setChats(List<ChatModel> chats) {
    state = chats;
    _chatsMap.clear();
    _chatsMap = <String, ChatModel>{for (var chat in chats) chat.id!: chat};
  }

  void addSentMessage(String content, String chatID, MessageType msgType) {
    final chat = _chatsMap[chatID];
    // todo(ahmed): make sure that new chats are added to the map first
    // I mean, new chats from the backend

    final MessageModel msg = MessageModel(
      senderId: ref.read(userProvider)!.id!,
      timestamp: DateTime.now(),
      content: content,
      messageType: msgType,
    );

    chat!.messages.insert(0, msg);
    _moveChatToFront(chatID);
  }

  Future<void> addReceivedMessage(String chatID, MessageModel msg) async {
    var chat = _chatsMap[chatID];

    if (chat == null) {
      chat = await ref.read(chattingControllerProvider).getChat(chatID);
      _chatsMap[chatID] = chat;
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

  void editMessage(String msgID, String chatID, String content) {
    final chat = _chatsMap[chatID];
    // Find the msg with the specified ID
    final msgIndex = chat!.messages.indexWhere((msg) => msg.id == msgID);

    if (msgIndex != -1) {
      chat.messages[msgIndex].copyWith(content: content);
    }
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
}
