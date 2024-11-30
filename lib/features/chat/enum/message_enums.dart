import 'package:hive/hive.dart';

part 'message_enums.g.dart';

@HiveType(typeId: 11)
enum MessageState {
  @HiveField(0)
  sent(text: 'sent'),
  @HiveField(1)
  read(text: 'read'),
  @HiveField(2)
  pending(text: 'pending');

  static MessageState getType(String type) {
    switch (type) {
      case 'sent':
        return MessageState.sent;
      case 'read':
        return MessageState.read;
      default:
        return MessageState.pending;
    }
  }

  final String text;

  const MessageState({required this.text});
}

@HiveType(typeId: 12)
enum MessageType {
  @HiveField(0)
  normal(text: 'normal'),
  @HiveField(1)
  announcement(text: 'announcement'),
  @HiveField(2)
  forward(text: 'forward');

  static MessageType getType(String type) {
    switch (type) {
      case 'announcement':
        return MessageType.announcement;
      case 'forward':
        return MessageType.forward;
      default:
        return MessageType.normal;
    }
  }

  final String text;

  const MessageType({required this.text});
}

@HiveType(typeId: 13)
enum MessageContentType {
  @HiveField(0)
  text(content: 'text'),
  @HiveField(1)
  image(content: 'image'),
  @HiveField(2)
  gif(content: 'GIF'),
  @HiveField(3)
  sticker(content: 'sticker'),
  @HiveField(4)
  audio(content: 'audio'),
  @HiveField(5)
  video(content: 'video'),
  @HiveField(6)
  file(content: 'file'),
  @HiveField(7)
  link(content: 'link');

  static MessageContentType getType(String type) {
    switch (type) {
      case 'image':
        return MessageContentType.image;
      case 'GIF':
        return MessageContentType.gif;
      case 'sticker':
        return MessageContentType.sticker;
      case 'audio':
        return MessageContentType.audio;
      case 'video':
        return MessageContentType.video;
      case 'file':
        return MessageContentType.file;
      case 'link':
        return MessageContentType.link;
      default:
        return MessageContentType.text;
    }
  }

  final String content;

  const MessageContentType({required this.content});
}

@HiveType(typeId: 14)
enum DeleteMessageType {
  @HiveField(0)
  onlyMe(text: 'only-me'),
  @HiveField(1)
  all(text: 'all');

  final String text;

  const DeleteMessageType({required this.text});
}
