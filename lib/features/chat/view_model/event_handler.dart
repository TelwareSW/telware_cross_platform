import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:telware_cross_platform/core/constants/server_constants.dart';
import 'package:telware_cross_platform/core/services/socket_service.dart';
import 'package:telware_cross_platform/features/chat/models/message_event_models.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';

class EventHandler {
  final ChattingController _chattingController;
  final SocketService _socket;
  late final Queue<MessageEvent> _queue;

  bool _isProcessing = false; // Flag to control processing loop
  bool _stopRequested = false; // Flag to request stopping the loop

  void init(Queue<MessageEvent> eventsQueue) {
    _queue = eventsQueue;
    // todo(ahmed): check is this the right url
    _socket.connect(API_URL, _onSocketConnect);
  }

  void addEvent(MessageEvent event) {
    _queue.add(event);

    // Start processing if not already running
    if (!_isProcessing) {
      _processQueue();
    }
  }

  void stopProcessing() {
    _stopRequested = true; // Gracefully request stopping the loop
  }

  void _processQueue() async {
    if (_isProcessing) return; // Avoid multiple loops

    _isProcessing = true;

    while (_queue.isNotEmpty && !_stopRequested) {
      final currentEvent = _queue.first;

      try {
        final bool success = await currentEvent.execute(
          _socket,
          timeout: const Duration(seconds: 5),
        );

        if (success) {
          _queue.removeFirst(); // Remove successful event
          debugPrint('Processed event: ${currentEvent.runtimeType}');
        } else {
          debugPrint('Failed to process event: ${currentEvent.runtimeType}');
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
    // receive a message
    _socket.on(EventType.receiveMessage.event, (response) {
      // send the message to the chatting controller
    });

    // todo(ahmed): add the rest of the recieved events
  }

  // Private constructor
  EventHandler._internal({
    required ChattingController controller,
    required SocketService socket,
  })  : _chattingController = controller,
        _socket = socket;

  // Singleton instance
  static EventHandler? _instance;

  // private constructor
  EventHandler._(this._chattingController, this._socket, this._queue);

  // Configure the singleton instance
  static void config({
    required ChattingController controller,
    required SocketService socket,
  }) {
    _instance ??=
        EventHandler._internal(controller: controller, socket: socket);
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
