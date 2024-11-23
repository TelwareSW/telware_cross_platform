import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/chat/view/screens/chat_screen.dart';

class ChatTileWidget extends StatelessWidget {
  const ChatTileWidget({
    super.key,
    required this.chatModel,
    required this.displayMessage,
    this.showDivider = true,
  });

  final ChatModel chatModel;
  final MessageModel displayMessage;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final imageBytes = chatModel.photoBytes;
    final hasDraft = chatModel.draft?.isNotEmpty ?? false;
    final isGroupChat = chatModel.type == ChatType.group;
    final messageStateIcon = _getMessageStateIcon(displayMessage);
    final unreadCount = _getUnreadMessageCount();
    final isMuted = chatModel.isMuted;
    final isMentioned = chatModel.isMentioned;

    return InkWell(
      onTap: () { context.push(ChatScreen.route, extra: chatModel); },
      child: Container(
        color: Palette.secondary,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0, left: 16.0, top: 8.0, bottom: 8.0),
              child: CircleAvatar(
                radius: 24,
                backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                backgroundColor: imageBytes == null ? Palette.primary : null,
                child: imageBytes == null
                    ? Text(
                  getInitials(chatModel.title),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Palette.primaryText,
                  ),
                )
                    : null,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding (
                    padding: const EdgeInsets.only(right: 14.0, top: 3.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                            if (isMuted)
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.volume_off,
                                  size: 18,
                                  color: Palette.inactiveSwitch,
                                ),
                              ),
                            if (messageStateIcon != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: messageStateIcon,
                              ),
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
                        Row(
                          children: [
                            // Displayed message content
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle:  FontStyle.italic,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: hasDraft ? "Draft: "
                                          : isGroupChat ? "${displayMessage.senderName.split(" ")[0]}: " : "",
                                      style: TextStyle(
                                        color: hasDraft ? Palette.error
                                            : isGroupChat ? Palette.primaryText : Palette.accentText,
                                        fontWeight: hasDraft ? FontWeight.bold : null,
                                      ),
                                    ),
                                    TextSpan(
                                      text: hasDraft
                                          ? chatModel.draft!
                                          : displayMessage.content ?? "",
                                      style: const TextStyle(
                                        color: Palette.accentText,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Add spacing between message content and unread count

                            if (unreadCount > 0) ...[
                              if (isMentioned)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.alternate_email_rounded,
                                    size: 18,
                                    color: Palette.primary,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
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
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showDivider) const Divider(),
                ],
              ),
            ),
          ],
        )

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