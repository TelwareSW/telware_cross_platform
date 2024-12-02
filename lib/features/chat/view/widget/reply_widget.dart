import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/message_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/theme/palette.dart';
import '../../enum/message_enums.dart';
import '../../view_model/chats_view_model.dart';

class ReplyWidget extends ConsumerWidget {
  final Function() onDiscard;
  final MessageModel message;
  const ReplyWidget({super.key, required this.message, required this.onDiscard, });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Container(
        color: Palette.trinary,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Icon(Icons.reply, color: Palette.primary),
            const SizedBox(width: 10),
            message.messageContentType == MessageContentType.text
                ? const Icon(Icons.person)
                : Image.memory(
              message.photoBytes!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FutureBuilder<UserModel?>(
                future: ref
                    .read(chatsViewModelProvider.notifier)
                    .getUser(message.senderId),
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
                  final userName = snapshot.data!.username;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reply to $userName",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Palette.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        message.messageContentType == MessageContentType.text
                            ? message.content?.toJson()['text'] ?? ""
                            : 'Photo',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Palette.accentText,
                        ),
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
