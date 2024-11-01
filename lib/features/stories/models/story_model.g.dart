// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoryModelAdapter extends TypeAdapter<StoryModel> {
  @override
  final int typeId = 1;

  @override
  StoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoryModel(
      storyId: fields[0] as String,
      isSeen: fields[1] as bool,
      createdAt: fields[4] as DateTime,
      seenIds: (fields[6] as List).cast<String>(),
      storyContentType: fields[2] as String,
      storyContentUrl: fields[3] as String,
      storyCaption: fields[5] as String,
      storyContent: fields[7] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, StoryModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.storyId)
      ..writeByte(1)
      ..write(obj.isSeen)
      ..writeByte(2)
      ..write(obj.storyContentType)
      ..writeByte(3)
      ..write(obj.storyContentUrl)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.storyCaption)
      ..writeByte(6)
      ..write(obj.seenIds)
      ..writeByte(7)
      ..write(obj.storyContent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
