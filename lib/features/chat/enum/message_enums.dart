enum MessageState {
  sent(text: 'sent'),
  read(text: 'read'),
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

enum MessageType {
  normal(text: 'normal'),
  announcement(text: 'announcement'),
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

enum MessageContentType {
  text(content: 'text'),
  image(content: 'image'),
  gif(content: 'GIF'),
  sticker(content: 'sticker'),
  audio(content: 'audio'),
  video(content: 'video'),
  file(content: 'file'),
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

enum DeleteMessageType {
  onlyMe(text: 'only-me'),
  all(text: 'all');

  final String text;
  const DeleteMessageType({required this.text});
}