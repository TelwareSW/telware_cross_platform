import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/highlight_text_widget.dart';

class MessageTileWidget extends StatelessWidget {
  final MessageModel messageModel;
  final bool isSentByMe;
  final bool showInfo;
  final Color nameColor;
  final Color imageColor;
  final List<MapEntry<int, int>> highlights;

  const MessageTileWidget({
    super.key,
    required this.messageModel,
    required this.isSentByMe,
    this.showInfo = false,
    this.nameColor = Palette.primary,
    this.imageColor = Palette.primary,
    this.highlights = const []
  });

  // Function to format timestamp to "hh:mm AM/PM"
  String formatTimestamp(DateTime timestamp) {
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    Alignment messageAlignment = isSentByMe ? Alignment.centerRight : Alignment.centerLeft;
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
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: isSentByMe
              ? LinearGradient(
            colors: [
              Color.lerp(Colors.deepPurpleAccent, Colors.white, 0.2) ?? Colors.black,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                senderNameWidget,
                Wrap(
                  children: [
                    HighlightTextWidget(
                      text: messageModel.content ?? "",
                      normalStyle: const TextStyle(
                        color: Palette.primaryText,
                        fontSize: 16,
                      ),
                      highlightStyle: const TextStyle(
                        color: Palette.primaryText,
                        fontSize: 16,
                        backgroundColor: Color.fromRGBO(
                            246, 225, 2, 0.43)
                      ),
                      highlights: highlights
                    ),
                    Text(
                      messageModel.content ?? "",
                      style: const TextStyle(color: Palette.primaryText),
                    ),
                    SizedBox(width: isSentByMe ? 70.0 : 55.0),
                    Text("")
                  ],
                )
              ],
            ),
            // The timestamp is always in the bottom-right corner if there's space
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                  padding: const EdgeInsets.only(top: 5), // Add some space above the timestamp
                  child: Row(
                    children: [
                      Text(
                        formatTimestamp(messageModel.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isSentByMe ? Palette.primaryText : Palette.inactiveSwitch,
                        ),
                      ),
                      if (isSentByMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          messageState,
                          size: 12,
                          color: Palette.primaryText
                        ),
                      ]
                    ],
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
