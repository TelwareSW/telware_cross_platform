// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_event_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageEventAdapter extends TypeAdapter<MessageEvent> {
  @override
  final int typeId = 7;

  @override
  MessageEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageEvent(
      (fields[0] as Map).cast<String, dynamic>(),
      msgId: fields[1] as String,
      chatId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MessageEvent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.payload)
      ..writeByte(1)
      ..write(obj.msgId)
      ..writeByte(2)
      ..write(obj.chatId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SendMessageEventAdapter extends TypeAdapter<SendMessageEvent> {
  @override
  final int typeId = 8;

  @override
  SendMessageEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SendMessageEvent(
      (fields[0] as Map).cast<String, dynamic>(),
      msgId: fields[1] as String,
      chatId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SendMessageEvent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.payload)
      ..writeByte(1)
      ..write(obj.msgId)
      ..writeByte(2)
      ..write(obj.chatId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendMessageEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeleteMessageEventAdapter extends TypeAdapter<DeleteMessageEvent> {
  @override
  final int typeId = 9;

  @override
  DeleteMessageEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeleteMessageEvent(
      (fields[0] as Map).cast<String, dynamic>(),
      msgId: fields[1] as String,
      chatId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeleteMessageEvent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.payload)
      ..writeByte(1)
      ..write(obj.msgId)
      ..writeByte(2)
      ..write(obj.chatId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteMessageEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EditMessageEventAdapter extends TypeAdapter<EditMessageEvent> {
  @override
  final int typeId = 10;

  @override
  EditMessageEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EditMessageEvent(
      (fields[0] as Map).cast<String, dynamic>(),
      msgId: fields[1] as String,
      chatId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EditMessageEvent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.payload)
      ..writeByte(1)
      ..write(obj.msgId)
      ..writeByte(2)
      ..write(obj.chatId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditMessageEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UpdateDraftEventAdapter extends TypeAdapter<UpdateDraftEvent> {
  @override
  final int typeId = 11;

  @override
  UpdateDraftEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdateDraftEvent(
      (fields[0] as Map).cast<String, dynamic>(),
      msgId: fields[1] as String,
      chatId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UpdateDraftEvent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.payload)
      ..writeByte(1)
      ..write(obj.msgId)
      ..writeByte(2)
      ..write(obj.chatId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateDraftEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
