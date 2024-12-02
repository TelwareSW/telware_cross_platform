import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';

import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/view/widget/audio_message_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/video_player_widget.dart';
import 'package:video_player/video_player.dart';

import 'package:telware_cross_platform/core/view/widget/highlight_text_widget.dart';

import '../screens/create_chat_screen.dart';
import 'floating_menu_overlay.dart';

class MessageTileWidget extends StatelessWidget {
  final MessageModel messageModel;
  final bool isSentByMe;
  final bool showInfo;
  final Color nameColor;
  final Color imageColor;
  final List<MapEntry<int, int>> highlights;
  final Function(MessageModel) onReply;
  final Function(MessageModel) onLongPress;
  final Function(MessageModel) onPin;
  final Function()? onPress;

  const MessageTileWidget({
    super.key,
    required this.messageModel,
    required this.isSentByMe,
    this.showInfo = false,
    this.nameColor = Palette.primary,
    this.imageColor = Palette.primary,
    this.highlights = const [],
    required this.onReply,
    required this.onLongPress,
    required this.onPress,
    required this.onPin,
  });

  // Function to format timestamp to "hh:mm AM/PM"
  String formatTimestamp(DateTime timestamp) {
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final keyValue = (key as ValueKey).value;
    Alignment messageAlignment =
        isSentByMe ? Alignment.centerRight : Alignment.centerLeft;
    IconData messageState = getMessageStateIcon(messageModel);
    Widget senderNameWidget = showInfo && !isSentByMe
        ? Text(
            key: ValueKey('$keyValue${MessageKeys.messageSenderPostfix.value}'),
            messageModel.senderId,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: nameColor,
              fontSize: 12,
            ),
          )
        : const SizedBox.shrink();
    return Align(
      alignment: messageAlignment,
      child: GestureDetector(
        onLongPress: () {
          onLongPress(messageModel);
        },
        onTap: onPress == null
            ? () {
                late OverlayEntry overlayEntry;
                overlayEntry = OverlayEntry(
                  builder: (context) => FloatingMenuOverlay(
                    onDismiss: () {
                      overlayEntry.remove();
                    },
                    onReply: () {
                      overlayEntry.remove();
                      onReply(messageModel);
                    },
                    onCopy: () {
                      overlayEntry.remove();
                    },
                    onForward: () {
                      overlayEntry.remove();
                      context.push(CreateChatScreen.route);
                    },
                    onPin: () {
                      overlayEntry.remove();
                      onPin(messageModel);
                    },
                    onEdit: () {
                      overlayEntry.remove();
                    },
                    onDelete: () {
                      overlayEntry.remove();
                    }, pinned: messageModel.isPinned,
                  ),
                );
                Overlay.of(context).insert(overlayEntry);
              }
            : () {
                onLongPress(messageModel);
              },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.all(messageModel.messageContentType ==
                      MessageContentType.image ||
                  messageModel.messageContentType == MessageContentType.video
              ? 3
              : 12),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            gradient: isSentByMe
                ? LinearGradient(
                    colors: [
                      Color.lerp(Colors.deepPurpleAccent, Colors.white, 0.2) ??
                          Colors.black,
                      Colors.deepPurpleAccent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: isSentByMe ? null : Palette.secondary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              messageModel.messageContentType == MessageContentType.text
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        senderNameWidget,
                        Wrap(
                          children: [
                            HighlightTextWidget(
                                key: ValueKey(
                                    '$keyValue${MessageKeys.messageContentPostfix.value}'),
                                text: messageModel.content?.toJson()['text'] ??
                                    "",
                                normalStyle: const TextStyle(
                                  color: Palette.primaryText,
                                  fontSize: 16,
                                ),
                                highlightStyle: const TextStyle(
                                    color: Palette.primaryText,
                                    fontSize: 16,
                                    backgroundColor:
                                        Color.fromRGBO(246, 225, 2, 0.43)),
                                highlights: highlights),
                            SizedBox(width: isSentByMe ? 70.0 : 55.0),
                            const Text("")
                          ],
                        )
                      ],
                    )
                  : messageModel.messageContentType == MessageContentType.audio
                      ? AudioMessageWidget(
                          duration: messageModel.content?.toJson()["duration"],
                          filePath: messageModel.content?.toJson()["filePath"])
                      : messageModel.messageContentType ==
                              MessageContentType.image
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                File(
                                    messageModel.content?.toJson()["filePath"]),
                                fit: BoxFit.cover,
                              ),
                            )
                          : messageModel.messageContentType ==
                                  MessageContentType.video
                              ? SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: VideoPlayerWidget(
                                      filePath: messageModel.content
                                          ?.toJson()["filePath"]))
                              : const SizedBox.shrink(),

              // The timestamp is always in the bottom-right corner if there's space
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    // Add some space above the timestamp
                    child: Row(
                      children: [
                        messageModel.isPinned ? const Icon(Icons.push_pin):const SizedBox(),
                        Text(
                          key: ValueKey(
                              '$keyValue${MessageKeys.messageTimePostfix.value}'),
                          formatTimestamp(messageModel.timestamp),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Palette.primaryText,
                          ),
                        ),
                        if (isSentByMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                              key: ValueKey(
                                  '$keyValue${MessageKeys.messageStatusPostfix.value}'),
                              messageState,
                              size: 12,
                              color: Palette.primaryText),
                        ]
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
