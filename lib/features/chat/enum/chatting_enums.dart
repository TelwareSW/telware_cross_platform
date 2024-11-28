import 'package:hive/hive.dart';

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

@HiveType(typeId: 5)
enum ChatType {
  @HiveField(0)
  private(type: 'private'),
  @HiveField(1)
  group(type: 'group'),
  @HiveField(2)
  channel(type: 'channel');

  static ChatType getType(String type) {
    switch (type) {
      case 'group':
        return ChatType.group;
      case 'channel':
        return ChatType.channel;
      default:
        return ChatType.private;
    }
  }

  final String type;
  const ChatType({required this.type});
}