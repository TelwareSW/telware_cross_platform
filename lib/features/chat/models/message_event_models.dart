import 'dart:async';

import 'package:hive/hive.dart';
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

part 'message_event_models.g.dart';

@HiveType(typeId: 7)
class MessageEvent {
  @HiveField(0)
  final dynamic payload;

  final ChattingController? _controller;

  MessageEvent(this.payload, {ChattingController? controller}): _controller = controller;

  Future<bool> execute(SocketService socket,
      {Duration timeout = const Duration(seconds: 10)}) async {return true;}

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

  MessageEvent copyWith({
    dynamic payload,
    ChattingController? controller,
  }) {
    return SendMessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
    );
  }
}

@HiveType(typeId: 8)
class SendMessageEvent extends MessageEvent {
  SendMessageEvent(super.payload, {super.controller});

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

  @override
  SendMessageEvent copyWith({
    dynamic payload,
    ChattingController? controller,
  }) {
    return SendMessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
    );
  }
}

@HiveType(typeId: 9)
class DeleteMessageEvent extends MessageEvent {
  DeleteMessageEvent(super.payload, {super.controller});

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

  @override
  DeleteMessageEvent copyWith({
    dynamic payload,
    ChattingController? controller,
  }) {
    return DeleteMessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
    );
  }
}

@HiveType(typeId: 10)
class EditMessageEvent extends MessageEvent {
  EditMessageEvent(super.payload, {super.controller});

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

  @override
  EditMessageEvent copyWith({
    dynamic payload,
    ChattingController? controller,
  }) {
    return EditMessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
    );
  }
}
