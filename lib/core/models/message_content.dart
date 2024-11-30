// Base class for all message contents
import 'dart:typed_data';

import 'package:camera/camera.dart';

abstract class MessageContent {
  Map<String, dynamic> toJson(); // For serialization
}

// For Text Messages
class TextContent extends MessageContent {
  final String text;

  TextContent(this.text);

  @override
  Map<String, dynamic> toJson() => {'text': text};
}

// For Audio Messages
class AudioContent extends MessageContent {
  final String audioUrl;
  final Duration duration;
  final String? filePath;
  final List<double>? waveformData;

  AudioContent(
      {required this.audioUrl,
      required this.duration,
      this.filePath,
      this.waveformData});

  @override
  Map<String, dynamic> toJson() => {
        'audioUrl': audioUrl,
        'duration': duration.inSeconds,
        'filePath': filePath,
        'waveformData': waveformData,
      };
}

// For Document Messages (PDFs, Docs)
class DocumentContent extends MessageContent {
  final String fileName;
  final String fileUrl;

  DocumentContent(this.fileName, this.fileUrl);

  @override
  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'fileUrl': fileUrl,
      };
}

// For Image Messages
class ImageContent extends MessageContent {
  final String imageUrl;
  final Uint8List? imageBytes;
  final XFile file;

  ImageContent({required this.imageUrl, this.imageBytes, required this.file});

  @override
  Map<String, dynamic> toJson() =>
      {'imageUrl': imageUrl, 'imageBytes': imageBytes, "file": file};
}

// For Video Messages
class VideoContent extends MessageContent {
  final String videoUrl;
  final Duration duration;
  final XFile file;

  VideoContent(
      {required this.videoUrl, required this.duration, required this.file});

  @override
  Map<String, dynamic> toJson() => {
        'videoUrl': videoUrl,
        'duration': duration.inSeconds,
        'file': file,
      };
}
