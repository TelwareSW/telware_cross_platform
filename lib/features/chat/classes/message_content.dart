// Base class for all message contents
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:hive/hive.dart';

part 'message_content.g.dart'; // Part file for generated code

abstract class MessageContent {
  Map<String, dynamic> toJson(); // For serialization
}

// For Text Messages
@HiveType(typeId: 15)
class TextContent extends MessageContent {
  @HiveField(0)
  final String text;

  TextContent(this.text);

  @override
  Map<String, dynamic> toJson() => {'text': text};
}

// For Audio Messages
@HiveType(typeId: 16)
class AudioContent extends MessageContent {
  @HiveField(0)
  final String audioUrl;
  @HiveField(1)
  final int duration;
  @HiveField(2)
  final String? filePath;
  @HiveField(3)
  final List<double>? waveformData;

  AudioContent(
      {required this.audioUrl,
      required this.duration,
      this.filePath,
      this.waveformData});

  @override
  Map<String, dynamic> toJson() => {
        'audioUrl': audioUrl,
        'duration': duration,
        'filePath': filePath,
        'waveformData': waveformData,
      };
}

// For Document Messages (PDFs, Docs)
@HiveType(typeId: 17)
class DocumentContent extends MessageContent {
  @HiveField(0)
  final String fileName;
  @HiveField(1)
  final String fileUrl;

  DocumentContent(this.fileName, this.fileUrl);

  @override
  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'fileUrl': fileUrl,
      };
}

// For Image Messages
@HiveType(typeId: 18)
class ImageContent extends MessageContent {
  @HiveField(0)
  final String imageUrl;
  @HiveField(1)
  final Uint8List? imageBytes;
  @HiveField(2)
  final String filePath;

  ImageContent(
      {required this.imageUrl, this.imageBytes, required this.filePath});

  @override
  Map<String, dynamic> toJson() =>
      {'imageUrl': imageUrl, 'imageBytes': imageBytes, "filePath": filePath};
}

// For Video Messages
@HiveType(typeId: 19)
class VideoContent extends MessageContent {
  @HiveField(0)
  final String videoUrl;
  @HiveField(1)
  final int duration;
  @HiveField(2)
  final String filePath;

  VideoContent(
      {required this.videoUrl, required this.duration, required this.filePath});

  @override
  Map<String, dynamic> toJson() => {
        'videoUrl': videoUrl,
        'duration': duration,
        'filePath': filePath,
      };
}
