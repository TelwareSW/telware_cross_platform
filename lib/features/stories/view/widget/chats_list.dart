import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_tile_widget.dart';
import 'package:telware_cross_platform/features/chat/view_model/chats_view_model.dart';

class ChatsList extends ConsumerWidget {
  const ChatsList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('Building chats_list...');
    final chatsList = ref.watch(chatsViewModelProvider);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return _delegate(
            chatsList[index],
            ref.read(userProvider)!.id!,
          );
        },
        childCount: chatsList.length,
      ),
    );
  }

  Widget _delegate(ChatModel chat, String userID) {
    final message = chat.messages[0];

    return ChatTileWidget(
      chatModel: chat,
      displayMessage: message,
      sentByUser: message.senderId != userID,
    );
  }
}
