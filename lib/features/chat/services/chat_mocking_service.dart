import 'dart:math';

import 'package:faker/faker.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';

import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';

class ChatMockingService {
  // Private constructor
  ChatMockingService._internal();

  // Singleton instance
  static ChatMockingService? _instance;

  // Getter for the singleton instance
  static ChatMockingService get instance {
    return _instance ??= ChatMockingService._internal();
  }

  // Method to create a mocked user
  UserModel createMockedUser() {
    final faker = Faker();

    return UserModel(
      username: faker.internet.userName(),
      screenFirstName: faker.person.firstName(),
      screenLastName: faker.person.lastName(),
      email: faker.internet.email(),
      photo: faker.internet.httpsUrl(),
      status: faker.lorem.sentence(),
      bio: faker.lorem.sentences(3).join(' '),
      maxFileSize: 10485760, // 10 MB
      automaticDownloadEnable: faker.randomGenerator.boolean(),
      lastSeenPrivacy: 'Everyone',
      readReceiptsEnablePrivacy: faker.randomGenerator.boolean(),
      storiesPrivacy: 'Everyone',
      picturePrivacy: 'Everyone',
      invitePermissionsPrivacy: 'Everyone',
      phone: faker.phoneNumber.us(),
      id: '11',
    );
  }

  // Method to create a list of mocked users
  List<UserModel> createMockedUsers(int count) {
    return List.generate(count, (_) => createMockedUser());
  }

  List<MessageModel> createMockedMessages(
      int count, String otherUserId, String appUserId) {
    final faker = Faker();

    return List.generate(count, (index) {
      final senderId =
          faker.randomGenerator.boolean() ? otherUserId : appUserId;
      return MessageModel(
        senderId: senderId,
        content: faker.lorem.sentence(),
        timestamp: DateTime.now().subtract(Duration(minutes: index)),
        messageType: MessageType.normal,
        userStates: {
          otherUserId: _getRandomMessageState(),
          appUserId: _getRandomMessageState(),
        },
      );
    });
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

  ChatModel createMockedChat(List<MessageModel> messages, List<String> users) {
    final faker = Faker();

    return ChatModel(
      id: faker.guid.guid(),
      title: faker.lorem.words(3).join(' '),
      userIds: users,
      type: ChatType.private,
      messages: messages,
      description: faker.lorem.sentence(),
      lastMessageTimestamp:
          messages.isNotEmpty ? messages.first.timestamp : null,
      isArchived: faker.randomGenerator.boolean(),
      isMuted: faker.randomGenerator.boolean(),
      isMentioned: faker.randomGenerator.boolean(),
      draft: faker.randomGenerator.boolean() ? faker.lorem.sentence() : null,
    );
  }

  ({List<ChatModel> chats, List<UserModel> users}) createMockedChats(
    int count,
    String appUserId,
  ) {
    final faker = Faker();

    final users = createMockedUsers(count);
    final chats = List.generate(count, (index) {
      final msgs = createMockedMessages(
        faker.randomGenerator.integer(25, min: 1),
        users[index].id!,
        appUserId,
      );
      return createMockedChat(msgs, [users[index].id!, appUserId]);
    });

    return (chats: chats, users: users);
  }
}
