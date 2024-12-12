import 'dart:async';

import 'package:flutter/foundation.dart';
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
  final Map<String, dynamic> payload;
  @HiveField(1)
  final String msgId;
  @HiveField(2)
  final String chatId;

  final ChattingController? _controller;
  static const int _timeOutSeconds = 10;

  MessageEvent(
    this.payload, {
    required this.msgId,
    required this.chatId,
    ChattingController? controller,
  }) : _controller = controller;

  Future<bool> execute(SocketService socket,
      {Duration timeout = const Duration(seconds: _timeOutSeconds)}) async {
    debugPrint('!!! this is the one excuted');
    return true;
  }

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
    String? msgId,
    String? chatId,
  }) {
    return MessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
    );
  }
}

@HiveType(typeId: 8)
class SendMessageEvent extends MessageEvent {
  SendMessageEvent(super.payload,
      {super.controller, required super.msgId, required super.chatId});

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    debugPrint('!!! Sending event statrted');
    // print(payload as Map);
    debugPrint('--- did not reach here in sending event');

    return await _execute(
      socket,
      EventType.sendMessage.event,
      timeout: timeout,
      ackCallback: (res, timer, completer) {
        try {
          final response = res as Map<String, dynamic>;
          debugPrint('### I got a response ${response['success'].toString()}');
          print(response);
          if (!completer.isCompleted) {
            timer.cancel(); // Cancel the timer on acknowledgment
            if (response['success'].toString() == 'true') {
              final res = response['res'] as Map<String, dynamic>;
              debugPrint('--- got the res');
              final messageId = res['messageId'] as String;
              debugPrint('--- got the id $messageId');

              _controller!.updateMessageId(
                msgId: messageId,
                msgLocalId: msgId,
                chatId: chatId,
              );
              completer.complete(true);
            } else {
              completer.complete(false);
            }
          }
        } catch (e) {
          debugPrint('--- Error in processing the acknowledgement');
          debugPrint(e.toString());
        }
      },
    );
  }

  @override
  SendMessageEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
  }) {
    return SendMessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
    );
  }
}

@HiveType(typeId: 9)
class DeleteMessageEvent extends MessageEvent {
  DeleteMessageEvent(
    super.payload, {
    super.controller,
    required super.msgId,
    required super.chatId,
  });

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
          timer.cancel(); // Cancel the timer on acknowledgment
          if (response['success'].toString() == 'true') {
            debugPrint('&()& delete msg sucessefully');
            completer.complete(true);
          } else {
            debugPrint('&()& delete msg failed');
            completer.complete(false);
          }
        }
      },
    );
  }

  @override
  DeleteMessageEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
  }) {
    return DeleteMessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
    );
  }
}

@HiveType(typeId: 10)
class EditMessageEvent extends MessageEvent {
  EditMessageEvent(
    super.payload, {
    super.controller,
    required super.msgId,
    required super.chatId,
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return await _execute(
      socket,
      EventType.editMessageClient.event,
      ackCallback: (res, timer, completer) {
        try {
          final response = res as Map<String, dynamic>;
          if (!completer.isCompleted) {
            timer.cancel(); // Cancel the timer on acknowledgment
            if (response['success'].toString() == 'true') {
              final res = response['res']['message'] as Map<String, dynamic>;

              _controller!.editMessageIdAck(
                msgId: res['_id'] ?? res['id'] ?? msgId,
                content: res['content'],
                chatId: res['chatId'] ?? chatId,
              );

              completer.complete(true);
            } else {
              completer.complete(false);
            }
          }
        } catch (e) {
          debugPrint('--- Error in processing the acknowledgement of the edit');
          debugPrint(e.toString());
          completer.complete(false);
        }
      },
    );
  }

  @override
  EditMessageEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
  }) {
    return EditMessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
    );
  }
}

@HiveType(typeId: 23)
class UpdateDraftEvent extends MessageEvent {
  UpdateDraftEvent(
    super.payload, {
    super.controller,
    required super.msgId,
    required super.chatId,
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return await _execute(
      socket,
      EventType.updateDraft.event,
      ackCallback: (response, timer, completer) {
        if (!completer.isCompleted) {
          timer.cancel(); // Cancel the timeout timer
          if (response['success'] == true) {
            // Handle successful response
            completer.complete(true);
          } else {
            // Handle error response
            completer.complete(false);
          }
        }
      },
    );
  }

  @override
  UpdateDraftEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
  }) {
    return UpdateDraftEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
    );
  }
}

@HiveType(typeId: 24)
class PinMessageEvent extends MessageEvent {
  PinMessageEvent(
    super.payload, {
    super.controller,
    required super.msgId,
    required super.chatId,
    required this.isToPin,
  });

  @HiveField(3)
  bool isToPin;

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    final event = isToPin
        ? EventType.pinMessageClient.event
        : EventType.unpinMessageClient.event;
    socket.emit(event, payload);
    return true;
  }

  @override
  PinMessageEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
    bool? isToPin,
  }) {
    return PinMessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      isToPin: isToPin ?? this.isToPin,
    );
  }
}
