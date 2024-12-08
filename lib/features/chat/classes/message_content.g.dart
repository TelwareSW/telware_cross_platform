// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_content.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TextContentAdapter extends TypeAdapter<TextContent> {
  @override
  final int typeId = 15;

  @override
  TextContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TextContent(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TextContent obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AudioContentAdapter extends TypeAdapter<AudioContent> {
  @override
  final int typeId = 16;

  @override
  AudioContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AudioContent(
      audioUrl: fields[0] as String?,
      duration: fields[1] as int?,
      filePath: fields[2] as String?,
      waveformData: (fields[3] as List?)?.cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, AudioContent obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.audioUrl)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.waveformData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentContentAdapter extends TypeAdapter<DocumentContent> {
  @override
  final int typeId = 17;

  @override
  DocumentContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentContent(
      fileName: fields[0] as String,
      fileUrl: fields[1] as String?,
      filePath: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentContent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.fileName)
      ..writeByte(1)
      ..write(obj.fileUrl)
      ..writeByte(2)
      ..write(obj.filePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ImageContentAdapter extends TypeAdapter<ImageContent> {
  @override
  final int typeId = 18;

  @override
  ImageContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageContent(
      imageUrl: fields[0] as String?,
      imageBytes: fields[1] as Uint8List?,
      filePath: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ImageContent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.imageUrl)
      ..writeByte(1)
      ..write(obj.imageBytes)
      ..writeByte(2)
      ..write(obj.filePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VideoContentAdapter extends TypeAdapter<VideoContent> {
  @override
  final int typeId = 19;

  @override
  VideoContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoContent(
      videoUrl: fields[0] as String?,
      duration: fields[1] as int?,
      filePath: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VideoContent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.videoUrl)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.filePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmojiContentAdapter extends TypeAdapter<EmojiContent> {
  @override
  final int typeId = 20;

  @override
  EmojiContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmojiContent(
      emojiUrl: fields[0] as String?,
      emojiName: fields[1] as String?,
      filePath: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EmojiContent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.emojiUrl)
      ..writeByte(1)
      ..write(obj.emojiName)
      ..writeByte(2)
      ..write(obj.filePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmojiContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GIFContentAdapter extends TypeAdapter<GIFContent> {
  @override
  final int typeId = 21;

  @override
  GIFContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GIFContent(
      gifUrl: fields[0] as String?,
      gifName: fields[1] as String?,
      filePath: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GIFContent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.gifUrl)
      ..writeByte(1)
      ..write(obj.gifName)
      ..writeByte(2)
      ..write(obj.filePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GIFContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StickerContentAdapter extends TypeAdapter<StickerContent> {
  @override
  final int typeId = 22;

  @override
  StickerContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StickerContent(
      stickerUrl: fields[0] as String?,
      stickerName: fields[1] as String?,
      filePath: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StickerContent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.stickerUrl)
      ..writeByte(1)
      ..write(obj.stickerName)
      ..writeByte(2)
      ..write(obj.filePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StickerContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
