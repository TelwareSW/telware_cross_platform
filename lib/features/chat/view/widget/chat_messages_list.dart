// ignore_for_file: must_be_immutable

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/providers/chat_provider.dart';
import 'package:telware_cross_platform/features/chat/view/widget/date_label_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/message_tile_widget.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';

class ChatMessagesList extends ConsumerStatefulWidget {
  ChatMessagesList({
    super.key,
    required this.scrollController,
    required this.chatContent,
    required this.selectedMessages,
    required this.type,
    required this.messageMatches,
    required this.replyMessage,
    required this.chatId,
    required this.pinnedMessages,
    required this.messages,
    required this.updateChatMessages,
    required this.onPin,
    required this.onLongPress,
    required this.onReply,
    required this.onEdit,
    this.showExtention=true,
  });

  final ScrollController scrollController;
  final ChatType type;
  final String? chatId;
  List chatContent;
  List<MessageModel> messages;
  List<MessageModel> selectedMessages;
  List<MessageModel> pinnedMessages;
  Map<int, List<MapEntry<int, int>>> messageMatches;
  MessageModel? replyMessage;
  final Function(List<MessageModel> messages) updateChatMessages;
  final Function(MessageModel message) onPin;
  final Function(MessageModel message) onLongPress;
  final Function(MessageModel message) onReply;
  final Function(MessageModel message) onEdit;
  final bool showExtention;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChatMessagesListState();
}

class _ChatMessagesListState extends ConsumerState<ChatMessagesList> {
  var messagesIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      controller: widget.scrollController, // Use the ScrollController
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: widget.chatContent.mapIndexed((index, item) {
            if (item is DateLabelWidget) {
              return item;
            } else if (item is MessageModel) {
              int parentIndex = -1;
              MessageModel? parentMessage;
              if (item.parentMessage != null &&
                  item.parentMessage!.isNotEmpty) {
                parentIndex = widget.messages
                    .indexWhere((msg) => msg.id == item.parentMessage);
              }
              List<MessageModel> thread = widget.messages
                  .where((msg) => msg.parentMessage == item.id)
                  .toList();
              if (parentIndex >= 0) {
                parentMessage = widget.messages[parentIndex];
              }
              return Row(
                mainAxisAlignment: item.senderId == ref.read(userProvider)!.id
                    ? widget.selectedMessages.isNotEmpty
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (widget.selectedMessages
                      .isNotEmpty) // Show check icon only if selected
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: 1), // White border
                      ),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            widget.selectedMessages.contains(item) == true
                                ? Colors.green
                                : Colors.transparent,
                        child: widget.selectedMessages.contains(item) == true
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : const SizedBox(),
                      ),
                    ),
                  if (widget.selectedMessages.contains(item))
                    const SizedBox(width: 10),
                  MessageTileWidget(
                    key: ValueKey(
                        '${MessageKeys.messagePrefix}${messagesIndex++}'),
                    messageModel: item,
                    chatId: widget.chatId ?? '',
                    isSentByMe: item.senderId == ref.read(userProvider)!.id,
                    showInfo: widget.type != ChatType.private,
                    highlights:
                        widget.messageMatches[index] ?? const [MapEntry(0, 0)],
                    onDownloadTap: (String? filePath) {
                      onMediaDownloaded(
                          filePath, item.id ?? item.localId, widget.chatId);
                    },
                    onReply: widget.onReply,
                    onEdit: widget.onEdit,
                    onPin: widget.onPin,
                    onPress: widget.selectedMessages.isEmpty ? null : () {},
                    onLongPress: widget.onLongPress,
                    parentMessage: parentMessage,
                    thread: thread,
                    showExtention: widget.showExtention,
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          }).toList(),
        ),
      ),
    );
  }

  //----------------------------------------------------------------------------
  //-------------------------------Media----------------------------------------


  void onMediaDownloaded(String? filePath, String messageId, String? chatId) {
    if (filePath == null) {
      showToastMessage('File has been deleted ask the sender to resend it');
      return;
    }

    if (chatId == null) {
      showToastMessage('Chat ID is missing');
      return;
    }
    debugPrint("Downloaded file path: $filePath");

    debugPrint("Message ID: $messageId");
    debugPrint("Chat ID: $chatId");
    ref
        .read(chattingControllerProvider)
        .editMessageFilePath(chatId, messageId, filePath);
    List<MessageModel> messages =
        ref.watch(chatProvider(chatId))?.messages ?? [];
    widget.updateChatMessages(messages);
  }
}
