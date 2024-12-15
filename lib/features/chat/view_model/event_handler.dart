import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/core/mock/constants_mock.dart';
import 'package:telware_cross_platform/core/services/socket_service.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/models/message_event_models.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';

class EventHandler {
  final ChattingController _chattingController;
  final SocketService _socket;
  Queue<MessageEvent> _queue;
  String _userId;
  String _sessionId;

  bool _isProcessing = false; // Flag to control processing loop
  bool _stopRequested = false; // Flag to request stopping the loop

  void init(
    Queue<MessageEvent> eventsQueue, {
    required String userId,
    required String sessionId,
  }) {
    _userId = userId;
    _sessionId = sessionId;
    _queue = eventsQueue;
    _socket.connect(
      serverUrl: SOCKET_URL,
      userId: _userId,
      onConnect: _onSocketConnect,
      sessionId: _sessionId,
      eventHandler: this,
    );
    processQueue();
  }

  void clear() {
    stopProcessing();
    _queue.clear();
    _socket.disconnect();
  }

  void addEvent(MessageEvent event) {
    debugPrint('!!! event added');
    _queue.add(event);

    _chattingController.setEventsQueue(_queue);
    // Start processing if not already running
    if (!_isProcessing) {
      processQueue();
    }
  }

  void stopProcessing() {
    if (!_isProcessing) return;
    _stopRequested = true; // Gracefully request stopping the loop
  }

