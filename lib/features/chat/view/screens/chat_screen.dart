import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_header_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';

class ChatScreen extends StatefulWidget {
  static const String route = '/chat';
  final ChatModel chatModel;

  const ChatScreen({super.key, required this.chatModel});

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    // Access chat model data
    final String title = widget.chatModel.title;
    final membersNumber = widget.chatModel.userIds.length;
    final String subtitle = widget.chatModel.type == ChatType.oneToOne ? "last seen a long time ago"
    : "$membersNumber Member${membersNumber > 1 ? "s" : ""}";
    final imageBytes = widget.chatModel.photoBytes;
    final photo = widget.chatModel.photo;
    final List<MessageModel> messages = widget.chatModel.messages ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop(); // Navigate back when pressed
          },
        ),
        title:
          ChatHeaderWidget(
            title: title,
            subtitle: subtitle,
            photo: photo,
            imageBytes: imageBytes,
          ),
        actions: [
          IconButton(
              onPressed:() {},
              icon: const Icon(Icons.more_vert))
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  message.content ?? "placeholder",
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
