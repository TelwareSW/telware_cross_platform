import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/mock/constants_mock.dart';
import 'package:telware_cross_platform/core/mock/user_mock.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/services/socket_service.dart';

import 'package:telware_cross_platform/features/chat/classes/message_content.dart';

import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/models/message_event_models.dart';
import 'package:telware_cross_platform/features/chat/repository/chat_local_repository.dart';
import 'package:telware_cross_platform/features/chat/repository/chat_remote_repository.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/features/chat/services/chat_mocking_service.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:telware_cross_platform/features/chat/view_model/event_handler.dart';

part 'chatting_controller.g.dart';

@Riverpod(keepAlive: true)
ChattingController chattingController(Ref ref) {
  final remoteRepo = ChatRemoteRepository(
    dio: Dio(BASE_OPTIONS),
  );

  final localRepo = ChatLocalRepository(
      chatsBox: Hive.box<List>('chats-box'),
      eventsBox: Hive.box<List>('chatting-events-box'),
      otherUsersBox: Hive.box<Map>('other-users-box'));

  return ChattingController(
    localRepository: localRepo,
    remoteRepository: remoteRepo,
    ref: ref,
  );
}

class ChattingController {
  // todo: transform this into a NotifierProvider
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
    // todo: make use of the return of this
    _remoteRepository.getUserChats(
        _ref.read(tokenProvider)!, _ref.read(userProvider)!.id!);
  }

  Future<void> init() async {
    debugPrint('!!! tried to enter controller init');
    debugPrint('!!! enter controller init');
    // get the chats and give it to the chats view model from local
    final chats = _localRepository.getChats();
    debugPrint('!!! chats list length ${chats.length}');
    _ref.read(chatsViewModelProvider.notifier).setChats(chats);

    // get the users list from local
    final otherUsers = _localRepository.getOtherUsers();
    _ref.read(chatsViewModelProvider.notifier).setOtherUsers(otherUsers);

    // get the events and give it to the handler from local
    final events = _localRepository.getEventQueue();
    final newEvents = events.map((e) => e.copyWith(controller: this));
    _eventHandler.init(Queue<MessageEvent>.from(newEvents.toList()));
  }

  Future<void> newLoginInit() async {
    debugPrint('!!! newLoginInit called');
    if (USE_MOCK_DATA) {
      final mocker = ChatMockingService.instance;

      final response =
          await mocker.createMockedChats(20, _ref.read(tokenProvider)!);
      // descending sorting for the chats, based on last message

      response.chats.sort(
        (a, b) => b.messages[0].timestamp.compareTo(
          a.messages[0].timestamp,
        ),
      );

      final otherUsersMap = <String, UserModel>{
        for (var user in response.users) user.id!: user
      };

      debugPrint((await _localRepository.setChats(response.chats)).toString());

      debugPrint(
          (await _localRepository.setOtherUsers(otherUsersMap)).toString());

      debugPrint('!!! ended the newLoginInit mock');
      return;
    }

    final response = await _remoteRepository.getUserChats(
        _ref.read(tokenProvider)!, _ref.read(userProvider)!.id!);

    if (response.appError != null) {
      // todo(ahmed): for the notifier provider, return a state of fail
    } else {
      // descending sorting for the chats, based on last message
      response.chats.sort(
        (a, b) {
          if (a.messages.isEmpty || b.messages.isEmpty) {
            return 0;
          }
          return b.messages[0].timestamp.compareTo(a.messages[0].timestamp);
        },
      );

      final otherUsersMap = <String, UserModel>{
        for (var user in response.users) user.id!: user
      };

      _localRepository.setChats(response.chats);
      _localRepository.setOtherUsers(otherUsersMap);
      debugPrint('!!! ended the newLoginInit');
    }
  }

  /// Send a text message.
  /// Must specify either the chatID or userID in case of new chat,
  /// otherwise, it will throw an error

  Future<void> sendMsg({
    required MessageContent content,
    required MessageType msgType,
    required MessageContentType contentType,
    required ChatType chatType,
    ChatModel? chatModel,
    String? userID,
  }) async {
    String? chatID = chatModel?.id;
    bool isChatNew = chatID == null;

    if (chatID == null && chatModel != null) {
      // Create a new chat if chatID is null
      final response = await _remoteRepository.createChat(
        _ref.read(tokenProvider)!,
        chatModel.title,
        chatModel.getChatTypeString(),
        chatModel.userIds,
      );

      if (response.appError != null) {
        debugPrint('Error: Could not create the chat');
      } else {
        chatID = response.chat!.id;
        chatModel.id = chatID;
        _ref.read(chatsViewModelProvider.notifier).addChat(response.chat!);
      }
    }


    _ref.read(chatsViewModelProvider.notifier).addSentMessage(content, chatID!, msgType, contentType);
    _localRepository.setChats(_ref.read(chatsViewModelProvider));

    final msgEvent = SendMessageEvent({
      'chatId': chatID,
      'content': content,
      'contentType': contentType.content,
      'senderId': _ref.read(userProvider)!.id,
      'isFirstTime': isChatNew,
      'chatType': chatType.type
    }, controller: this);

    _eventHandler.addEvent(msgEvent);
  }

  void receiveMsg(String chatID, MessageModel msg) {
    _ref.read(chatsViewModelProvider.notifier).addReceivedMessage(chatID, msg);
    _localRepository.setChats(_ref.read(chatsViewModelProvider));
  }

  // delete a message
  void deleteMsg(String msgID, String chatID, DeleteMessageType deleteType) {
    final msgEvent = DeleteMessageEvent({
      'chatId': chatID,
      'senderId': _ref.read(userProvider)!.id,
      'messageId': msgID,
      'deleteType': deleteType.name
    }, controller: this);

    _eventHandler.addEvent(msgEvent);

    _ref.read(chatsViewModelProvider.notifier).deleteMessage(msgID, chatID);
    _localRepository.setChats(_ref.read(chatsViewModelProvider));
  }

  // edit a message

  void editMsg(String msgID, String chatID, MessageContent content) {
    final msgEvent = DeleteMessageEvent({
      'chatId': chatID,
      'senderId': _ref.read(userProvider)!.id,
      'messageId': msgID,
      'content': content
    }, controller: this);

    _eventHandler.addEvent(msgEvent);

    _ref
        .read(chatsViewModelProvider.notifier)
        .editMessage(msgID, chatID, content);
    _localRepository.setChats(_ref.read(chatsViewModelProvider));
  }

  // receive a message

  Future<ChatModel> getChat(String chatID) async {
    final sessionID = _ref.read(tokenProvider);
    final response = await _remoteRepository.getChat(sessionID!, chatID);
    return response.chat!;
  }


  Future<UserModel?> getOtherUser(String id) async {
    UserModel? user =
        await _remoteRepository.getOtherUser(_ref.read(tokenProvider)!, id);
    return user;
  }

  void restoreOtherUsers(Map<String, UserModel> otherUsers) {
    _localRepository.setOtherUsers(otherUsers);
  }

  Future<void> muteChat(String chatID, DateTime? muteUntil) async {
    // Get muteUntil in seconds from today
    final muteUntilSeconds = muteUntil!.difference(DateTime.now()).inSeconds > 10 * 365 * 24 * 60 * 60
        ? -1 : muteUntil.difference(DateTime.now()).inSeconds;

    if (USE_MOCK_DATA) {
      final chats = _localRepository.getChats();
      final chat = chats.firstWhere((element) => element.id == chatID);
      final updatedChat = chat.copyWith(isMuted: true, muteUntil: muteUntil);
      final updatedChats = chats.map((e) => e.id == chatID ? updatedChat : e).toList();
      _localRepository.setChats(updatedChats);
      return;
    }

    final response = await _remoteRepository.muteChat(
      _ref.read(tokenProvider)!,
      chatID,
      muteUntilSeconds
    );

    if (response.appError != null) {
      debugPrint('Error: Could not mute the chat');
    } else {
      _ref.read(chatsViewModelProvider.notifier).muteChat(chatID, muteUntilSeconds);
      _localRepository.setChats(_ref.read(chatsViewModelProvider));
    }
  }

  Future<void> unmuteChat(String chatID) async {
    if (USE_MOCK_DATA) {
      final chats = _localRepository.getChats();
      final chat = chats.firstWhere((element) => element.id == chatID);
      final updatedChat = chat.copyWith(isMuted: false, muteUntil: null);
      final updatedChats = chats.map((e) => e.id == chatID ? updatedChat : e).toList();
      _localRepository.setChats(updatedChats);
      return;
    }

    final response = await _remoteRepository.unmuteChat(
      _ref.read(tokenProvider)!,
      chatID,
    );

    if (response.appError != null) {
      debugPrint('Error: Could not unmute the chat');
    } else {
      _ref.read(chatsViewModelProvider.notifier).unmuteChat(chatID);
      _localRepository.setChats(_ref.read(chatsViewModelProvider));
    }
  }
}
