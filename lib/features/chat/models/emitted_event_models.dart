import 'dart:async';

import 'package:telware_cross_platform/core/services/socket_service.dart';

enum EventType {
  sendMessage(event: 'SEND_MESSAGE'),
  sendAnnouncement(event: 'SEND_ANNOUNCEMENT'),
  editMessage(event: 'EDIT_MESSAGE'),
  deleteMessage(event: 'DELETE_MESSAGE'),
  replyOnMessage(event: 'REPLY_MESSAGE'),
  forwardMessage(event: 'FORWARD_MESSAGE'),
  readChat(event: 'READ_CHAT'),
  //////////////////////////////
  receiveMessage(event: 'RECEIVE_MESSAGE'),
  receiveReply(event: 'RECEIVE_REPLY'),
  receiveDraft(event: 'RECEIVE_DRAFT'),
  ;

  final String event;

  const EventType({required this.event});

}

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

abstract class EmittedEvent {
  final Object payload;
  EmittedEvent(this.payload);

  Future<bool> execute(SocketService socket, {Duration timeout = const Duration(seconds: 10)});
}


// final completer = Completer<bool>();
//     final timer = Timer(timeout, () {
//       if (!completer.isCompleted) {
//         completer.complete(false); // Timeout occurred
//       }
//     });

//     // Emit the event and wait for acknowledgment
//     socket.emitWithAck(type, payload, ack: (response) {
//       if (!completer.isCompleted) {
//         timer.cancel(); // Cancel the timeout timer
//         if (response['status'] == 'success') {
//           completer.complete(true);
//         } else {
//           completer.complete(false);
//         }
//       }
//     });

//     return completer.future;