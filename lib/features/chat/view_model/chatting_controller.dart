import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/mock/constants_mock.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/token_provider.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/services/socket_service.dart';

import 'package:telware_cross_platform/features/chat/classes/message_content.dart';

import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/models/message_event_models.dart';
import 'package:telware_cross_platform/features/chat/providers/call_provider.dart';
import 'package:telware_cross_platform/features/chat/repository/chat_local_repository.dart';
import 'package:telware_cross_platform/features/chat/repository/chat_remote_repository.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/features/chat/services/chat_mocking_service.dart';
import 'package:telware_cross_platform/features/chat/services/encryption_service.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:telware_cross_platform/features/chat/view_model/event_handler.dart';

part 'chatting_controller.g.dart';

@Riverpod(keepAlive: true)
ChattingController chattingController(Ref ref) {
  final remoteRepo = ChatRemoteRepository(
    dio: Dio(CHAT_BASE_OPTIONS),
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
    EventHandler.config(
        controller: this,
        socket: SocketService.instance,
        userId: _ref.read(userProvider)!.id!,
        sessionId: _ref.read(tokenProvider)!);
    _eventHandler = EventHandler.instance;
  }

  Future<void> getUserChats() async {
    // todo: make use of the return of this
    final response = await _remoteRepository.getUserChats(
        _ref.read(tokenProvider)!, _ref.read(userProvider)!.id!);
    final String userId = _ref.read(userProvider)!.id!;
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

      // update the local storage chat's info using the response but not override it
      final chats = _localRepository.getChats(userId);
      final updatedChats = response.chats.map((chat) {
        final ChatModel localChat = chats
            .firstWhere((element) => element.id == chat.id, orElse: () => chat);
        if (localChat.id == chat.id) {
          return chat;
        }
        return localChat.copyWith(
          userIds: chat.userIds,
          photo: chat.photo,
          admins: chat.admins,
          description: chat.description,
          isMuted: chat.isMuted,
          muteUntil: chat.muteUntil,
        );
      }).toList();

      _localRepository.setChats(updatedChats, userId);
      _localRepository.setOtherUsers(response.users, userId);
      debugPrint('!!! ended the newLoginInit');
    }
  }

  Future<void> init() async {
    debugPrint('!!! tried to enter controller init');
    debugPrint('!!! enter controller init');
    // get the chats and give it to the chats view model from local
    final chats = _localRepository.getChats(_ref.read(userProvider)!.id!);
    debugPrint('!!! chats list length ${chats.length}');
    _ref.read(chatsViewModelProvider.notifier).setChats(chats);

    // get the users list from local
    final otherUsers =
        _localRepository.getOtherUsers(_ref.read(userProvider)!.id!);
    // * the next three lines are for dubuging
    // String ids = '';
    // otherUsers.forEach((key, _) => ids += '$key\n');
    // debugPrint('!!! OtherUsers Map ID\'s: $ids');
    _ref.read(chatsViewModelProvider.notifier).setOtherUsers(otherUsers);

    // get the events and give it to the handler from local
    final events = _localRepository.getEventQueue(_ref.read(userProvider)!.id!);
    final newEvents = events.map((e) => e.copyWith(controller: this));
    _eventHandler.init(
      Queue<MessageEvent>.from(
        newEvents.toList(),
      ),
      userId: _ref.read(userProvider)!.id!,
      sessionId: _ref.read(tokenProvider)!,
    );
  }

  Future<void> newLoginInit() async {
    debugPrint('!!! newLoginInit called');
    if (USE_MOCK_DATA) {
      final mocker = ChatMockingService.instance;

      final response =
          await mocker.createMockedChats(20, _ref.read(userProvider)!.id!);
      // descending sorting for the chats, based on last message

      response.chats.sort(
        (a, b) => b.messages[0].timestamp.compareTo(
          a.messages[0].timestamp,
        ),
      );

      final otherUsersMap = <String, UserModel>{
        for (var user in response.users) user.id!: user
      };

      // * the next three lines are for dubuging
      // String ids = '';
      // otherUsersMap.forEach((key, _) => ids += '$key\n');
      // debugPrint('!!! OtherUsers Map created ID\'s: $ids');

      debugPrint((await _localRepository.setChats(
              response.chats, _ref.read(userProvider)!.id!))
          .toString());

      debugPrint((await _localRepository.setOtherUsers(
              otherUsersMap, _ref.read(userProvider)!.id!))
          .toString());

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

      _localRepository.setChats(response.chats, _ref.read(userProvider)!.id!);
      _localRepository.setOtherUsers(
          response.users, _ref.read(userProvider)!.id!);
      debugPrint('!!! ended the newLoginInit');
    }
  }

  void clear() {
    _eventHandler.clear();
    final userId = (_ref.read(userProvider))?.id! ?? '';
    _localRepository.clearChats(userId);
    _localRepository.clearOtherUsers(userId);
    _localRepository.clearEventQueue(userId);
    _ref.read(chatsViewModelProvider.notifier).clear();
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
    String? parentMessgeId,
    required String? encryptionKey,
    required String? initializationVector,
  }) async {
    String? chatID = chatModel?.id;
    bool isChatNew = chatID == null;

    if (chatID == null && chatModel != null) {
      // todo(ahmed): handle correct creation of a new chat
      // Create a new chat if chatID is null
      final response = await _remoteRepository.createChat(
        _ref.read(tokenProvider)!,
        chatModel.title,
        chatModel.getChatTypeString(),
        chatModel.userIds,
      );

      if (response.appError != null) {
        debugPrint('Error: Could not create the chat');
        return;
      } else {
        chatID = response.chat!.id;
        chatModel.id = chatID;
        _ref.read(chatsViewModelProvider.notifier).addChat(response.chat!);
      }
    }

    final identifier =
        _ref.read(chatsViewModelProvider.notifier).addSentMessage(
              content: content,
              chatId: chatID!,
              msgType: msgType,
              msgContentType: contentType,
              parentMessageId: parentMessgeId,
            );

    _localRepository.setChats(
        _ref.read(chatsViewModelProvider), _ref.read(userProvider)!.id!);

    final encryptionService = EncryptionService.instance;

    final text = encryptionService.encrypt(
      chatType: chatType,
      msg: content.getContent(),
      encryptionKey: encryptionKey,
      initializationVector: initializationVector,
    );

    final msgEvent = SendMessageEvent(
      {
        'chatId': chatID,
        'media': content.getMediaURL(),
        'content': text,
        'contentType': contentType.content,
        'parentMessageId': parentMessgeId,
        'senderId': _ref.read(userProvider)!.id,
        'isFirstTime': isChatNew,
        'chatType': chatType.type,
        'isReplay': false,
        'isForward': false,
      },
      controller: this,
      msgId: identifier.msgLocalId,
      chatId: identifier.chatId,
      onEventComplete: (Map<String, dynamic> res) {},
    );

    _eventHandler.addEvent(msgEvent);
  }

  void receiveMsg(Map<String, dynamic> response) {
    _ref.read(chatsViewModelProvider.notifier).addReceivedMessage(response);
    _localRepository.setChats(
        _ref.read(chatsViewModelProvider), _ref.read(userProvider)!.id!);
  }

  void receiveGroupCreation(Map<String, dynamic> response) {
    // _ref.read(chatsViewModelProvider.notifier).get(response);
    // _localRepository.setChats(
    //     _ref.read(chatsViewModelProvider), _ref.read(userProvider)!.id!);
  }

  void pinMessageClient(String msgId, String chatId) {
    final isToPin =
        _ref.read(chatsViewModelProvider.notifier).pinMessage(msgId, chatId);
    _eventHandler.addEvent(
      PinMessageEvent(
        {
          'chatId': chatId,
          'messageId': msgId,
        },
        msgId: msgId,
        chatId: chatId,
        isToPin: isToPin,
        onEventComplete: (Map<String, dynamic> res) {},
      ),
    );
  }

  void pinMessageServer(String msgId, String chatId) {
    _ref.read(chatsViewModelProvider.notifier).pinMessage(msgId, chatId);
  }

  // delete a message
  void deleteMsg(
    String msgId,
    String chatId,
    DeleteMessageType deleteType, {
    bool isFromServer = false,
    bool isUsingMsgLocalId = false,
  }) {
    late bool isMsgSend;
    isUsingMsgLocalId
        ? isMsgSend = !_eventHandler.preventEventSending(msgId)
        : isMsgSend = true;

    debugPrint('))) event is sent about to send');
    if (!isFromServer && isMsgSend) {
      debugPrint('))) event is sent');

      late String msgGlobalId;
      isUsingMsgLocalId && isMsgSend
          ? msgGlobalId = _ref
              .read(chatsViewModelProvider.notifier)
              .getMsgGlobalId(msgId, chatId)!
          : msgGlobalId = msgId;

      final msgEvent = DeleteMessageEvent(
        {
          'messageId': msgId,
          'chatId': chatId
        },
        controller: this,
        msgId: msgId,
        chatId: msgGlobalId,
        onEventComplete: (Map<String, dynamic> res) {},
      );

      _eventHandler.addEvent(msgEvent);
    }

    _ref.read(chatsViewModelProvider.notifier).deleteMessage(msgId, chatId);
    _localRepository.setChats(
        _ref.read(chatsViewModelProvider), _ref.read(userProvider)!.id!);
  }

  // edit a message

  void editMsg(
    String msgId,
    String chatId,
    String content, {
    required ChatType chatType,
    required String? encryptionKey,
    required String? initializationVector,
  }) {
    final encryptionService = EncryptionService.instance;

    final text = encryptionService.encrypt(
      chatType: chatType,
      msg: content,
      encryptionKey: encryptionKey,
      initializationVector: initializationVector,
    );

    final msgEvent = EditMessageEvent(
      {
        'chatId': chatId,
        'senderId': _ref.read(userProvider)!.id,
        'messageId': msgId,
        'content': text
      },
      controller: this,
      msgId: msgId,
      chatId: chatId,
      onEventComplete: (Map<String, dynamic> res) {},
    );

    _eventHandler.addEvent(msgEvent);

    _ref.read(chatsViewModelProvider.notifier).editMessage(
          msgId: msgId,
          chatId: chatId,
          content: content,
        );

    _localRepository.setChats(
        _ref.read(chatsViewModelProvider), _ref.read(userProvider)!.id!);
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

    user ??= UserModel(
      username: '',
      screenFirstName: 'Not',
      screenLastName: 'Found',
      email: '',
      status: '',
      bio: '',
      maxFileSize: 0,
      automaticDownloadEnable: false,
      lastSeenPrivacy: '',
      readReceiptsEnablePrivacy: false,
      storiesPrivacy: '',
      picturePrivacy: '',
      invitePermissionsPrivacy: '',
      phone: '',
      id: '',
    );
    return user;
  }

  void restoreOtherUsers(Map<String, UserModel> otherUsers) {
    _localRepository.setOtherUsers(otherUsers, _ref.read(userProvider)!.id!);
  }

  Future<String?> uploadMedia(String filePath, String contentType) async {
    if (USE_MOCK_DATA) {
      switch (contentType) {
        case 'image':
          return 'assets/images/moamen.jpeg';
        case 'video':
          return 'assets/video/demo.mp4';
        case 'audio':
          return 'assets/audio/test8.mp3';
        case 'file':
          return 'assets/docs/Async Js Requirment.pdf';
        default:
          return null;
      }
    }
    final response = await _remoteRepository.uploadMedia(
        _ref.read(tokenProvider)!, filePath);
    if (response.appError != null) {
      debugPrint('Error: Could not create the media');
    } else {
      return response.url;
    }
    return null;
  }

  void editMessageFilePath(
      String chatID, String msgLocalID, String newFilePath) {
    _ref
        .read(chatsViewModelProvider.notifier)
        .updateMessageFilePath(chatID, msgLocalID, newFilePath);
    _localRepository.setChats(
        _ref.read(chatsViewModelProvider), _ref.read(userProvider)!.id!);
  }

  Future<void> muteChat(ChatModel chatModel, DateTime? muteUntil) async {
    debugPrint('!!! muteChat called');
    final String chatID = chatModel.id!;
    final String userId = _ref.read(userProvider)!.id!;
    final muteUntilSeconds =
        muteUntil == null ? -1 : muteUntil.difference(DateTime.now()).inSeconds;

    if (USE_MOCK_DATA) {
      final chats = _localRepository.getChats(userId);
      chatModel = chatModel.copyWith(isMuted: true, muteUntil: muteUntil);
      final updatedChats =
          chats.map((e) => e.id == chatID ? chatModel : e).toList();
      _localRepository.setChats(updatedChats, userId);
      _ref.read(chatsViewModelProvider.notifier).setChats(updatedChats);
      debugPrint('!!! chat muted until: ${chatModel.muteUntil}');
      return;
    }

    final response = await _remoteRepository.muteChat(
        _ref.read(tokenProvider)!, chatID, muteUntilSeconds);

    if (response.appError != null) {
      debugPrint('Error: Could not mute the chat');
    } else {
      final chats = _localRepository.getChats(userId);
      chatModel = chatModel.copyWith(isMuted: true, muteUntil: muteUntil);
      final updatedChats =
          chats.map((e) => e.id == chatID ? chatModel : e).toList();
      _localRepository.setChats(updatedChats, userId);
      _ref.read(chatsViewModelProvider.notifier).setChats(updatedChats);
      debugPrint('!!! chat muted until: ${chatModel.muteUntil}');
    }
  }

  Future<void> unmuteChat(ChatModel chatModel) async {
    final String chatID = chatModel.id!;
    final String userId = _ref.read(userProvider)!.id!;
    debugPrint('!!! unmuteChat called');
    if (USE_MOCK_DATA) {
      final chats = _localRepository.getChats(userId);
      chatModel = chatModel.copyWith(isMuted: false, muteUntil: null);
      final updatedChats =
          chats.map((e) => e.id == chatID ? chatModel : e).toList();
      _localRepository.setChats(updatedChats, userId);
      _ref.read(chatsViewModelProvider.notifier).setChats(updatedChats);
      debugPrint('!!! chat unmuted ${chatModel.isMuted}');
      return;
    }

    final response = await _remoteRepository.unmuteChat(
      _ref.read(tokenProvider)!,
      chatID,
    );

    if (response.appError != null) {
      debugPrint('Error: Could not unmute the chat');
    } else {
      final chats = _localRepository.getChats(userId);
      chatModel.copyWith(isMuted: false, muteUntil: null);
      final updatedChats =
          chats.map((e) => e.id == chatID ? chatModel : e).toList();
      _localRepository.setChats(updatedChats, userId);
      _ref.read(chatsViewModelProvider.notifier).setChats(updatedChats);
    }
  }

  void updateMessageId(
      {required String msgId,
      required String msgLocalId,
      required String chatId}) {
    _ref.read(chatsViewModelProvider.notifier).updateMsgId(
          newMsgId: msgId,
          msgLocalId: msgLocalId,
          chatId: chatId,
        );
    _localRepository.setChats(
        _ref.read(chatsViewModelProvider), _ref.read(userProvider)!.id!);
  }

  void editMessageIdAck({
    required String msgId,
    required String content,
    required String chatId,
  }) {
    _ref.read(chatsViewModelProvider.notifier).editMessage(
          msgId: msgId,
          content: content,
          chatId: chatId,
        );

    _localRepository.setChats(
        _ref.read(chatsViewModelProvider), _ref.read(userProvider)!.id!);
  }

  void setEventsQueue(Queue<MessageEvent> queue) {
    _localRepository.setEventQueue(queue, _ref.read(userProvider)!.id!);
  }

  void updateDraft(ChatModel chatModel, String draft) {
    debugPrint('!!! updateDraft called');
    final String? chatID = chatModel.id;
    final String userId = _ref.read(userProvider)!.id!;
    if (chatID == null) {
      // final chats = _localRepository.getChats();
      // if (draft.isEmpty) {
      //   print('!!! chatID is null and draft is empty');
      //   final updatedChats = chats.where((chat) => chat.id != chatID).toList();
      //   _localRepository.setChats(updatedChats);
      // } else {
      //   print('!!! chatID is null and draft is not empty');
      //   final chat = chats.firstWhere((element) => element.id == null,
      //       orElse: () => chatModel);
      //   final updatedChat = chat.copyWith(draft: draft);
      //   _localRepository.setChats([...chats, updatedChat]);
      // }
      return;
    }

    if (USE_MOCK_DATA) {
      final chats = _localRepository.getChats(userId);
      final chat = chats.firstWhere((element) => element.id == chatID);
      final updatedChat = chat.copyWith(draft: draft);
      final updatedChats =
          chats.map((e) => e.id == chatID ? updatedChat : e).toList();
      _localRepository.setChats(updatedChats, userId);
      _ref.read(chatsViewModelProvider.notifier).setChats(updatedChats);
      return;
    }

    // create send draft event
    // final msgEvent = UpdateDraftEvent({
    //   'chatId': chatID,
    //   'content': draft,
    //   'senderId': _ref.read(userProvider)!.id,
    // }, controller: this);
    // _eventHandler.addEvent(msgEvent);
    // final chats = _localRepository.getChats(userId);
    // final chat = chats.firstWhere((element) => element.id == chatID);
    // final updatedChat = chat.copyWith(draft: draft);
    // final updatedChats =
    //     chats.map((e) => e.id == chatID ? updatedChat : e).toList();
    // _localRepository.setChats(updatedChats, userId);
    // _ref.read(chatsViewModelProvider.notifier).setChats(updatedChats);
    // debugPrint('!!! draft updated remotely and locally: ${updatedChat.draft}');
  }

  Future<String?> getDraft(String chatID) async {
    debugPrint('!!! getDraft called');
    try {
      final String userId = _ref.read(userProvider)!.id!;
      if (USE_MOCK_DATA) {
        final chats = _localRepository.getChats(userId);
        final chat = chats.firstWhere((element) => element.id == chatID);
        return chat.draft;
      }
      final sessionID = _ref.read(tokenProvider);
      final draft = await _remoteRepository.getDraft(
          sessionID!, _ref.read(tokenProvider)!, chatID);
      debugPrint('!!! draft: $draft');
      if (draft.draft == null) {
        final chats = _localRepository.getChats(userId);
        final chat = chats.firstWhere((element) => element.id == chatID);
        return chat.draft;
      }
      return draft.draft;
    } catch (e) {
      return null;
    }
  }

  Future<void> receiveCall(Map<String, dynamic> response) async {
    // Check if user is in a call already
    if (_ref.read(callStateProvider.notifier).isInCall()) {
      // Send busy signal
      debugPrint('!!! Call rejected: ${response['voiceCallId']}');
      return;
    }

    UserModel? caller = await getOtherUser(response['snederId']);
    _ref
        .read(callStateProvider.notifier)
        .receiveCall(response['voiceCallId'], caller);
    debugPrint('!!! Call received: ${response['voiceCallId']}');
  }

  Future<bool> createGroup({
    required String type,
    required String name,
    required List<String> members,
    required Function(Map<String, dynamic> res) onEventComplete,
  }) async {
    Map<String, dynamic> payload = {
      "type": type,
      "name": name,
      "members": members,
    };
    final msgEvent = CreateGroupEvent(payload,
        controller: this,
        msgId: '',
        chatId: '',
        onEventComplete: onEventComplete);
    _eventHandler.addEvent(msgEvent);
    getUserChats();
    return true;
  }

  Future<bool> deleteGroup({
    required String chatId,
    required Function(Map<String, dynamic> res) onEventComplete,
  }) async {
    Map<String, dynamic> payload = {
      "chatId": chatId,
    };
    final msgEvent = DeleteGroupEvent(payload,
        controller: this,
        msgId: '',
        chatId: '',
        onEventComplete: onEventComplete);
    _eventHandler.addEvent(msgEvent);
    getUserChats();
    return true;
  }

  Future<bool> leaveGroup({
    required String chatId,
    required Function(Map<String, dynamic> res) onEventComplete,
  }) async {
    Map<String, dynamic> payload = {
      "chatId": chatId,
    };
    final msgEvent = LeaveGroupEvent(payload,
        controller: this,
        msgId: '',
        chatId: '',
        onEventComplete: onEventComplete);
    _eventHandler.addEvent(msgEvent);
    getUserChats();
    return true;
  }

  Future<bool> addMembers({
    required String chatId,
    required List<String> members,
    required Function(Map<String, dynamic> res) onEventComplete,
  }) async {
    Map<String, dynamic> payload = {
      "chatId": chatId,
      "users": members,
    };
    final msgEvent = AddMembersEvent(payload,
        controller: this,
        msgId: '',
        chatId: '',
        onEventComplete: onEventComplete);
    _eventHandler.addEvent(msgEvent);
    getUserChats();
    return true;
  }

  Future<bool> addAdmin({
    required String chatId,
    required List<String> members,
    required Function(Map<String, dynamic> res) onEventComplete,
  }) async {
    Map<String, dynamic> payload = {
      "chatId": chatId,
      "members": members,
    };
    final msgEvent = AddAdminEvent(payload,
        controller: this,
        msgId: '',
        chatId: '',
        onEventComplete: onEventComplete);
    _eventHandler.addEvent(msgEvent);
    getUserChats();
    return true;
  }

  Future<bool> removeMember({
    required String chatId,
    required List<String> members,
    required Function(Map<String, dynamic> res) onEventComplete,
  }) async {
    Map<String, dynamic> payload = {
      "chatId": chatId,
      "members": members,
    };
    final msgEvent = RemoveMemberEvent(payload,
        controller: this,
        msgId: '',
        chatId: '',
        onEventComplete: onEventComplete);
    _eventHandler.addEvent(msgEvent);
    getUserChats();
    return true;
  }

  Future<bool> setPermissions({
    required String chatId,
    required Function(Map<String, dynamic> res) onEventComplete,
    required String type,
    required String who,
  }) async {
    Map<String, dynamic> payload = {
      "chatId": chatId,
      "type": type,
      "who": who,
    };
    final msgEvent = SetPermissions(payload,
        controller: this,
        msgId: '',
        chatId: '',
        onEventComplete: onEventComplete);
    getUserChats();
    _eventHandler.addEvent(msgEvent);
    return true;
  }
}
