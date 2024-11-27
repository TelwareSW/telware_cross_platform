import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg
import 'package:intl/intl.dart';
import 'package:telware_cross_platform/core/mock/messages_mock.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/chat/view/widget/bottom_input_bar_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_header_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/date_label_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/message_tile_widget.dart';

class ChatScreen extends StatefulWidget {
  static const String route = '/chat';
  final ChatModel chatModel;

  const ChatScreen({super.key, required this.chatModel});

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> with WidgetsBindingObserver {
  List<dynamic> chatContent = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatType type;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.chatModel.draft ?? "";
    type = widget.chatModel.type;
    WidgetsBinding.instance.addObserver(this);
    final messages = generateFakeMessages();
    chatContent = _generateChatContentWithDateLabels(messages);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose(); // Dispose of the ScrollController
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    super.dispose();
  }

  List<dynamic> _generateChatContentWithDateLabels(List<MessageModel> messages) {
    List<dynamic> chatContent = [];
    for (int i = 0; i < messages.length; i++) {
      if (i == 0 || !isSameDay(messages[i - 1].timestamp, messages[i].timestamp)) {
        chatContent.add(DateLabelWidget(label: DateFormat('MMMM d').format(messages[i].timestamp)));
      }
      chatContent.add(messages[i]);
    }
    return chatContent;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  // Called when the keyboard visibility changes
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (_scrollController.hasClients && _isAtBottom()) {
      // When the keyboard is shown and the user is at the bottom, scroll to the bottom
      _scrollToBottom();
    }
  }

  // Check if the user is already at the bottom of the scroll view
  bool _isAtBottom() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      return true;
    }
    return false;
  }

  // Scroll the chat view to the bottom
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.chatModel.title;
    final membersNumber = widget.chatModel.userIds.length;
    final String subtitle = widget.chatModel.type == ChatType.oneToOne
        ? "last seen a long time ago"
        : "$membersNumber Member${membersNumber > 1 ? "s" : ""}";
    final imageBytes = widget.chatModel.photoBytes;
    final photo = widget.chatModel.photo;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back when pressed
          },
        ),
        title: ChatHeaderWidget(
          title: title,
          subtitle: subtitle,
          photo: photo,
          imageBytes: imageBytes,
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert))
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Hide the keyboard when tapping outside of text field
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Chat content area (with background SVG)
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/svg/default_pattern.svg',
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  Palette.trinary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController, // Use the ScrollController
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        children: chatContent.map((item) {
                          if (item is DateLabelWidget) {
                            return item;
                          } else if (item is MessageModel) {
                            return MessageTileWidget(
                              messageModel: item,
                              isSentByMe: item.senderName == "John Doe",
                              showInfo: type == ChatType.group,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                // The input bar at the bottom
                BottomInputBarWidget(controller: _controller),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
