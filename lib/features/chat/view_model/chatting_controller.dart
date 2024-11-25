import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/services/socket_service.dart';
import 'package:telware_cross_platform/features/chat/models/emitted_event_models.dart';
import 'package:telware_cross_platform/features/chat/repository/chat_local_repository.dart';
import 'package:telware_cross_platform/features/chat/repository/chat_remote_repository.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/features/chat/view_model/event_handler.dart';

part 'chatting_controller.g.dart';

@Riverpod(keepAlive: true)
ChattingController authRemoteRepository(Ref ref) {
  final remoteRepo = ChatRemoteRepository(
    dio: Dio(BASE_OPTIONS),
  );

  final localRepo = ChatLocalRepository(
    chatsBox: Hive.box<List<ChatModel>>('chats-box'),
    eventsBox: Hive.box<List<EmittedEvent>>('chatting-events-box'),
    otherUsersBox: Hive.box<Map<String, UserModel>>('other-users-box')
  );

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

  Future<void> init() async {
    // get the chats and give it to the chats view model from local
    final chats = _localRepository.getChats();
    // todo(ahmed): set to the chats view model

    // get the users list from local
    final otherUsers = _localRepository.getOtherUsers();
    // todo(ahmed): set to the chats view model

    // get the events and give it to the handler from local
    final events = _localRepository.getEventQueue();

    // make sure handler started the socket
  }

  // send a message

  // delete a message

  // edit a message

  // recieve a message
}
