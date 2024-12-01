// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageStateAdapter extends TypeAdapter<MessageState> {
  @override
  final int typeId = 11;

  @override
  MessageState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageState.sent;
      case 1:
        return MessageState.read;
      case 2:
        return MessageState.pending;
      default:
        return MessageState.sent;
    }
  }

  @override
  void write(BinaryWriter writer, MessageState obj) {
    switch (obj) {
      case MessageState.sent:
        writer.writeByte(0);
        break;
      case MessageState.read:
        writer.writeByte(1);
        break;
      case MessageState.pending:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 12;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.normal;
      case 1:
        return MessageType.announcement;
      case 2:
        return MessageType.forward;
      default:
        return MessageType.normal;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    switch (obj) {
      case MessageType.normal:
        writer.writeByte(0);
        break;
      case MessageType.announcement:
        writer.writeByte(1);
        break;
      case MessageType.forward:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageContentTypeAdapter extends TypeAdapter<MessageContentType> {
  @override
  final int typeId = 13;

  @override
  MessageContentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageContentType.text;
      case 1:
        return MessageContentType.image;
      case 2:
        return MessageContentType.emoji;
      case 3:
        return MessageContentType.gif;
      case 4:
        return MessageContentType.sticker;
      case 5:
        return MessageContentType.audio;
      case 6:
        return MessageContentType.video;
      case 7:
        return MessageContentType.file;
      case 8:
        return MessageContentType.link;
      default:
        return MessageContentType.text;
    }
  }

  @override
  void write(BinaryWriter writer, MessageContentType obj) {
    switch (obj) {
      case MessageContentType.text:
        writer.writeByte(0);
        break;
      case MessageContentType.image:
        writer.writeByte(1);
        break;
      case MessageContentType.emoji:
        writer.writeByte(2);
        break;
      case MessageContentType.gif:
        writer.writeByte(3);
        break;
      case MessageContentType.sticker:
        writer.writeByte(4);
        break;
      case MessageContentType.audio:
        writer.writeByte(5);
        break;
      case MessageContentType.video:
        writer.writeByte(6);
        break;
      case MessageContentType.file:
        writer.writeByte(7);
        break;
      case MessageContentType.link:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageContentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeleteMessageTypeAdapter extends TypeAdapter<DeleteMessageType> {
  @override
  final int typeId = 14;

  @override
  DeleteMessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DeleteMessageType.onlyMe;
      case 1:
        return DeleteMessageType.all;
      default:
        return DeleteMessageType.onlyMe;
    }
  }

  @override
  void write(BinaryWriter writer, DeleteMessageType obj) {
    switch (obj) {
      case DeleteMessageType.onlyMe:
        writer.writeByte(0);
        break;
      case DeleteMessageType.all:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteMessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
