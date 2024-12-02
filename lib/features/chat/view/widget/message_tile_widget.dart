import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';

import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/view/widget/audio_message_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/video_player_widget.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:video_player/video_player.dart';

import 'package:telware_cross_platform/core/view/widget/highlight_text_widget.dart';

class MessageTileWidget extends StatelessWidget {
  final MessageModel messageModel;
  final bool isSentByMe;
  final bool showInfo;
  final Color nameColor;
  final Color imageColor;
  final List<MapEntry<int, int>> highlights;

  const MessageTileWidget(
      {super.key,
      required this.messageModel,
      required this.isSentByMe,
      this.showInfo = false,
      this.nameColor = Palette.primary,
      this.imageColor = Palette.primary,
      this.highlights = const []});

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
    // final String otherUserName = ;

    return Align(
      alignment: messageAlignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(
            messageModel.messageContentType == MessageContentType.image ||
                    messageModel.messageContentType == MessageContentType.video
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
            messageModel.messageContentType == MessageContentType.text
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SenderNameWidget(
                        keyValue,
                        nameColor,
                        showInfo: showInfo,
                        isSentByMe: isSentByMe,
                        userId: messageModel.senderId,
                      ),
                      Wrap(
                        children: [
                          HighlightTextWidget(
                              key: ValueKey(
                                  '$keyValue${MessageKeys.messageContentPostfix.value}'),
                              text:
                                  messageModel.content?.toJson()['text'] ?? "",
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
                              File(messageModel.content?.toJson()["filePath"]),
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
    );
  }
}

class SenderNameWidget extends ConsumerStatefulWidget {
  final bool showInfo, isSentByMe;
  final String userId;
  final dynamic keyValue;
  final Color nameColor;
  const SenderNameWidget(
    this.keyValue,
    this.nameColor, {
    super.key,
    required this.showInfo,
    required this.isSentByMe,
    required this.userId,
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SenderNameWidgetState();
}

class _SenderNameWidgetState extends ConsumerState<SenderNameWidget> {
  bool showName = false;
  String otherUserName = '';

  @override
  void initState() {
    super.initState();
    _getName();
  }

  Future<void> _getName() async {
    if (widget.showInfo && !widget.isSentByMe) {
      final user = (await ref
          .read(chatsViewModelProvider.notifier)
          .getUser(widget.userId));
      setState(() {
        otherUserName = '${user!.screenFirstName} ${user.screenLastName}';
        showName = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget senderNameWidget = showName
        ? Text(
            key: ValueKey(
                '${widget.keyValue}${MessageKeys.messageSenderPostfix.value}'),
            otherUserName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.nameColor,
              fontSize: 12,
            ),
          )
        : const SizedBox.shrink();
    return senderNameWidget;
  }
}
