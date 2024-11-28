import 'dart:async';

import 'package:telware_cross_platform/core/services/socket_service.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';

// todo: create the event classes here
// ------------------
// send message/announcement *
// edit message *
// delete message *
// reply *
// forward *
// ------------------
// see/read/open a chat - not in api
// draft

// recieve msg/reply/draft
// edit/delete msg

abstract class MessageEvent {
  final dynamic payload;
  final ChattingController _controller;
  MessageEvent(this._controller, this.payload);

  Future<bool> execute(SocketService socket,
      {Duration timeout = const Duration(seconds: 10)});

  Future<bool> _execute(
    SocketService socket,
    String event, {
    Duration timeout = const Duration(seconds: 10),
    required Function(
      dynamic data,
      Timer timer,
      Completer completer,
    ) ackCallback,
  }) async {
    final completer = Completer<bool>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false); // Timeout occurred
      }
    });

    // Emit the event and wait for acknowledgment
    socket.emitWithAck(event, payload, ackCallback: (response) {
      ackCallback(response, timer, completer);
    });

    return completer.future;
  }
}

class SendMessageEvent extends MessageEvent {
  SendMessageEvent(super._controller, super.payload);

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return await _execute(
      socket,
      EventType.deleteMessage.event,
      ackCallback: (response, timer, completer) {
        if (!completer.isCompleted) {
          timer.cancel(); // Cancel the timeout timer
          // todo(moamen): confirm msg was sent
          // change from pending to sent
          completer.complete(true);
        }
      },
    );
  }
}

class DeleteMessageEvent extends MessageEvent {
  DeleteMessageEvent(super._controller, super.payload);

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return await _execute(
      socket,
      EventType.deleteMessage.event,
      ackCallback: (response, timer, completer) {
        if (!completer.isCompleted) {
          timer.cancel(); // Cancel the timeout timer
          completer.complete(true);
        }
      },
    );
  }
}

class EditMessageEvent extends MessageEvent {
  EditMessageEvent(super._controller, super.payload);

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return await _execute(
      socket,
      EventType.deleteMessage.event,
      ackCallback: (response, timer, completer) {
        if (!completer.isCompleted) {
          timer.cancel(); // Cancel the timeout timer
          if (response['status'] == 'success') {
            completer.complete(true);
          } else {
            completer.complete(false);
          }
        }
      },
    );
  }
}
