import 'dart:io';
import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import '../../../core/constants/server_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String?> downloadAndSaveFile(
    String? url, String? originalFileName) async {
  if (url == null || url.isEmpty) {
    return null;
  }

  // Ensure URL is complete
  if (!url.startsWith('https')) {
    url = '$API_URL_PICTURES/$url';
  }

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Get the bytes from the response
      Uint8List fileBytes = response.bodyBytes;

      // Determine the local path to save the file
      final Directory directory = await getTemporaryDirectory();
      final String fileName = url.split('/').last; // Extract file name from URL
      final String filePath = '${directory.path}/$fileName';

      // Save the file locally
      File file = File(filePath);
      await file.writeAsBytes(fileBytes);

      debugPrint('File saved at: $filePath');
      return filePath; // Return the saved file path
    } else {
      debugPrint(
          'Failed to download file. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    debugPrint('Error downloading file: $e');
    return null;
  }
}

Future<void> downloadFile(String url, String fileName) async {
  // Request storage permission
  var status = await Permission.storage.request();
  if (status.isGranted) {
    try {
      // Get device's download directory
      Directory? directory = await getExternalStorageDirectory();
      String filePath = '${directory!.path}/$fileName';

      // Download the file using Dio
      Dio dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint(
                '${(received / total * 100).toStringAsFixed(0)}%'); // Progress percentage
          }
        },
      );

      debugPrint('File downloaded to: $filePath');
    } catch (e) {
      debugPrint('Download error: $e');
    }
  } else {
    debugPrint('Permission denied');
  }
}

bool doesFileExistSync(String filePath) {
  final file = File(filePath);
  return file.existsSync();
}

/////////////////////////////////////
// update file path
//TODO MUST BE UPDATED WHEN ADDING OTHER CHAT TYPES

List<ChatModel> updateMessagesFilePath(List<ChatModel> chats,
    {String? filePath}) {
  // Iterate through each chat and update messages if the file path is invalid
  return chats.map((chat) {
    List<MessageModel> updatedMessages = chat.messages.map((message) {
      return updateMessageIfFileMissing(message, filePath);
    }).toList();

    return chat.copyWith(messages: updatedMessages);
  }).toList();
}

MessageModel updateMessageIfFileMissing(
    MessageModel message, String? filePath) {
  final content = message.content;

  // Check if the file exists
  bool fileExists(String? path) => path != null && doesFileExistSync(path);

  switch (message.messageContentType) {
    case MessageContentType.image:
      return updateContent<ImageContent>(
          message, content as ImageContent, fileExists, filePath);

    case MessageContentType.video:
      return updateContent<VideoContent>(
          message, content as VideoContent, fileExists, filePath);

    case MessageContentType.audio:
      return updateContent<AudioContent>(
          message, content as AudioContent, fileExists, filePath);

    case MessageContentType.file:
      return updateContent<DocumentContent>(
          message, content as DocumentContent, fileExists, filePath);

    case MessageContentType.sticker:
      return updateContent<StickerContent>(
          message, content as StickerContent, fileExists, filePath);

    case MessageContentType.gif:
      return updateContent<GIFContent>(
          message, content as GIFContent, fileExists, filePath);

    case MessageContentType.emoji:
      return updateContent<EmojiContent>(
          message, content as EmojiContent, fileExists, filePath);

    default:
      return message;
  }
}

// Generic function to handle content updates based on file existence
MessageModel updateContent<T>(MessageModel message, T content,
    bool Function(String?) fileExists, String? newFilePath) {
  final filePath = (content as dynamic).filePath;
  if (!fileExists(filePath)) {
    debugPrint('!!! ${T.toString()} content: $filePath');
    debugPrint("!!! file does not exist");
    return message.copyWith(content: content.copyWith(filePath: newFilePath));
  }
  return message;
}

/////////////////////////////////////

// TODO: ADD OTHER CHAT TYPES
MessageContent createMessageContent({
  required MessageContentType contentType,
  String? filePath,
  String? fileName,
  String? mediaUrl,
  int? duration,
  String text = '',
  bool isMusic = false,
}) {
  switch (contentType) {
    case MessageContentType.text || MessageContentType.link:
      return TextContent(text);
    case MessageContentType.image:
      return ImageContent(
        filePath: filePath,
        fileName: fileName,
        mediaUrl: mediaUrl,
        caption: text,
      );
    case MessageContentType.video:
      return VideoContent(
        filePath: filePath,
        fileName: fileName,
        mediaUrl: mediaUrl,
        duration: duration,
      );
    case MessageContentType.audio:
      return AudioContent(
        filePath: filePath,
        fileName: fileName,
        mediaUrl: mediaUrl,
        duration: duration,
        isMusic: isMusic,
      );
    case MessageContentType.file:
      return DocumentContent(
        mediaUrl: mediaUrl,
        filePath: filePath,
        fileName: fileName ??
            (filePath != null ? filePath.split('/').last : "Untitled"),
      );
    case MessageContentType.sticker:
      return StickerContent(
        filePath: filePath,
        fileName: fileName,
        mediaUrl: mediaUrl,
      );
    case MessageContentType.gif:
      return GIFContent(
        filePath: filePath,
        fileName: fileName,
        mediaUrl: mediaUrl,
      );
    case MessageContentType.emoji:
      return EmojiContent(
        filePath: filePath,
        fileName: fileName,
        mediaUrl: mediaUrl,
      );
    default:
      return TextContent('This is a text message for unknown content type');
  }
}

String getUniqueMessageId() {
  return faker.guid.guid();
}
