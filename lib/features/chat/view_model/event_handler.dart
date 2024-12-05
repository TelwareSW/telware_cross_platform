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

  void init(Queue<MessageEvent> eventsQueue) {
    _queue = eventsQueue;
    _socket.connect(
      serverUrl: SOCKET_URL,
      userId: _userId,
      onConnect: _onSocketConnect,
      sessionId: _sessionId,
    );
    processQueue();
  }

  void addEvent(MessageEvent event) {
    debugPrint('!!! event added');
    _queue.add(event);

    _chattingController.setEventsQueue(_queue);
    // Start processing if not already running
    if (!_isProcessing) {
      ();
    }
  }

  void stopProcessing() {
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
        _socket.connect(
          serverUrl: SOCKET_URL,
          userId: _userId,
          onConnect: _onSocketConnect,
          sessionId: _sessionId,
        );
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
        } else {
          debugPrint('Failed to process event: ${currentEvent.runtimeType}');
          failingCounter++;
          if (failingCounter == EVENT_FAIL_LIMIT) {
            failingCounter = 0;
            _stopRequested =
                true; // it is already called in the onError method, but I add it for insurance
            _socket.onError();
          }
          // Retry after a delay
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        debugPrint('Error processing event: ${currentEvent.runtimeType}, $e');
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
        _chattingController.receiveMsg(response);
      } on Exception catch (e) {
        debugPrint('!!! Error in recieving a message:\n${e.toString()}');
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
