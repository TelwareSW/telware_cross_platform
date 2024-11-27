import 'dart:math';
import 'package:telware_cross_platform/core/models/message_model.dart';

// Faker function to generate a list of random MessageModel objects
List<MessageModel> generateFakeMessages() {
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
  DateTime currentDate = DateTime.now().subtract(Duration(days: 7));

  // List to store the generated messages
  List<MessageModel> generatedMessages = [];

  // Generate 30 random messages
  for (int i = 0; i < 30; i++) {
    // Randomly increase the current date by 0 to 2 days
    currentDate = currentDate.add(Duration(days: random.nextInt(3)));

    // Create a new message
    MessageModel message = MessageModel(
      senderName: random.nextBool() ? "John Doe" : "Jane Smith",
      content: sampleMessages[random.nextInt(sampleMessages.length)],
      timestamp: currentDate.add(Duration(
        hours: random.nextInt(24),
        minutes: random.nextInt(60),
      )),
    );

    // Add the generated message to the list
    generatedMessages.add(message);
  }

  return generatedMessages;
}
