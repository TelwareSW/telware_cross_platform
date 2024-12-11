import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/chat/enum/message_enums.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';

class DeletePopUpMenu extends ConsumerWidget {
  final String chatId;
  final String messageId;
  const DeletePopUpMenu({
    super.key,
    required this.chatId,
    required this.messageId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      color: Palette.secondary,
      icon: const Icon(Icons.menu),
      onSelected: (String result) {
        if (result == 'delete') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm Deletion"),
                content: const Text("Are you sure you want to delete this Message?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(chattingControllerProvider).deleteMsg(
                            messageId,
                            chatId,
                            DeleteMessageType.all,
                          );
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: 'delete',
            child: Text('Delete'),
          ),
        ];
      },
    );
  }
}
