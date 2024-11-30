import 'dart:math';

import 'package:camera/camera.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/core/utils.dart';

import 'package:faker/faker.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';

// Faker function to generate a list of random MessageModel objects
Future<List<MessageModel>> generateFakeMessages() async {
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

    // Create a new message
    MessageModel message = MessageModel(
      senderId: random.nextBool() ? '11' : faker.guid.guid(),
      messageType: MessageType.normal,
      messageContentType: MessageContentType.text,
      content:
          TextContent(sampleMessages[random.nextInt(sampleMessages.length)]),
      timestamp: currentDate.add(Duration(
        hours: random.nextInt(24),
        minutes: random.nextInt(60),
      )),
      userStates: {},
    );

    // Add the generated message to the list
    generatedMessages.add(message);
  }
  MessageModel audioMessage = MessageModel(
    messageType: MessageType.normal,
    messageContentType: MessageContentType.audio,
    senderId: "11",
    content: AudioContent(
      audioUrl: "dummy_audio_url",
      duration: const Duration(minutes: 1, seconds: 20).inSeconds,
      filePath: "assets/audio/test8.mp3",
    ),
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    userStates: {},
  );
  XFile imageFile =
      await loadAssetAsXFile("assets/imgs/marwan.jpg", "marwan.jpg");
  XFile videoFile = await loadAssetAsXFile("assets/video/demo.mp4", "demo.mp4");

  MessageModel imageMessage = MessageModel(
    messageType: MessageType.normal,
    messageContentType: MessageContentType.image,
    senderId: "11",
    content: ImageContent(
      imageUrl: "assets/imgs/marwan.jpg",
      filePath: imageFile.path,
    ),
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    userStates: {},
  );

  MessageModel videoMessage = MessageModel(
    messageType: MessageType.normal,
    messageContentType: MessageContentType.video,
    senderId: "11",
    content: VideoContent(
      videoUrl: "assets/video/demo.mp4",
      duration: const Duration(minutes: 1, seconds: 20).inSeconds,
      filePath: videoFile.path,
    ),
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    userStates: {},
  );

  generatedMessages.add(audioMessage);
  generatedMessages.add(imageMessage);
  generatedMessages.add(videoMessage);

  return generatedMessages;
}
