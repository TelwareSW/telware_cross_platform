import 'dart:math';
import 'package:camera/camera.dart';
import 'package:telware_cross_platform/core/models/message_content.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/utils.dart';

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
      type: MessageType.text,
      senderName: random.nextBool() ? "John Doe" : "Jane Smith",
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
    type: MessageType.audio,
    senderName: "John Doe",
    content: AudioContent(
      audioUrl: "dummy_audio_url",
      duration: const Duration(minutes: 1, seconds: 20),
      filePath: "assets/audio/test8.mp3",
    ),
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    userStates: {},
  );
  XFile imageFile =
      await loadAssetAsXFile("assets/imgs/marwan.jpg", "marwan.jpg");
  XFile videoFile = await loadAssetAsXFile("assets/video/demo.mp4", "demo.mp4");

  MessageModel imageMessage = MessageModel(
    type: MessageType.image,
    senderName: "John Doe",
    content: ImageContent(
      imageUrl: "assets/imgs/marwan.jpg",
      file: imageFile,
    ),
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    userStates: {},
  );

  MessageModel videoMessage = MessageModel(
    type: MessageType.video,
    senderName: "John Doe",
    content: VideoContent(
      videoUrl: "assets/video/demo.mp4",
      duration: const Duration(minutes: 1, seconds: 20),
      file: videoFile,
    ),
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    userStates: {},
  );

  generatedMessages.add(audioMessage);
  generatedMessages.add(imageMessage);
  generatedMessages.add(videoMessage);

  return generatedMessages;
}
