// Base class for all message contents
import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'message_content.g.dart'; // Part file for generated code

@HiveType(typeId: 32)
class MessageContent {
  @HiveField(0)
  String? fileName;
  @HiveField(1)
  String? filePath;
  @HiveField(2)
  String? mediaUrl;

  MessageContent({this.fileName, this.filePath, this.mediaUrl});

  Map<String, dynamic> toJson() {
    return {};
  }

  MessageContent copyWith() {
    return MessageContent();
  }

  String getContent() {
    return '';
  }

  String? getMediaURL() {
    return null;
  }
}

// For Text Messages
@HiveType(typeId: 15)
class TextContent extends MessageContent {
  @HiveField(3)
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

  @override
  String? getMediaURL() {
    return null;
  }
}

// For Audio Messages
@HiveType(typeId: 16)
class AudioContent extends MessageContent {
  @HiveField(3)
  final int? duration;
  @HiveField(4)
  final bool? isMusic;

  AudioContent({
    this.isMusic,
    super.mediaUrl,
    this.duration,
    super.filePath,
    super.fileName,
  });

  @override
  Map<String, dynamic> toJson() => {
        'audioUrl': super.mediaUrl,
        'duration': duration,
        'filePath': super.filePath,
        'fileName': super.fileName,
        'isMusic': isMusic,
      };

  @override
  AudioContent copyWith({
    String? audioUrl,
    int? duration,
    String? filePath,
    String? fileName,
    bool? isMusic,
  }) {
    return AudioContent(
      mediaUrl: audioUrl ?? super.mediaUrl,
      duration: duration ?? this.duration,
      filePath: filePath ?? super.filePath,
      fileName: fileName ?? super.fileName,
      isMusic: isMusic ?? this.isMusic,
    );
  }

  @override
  String getContent() {
    return fileName ?? '';
  }

  @override
  String? getMediaURL() {
    return mediaUrl;
  }
}

// For Document Messages (PDFs, Docs)
@HiveType(typeId: 17)
class DocumentContent extends MessageContent {
  DocumentContent({super.fileName, super.mediaUrl, super.filePath});

  @override
  Map<String, dynamic> toJson() => {
        'fileName': super.fileName,
        'fileUrl': super.mediaUrl,
        'filePath': super.filePath,
      };

  @override
  DocumentContent copyWith({
    String? fileName,
    String? fileUrl,
    String? filePath,
  }) {
    return DocumentContent(
      fileName: fileName ?? super.fileName,
      mediaUrl: fileUrl ?? super.mediaUrl,
      filePath: filePath ?? super.filePath,
    );
  }

  @override
  String getContent() {
    return fileName ?? '';
  }

  @override
  String? getMediaURL() {
    return mediaUrl;
  }
}

// For Image Messages
@HiveType(typeId: 18)
class ImageContent extends MessageContent {
  @HiveField(3)
  final String? caption;

  ImageContent({super.mediaUrl, super.filePath, super.fileName, this.caption});

  @override
  Map<String, dynamic> toJson() => {
        'imageUrl': super.mediaUrl,
        "filePath": super.filePath,
        "fileName": super.fileName,
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
      mediaUrl: imageUrl ?? super.mediaUrl,
      filePath: filePath ?? super.filePath,
      fileName: fileName ?? super.fileName,
      caption: caption ?? this.caption,
    );
  }

  @override
  String getContent() {
    return caption?.isNotEmpty == true ? (caption ?? '') : (fileName ?? '');
  }

  @override
  String? getMediaURL() {
    return mediaUrl;
  }
}

// For Video Messages
@HiveType(typeId: 19)
class VideoContent extends MessageContent {
  @HiveField(3)
  final int? duration;

  VideoContent({super.mediaUrl, this.duration, super.fileName, super.filePath});

  @override
  Map<String, dynamic> toJson() => {
        'videoUrl': super.mediaUrl,
        'duration': duration,
        'filePath': super.filePath,
        'fileName': super.fileName,
      };

  @override
  VideoContent copyWith({
    String? videoUrl,
    int? duration,
    String? filePath,
    String? fileName,
  }) {
    return VideoContent(
      mediaUrl: videoUrl ?? super.mediaUrl,
      duration: duration ?? this.duration,
      filePath: filePath ?? super.filePath,
      fileName: fileName ?? super.fileName,
    );
  }

  @override
  String getContent() {
    return fileName ?? '';
  }

  @override
  String? getMediaURL() {
    return mediaUrl;
  }
}

// for emoji, gifs and stickers
@HiveType(typeId: 20)
class EmojiContent extends MessageContent {
  EmojiContent({super.mediaUrl, super.fileName, super.filePath});

  @override
  Map<String, dynamic> toJson() => {
        'emojiUrl': super.mediaUrl,
        'emojiName': super.fileName,
        'filePath': filePath,
      };

  @override
  EmojiContent copyWith({
    String? emojiUrl,
    String? emojiName,
    String? filePath,
  }) {
    return EmojiContent(
      mediaUrl: emojiUrl ?? super.mediaUrl,
      fileName: emojiName ?? super.fileName,
      filePath: filePath ?? super.filePath,
    );
  }

  @override
  String getContent() {
    return fileName ?? '';
  }

  @override
  String? getMediaURL() {
    return mediaUrl;
  }
}

@HiveType(typeId: 21)
class GIFContent extends MessageContent {
  GIFContent({super.mediaUrl, super.fileName, super.filePath});

  @override
  Map<String, dynamic> toJson() => {
        'gifUrl': super.mediaUrl,
        'gifName': super.fileName,
        'filePath': super.filePath,
      };

  @override
  GIFContent copyWith({
    String? gifUrl,
    String? gifName,
    String? filePath,
  }) {
    return GIFContent(
      mediaUrl: gifUrl ?? super.mediaUrl,
      fileName: gifName ?? super.fileName,
      filePath: filePath ?? super.filePath,
    );
  }

  @override
  String getContent() {
    return fileName ?? '';
  }

  @override
  String? getMediaURL() {
    return mediaUrl;
  }
}

@HiveType(typeId: 22)
class StickerContent extends MessageContent {
  StickerContent({super.mediaUrl, super.fileName, super.filePath});

  @override
  Map<String, dynamic> toJson() => {
        'stickerUrl': super.mediaUrl,
        'stickerName': super.fileName,
        'filePath': super.filePath,
      };

  @override
  StickerContent copyWith({
    String? stickerUrl,
    String? stickerName,
    String? filePath,
  }) {
    return StickerContent(
      mediaUrl: stickerUrl ?? super.mediaUrl,
      fileName: stickerName ?? super.fileName,
      filePath: filePath ?? super.filePath,
    );
  }

  @override
  String getContent() {
    return fileName ?? '';
  }

  @override
  String? getMediaURL() {
    return mediaUrl;
  }
}
