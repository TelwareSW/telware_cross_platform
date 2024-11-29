import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/chat/view/widget/audio_message_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/video_player_widget.dart';
import 'package:video_player/video_player.dart';

class MessageTileWidget extends StatelessWidget {
  final MessageModel messageModel;
  final bool isSentByMe;
  final bool showInfo;
  final Color nameColor;
  final Color imageColor;

  const MessageTileWidget({
    super.key,
    required this.messageModel,
    required this.isSentByMe,
    this.showInfo = false,
    this.nameColor = Palette.primary,
    this.imageColor = Palette.primary,
  });

  // Function to format timestamp to "hh:mm AM/PM"
  String formatTimestamp(DateTime timestamp) {
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    Alignment messageAlignment =
        isSentByMe ? Alignment.centerRight : Alignment.centerLeft;
    IconData messageState = getMessageStateIcon(messageModel);
    Widget senderNameWidget = showInfo && !isSentByMe
        ? Text(
            messageModel.senderName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: nameColor,
              fontSize: 12,
            ),
          )
        : const SizedBox.shrink();

    return Align(
      alignment: messageAlignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(messageModel.type == MessageType.image ||
                messageModel.type == MessageType.video
            ? 3
            : 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
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
            messageModel.type == MessageType.text
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      senderNameWidget,
                      Wrap(
                        children: [
                          Text(
                            messageModel.content?.toJson()["text"] ?? "",
                            style: const TextStyle(color: Palette.primaryText),
                          ),
                          SizedBox(width: isSentByMe ? 70.0 : 55.0),
                          const Text("")
                        ],
                      )
                    ],
                  )
                : messageModel.type == MessageType.audio
                    ? AudioMessageWidget(
                        duration: messageModel.content?.toJson()["duration"],
                        filePath: messageModel.content?.toJson()["filePath"])
                    : messageModel.type == MessageType.image
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              File(messageModel.content?.toJson()["file"].path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : messageModel.type == MessageType.video
                            ? SizedBox(
                                width: 200,
                                height: 200,
                                child: VideoPlayerWidget(
                                    file:
                                        messageModel.content?.toJson()["file"]))
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
                      Text(
                        formatTimestamp(messageModel.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isSentByMe
                              ? Palette.primaryText
                              : Palette.inactiveSwitch,
                        ),
                      ),
                      if (isSentByMe) ...[
                        const SizedBox(width: 4),
                        Icon(messageState,
                            size: 12, color: Palette.primaryText),
                      ]
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
