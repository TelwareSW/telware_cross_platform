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

// receive msg/reply/draft
// edit/delete msg

part 'message_event_models.g.dart';

@HiveType(typeId: 7)
class MessageEvent {
  @HiveField(0)
  final Map<String, dynamic> payload;
  @HiveField(1)
  final String? msgId;
  @HiveField(2)
  final String? chatId;

  final ChattingController? _controller;
  static const int _timeOutSeconds = 10;
  final Function(Map<String, dynamic> res)? _onEventComplete;

  MessageEvent(
    this.payload, {
    required this.msgId,
    required this.chatId,
    Function(Map<String, dynamic> res)? onEventComplete,
    ChattingController? controller,
  })  : _controller = controller,
        _onEventComplete = onEventComplete;

  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: _timeOutSeconds),
  }) async {
    final success = await _execute(
      socket,
      'eventName', // Event name for the socket message
      timeout: timeout,
      ackCallback: (response, timer, completer) {
        // Handle the acknowledgment response and provide feedback
        if (response != null) {
          if (_onEventComplete == null) {
            print('fdsafasd');
          } else {
            _onEventComplete({});
          }
          completer.complete(true);
        } else {
          if (_onEventComplete == null) {
            print('fdsafasd');
          } else {
            _onEventComplete({});
          }
          completer.complete(false);
        }
      },
    );

    if (!success) {
      if (_onEventComplete == null) {
        print('fdsafasd');
      } else {
        _onEventComplete({});
      }
    }
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
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return MessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      onEventComplete: onEventComplete ?? _onEventComplete,
    );
  }
}

