import 'package:flutter/material.dart';

import '../../../../core/models/message_model.dart';
import '../../../../core/theme/palette.dart';
import '../../enum/message_enums.dart';

class ReplyWidget extends StatelessWidget {
  final Function() onDiscard;
  final MessageModel message;
  const ReplyWidget({super.key, required this.message, required this.onDiscard, });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1),
      child: Container(
        color: Palette.trinary,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Icon(Icons.reply, color: Palette.primary),
            const SizedBox(width: 10),
            message.messageContentType == MessageContentType.text ? const Icon(Icons.person) : Image.memory(message.photoBytes!),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reply to ${message.senderId}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Palette.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    message.messageContentType == MessageContentType.text ? message.content?.toJson()['text'] ?? "" : 'Photo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Palette.accentText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: (){onDiscard();},
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
