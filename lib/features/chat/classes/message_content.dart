// Base class for all message contents
import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'message_content.g.dart'; // Part file for generated code

abstract class MessageContent {
  Map<String, dynamic> toJson();

  MessageContent copyWith();

  String getContent();
}

// For Text Messages
@HiveType(typeId: 15)
class TextContent extends MessageContent {
  @HiveField(0)
  final String text;

  TextContent(this.text);

  @override
  Map<String, dynamic> toJson() => {'text': text};

  @override
  TextContent copyWith({
    String? text,
  }) {
    return TextContent(
      text ?? this.text,
    );
  }

  @override
  String getContent() {
    return text;
  }
}

// For Audio Messages
@HiveType(typeId: 16)
class AudioContent extends MessageContent {
  @HiveField(0)
  final String? audioUrl;
  @HiveField(1)
  final int? duration;
  @HiveField(2)
  final String? filePath;
  @HiveField(4)
  final String? fileName;
  @HiveField(5)
  final List<double>? waveformData;
  @HiveField(6)
  final bool? isMusic;

  AudioContent(
      {this.isMusic,
      this.audioUrl,
      this.duration,
      this.filePath,
      this.fileName,
      this.waveformData});

  @override
  Map<String, dynamic> toJson() => {
        'audioUrl': audioUrl,
        'duration': duration,
        'filePath': filePath,
        'fileName': fileName,
        'waveformData': waveformData,
        'isMusic': isMusic,
      };

  @override
  AudioContent copyWith({
    String? audioUrl,
    int? duration,
    String? filePath,
    String? fileName,
    List<double>? waveformData,
    bool? isMusic,
  }) {
    return AudioContent(
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      waveformData: waveformData ?? this.waveformData,
      isMusic: isMusic ?? this.isMusic,
    );
  }

  @override
  String getContent() {
    return '';
  }
}

// For Document Messages (PDFs, Docs)
@HiveType(typeId: 17)
class DocumentContent extends MessageContent {
  @HiveField(0)
  final String fileName;
  @HiveField(1)
  final String? fileUrl;
  @HiveField(2)
  final String? filePath;

  DocumentContent({required this.fileName, this.fileUrl, this.filePath});

  @override
  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'fileUrl': fileUrl,
        'filePath': filePath,
      };

  @override
  DocumentContent copyWith({
    String? fileName,
    String? fileUrl,
    String? filePath,
  }) {
    return DocumentContent(
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  String getContent() {
    return '';
  }
}

// For Image Messages
@HiveType(typeId: 18)
class ImageContent extends MessageContent {
  @HiveField(0)
  final String? imageUrl;
  @HiveField(1)
  final Uint8List? imageBytes;
  @HiveField(2)
  final String? filePath;
  @HiveField(3)
  final String? fileName;
  @HiveField(4)
  final String? caption;

  ImageContent(
      {this.imageUrl,
      this.imageBytes,
      this.filePath,
      this.fileName,
      this.caption});

  @override
  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'imageBytes': imageBytes,
        "filePath": filePath,
        "fileName": fileName,
        "caption": caption
      };

  @override
  ImageContent copyWith({
    String? imageUrl,
    Uint8List? imageBytes,
    String? filePath,
    String? fileName,
    String? caption,
  }) {
    return ImageContent(
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      caption: caption ?? this.caption,
    );
  }

  @override
  String getContent() {
    return '';
  }
}

// For Video Messages
@HiveType(typeId: 19)
class VideoContent extends MessageContent {
  @HiveField(0)
  final String? videoUrl;
  @HiveField(1)
  final int? duration;
  @HiveField(2)
  final String? filePath;
  @HiveField(3)
  final String? fileName;

  VideoContent({this.videoUrl, this.duration, this.fileName, this.filePath});

  @override
  Map<String, dynamic> toJson() => {
        'videoUrl': videoUrl,
        'duration': duration,
        'filePath': filePath,
        'fileName': fileName,
      };

  @override
  VideoContent copyWith({
    String? videoUrl,
    int? duration,
    String? filePath,
    String? fileName,
  }) {
    return VideoContent(
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
    );
  }

  @override
  String getContent() {
    return '';
  }
}

// for emoji, gifs and stickers
@HiveType(typeId: 20)
class EmojiContent extends MessageContent {
  @HiveField(0)
  final String? emojiUrl;
  @HiveField(1)
  final String? emojiName;
  @HiveField(2)
  final String? filePath;

  EmojiContent({this.emojiUrl, this.emojiName, this.filePath});

  @override
  Map<String, dynamic> toJson() => {
        'emojiUrl': emojiUrl,
        'emojiName': emojiName,
        'filePath': filePath,
      };

  @override
  EmojiContent copyWith({
    String? emojiUrl,
    String? emojiName,
    String? filePath,
  }) {
    return EmojiContent(
      emojiUrl: emojiUrl ?? this.emojiUrl,
      emojiName: emojiName ?? this.emojiName,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  String getContent() {
    return '';
  }
}

@HiveType(typeId: 21)
class GIFContent extends MessageContent {
  @HiveField(0)
  final String? gifUrl;
  @HiveField(1)
  final String? gifName;
  @HiveField(2)
  final String? filePath;

  GIFContent({this.gifUrl, this.gifName, this.filePath});

  @override
  Map<String, dynamic> toJson() => {
        'gifUrl': gifUrl,
        'gifName': gifName,
        'filePath': filePath,
      };

  @override
  GIFContent copyWith({
    String? gifUrl,
    String? gifName,
    String? filePath,
  }) {
    return GIFContent(
      gifUrl: gifUrl ?? this.gifUrl,
      gifName: gifName ?? this.gifName,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  String getContent() {
    return '';
  }
}

@HiveType(typeId: 22)
class StickerContent extends MessageContent {
  @HiveField(0)
  final String? stickerUrl;
  @HiveField(1)
  final String? stickerName;
  @HiveField(2)
  final String? filePath;

  StickerContent({this.stickerUrl, this.stickerName, this.filePath});

  @override
  Map<String, dynamic> toJson() => {
        'stickerUrl': stickerUrl,
        'stickerName': stickerName,
        'filePath': filePath,
      };

  @override
  StickerContent copyWith({
    String? stickerUrl,
    String? stickerName,
    String? filePath,
  }) {
    return StickerContent(
      stickerUrl: stickerUrl ?? this.stickerUrl,
      stickerName: stickerName ?? this.stickerName,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  String getContent() {
    return '';
  }
}
