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
      senderName: fields[0] as String,
      content: fields[1] as String?,
      timestamp: fields[2] as DateTime,
      autoDeleteDuration: fields[3] as Duration?,
      id: fields[4] as String?,
      photo: fields[5] as String?,
      photoBytes: fields[6] as Uint8List?,
      userStates: (fields[7] as Map?)?.cast<String, MessageState>(),
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.senderName)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.autoDeleteDuration)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.photo)
      ..writeByte(6)
      ..write(obj.photoBytes)
      ..writeByte(7)
      ..write(obj.userStates);
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