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

Future<String?> downloadAndSaveFile(String? url) async {
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
      final Directory directory = await getApplicationDocumentsDirectory();
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
List<ChatModel> updateMessagesFilePath(List<ChatModel> chats) {
  // loop over chat messages and check if they are a media and if they are check if the file exists
  // if not set the file path to null
  bool isUpdated = false;
  for (var i = 0; i < chats.length; i++) {
    List<MessageModel> updatedMessages = [];
    for (var j = 0; j < chats[i].messages.length; j++) {
      var message = chats[i].messages[j];

      if (message.messageContentType != MessageContentType.text) {
        switch (message.messageContentType) {
          case MessageContentType.image:
            final imageContent = message.content as ImageContent;
            if (imageContent.filePath != null &&
                !doesFileExistSync(imageContent.filePath!)) {
              debugPrint('!!! image content: ${imageContent.filePath}');
              debugPrint("!!! file does not exist");
              isUpdated = true;
              message = message.copyWith(
                  content: imageContent.copyWith(filePath: null));
            }
            break;

          case MessageContentType.video:
            final videoContent = message.content as VideoContent;
            if (videoContent.filePath != null &&
                !doesFileExistSync(videoContent.filePath!)) {
              isUpdated = true;
              message = message.copyWith(
                  content: videoContent.copyWith(filePath: null));
            }
            break;

          case MessageContentType.audio:
            final audioContent = message.content as AudioContent;
            if (audioContent.filePath != null &&
                !doesFileExistSync(audioContent.filePath!)) {
              isUpdated = true;
              message = message.copyWith(
                  content: audioContent.copyWith(filePath: null));
            }
            break;

          case MessageContentType.file:
            final mediaContent = message.content as DocumentContent;
            if (mediaContent.filePath != null &&
                !doesFileExistSync(mediaContent.filePath!)) {
              isUpdated = true;
              message = message.copyWith(
                  content: mediaContent.copyWith(filePath: null));
            }
            break;

          default:
            break;
        }
      }
      updatedMessages.add(message);
    }
    // Update the chat with the modified messages
    chats[i] = chats[i].copyWith(messages: updatedMessages);
  }

  return chats;
}

// TODO: ADD OTHER CHAT TYPES
MessageContent createMessageContent({
  required MessageContentType contentType,
  required String filePath,
  String? mediaUrl,
  int duration = 0,
  String text = '',
}) {
  switch (contentType) {
    case MessageContentType.text:
      return TextContent(text);
    case MessageContentType.image:
      return ImageContent(
        filePath: filePath,
        imageUrl: mediaUrl,
      );
    case MessageContentType.video:
      return VideoContent(
        filePath: filePath,
        videoUrl: mediaUrl,
      );
    case MessageContentType.audio:
      return AudioContent(
        filePath: filePath,
        audioUrl: mediaUrl,
        duration: duration,
      );
    case MessageContentType.file:
      return DocumentContent(
        filePath: filePath,
        fileName: 'sample.pdf',
      );
    default:
      return TextContent('Hello, how are you?');
  }
}

String getUniqueMessageId() {
  return faker.guid.guid();
}
