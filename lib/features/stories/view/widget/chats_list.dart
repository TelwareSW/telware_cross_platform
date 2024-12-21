import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/features/chat/classes/message_content.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';

import 'package:telware_cross_platform/features/chat/view/widget/chat_tile_widget.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';

class ChatsList extends ConsumerWidget {
  final Function(ChatModel) onChatSelected;

  const ChatsList({
    super.key,
    required this.onChatSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsList = ref.watch(chatsViewModelProvider);
    ChatKeys.resetChatTilePrefixSubvalue();
    debugPrint('^*^*^*^*^* chat list rebuilding');

    return SliverList(
      key: ChatKeys.chatsListKey,
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final listKey = ValueKey(
              '${ChatKeys.chatTilePrefix.value + ChatKeys.chatTilePrefixSubvalue}$index');
          final tileKey = ValueKey('${ChatKeys.chatTilePrefix.value}$index');

          return _delegate(
            listKey,
            tileKey,
            chatsList[index],
            ref.read(userProvider)!.id!,
          );
        },
        childCount: chatsList.length,
      ),
    );
  }

  Widget _delegate(
      ValueKey listKey, ValueKey tileKey, ChatModel chat, String userID) {
    final Random random = Random();
    DateTime currentDate = DateTime.now().subtract(const Duration(days: 7));
    final MessageModel fakeMessage = MessageModel(
      senderId: userID,
      messageType: MessageType.normal,
      messageContentType: MessageContentType.text,
      content: TextContent(chat.createdAt != null
          ? '${chat.type.type[0].toUpperCase()}${chat.type.type.substring(1)} created on ${chat.createdAt!.year}-${chat.createdAt!.month}-${chat.createdAt!.day}'
          : 'No messages yet'),
      timestamp: currentDate.add(Duration(
        hours: random.nextInt(24),
        minutes: random.nextInt(60),
      )),
      userStates: {},
    );
    final message = chat.messages.isNotEmpty ? chat.messages.last : fakeMessage;

    return Container(
      key: listKey,
      child: ChatTileWidget(
        key: tileKey,
        chatModel: chat,
        displayMessage: message,
        sentByUser: message.senderId == userID,
        senderID: message.senderId,
        onChatSelected: onChatSelected,
      ),
    );
  }
}
