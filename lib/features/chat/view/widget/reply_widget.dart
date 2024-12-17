import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';

import '../../../../core/models/message_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/theme/palette.dart';
import '../../enum/message_enums.dart';
import '../../view_model/chats_view_model.dart';

class ReplyEditFieldHeader extends ConsumerWidget {
  final Function() onDiscard;
  final MessageModel message;
  final bool isReplyOrEdit;

  const ReplyEditFieldHeader({
    super.key,
    required this.message,
    required this.onDiscard,
    required this.isReplyOrEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Container(
        color: Palette.trinary,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            isReplyOrEdit
                ? const Icon(Icons.reply, color: Palette.primary)
                : const Icon(Icons.edit, color: Palette.primary),
            const SizedBox(width: 10),
            if (isReplyOrEdit) const Icon(Icons.person),
            if (isReplyOrEdit) const SizedBox(width: 10),
            Expanded(
              child: FutureBuilder<UserModel?>(
                future: isReplyOrEdit ? ref
                    .read(chatsViewModelProvider.notifier)
                    .getUser(message.senderId) : Future.value(ref.read(userProvider)),
                builder: (context, snapshot) {
                  // Handle loading, error, and data states
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      "Loading...",
                      style: TextStyle(color: Palette.primary),
                    );
                  } else if (snapshot.hasError) {
                    return const Text(
                      "Error loading user",
                      style: TextStyle(color: Palette.primary),
                    );
                  } else if (!snapshot.hasData) {
                    return const Text(
                      "Unknown User",
                      style: TextStyle(color: Palette.primary),
                    );
                  }
                  final userName =
                      '${snapshot.data!.screenFirstName} ${snapshot.data!.screenLastName}';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReplyOrEdit ? "Reply to $userName" : "Edit Message",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Palette.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (isReplyOrEdit) Text(
                        message.messageContentType == MessageContentType.text
                            ? message.content?.getContent() ?? ""
                            : message.messageContentType.content.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Palette.accentText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            ),
            // Discard icon
            GestureDetector(
              onTap: onDiscard,
              child: const Icon(
                Icons.close,
                color: Palette.accentText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
