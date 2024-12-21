import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/highlight_text_widget.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/view/widget/audio_message_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/delete_popup_menu.dart';
import 'package:telware_cross_platform/features/chat/view/widget/document_message_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/image_message_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/parent_message.dart';
import 'package:telware_cross_platform/features/chat/view/widget/sender_name_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/sticker_message_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/video_player_widget.dart';

import '../../../../core/models/chat_model.dart';
import '../screens/create_chat_screen.dart';
import 'announcement_message_extention.dart';
import 'floating_menu_overlay.dart';

class MessageTileWidget extends ConsumerWidget {
  final MessageModel messageModel;
  final String chatId;
  final bool isSentByMe;
  final bool showInfo;
  final Color nameColor;
  final Color imageColor;
  final List<MapEntry<int, int>> highlights;
  final void Function(String?) onDownloadTap;
  final Function(MessageModel) onReply;
  final Function(MessageModel) onEdit;
  final Function(MessageModel) onLongPress;
  final Function(MessageModel) onPin;
  final Function()? onPress;
  final MessageModel? parentMessage;
  final List<MessageModel>? thread;
  final ChatModel? chat;
  final bool showExtention;

  const MessageTileWidget(
      {super.key,
      required this.messageModel,
      required this.chatId,
      required this.isSentByMe,
      this.showInfo = false,
      this.nameColor = Palette.primary,
      this.imageColor = Palette.primary,
      this.highlights = const [],
      required this.onDownloadTap,
      required this.onReply,
      required this.onEdit,
      required this.onLongPress,
      required this.onPress,
      required this.onPin,
      this.parentMessage,
      this.thread,
      this.chat,
      this.showExtention=true});

  // Function to format timestamp to "hh:mm AM/PM"
  String formatTimestamp(DateTime timestamp) {
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(timestamp);
  }

