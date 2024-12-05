import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/view/widget/audio_message_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/document_message_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/image_message_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/video_player_widget.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';
import 'package:telware_cross_platform/core/view/widget/highlight_text_widget.dart';
import '../../../../core/models/user_model.dart';
import '../screens/create_chat_screen.dart';
import 'floating_menu_overlay.dart';

class MessageTileWidget extends ConsumerWidget {
  final MessageModel messageModel;
  final bool isSentByMe;
  final bool showInfo;
  final Color nameColor;
  final Color imageColor;
  final List<MapEntry<int, int>> highlights;
  final void Function(String?) onDownloadTap;
  final Function(MessageModel) onReply;
  final Function(MessageModel) onLongPress;
  final Function(MessageModel) onPin;
  final Function(String, String, DeleteMessageType) onDelete;
  final Function()? onPress;
  final MessageModel? parentMessage;

  const MessageTileWidget(
      {super.key,
      required this.messageModel,
      required this.isSentByMe,
      this.showInfo = false,
      this.nameColor = Palette.primary,
      this.imageColor = Palette.primary,
      this.highlights = const [],
      required this.onDownloadTap,
      required this.onReply,
      required this.onLongPress,
      required this.onPress,
      required this.onPin,
      this.parentMessage,
      required this.onDelete});

  // Function to format timestamp to "hh:mm AM/PM"
  String formatTimestamp(DateTime timestamp) {
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(timestamp);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyValue = (key as ValueKey).value;
    Alignment messageAlignment =
        isSentByMe ? Alignment.centerRight : Alignment.centerLeft;
    IconData messageState = getMessageStateIcon(messageModel);
    // final String otherUserName = ;

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
                      List<MessageModel> messageList = [messageModel];
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
                          SenderNameWidget(
                            keyValue,
                            nameColor,
                            showInfo: showInfo,
                            isSentByMe: isSentByMe,
                            userId: messageModel.senderId,
                          ),
                          parentMessage != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // First message
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: isSentByMe
                                            ? LinearGradient(
                                                colors: [
                                                  Color.lerp(
                                                          Colors
                                                              .deepPurpleAccent,
                                                          Colors.white,
                                                          0.4) ??
                                                      Colors.black,
                                                  // Increase brightness by using 0.4
                                                  Color.lerp(
                                                          Colors
                                                              .deepPurpleAccent,
                                                          Colors.white,
                                                          0.2) ??
                                                      Colors.deepPurpleAccent,
                                                  // Slightly brighten the bottom color
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              )
                                            : LinearGradient(
                                                colors: [
                                                  Color.lerp(Palette.secondary,
                                                          Colors.white, 0.4) ??
                                                      Colors.black,
                                                  // Increase brightness by using 0.4
                                                  Color.lerp(Palette.secondary,
                                                          Colors.white, 0.2) ??
                                                      Palette.secondary,
                                                  // Slightly brighten the bottom color
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(16),
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(3),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FutureBuilder<UserModel?>(
                                            future: ref
                                                .read(chatsViewModelProvider
                                                    .notifier)
                                                .getUser(messageModel.senderId),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator(); // Show loading spinner
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                  'Error: ${snapshot.error}',
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                );
                                              } else if (snapshot.hasData) {
                                                return Text(
                                                  snapshot.data!.username ?? '',
                                                  style: const TextStyle(
                                                    color: Palette.primaryText,
                                                    fontSize: 16,
                                                  ),
                                                );
                                              } else {
                                                return const Text(
                                                  'No data',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          Text(
                                            parentMessage?.content
                                                    ?.toJson()['text'] ??
                                                "",
                                            style: const TextStyle(
                                              color: Palette.primaryText,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          Wrap(
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
                                      text: messageModel.content
                                              ?.toJson()['text'] ??
                                          "",
                                      normalStyle: const TextStyle(
                                        color: Palette.primaryText,
                                        fontSize: 16,
                                      ),
                                      highlightStyle: const TextStyle(
                                          color: Palette.primaryText,
                                          fontSize: 16,
                                          backgroundColor: Color.fromRGBO(
                                              246, 225, 2, 0.43)),
                                      highlights: highlights),
                                  SizedBox(width: isSentByMe ? 70.0 : 55.0),
                                  const Text("")
                                ],
                              )
                            ],
                          )
                        ])
                  : messageModel.messageContentType == MessageContentType.audio
                      ? AudioMessageWidget(
                          duration: messageModel.content?.toJson()["duration"],
                          filePath: messageModel.content?.toJson()["filePath"],
                          url: messageModel.content?.toJson()["audioUrl"],
                          onDownloadTap: onDownloadTap,
                        )
                      : messageModel.messageContentType ==
                              MessageContentType.image
                          ? ImageMessageWidget(
                              onDownloadTap: onDownloadTap,
                              filePath:
                                  messageModel.content?.toJson()["filePath"],
                              url: messageModel.content?.toJson()["imageUrl"],
                            )
                          : messageModel.messageContentType ==
                                  MessageContentType.video
                              ? VideoPlayerWidget(
                                  url: messageModel.content
                                      ?.toJson()["videoUrl"],
                                  onDownloadTap: onDownloadTap,
                                  filePath: messageModel.content
                                      ?.toJson()["filePath"])
                              : messageModel.messageContentType ==
                                      MessageContentType.file
                                  ? DocumentMessageWidget(
                                      url: messageModel.content
                                          ?.toJson()["fileUrl"],
                                      onDownloadTap: onDownloadTap,
                                      filePath: messageModel.content
                                          ?.toJson()["filePath"],
                                      openOptions: () {},
                                    )
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
