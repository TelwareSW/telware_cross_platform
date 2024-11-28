import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/mock/user_mock.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/services/socket_service.dart';
import 'package:telware_cross_platform/features/chat/models/enums.dart';
import 'package:telware_cross_platform/features/chat/models/message_event_models.dart';
import 'package:telware_cross_platform/features/chat/repository/chat_local_repository.dart';
import 'package:telware_cross_platform/features/chat/repository/chat_remote_repository.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:telware_cross_platform/features/chat/view_model/event_handler.dart';

part 'chatting_controller.g.dart';

@Riverpod(keepAlive: true)
ChattingController chattingController(Ref ref) {
  final remoteRepo = ChatRemoteRepository(
    dio: Dio(BASE_OPTIONS),
  );

  final localRepo = ChatLocalRepository(
      chatsBox: Hive.box<List<ChatModel>>('chats-box'),
      eventsBox: Hive.box<List<MessageEvent>>('chatting-events-box'),
      otherUsersBox: Hive.box<Map<String, UserModel>>('other-users-box'));

  return ChattingController(
    localRepository: localRepo,
    remoteRepository: remoteRepo,
    ref: ref,
  );
}

class ChattingController {
  late final EventHandler _eventHandler;
  final ChatRemoteRepository _remoteRepository;
  final ChatLocalRepository _localRepository;
  final Ref _ref;

  ChattingController({
    required ChatRemoteRepository remoteRepository,
    required ChatLocalRepository localRepository,
    required Ref ref,
  })  : _remoteRepository = remoteRepository,
        _localRepository = localRepository,
        _ref = ref {
    EventHandler.config(controller: this, socket: SocketService.instance);
    _eventHandler = EventHandler.instance;
  }

  Future<void> getUserChats() async {
    _remoteRepository.getUserChats(_ref.read(tokenProvider)!);
  }

  Future<void> init() async {
    // get the chats and give it to the chats view model from local
    final chats = _localRepository.getChats();
    _ref.read(chatsViewModelProvider.notifier).setChats(chats);

    // get the users list from local
    final otherUsers = _localRepository.getOtherUsers();
    _ref.read(chatsViewModelProvider.notifier).setOtherUsers(otherUsers);

    // get the events and give it to the handler from local
    final events = _localRepository.getEventQueue();
    _eventHandler.init(events);
  }

  /// Send a text message.
  /// Must specify either the chatID or userID in case of new chat,
  /// otherwise, it will throw an error
  void sendMsg(String content, {String? chatID, String? userID}) {
    // todo: handle new chats case
    if (chatID == null && userID == null) {
      throw Exception('specify the chatID, or userID in case of new chats');
    }

    final MessageModel msg = MessageModel(
      senderName: _ref.read(userProvider)!.screenName,
      timestamp: DateTime.now(),
      content: content, 
    );

    final msgEvent = SendMessageEvent(this, {
      'chatId': chatID ?? userID,
      'content': content,
      'contentType': 'text',
      'senderId': _ref.read(userProvider)!.id,
      'isFirstTime': chatID == null
    });

    _eventHandler.addEvent(msgEvent);

    // todo: handle new chats case ----------------------------------!
    _ref.read(chatsViewModelProvider.notifier).addMessage(msg, chatID!);
  }

  // delete a message
  void deleteMsg(String msgID, String chatID, DeleteMsgType deleteType) {
    final msgEvent = DeleteMessageEvent(this, {
      'chatId': chatID,
      'senderId': _ref.read(userProvider)!.id,
      'messageId': msgID,
      'deleteType': deleteType.name
    });

    _eventHandler.addEvent(msgEvent);

    _ref.read(chatsViewModelProvider.notifier).deleteMessage(msgID, chatID);
  }

  // edit a message
  void editMsg(String msgID, String chatID, String content) {
    final msgEvent = DeleteMessageEvent(this, {
      'chatId': chatID,
      'senderId': _ref.read(userProvider)!.id,
      'messageId': msgID,
      'content': content
    });

    _eventHandler.addEvent(msgEvent);

    _ref.read(chatsViewModelProvider.notifier).editMessage(msgID, chatID, content);
  }

  // recieve a message

  Future<UserModel> getOtherUser(String id) async {
    // todo: call the remote repo and get the other user from server
    _remoteRepository.getOtherUser(id);
    return userMock;
  }

  void restoreOtherUsers(Map<String, UserModel> otherUsers) {
    _localRepository.setOtherUsers(otherUsers);
  }
}
