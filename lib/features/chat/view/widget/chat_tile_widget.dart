import 'dart:math';
import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';

class ChatTileWidget extends StatelessWidget {
  const ChatTileWidget({
    super.key,
    required this.chatModel,
    required this.displayMessage,
  });

  final ChatModel chatModel;
  final MessageModel displayMessage;

  @override
  Widget build(BuildContext context) {
    final imageBytes = chatModel.photoBytes;
    final hasDraft = chatModel.draft?.isNotEmpty ?? false;
    final isGroupChat = chatModel.type == ChatType.group;
    final messageStateIcon = _getMessageStateIcon(displayMessage);
    final unreadCount = _getUnreadMessageCount();
    final isMuted = chatModel.isMuted; // Check if the chat is muted

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          // Avatar Section
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 24,
              backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
              backgroundColor: imageBytes == null ? Palette.primary : null,
              child: imageBytes == null
                  ? Text(
                getInitials(chatModel.title),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Palette.primaryText,
                ),
              )
                  : null,
            ),
          ),

          // Chat Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row for Title and Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Chat Title with Ellipsis (Handling large text)
                    Expanded(
                      child: Text(
                        chatModel.title,
                        style: const TextStyle(
                          color: Palette.primaryText,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Mute Icon Space (Reserve Space Even When Not Available)
                    if (isMuted)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.volume_off,
                          size: 18,
                          color: Palette.inactiveSwitch,
                        ),
                      ),

                    // Message State Icon (Sent/Read Status)
                    if (messageStateIcon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: messageStateIcon,
                      ),

                    // Timestamp
                    Text(
                      formatTimestamp(displayMessage.timestamp),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                // Row for Displayed Message and Unread Count
                Row(
                  children: [
                    // Displayed message content
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: hasDraft ? Colors.red : Colors.grey,
                            fontSize: 14,
                            fontStyle: hasDraft ? FontStyle.italic : FontStyle.normal,
                          ),
                          children: [
                            TextSpan(
                              text: hasDraft ? "Draft: " : "",
                              style: TextStyle(
                                color: hasDraft ? Palette.error : Palette.accentText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: hasDraft
                                  ? chatModel.draft!
                                  : isGroupChat
                                  ? "${displayMessage.senderName}: ${displayMessage.content ?? ""}"
                                  : "${displayMessage.content ?? ""}",
                              style: TextStyle(
                                color: Palette.accentText,
                                fontStyle: hasDraft ? FontStyle.normal : FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Add spacing between message content and unread count
                    if (unreadCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Palette.accent,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Palette.primaryText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _getMessageStateIcon(MessageModel message) {
    if (message.isReadByAll()) {
      return const Icon(Icons.done_all, size: 16, color: Colors.blue);
    }

    if (message.isDeliveredToAll()) {
      return const Icon(Icons.check, size: 16, color: Colors.blue);
    }

    return const Icon(Icons.check, size: 16, color: Colors.grey);
  }

  int _getUnreadMessageCount() {
    final random = Random();
    return random.nextInt(3); // Generate random number between 0 and 10
  }
}
