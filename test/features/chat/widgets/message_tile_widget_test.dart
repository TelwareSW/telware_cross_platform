import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/view/widget/message_tile_widget.dart';

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
  group('Message Tile Widget Tests', () {
    testWidgets("renders message tile", (WidgetTester tester) async {
      MessageModel message = MessageModel(
        id: '1',
        senderId: '1',
        messageContentType: MessageContentType.text,
        content: TextContent('Hello'),
        userStates: {},
        timestamp: DateTime.now(),
        messageType: MessageType.normal,
      );
      const index = '0';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTileWidget(
              key: ValueKey("${ChatKeys.chatTilePrefix.value}$index"),
              messageModel: message,
              isSentByMe: false,
            ),
          ),
        ),
      );

      expect(find.byKey(ValueKey("${ChatKeys.chatTilePrefix.value}$index")), findsOneWidget,
          reason: "Expected message tile to render");

      expect(find.byKey(ValueKey("${ChatKeys.chatTilePrefix.value}$index${MessageKeys.messageContentPostfix.value}")), findsOneWidget,
          reason: "Expected message content to render");

      expect(find.byKey(ValueKey("${ChatKeys.chatTilePrefix.value}$index${MessageKeys.messageTimePostfix.value}")), findsOneWidget,
          reason: "Expected message timestamp to render");
    });

    testWidgets("renders message tile with rich text", (WidgetTester tester) async {
      MessageModel message = MessageModel(
        id: '1',
        senderId: '1',
        messageContentType: MessageContentType.text,
        content: TextContent('Hello'),
        userStates: {},
        timestamp: DateTime.now(),
        messageType: MessageType.normal,
      );
      const index = '0';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageTileWidget(
              key: ValueKey("${ChatKeys.chatTilePrefix.value}$index"),
              messageModel: message,
              isSentByMe: false,
            ),
          ),
        ),
      );

      final Finder highlightTextFinder = find.byKey(ValueKey("${ChatKeys.chatTilePrefix.value}$index${MessageKeys.messageContentPostfix.value}"));
      final Finder richTextFinder = find.descendant(
        of: highlightTextFinder,
        matching: find.byType(RichText),
      );
      expect(richTextFinder, findsOneWidget);
      final RichText richText = tester.firstWidget(richTextFinder) as RichText;
      expect(extractTextFromRichText(richText), message.content?.toJson()['text'],
          reason: "Expected message content to render as rich text");
    });

    testWidgets("renders message tile with message status if sent by user", (WidgetTester tester) async {
      MessageModel message = MessageModel(
        id: '1',
        senderId: '1',
        messageContentType: MessageContentType.text,
        content: TextContent('Hello'),
        userStates: {},
        timestamp: DateTime.now(),
        messageType: MessageType.normal,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MessageTileWidget(
                  key: ValueKey("${ChatKeys.chatTilePrefix.value}0"),
                  messageModel: message,
                  isSentByMe: true,
                ),
                MessageTileWidget(
                  key: ValueKey("${ChatKeys.chatTilePrefix.value}1"),
                  messageModel: message,
                  isSentByMe: false,
                ),
              ],
            )
          ),
        ),
      );

      expect(find.byKey(ValueKey("${ChatKeys.chatTilePrefix.value}0${MessageKeys.messageStatusPostfix.value}")), findsOneWidget,
          reason: "Expected message status to render");
      expect(find.byKey(ValueKey("${ChatKeys.chatTilePrefix.value}1${MessageKeys.messageStatusPostfix.value}")), findsNothing,
          reason: "Expected message status to not render");
    });

    testWidgets("renders message sender if enabled", (WidgetTester tester) async {
      MessageModel message = MessageModel(
        id: '1',
        senderId: '1',
        messageContentType: MessageContentType.text,
        content: TextContent('Hello'),
        userStates: {},
        timestamp: DateTime.now(),
        messageType: MessageType.normal,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MessageTileWidget(
                  key: ValueKey("${ChatKeys.chatTilePrefix.value}0"),
                  messageModel: message,
                  isSentByMe: false,
                  showInfo: true,
                ),
                MessageTileWidget(
                  key: ValueKey("${ChatKeys.chatTilePrefix.value}1"),
                  messageModel: message,
                  isSentByMe: false,
                  showInfo: false,
                ),
                MessageTileWidget(
                  key: ValueKey("${ChatKeys.chatTilePrefix.value}2"),
                  messageModel: message,
                  isSentByMe: true,
                  showInfo: true,
                ),
              ],
            )
          ),
        ),
      );

      expect(find.byKey(ValueKey("${ChatKeys.chatTilePrefix.value}0${MessageKeys.messageSenderPostfix.value}")), findsOneWidget,
          reason: "Expected message sender to render");
      expect(find.byKey(ValueKey("${ChatKeys.chatTilePrefix.value}1${MessageKeys.messageSenderPostfix.value}")), findsNothing,
          reason: "Expected message sender to not render");
      expect(find.byKey(ValueKey("${ChatKeys.chatTilePrefix.value}2${MessageKeys.messageSenderPostfix.value}")), findsNothing,
          reason: "Expected message sender to not render");
    });
  });
}
