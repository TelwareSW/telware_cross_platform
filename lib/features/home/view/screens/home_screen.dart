import 'package:flutter/material.dart';

import '../../../../core/models/chat_model.dart';
import '../../../chat/view/screens/chat_screen.dart';
import 'inbox_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String route = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ChatModel? _selectedChat;

  void _openChat(ChatModel chat) {
    setState(() {
      _selectedChat = chat;
    });
  }

  void _closeChat() {
    setState(() {
      _selectedChat = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Default width for inboxPart
      double inboxPartWidth = 150;

      if (constraints.maxWidth < 600) {
        inboxPartWidth = constraints.maxWidth;
      } else {
        inboxPartWidth = 350;
      }

      // Building the UI
      return constraints.maxWidth < 600
          ? InboxScreen(onChatSelected: _openChat) // Single screen for smaller devices
          : Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: inboxPartWidth,
              minWidth: 200, // Ensuring minWidth does not conflict
            ),
            child: InboxScreen(onChatSelected: _openChat),
          ),
          Expanded(
            child: _selectedChat == null
                ? const Center(
              child: Text(
                'Chat Screen',
                style: TextStyle(fontSize: 18),
              ),
            )
                : ChatScreen(
              chatModel: _selectedChat,
              chatId: _selectedChat!.id!,
            ),
          ),
        ],
      );
    });
  }
}