  Widget textMessage(keyValue, ref, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SenderNameWidget(
          keyValue,
          nameColor,
          showInfo: showInfo,
          isSentByMe: isSentByMe,
          userId: messageModel.senderId,
        ),
        if (parentMessage != null) ParentMessage(parentMessage: parentMessage),
        Wrap(
          children: [
            Wrap(
              children: [
                HighlightTextWidget(
                    key: ValueKey(
                        '$keyValue${MessageKeys.messageContentPostfix.value}'),
                    text: text,
                    normalStyle: const TextStyle(
                      color: Palette.primaryText,
                      fontSize: 16,
                    ),
                    highlightStyle: const TextStyle(
                        color: Palette.primaryText,
                        fontSize: 16,
                        backgroundColor: Color.fromRGBO(246, 225, 2, 0.43)),
                    highlights: highlights),
                SizedBox(width: isSentByMe ? 70.0 : 55.0),
                const Text("")
              ],
            )
          ],
        ),
        (messageModel.parentMessage==null && chat?.type == ChatType.channel)?AnnouncementExtenstion(
          isSentByMe: isSentByMe,
          message: messageModel,
          thread: thread,
          chatId: chatId,
          chatModel: chat,
        ):SizedBox(),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyValue = (key as ValueKey).value;
    bool isPinned = messageModel.isPinned;
    bool isEdited = messageModel.isEdited;
    String text = messageModel.content?.toJson()['text'] ?? "";
    if (text.length <= 35 && isPinned) text += '   ';
    if (text.length <= 35 && isEdited) text += '        ';
    Alignment messageAlignment =
        isSentByMe ? Alignment.centerRight : Alignment.centerLeft;
    IconData messageState = getMessageStateIcon(messageModel);
    bool noBackGround =
        messageModel.messageContentType == MessageContentType.sticker ||
            messageModel.messageContentType == MessageContentType.gif ||
            messageModel.messageContentType == MessageContentType.emoji;
    bool mediaMessage =
        messageModel.messageContentType == MessageContentType.audio ||
            messageModel.messageContentType == MessageContentType.image ||
            messageModel.messageContentType == MessageContentType.video;

    return Align(
      alignment: messageAlignment,
      child: GestureDetector(
        onLongPress: () {
          onLongPress(messageModel);
        },
        onTap: onPress == null
            ? () {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                late OverlayEntry overlayEntry;
                overlayEntry = OverlayEntry(
                  builder: (context) => FloatingMenuOverlay(
                    isSentByMe:
                        messageModel.senderId == ref.read(userProvider)!.id,
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
                      // List<MessageModel> messageList = [messageModel];
                      context.push(CreateChatScreen.route);
                    },
                    onPin: () {
                      overlayEntry.remove();
                      onPin(messageModel);
                    },
                    onEdit: () {
                      overlayEntry.remove();
                      onEdit(messageModel);
                    },
                    onDelete: () {
                      overlayEntry.remove();
                      final msgId = messageModel.id ?? messageModel.localId;
                      showDeleteMessageAlert(
                        context: context,
                        msgId: msgId,
                        chatId: chatId,
                        isUsingMsgLocalId: msgId == messageModel.localId,
                      );
                    },
                    pinned: messageModel.isPinned,
                  ),
                );
                Overlay.of(context).insert(overlayEntry);
              }
            : () {
                onLongPress(messageModel);
              },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
              horizontal: mediaMessage ? 3 : 12,
              vertical: mediaMessage ? 3 : 7),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            gradient: isSentByMe && !noBackGround
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
            color: isSentByMe || noBackGround ? null : Palette.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              _createMessageTile(
                  messageModel.messageContentType, keyValue, ref, text),
              // The timestamp is always in the bottom-right corner if there's space
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(top: 5),
                  // Add some space above the timestamp
                  child: Row(
                    children: [
                      if (isPinned) ...[
                        Transform.rotate(
                          angle: 45 *
                              (3.141592653589793 /
                                  180), // Convert degrees to radians
                          child: const Icon(Icons.push_pin_rounded, size: 12),
                        ),
                        const SizedBox(
                          width: 2,
                        )
                      ],
                      if (isEdited) ...[
                        const Text("edited",
                            style: TextStyle(
                              fontSize: 11,
                              color: Palette.primaryText,
                            )),
                        const SizedBox(
                          width: 2,
                        )
                      ],
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createMessageTile(
      MessageContentType contentType, keyValue, ref, String text) {
    switch (contentType) {
      case MessageContentType.text || MessageContentType.link:
        return textMessage(
          keyValue,
          ref,
          text,
        );
      case MessageContentType.image:
        return ImageMessageWidget(
          onDownloadTap: onDownloadTap,
          filePath: messageModel.content?.toJson()["filePath"],
          fileName: messageModel.content?.toJson()["fileName"],
          url: messageModel.content?.toJson()["imageUrl"],
          caption: messageModel.content?.toJson()["caption"],
        );
      case MessageContentType.video:
        return VideoPlayerWidget(
          onDownloadTap: onDownloadTap,
          filePath: messageModel.content?.toJson()["filePath"],
          fileName: messageModel.content?.toJson()["fileName"],
          url: messageModel.content?.toJson()["videoUrl"],
        );
      case MessageContentType.audio:
        return AudioMessageWidget(
          duration: messageModel.content?.toJson()["duration"],
          filePath: messageModel.content?.toJson()["filePath"],
          fileName: messageModel.content?.toJson()["fileName"],
          url: messageModel.content?.toJson()["audioUrl"],
          onDownloadTap: onDownloadTap,
        );
      case MessageContentType.file:
        return DocumentMessageWidget(
          onDownloadTap: onDownloadTap,
          filePath: messageModel.content?.toJson()["filePath"],
          url: messageModel.content?.toJson()["fileUrl"],
          fileName: messageModel.content?.toJson()["fileName"],
          openOptions: () {},
        );
      case MessageContentType.sticker:
        return StickerMessageWidget(
          onDownloadTap: onDownloadTap,
          filePath: messageModel.content?.toJson()["filePath"],
          url: messageModel.content?.toJson()["stickerUrl"],
          stickerName: messageModel.content?.toJson()["stickerName"] ?? '',
        );
      case MessageContentType.gif:
        return ImageMessageWidget(
          onDownloadTap: onDownloadTap,
          filePath: messageModel.content?.toJson()["filePath"],
          fileName: messageModel.content?.toJson()["gifName"],
          url: messageModel.content?.toJson()["gifUrl"],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
