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