  Future<void> processQueue() async {
    if (_isProcessing || USE_MOCK_DATA) return; // Avoid multiple loops

    _isProcessing = true;
    debugPrint('()()() called Processing Queue');
    debugPrint('()()() ${_queue.length}');
    debugPrint('()()() $_stopRequested');

    int failingCounter = 0;

    while (_queue.isNotEmpty && !_stopRequested) {
      final currentEvent = _queue.first;

      if (!_socket.isConnected) {
        debugPrint('&%^ called the connect from handler loop');
        _socket.onError();
        break;
      }

      try {
        final bool success = await currentEvent.execute(
          _socket,
          timeout: const Duration(seconds: 5),
        );

        if (success) {
          _queue.removeFirst(); // Remove successful event
          debugPrint('Processed event: ${currentEvent.runtimeType}');
          _chattingController.setEventsQueue(_queue);
          failingCounter = 0;
        } else {
          debugPrint('Failed to process event: ${currentEvent.runtimeType}');
          failingCounter++;
          if (failingCounter == EVENT_FAIL_LIMIT) {
            _stopRequested =
                true; // it is already called in the onError method, but I add it for insurance
            _socket.onError();
          }
          // Retry after a delay
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        debugPrint('Error processing event: ${currentEvent.runtimeType}, $e');
        if (failingCounter == EVENT_FAIL_LIMIT) {
          _stopRequested = true;
          _socket.onError();
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    _isProcessing = false;
    if (_stopRequested) _stopRequested = false;
  }

  void _onSocketConnect() {
    debugPrint('!!! connected succeffully');
    // receive a message
    _socket.on(EventType.receiveMessage.event, (response) async {
      try {
        debugPrint('/|\\ got a message id: ${response['id']}');
        _chattingController.receiveMsg(response);
      } on Exception catch (e) {
        debugPrint('!!! Error in recieving a message:\n${e.toString()}');
      }
    });
    // pin a message
    _socket.on(EventType.pinMessageServer.event, (response) async {
      try {
        _chattingController.pinMessageServer(
            response['messageId'] as String, response['chatId'] as String);
      } on Exception catch (e) {
        debugPrint('!!! Error in pinning a message:\n${e.toString()}');
      }
    });
    // unpin a message
    _socket.on(EventType.unpinMessageServer.event, (response) async {
      try {
        _chattingController.pinMessageServer(
            response['messageId'] as String, response['chatId'] as String);
      } on Exception catch (e) {
        debugPrint('!!! Error in unpinning a message:\n${e.toString()}');
      }
    });
    // edit a message
    _socket.on(EventType.editMessageServer.event, (response) async {
      try {
        debugPrint('#!#! this is a response of edit:');
        _chattingController.editMessageIdAck(chatId: response['chatId'], content: response['content'], msgId: response['id']);
      } on Exception catch (e) {
        debugPrint('!!! Error in editing a message:\n${e.toString()}');
      }
    });
    _socket.on(EventType.receiveCreateGroup.event, (response) async {
      try {
        debugPrint('/|\\ got a group creation id:');
        print(response.toString());
        _chattingController.getUserChats();
      } on Exception catch (e) {
        debugPrint('!!! Error in recieving a message:\n${e.toString()}');
      }
    });

    _socket.on(EventType.receiveCreateGroup.event, (response) async {
      try {
        debugPrint('/|\\ got a group creation id:');
        print(response.toString());
        _chattingController.getUserChats();
      } on Exception catch (e) {
        debugPrint('!!! Error in recieving a message:\n${e.toString()}');
      }
    });

    _socket.on(EventType.receiveDeleteGroup.event, (response) async {
      try {
        debugPrint('/|\\ got a delete group id:');
        print(response.toString());
        _chattingController.getUserChats();
      } on Exception catch (e) {
        debugPrint('!!! Error in recieving a event:\n${e.toString()}');
      }
    });

    _socket.on(EventType.receiveLeaveGroup.event, (response) async {
      try {
        debugPrint('/|\\ got a leave group id:');
        print(response.toString());
        _chattingController.getUserChats();
      } on Exception catch (e) {
        debugPrint('!!! Error in recieving a event:\n${e.toString()}');
      }
    });

    _socket.on(EventType.receiveAddMember.event, (response) async {
      try {
        debugPrint('/|\\ got a AddMember :');
        print(response.toString());
        _chattingController.getUserChats();
      } on Exception catch (e) {
        debugPrint('!!! Error in recieving a event:\n${e.toString()}');
      }
    });

    _socket.on(EventType.receiveAddAdmin.event, (response) async {
      try {
        debugPrint('/|\\ got a AddAdmin :');
        print(response.toString());
        _chattingController.getUserChats();
      } on Exception catch (e) {
        debugPrint('!!! Error in recieving a event:\n${e.toString()}');
      }
    });

    _socket.on(EventType.receiveRemoveMember.event, (response) async {
      try {
        debugPrint('/|\\ got a receiveRemoveMember:');
        print(response.toString());
        _chattingController.getUserChats();
      } on Exception catch (e) {
        debugPrint('!!! Error in recieving a event:\n${e.toString()}');
      }
    });

    _socket.on(EventType.receiveSetPermissions.event, (response) async {
      try {
        debugPrint('/|\\ got a receiveSetPermissions:');
        print(response.toString());
        _chattingController.getUserChats();
      } on Exception catch (e) {
        debugPrint('!!! Error in receiveSetPermissions a event:\n${e.toString()}');
      }
    });


    // todo(ahmed): add the rest of the recieved events
  }

  // Private constructor
  EventHandler._internal({
    required ChattingController controller,
    required SocketService socket,
    required String userId,
    required String sessionId,
  })  : _chattingController = controller,
        _socket = socket,
        _userId = userId,
        _sessionId = sessionId,
        _queue = Queue();

  // Singleton instance
  static EventHandler? _instance;

  // private constructor
  EventHandler._(this._chattingController, this._socket, this._queue,
      this._userId, this._sessionId);

  // Configure the singleton instance
  static void config({
    required ChattingController controller,
    required SocketService socket,
    required String userId,
    required String sessionId,
  }) {
    _instance = EventHandler._internal(
        controller: controller,
        socket: socket,
        userId: userId,
        sessionId: sessionId);
  }

  // Getter for the singleton instance
  static EventHandler get instance {
    if (_instance == null) {
      debugPrint(
          '!!! EventHandler is not configured. Call EventHandler.config() first.');
      throw Exception(
          'EventHandler is not configured. Call EventHandler.config() first.');
    }
    return _instance!;
  }
}
