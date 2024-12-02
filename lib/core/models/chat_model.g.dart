// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatModelAdapter extends TypeAdapter<ChatModel> {
  @override
  final int typeId = 4;

  @override
  ChatModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatModel(
      title: fields[0] as String,
      userIds: (fields[1] as List).cast<String>(),
      photo: fields[2] as String?,
      type: fields[3] as ChatType,
      id: fields[5] as String?,
      photoBytes: fields[4] as Uint8List?,
      admins: (fields[6] as List?)?.cast<String>(),
      description: fields[7] as String?,
      lastMessageTimestamp: fields[8] as DateTime?,
      isArchived: fields[9] as bool,
      isMuted: fields[10] as bool,
      isMentioned: fields[12] as bool,
      draft: fields[11] as String?,
      messages: (fields[13] as List).cast<MessageModel>(),
      muteUntil: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.userIds)
      ..writeByte(2)
      ..write(obj.photo)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.photoBytes)
      ..writeByte(5)
      ..write(obj.id)
      ..writeByte(6)
      ..write(obj.admins)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.lastMessageTimestamp)
      ..writeByte(9)
      ..write(obj.isArchived)
      ..writeByte(10)
      ..write(obj.isMuted)
      ..writeByte(11)
      ..write(obj.draft)
      ..writeByte(12)
      ..write(obj.isMentioned)
      ..writeByte(13)
      ..write(obj.messages)
      ..writeByte(14)
      ..write(obj.muteUntil);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
