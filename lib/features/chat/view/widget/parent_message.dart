import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/features/chat/view/widget/sender_name_widget.dart';

class ParentMessage extends StatelessWidget {
  const ParentMessage({super.key, required this.parentMessage});
  final MessageModel? parentMessage;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 100.0, // Set your desired maximum height here
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: const Border(
            left: BorderSide(color: Colors.white, width: 4.0), // White edge
          ),
          shape: BoxShape.rectangle,
        ),
        // height: 50,
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SenderNameWidget(
              DateTime.now().millisecondsSinceEpoch,
              Colors.white,
              showInfo: true,
              isSentByMe: false,
              userId: parentMessage?.senderId ?? '',
            ),
            Text(
              parentMessage?.content!.getContent() ?? '',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow
                  .ellipsis, // Trim the text if it exceeds the available space
              maxLines: 3,
            )
          ],
        ),
      ),
    );
  }
}