@HiveType(typeId: 8)
class SendMessageEvent extends MessageEvent {
  SendMessageEvent(
    super.payload, {
    super.controller,
    required super.msgId,
    required super.chatId,
    super.onEventComplete,
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    return await _execute(
      socket,
      EventType.sendMessage.event,
      timeout: timeout,
      ackCallback: (res, timer, completer) {
        try {
          final response = res as Map<String, dynamic>;
          print(response);
          if (!completer.isCompleted) {
            timer.cancel(); // Cancel the timer on acknowledgment
            if (response['success'].toString() == 'true') {
              final res = response['res'] as Map<String, dynamic>;
              final messageId = res['messageId'] as String;

              _controller!.updateMessageId(
                msgId: messageId,
                msgLocalId: msgId!,
                chatId: chatId!,
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
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return SendMessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      onEventComplete: onEventComplete ?? _onEventComplete,
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
    super.onEventComplete,
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return await _execute(
      socket,
      EventType.deleteMessageClient.event,
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
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return DeleteMessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      onEventComplete: onEventComplete ?? _onEventComplete,
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
    super.onEventComplete,
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
    Function(Map<String, dynamic> res)? onEventComplete,
    String? senderId,
    String? targetId,
    String? clientId,
    String? voiceCallId,
    String? type,
    dynamic data,
  }) {
    return EditMessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      onEventComplete: onEventComplete ?? _onEventComplete,
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
    super.onEventComplete,
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
    Function(Map<String, dynamic> res)? onEventComplete,
    String? senderId,
    String? targetId,
    String? clientId,
    String? voiceCallId,
    String? type,
    dynamic data,
  }) {
    return UpdateDraftEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      onEventComplete: onEventComplete ?? _onEventComplete,
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
    super.onEventComplete,
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
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return PinMessageEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      isToPin: isToPin ?? this.isToPin,
      onEventComplete: onEventComplete ?? _onEventComplete,
    );
  }
}

@HiveType(typeId: 25)
class CreateGroupEvent extends MessageEvent {
  CreateGroupEvent(
    super.payload, {
    super.controller,
    required super.msgId,
    required super.chatId,
    super.onEventComplete,
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    return await _execute(
      socket,
      EventType.createGroup.event,
      timeout: timeout,
      ackCallback: (res, timer, completer) {
        try {
          final response = res as Map<String, dynamic>;
          debugPrint('### I got a response ${response['success'].toString()}');
          print(response);
          if (!completer.isCompleted) {
            timer.cancel(); // Cancel the timer on acknowledgment
            if (response['success'].toString() == 'true') {
              final res = response['data'] as Map<String, dynamic>;
              print(res.toString());
              if (_onEventComplete != null) {
                _onEventComplete(response);
              }
              _controller?.getUserChats();
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
  CreateGroupEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
    bool? isToPin,
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return CreateGroupEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      onEventComplete: onEventComplete ?? _onEventComplete,
    );
  }
}

@HiveType(typeId: 26)
class DeleteGroupEvent extends MessageEvent {
  DeleteGroupEvent(
    super.payload, {
    super.controller,
    required super.msgId,
    required super.chatId,
    super.onEventComplete,
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    return await _execute(
      socket,
      EventType.deleteGroup.event,
      timeout: timeout,
      ackCallback: (res, timer, completer) {
        try {
          final response = res as Map<String, dynamic>;
          debugPrint('### I got a response ${response['success'].toString()}');
          print(response);
          if (!completer.isCompleted) {
            timer.cancel();
            if (_onEventComplete != null) {
              _onEventComplete(response);
            }
            if (response['success'].toString() == 'true') {
              final res = response['data'] as Map<String, dynamic>;
              print(res.toString());
              _controller?.getUserChats();
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
  DeleteGroupEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
    bool? isToPin,
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return DeleteGroupEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      onEventComplete: onEventComplete ?? _onEventComplete,
    );
  }
}

@HiveType(typeId: 27)
class LeaveGroupEvent extends MessageEvent {
  LeaveGroupEvent(
    super.payload, {
    super.controller,
    required super.msgId,
    required super.chatId,
    super.onEventComplete,
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    return await _execute(
      socket,
      EventType.leaveGroup.event,
      timeout: timeout,
      ackCallback: (res, timer, completer) {
        try {
          final response = res as Map<String, dynamic>;
          debugPrint('### I got a response ${response['success'].toString()}');
          print(response);
          if (!completer.isCompleted) {
            timer.cancel();
            if (_onEventComplete != null) {
              _onEventComplete(response);
            }
            if (response['success'].toString() == 'true') {
              final res = response['data'] as Map<String, dynamic>;
              print(res.toString());
              _controller?.getUserChats();
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
  LeaveGroupEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
    bool? isToPin,
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return LeaveGroupEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      onEventComplete: onEventComplete ?? _onEventComplete,
    );
  }
}

@HiveType(typeId: 28)
class AddMembersEvent extends MessageEvent {
  AddMembersEvent(
    super.payload, {
    super.controller,
    required super.msgId,
    required super.chatId,
    super.onEventComplete,
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    return await _execute(
      socket,
      EventType.addMember.event,
      timeout: timeout,
      ackCallback: (res, timer, completer) {
        try {
          final response = res as Map<String, dynamic>;
          debugPrint('### I got a response ${response['success'].toString()}');
          print(response);
          if (!completer.isCompleted) {
            timer.cancel();
            if (_onEventComplete != null) {
              _onEventComplete(response);
            }
            if (response['success'].toString() == 'true') {
              final res = response['data'] as Map<String, dynamic>;
              print(res.toString());
              _controller?.getUserChats();
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
  AddMembersEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
    bool? isToPin,
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return AddMembersEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      onEventComplete: onEventComplete ?? _onEventComplete,
    );
  }
}

@HiveType(typeId: 29)
class AddAdminEvent extends MessageEvent {
  AddAdminEvent(
    super.payload, {
    super.controller,
    required super.msgId,
    required super.chatId,
    super.onEventComplete,
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    return await _execute(
      socket,
      EventType.addAdmin.event,
      timeout: timeout,
      ackCallback: (res, timer, completer) {
        try {
          final response = res as Map<String, dynamic>;
          debugPrint('### I got a response ${response['success'].toString()}');
          print(response);
          if (!completer.isCompleted) {
            timer.cancel();
            if (_onEventComplete != null) {
              _onEventComplete(response);
            }
            if (response['success'].toString() == 'true') {
              final res = response['data'] as Map<String, dynamic>;
              print(res.toString());
              _controller?.getUserChats();
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
  AddAdminEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
    bool? isToPin,
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return AddAdminEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      onEventComplete: onEventComplete ?? _onEventComplete,
    );
  }
}

@HiveType(typeId: 30)
class RemoveMemberEvent extends MessageEvent {
  RemoveMemberEvent(
    super.payload, {
    super.controller,
    required super.msgId,
    required super.chatId,
    super.onEventComplete,
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    return await _execute(
      socket,
      EventType.removeMember.event,
      timeout: timeout,
      ackCallback: (res, timer, completer) {
        try {
          final response = res as Map<String, dynamic>;
          debugPrint('### I got a response ${response['success'].toString()}');
          print(response);
          if (!completer.isCompleted) {
            timer.cancel();
            if (_onEventComplete != null) {
              _onEventComplete(response);
            }
            if (response['success'].toString() == 'true') {
              final res = response['data'] as Map<String, dynamic>;
              print(res.toString());
              _controller?.getUserChats();
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
  RemoveMemberEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
    bool? isToPin,
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return RemoveMemberEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      onEventComplete: onEventComplete ?? _onEventComplete,
    );
  }
}

@HiveType(typeId: 31)
class SetPermissions extends MessageEvent {
  SetPermissions(
    super.payload, {
    super.controller,
    required super.msgId,
    required super.chatId,
    super.onEventComplete,
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    return await _execute(
      socket,
      EventType.setPermissions.event,
      timeout: timeout,
      ackCallback: (res, timer, completer) {
        try {
          final response = res as Map<String, dynamic>;
          debugPrint('### I got a response ${response['success'].toString()}');
          print(response);
          if (!completer.isCompleted) {
            timer.cancel();
            if (_onEventComplete != null) {
              _onEventComplete(response);
            }
            if (response['success'].toString() == 'true') {
              final res = response['data'] as Map<String, dynamic>;
              print(res.toString());
              _controller?.getUserChats();
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
  SetPermissions copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
    bool? isToPin,
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return SetPermissions(
      payload ?? this.payload,
      controller: controller ?? _controller,
      msgId: msgId ?? this.msgId,
      chatId: chatId ?? this.chatId,
      onEventComplete: onEventComplete ?? _onEventComplete,
    );
  }
}

@HiveType(typeId: 25)
class CreateCallEvent extends MessageEvent {
  CreateCallEvent(
    super.payload, {
    super.controller,
    required super.chatId,
    super.msgId = '',
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    socket.emit(EventType.createCall.event, payload);
    return true;
  }

  @override
  CreateCallEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
    bool? isToPin,
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return CreateCallEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
      chatId: chatId ?? this.chatId,
      msgId: '',
    );
  }
}

@HiveType(typeId: 26)
class JoinCallEvent extends MessageEvent {
  JoinCallEvent(
    super.payload, {
    super.controller,
    super.msgId = '',
    super.chatId = '',
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    socket.emit(EventType.joinCall.event, payload);
    return true;
  }

  @override
  JoinCallEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
    bool? isToPin,
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return JoinCallEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
    );
  }
}

@HiveType(typeId: 27)
class SendSignalEvent extends MessageEvent {
  SendSignalEvent(
    super.payload, {
    super.controller,
    super.msgId = '',
    super.chatId = '',
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    socket.emit(EventType.sendCallSignal.event, payload);
    return true;
  }

  @override
  SendSignalEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
    bool? isToPin,
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return SendSignalEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
    );
  }
}

@HiveType(typeId: 28)
class LeaveCallEvent extends MessageEvent {
  LeaveCallEvent(
    super.payload, {
    super.controller,
    super.msgId = '',
    super.chatId = '',
  });

  @override
  Future<bool> execute(
    SocketService socket, {
    Duration timeout = const Duration(seconds: MessageEvent._timeOutSeconds),
  }) async {
    socket.emit(EventType.leaveCall.event, payload);
    return true;
  }

  @override
  LeaveCallEvent copyWith({
    dynamic payload,
    ChattingController? controller,
    String? msgId,
    String? chatId,
    bool? isToPin,
    Function(Map<String, dynamic> res)? onEventComplete,
  }) {
    return LeaveCallEvent(
      payload ?? this.payload,
      controller: controller ?? _controller,
    );
  }
}
