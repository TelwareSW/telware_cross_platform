import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:telware_cross_platform/features/user/view/widget/avatar_generator.dart';

class ChatTileWidget extends ConsumerStatefulWidget {
  const ChatTileWidget({
    super.key,
    required this.chatModel,
    required this.displayMessage,
    required this.sentByUser,
    required this.senderID,
    this.showDivider = true,
    required this.onChatSelected,
  });

  final ChatModel chatModel;
  final MessageModel displayMessage;
  final String senderID;
  final bool showDivider;
  final bool sentByUser;
  final Function(ChatModel) onChatSelected;


  @override
  ConsumerState<ChatTileWidget> createState() => _ChatTileWidget();
}

class _ChatTileWidget extends ConsumerState<ChatTileWidget> {
  // create getter
  late ChatModel chatModel;
  late MessageModel displayMessage;
  late String senderID;
  late bool sentByUser;
  late bool showDivider;

  @override
  void initState() {
    super.initState();
    chatModel = widget.chatModel;
    displayMessage = widget.displayMessage;
    senderID = widget.senderID;
    sentByUser = widget.sentByUser;
    showDivider = widget.showDivider;
  }

  String _getDisplayText(MessageContentType displayMessageContentType) {
    if (chatModel.draft?.isNotEmpty ?? false) {
      return chatModel.draft!;
    }

    switch (displayMessageContentType) {
      case MessageContentType.text:
        return displayMessage.content?.toJson()['text'];
      case MessageContentType.image:
        return "Photo";
      case MessageContentType.video:
        return "Video";
      case MessageContentType.audio:
        return "Voice message";
      case MessageContentType.file:
        return "File";
      case MessageContentType.sticker:
        return "Sticker";
      case MessageContentType.emoji:
        return "Emoji";
      case MessageContentType.gif:
        return "GIF";
      case MessageContentType.link:
        return "Link";
      default:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future:
          ref.watch(chatsViewModelProvider.notifier).getUser(widget.senderID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Or any placeholder widget
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final UserModel sender = snapshot.data!;
          final senderName = sender.screenFirstName.isEmpty
              ? sender.username
              : sender.screenFirstName;
          final keyValue = (widget.key as ValueKey).value;
          final imageBytes = chatModel.photoBytes;
          final hasDraft = chatModel.draft?.isNotEmpty ?? false;
          final isGroupChat = chatModel.type == ChatType.group;
          final unreadCount = _getUnreadMessageCount();
          final isMuted = chatModel.isMuted;
          final isMentioned = chatModel.isMentioned;
          final displayMessageContentType = displayMessage.messageContentType;

          return InkWell(
            onTap: () {
              // Get the width of the screen
              double width = MediaQuery.of(context).size.width;

              // Check if the width is greater than 600
              if (width > 600) {
                // Handle wider screens (e.g., tablets or large phones in landscape mode)
                widget.onChatSelected(chatModel);
              } else {
                // Handle smaller screens (e.g., phones in portrait or smaller landscape)
                context.push(Routes.chatScreen, extra: chatModel.id ?? chatModel);
              }
            },
            child: Container(
                color: Palette.secondary,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 12.0, left: 12.0, top: 8.0, bottom: 8.0),
                      child: CircleAvatar(
                        key: ValueKey(
                            "$keyValue${ChatKeys.chatAvatarPostfix.value}"),
                        radius: 28,
                        backgroundImage:
                            imageBytes != null ? MemoryImage(imageBytes) : null,
                        backgroundColor:
                            imageBytes == null ? Palette.primary : null,
                        child: imageBytes == null
                            ? AvatarGenerator(
                                name: chatModel.title,
                                backgroundColor: getRandomColor(),
                                size: 100,
                              )
                            : null,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 14.0, top: 3.0, bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        key: ValueKey(
                                            "$keyValue${ChatKeys.chatNamePostfix.value}"),
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
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 2.0),
                                        child: Icon(
                                          key: ValueKey(
                                              "$keyValue${ChatKeys.chatTileMutePostfix.value}"),
                                          Icons.volume_off,
                                          size: 18,
                                          color: Palette.inactiveSwitch,
                                        ),
                                      ),
                                    if (sentByUser)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 2.0),
                                        child: Icon(
                                          key: ValueKey(
                                              "$keyValue${ChatKeys.chatTileMessageStatusPostfix.value}"),
                                          getMessageStateIcon(displayMessage),
                                          size: 16,
                                          color: Palette.accent,
                                        ),
                                      ),
                                    Text(
                                      key: ValueKey(
                                          "$keyValue${ChatKeys.chatTileDisplayTimePostfix.value}"),
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
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    // Displayed message content
                                    Expanded(
                                      child: RichText(
                                        key: ValueKey(
                                            "$keyValue${ChatKeys.chatTileDisplayTextPostfix.value}"),
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: hasDraft
                                                  ? "Draft: "
                                                  : !isGroupChat
                                                      ? ""
                                                      : sentByUser
                                                          ? "You: "
                                                          : "$senderName: ",
                                              style: TextStyle(
                                                color: hasDraft
                                                    ? Palette.error
                                                    : isGroupChat
                                                        ? Palette.primaryText
                                                        : Palette.accentText,
                                                fontWeight: hasDraft
                                                    ? FontWeight.bold
                                                    : null,
                                              ),
                                            ),
                                            TextSpan(
                                              text: _getDisplayText(
                                                  displayMessageContentType),
                                              style: TextStyle(
                                                color: hasDraft ||
                                                        displayMessageContentType ==
                                                            MessageContentType
                                                                .text
                                                    ? Palette.accentText
                                                    : Palette.accent,
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
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Icon(
                                            key: ValueKey(
                                                "$keyValue${ChatKeys.chatTileMentionPostfix.value}"),
                                            Icons.alternate_email_rounded,
                                            size: 18,
                                            color: Palette.primary,
                                          ),
                                        ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 4.0),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0, vertical: 2.0),
                                          decoration: BoxDecoration(
                                            color: Palette.accent,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Text(
                                            key: ValueKey(
                                                "$keyValue${ChatKeys.chatTileDisplayUnreadCountPostfix.value}"),
                                            unreadCount.toString(),
                                            style: const TextStyle(
                                              color: Palette.primaryText,
                                              fontSize: 10,
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
                )),
          );
        } else {
          return const Text('No user data available'); // Handle no data state
        }
      },
    );
  }

  int _getUnreadMessageCount() {
    final random = Random();
    return random.nextInt(3); // Generate random number between 0 and 10
  }
}
