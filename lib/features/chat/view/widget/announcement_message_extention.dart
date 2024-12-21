import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';

import '../../../../core/models/chat_model.dart';
import '../../../../core/models/message_model.dart';
import '../../../../core/theme/palette.dart';

class AnnouncementExtenstion extends StatelessWidget {
  AnnouncementExtenstion({
    super.key,
    required this.isSentByMe,
    required this.message,
    required this.thread,
    this.chatModel,
    required this.chatId,
  });

  final bool isSentByMe;
  final MessageModel message;
  final List<MessageModel>? thread;
  final ChatModel? chatModel;
  final String chatId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        Divider(
          thickness: 1,
          color: isSentByMe ? Palette.secondary : Palette.primary,
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            Icon(
              Icons.messenger_outline,
              color: isSentByMe ? Palette.secondary : Palette.primary,
            ),
            const SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                context.push(Routes.threadScreen, extra: {
                  'announcement': message,
                  'thread': thread,
                  'chatModel': chatModel,
                  'chatId': chatId,
                });
              },
              child: Text(
                message.threadMessages.isNotEmpty
                    ? '${message.threadMessages.length} comments'
                    : 'Leave a comment',
                style: TextStyle(
                    color: isSentByMe ? Palette.secondary : Palette.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
