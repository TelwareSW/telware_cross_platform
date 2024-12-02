import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_tile_widget.dart';

String extractTextFromRichText(RichText richText) {
  final textSpan = richText.text as TextSpan;
  return _extractTextSpan(textSpan);
}

String _extractTextSpan(TextSpan textSpan) {
  final buffer = StringBuffer();
  textSpan.visitChildren((span) {
    if (span is TextSpan) {
      buffer.write(span.text);
      // Recursively visit children if they exist
      if (span.children != null) {
        for (var child in span.children!) {
          buffer.write(_extractTextSpan(child as TextSpan));
        }
      }
    }
    return true; // Continue visiting
  });
  return buffer.toString();
}

void main() {
  Faker faker = Faker();
  group('Chat Tile Widget Tests', () {
    testWidgets("renders chat tile", (WidgetTester tester) async {
      MessageModel message = MessageModel(
        id: '1',
        senderId: '1',
        messageContentType: MessageContentType.text,
        content: TextContent('Hello'),
        timestamp: DateTime.now(),
        messageType: MessageType.normal,
        userStates: {},
      );
      const index = '0';
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ChatTileWidget(
                key: ValueKey("${ChatKeys.chatTilePrefix.value}$index"),
                chatModel: ChatModel(
                  id: faker.guid.guid(),
                  title: 'Chat 1',
                  messages: [message],
                  userIds: [faker.guid.guid()],
                  type: ChatType.private,
                ),
                displayMessage: message,
                sentByUser: false,
                senderID: message.senderId,
              ),
            ),
          ),
        ),
      );

      // Allow FutureBuilder to complete
      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey(ChatKeys.chatTilePrefix.value + index)),
          findsOneWidget,
          reason: 'Expected chat tile to render.');
      expect(
          find.byKey(ValueKey(ChatKeys.chatTilePrefix.value +
              index +
              ChatKeys.chatNamePostfix.value)),
          findsOneWidget,
          reason: 'Expected chat title to render.');
      expect(
          find.byKey(ValueKey(ChatKeys.chatTilePrefix.value +
              index +
              ChatKeys.chatTileDisplayTextPostfix.value)),
          findsOneWidget,
          reason: 'Expected chat message to render.');
      expect(
          find.byKey(ValueKey(ChatKeys.chatTilePrefix.value +
              index +
              ChatKeys.chatAvatarPostfix.value)),
          findsOneWidget,
          reason: 'Expected chat avatar to render.');
      expect(
          find.byKey(ValueKey(ChatKeys.chatTilePrefix.value +
              index +
              ChatKeys.chatTileDisplayTimePostfix.value)),
          findsOneWidget,
          reason: 'Expected chat time to render.');
    });

    testWidgets("renders chat tile with different chat types",
        (WidgetTester tester) async {
      MessageModel message = MessageModel(
        id: '1',
        senderId: '1',
        messageContentType: MessageContentType.text,
        content: TextContent('Hello'),
        userStates: {},
        timestamp: DateTime.now(),
        messageType: MessageType.normal,
      );
      final chats = [
        ChatModel(
          id: faker.guid.guid(),
          title: 'Chat 1',
          messages: [message],
          userIds: [faker.guid.guid()],
          type: ChatType.private,
        ),
        ChatModel(
          id: faker.guid.guid(),
          title: 'Chat 2',
          messages: [message],
          userIds: [faker.guid.guid()],
          type: ChatType.group,
        ),
        ChatModel(
          id: faker.guid.guid(),
          title: 'Chat 3',
          messages: [message],
          userIds: [faker.guid.guid()],
          type: ChatType.channel,
        ),
      ];
      var index = 0;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
                body: Column(
              children: chats.map((chat) {
                return ChatTileWidget(
                  key: ValueKey("${ChatKeys.chatTilePrefix.value}${index++}"),
                  chatModel: chat,
                  displayMessage: message,
                  sentByUser: false,
                  senderID: message.senderId,
                );
              }).toList(),
            )),
          ),
        ),
      );

      final String content = message.content?.toJson()['text'];

      for (int i = 0; i < 3; i++) {
        expect(find.byKey(ValueKey('${ChatKeys.chatTilePrefix.value}$i')),
            findsOneWidget,
            reason: 'Expected chat tile to render.');
        expect(
            find.byKey(ValueKey(
                '${ChatKeys.chatTilePrefix.value}$i${ChatKeys.chatTileDisplayTextPostfix.value}')),
            findsOneWidget,
            reason: 'Expected chat message to render.');
      }
      Finder displayedTextFind = find.byKey(ValueKey(
          '${ChatKeys.chatTilePrefix.value}1${ChatKeys.chatTileDisplayTextPostfix.value}'));
      RichText displayedTextWidget = tester.firstWidget(displayedTextFind);
      expect(extractTextFromRichText(displayedTextWidget),
          '${'John Doe'.split(" ")[0]}: $content',
          reason:
              'Expected chat message to render with sender ID in group chat ${chats[1].type}.');
      displayedTextFind = find.byKey(ValueKey(
          '${ChatKeys.chatTilePrefix.value}0${ChatKeys.chatTileDisplayTextPostfix.value}'));
      displayedTextWidget = tester.firstWidget(displayedTextFind);
      expect(extractTextFromRichText(displayedTextWidget), content,
          reason: 'Expected chat message to render normally in private chat.');
      displayedTextFind = find.byKey(ValueKey(
          '${ChatKeys.chatTilePrefix.value}2${ChatKeys.chatTileDisplayTextPostfix.value}'));
      displayedTextWidget = tester.firstWidget(displayedTextFind);
      expect(extractTextFromRichText(displayedTextWidget), content,
          reason: 'Expected chat message to render normally in channel chat.');
    });

    testWidgets("renders chat draft", (WidgetTester tester) async {
      MessageModel message = MessageModel(
        id: '1',
        senderId: '1',
        messageContentType: MessageContentType.text,
        content: TextContent('Hello'),
        timestamp: DateTime.now(),
        messageType: MessageType.normal,
        userStates: {},
      );
      ChatModel chat = ChatModel(
        id: faker.guid.guid(),
        title: 'Chat 1',
        messages: [message],
        userIds: [faker.guid.guid()],
        type: ChatType.private,
        draft: 'This is a draft message',
      );
      const index = '0';
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ChatTileWidget(
                key: ValueKey("${ChatKeys.chatTilePrefix.value}$index"),
                chatModel: chat,
                displayMessage: message,
                sentByUser: false,
                senderID: message.senderId,
              ),
            ),
          ),
        ),
      );
      expect(
          find.byKey(ValueKey(ChatKeys.chatTilePrefix.value +
              index +
              ChatKeys.chatTileDisplayTextPostfix.value)),
          findsOneWidget,
          reason: 'Expected chat display text to render.');
      Finder displayedTextFind = find.byKey(ValueKey(
          '${ChatKeys.chatTilePrefix.value}$index${ChatKeys.chatTileDisplayTextPostfix.value}'));
      RichText displayedTextWidget = tester.firstWidget(displayedTextFind);
      expect(
          extractTextFromRichText(displayedTextWidget), 'Draft: ${chat.draft}',
          reason: 'Expected chat message to render with draft message.');
    });

    testWidgets("renders message status only if it was sent by the user",
        (WidgetTester tester) async {
      MessageModel message = MessageModel(
        id: '1',
        senderId: '1',
        messageContentType: MessageContentType.text,
        content: TextContent('Hello'),
        timestamp: DateTime.now(),
        messageType: MessageType.normal,
        userStates: {},
      );
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ChatTileWidget(
                    key: ValueKey("${ChatKeys.chatTilePrefix.value}0"),
                    chatModel: ChatModel(
                      id: faker.guid.guid(),
                      title: 'Chat 1',
                      messages: [message],
                      userIds: [faker.guid.guid()],
                      type: ChatType.private,
                    ),
                    displayMessage: message,
                    sentByUser: true,
                    senderID: message.senderId,
                  ),
                  ChatTileWidget(
                    key: ValueKey("${ChatKeys.chatTilePrefix.value}1"),
                    chatModel: ChatModel(
                      id: faker.guid.guid(),
                      title: 'Chat 1',
                      messages: [message],
                      userIds: [faker.guid.guid()],
                      type: ChatType.private,
                    ),
                    displayMessage: message,
                    sentByUser: false,
                    senderID: message.senderId,
                  )
                ],
              ),
            ),
          ),
        ),
      );
      expect(
          find.byKey(ValueKey(
              '${ChatKeys.chatTilePrefix.value}0${ChatKeys.chatTileMessageStatusPostfix.value}')),
          findsOneWidget,
          reason: 'Expected message status to render if sent by user.');
      expect(
          find.byKey(ValueKey(
              '${ChatKeys.chatTilePrefix.value}1${ChatKeys.chatTileMessageStatusPostfix.value}')),
          findsNothing,
          reason: 'Expected message status not to render if not sent by user.');
    });
  });
}
