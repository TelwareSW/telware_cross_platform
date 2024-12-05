import 'dart:math';

import 'package:camera/camera.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/core/utils.dart';

import 'package:faker/faker.dart';

randomizeMessageContentType() {
  final Random random = Random();
  const List<MessageContentType> messageContentTypes = [
    MessageContentType.text,
    MessageContentType.text,
    MessageContentType.text,
    MessageContentType.text,
    MessageContentType.image,
    MessageContentType.audio,
    MessageContentType.video,
  ];
  return messageContentTypes[random.nextInt(messageContentTypes.length)];
}

randomizeMessageContent(MessageContentType contentType) async {
  // Sample messages
  final List<String> sampleMessages = [
    "Hello! How are you?",
    "Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum.",
    "I'm doing great, thanks!",
    "Vestibulum id ligula porta felis euismod semper.",
    "Any plans for the weekend?",
    "Just catching up on some reading. You?",
    "Same here, maybe a short trip if the weather is nice.",
    "Sounds like a great plan!",
    "Can we meet tomorrow?",
    "Sure, let's catch up in the afternoon.",
  ];

  final Random random = Random();
  switch (contentType) {
    case MessageContentType.text:
      return TextContent(sampleMessages[random.nextInt(sampleMessages.length)]);
    case MessageContentType.image:
      XFile imageFile =
          await loadAssetAsXFile("assets/imgs/marwan.jpg", "marwan.jpg");
      return ImageContent(
        imageUrl: "assets/imgs/marwan.jpg",
        filePath: imageFile.path,
      );
    case MessageContentType.audio:
      XFile audioFile =
          await loadAssetAsXFile("assets/audio/test8.mp3", "test8.mp3");
      return AudioContent(
        audioUrl: "assets/audio/test8.mp3",
        duration: const Duration(minutes: 1, seconds: 20).inSeconds,
        filePath: audioFile.path,
      );
    case MessageContentType.video:
      XFile videoFile =
          await loadAssetAsXFile("assets/video/demo.mp4", "demo.mp4");
      return VideoContent(
        videoUrl: "assets/video/demo.mp4",
        duration: const Duration(minutes: 1, seconds: 20).inSeconds,
        filePath: videoFile.path,
      );
    default:
      return TextContent(sampleMessages[random.nextInt(sampleMessages.length)]);
  }
}

Future<List<MessageModel>> generateFakeMessages(
    int count, String secondUserID, String appUserID) async {
  // Random generator
  final Random random = Random();

  // Starting date (7 days ago)
  DateTime currentDate = DateTime.now().subtract(const Duration(days: 7));

  // List to store the generated messages
  List<MessageModel> generatedMessages = [];

  // Generate 30 random messages
  for (int i = 0; i < 30; i++) {
    // Randomly increase the current date by 0 to 2 days
    currentDate = currentDate.add(Duration(days: random.nextInt(3)));
    MessageContentType contentType = randomizeMessageContentType();
    MessageContent content = await randomizeMessageContent(contentType);
    final senderId = faker.randomGenerator.boolean() ? secondUserID : appUserID;
    // Create a new message
    MessageModel message = MessageModel(
      senderId: senderId,
      messageType: MessageType.normal,
      messageContentType: contentType,
      content: content,
      timestamp: currentDate.add(Duration(
        hours: random.nextInt(24),
        minutes: random.nextInt(60),
      )),
      userStates: {
        secondUserID: getRandomMessageState(),
        appUserID: getRandomMessageState(),
      },
      id: faker.guid.guid(),
    );

    // Add the generated message to the list
    generatedMessages.add(message);
  }

  return generatedMessages;
}

MessageState getRandomMessageState() {
  final Random random = Random();
  final int stateIndex = random.nextInt(3); // 0, 1, or 2
  switch (stateIndex) {
    case 0:
      return MessageState.sent;
    case 1:
      return MessageState.read;
    default:
      return MessageState.sent;
  }
}
