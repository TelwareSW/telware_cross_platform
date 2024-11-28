import 'dart:math';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_tile_widget.dart';

class ChatsList extends StatelessWidget {
  const ChatsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('Building chats_list...');
    return SliverList(
      delegate: SliverChildBuilderDelegate(_delegate, childCount: 20),
    );
  }

  Widget _delegate(BuildContext context, int index) {
    final Faker faker = Faker();
    final Random random = Random();

    // Randomly decide if a draft should exist
    final hasDraft = random.nextBool();
    final draft = hasDraft ? faker.lorem.sentence() : null;

    // Random booleans for various chat properties
    final isArchived = random.nextBool();
    final isMuted = random.nextBool();
    final isMentioned = random.nextBool();
    final isGroupChat = random.nextBool();

    // Randomly generate message states for demonstration
    final messageStates = _generateRandomMessageStates();
    final message = MessageModel(
        senderName: faker.person.name(),
        content: faker.lorem.sentence(),
        timestamp: faker.date.dateTimeBetween(
          DateTime.now().subtract(const Duration(days: 800)), // from one year ago
          DateTime.now(), // to current date
        ),
        autoDeleteDuration: const Duration(hours: 1), // Example auto-delete duration
        userStates: messageStates,
    );
    final personName = faker.person.name();

    return ChatTileWidget(
      chatModel: ChatModel(
        id: faker.guid.guid(),
        title: isGroupChat ? faker.company.name() : personName,
        userIds: [faker.guid.guid()],
        type: isGroupChat ? ChatType.group : ChatType.oneToOne,
        description: faker.lorem.sentence(),
        lastMessageTimestamp: DateTime.now(),
        isArchived: isArchived,
        isMuted: isMuted,
        isMentioned: isMentioned,
        draft: draft,
        messages: [message],
      ),
      displayMessage: message,
      sentByUser: message.senderName != personName,
    );
  }

  // Helper method to generate random message states
  Map<String, MessageState> _generateRandomMessageStates() {
    final Faker faker = Faker();
    final Random random = Random();

    // Generate 1 to 3 random message states
    final int numStates = random.nextInt(3) + 1;
    final Map<String, MessageState> messageStates = {};

    for (int i = 0; i < numStates; i++) {
      final String userId = faker.guid.guid();
      final MessageState state = _getRandomMessageState();
      messageStates[userId] = state;
    }

    return messageStates;
  }

  // Helper method to get a random message state
  MessageState _getRandomMessageState() {
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
}
