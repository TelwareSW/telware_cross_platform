// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 6;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      autoDeleteTimestamp: fields[4] as DateTime?,
      senderId: fields[0] as String,
      messageType: fields[1] as MessageType,
      messageContentType: fields[2] as MessageContentType,
      content: fields[3] as MessageContent?,
      timestamp: fields[5] as DateTime,
      id: fields[6] as String?,
      photo: fields[7] as String?,
      photoBytes: fields[8] as Uint8List?,
      userStates: (fields[9] as Map).cast<String, MessageState>(),
      isPinned: fields[10] as bool,
      localId: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.senderId)
      ..writeByte(1)
      ..write(obj.messageType)
      ..writeByte(2)
      ..write(obj.messageContentType)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.autoDeleteTimestamp)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.id)
      ..writeByte(7)
      ..write(obj.photo)
      ..writeByte(8)
      ..write(obj.photoBytes)
      ..writeByte(9)
      ..write(obj.userStates)
      ..writeByte(10)
      ..write(obj.isPinned)
      ..writeByte(11)
      ..write(obj.localId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
