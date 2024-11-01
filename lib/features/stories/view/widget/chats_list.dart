import 'package:flutter/material.dart';

class ChatsList extends StatelessWidget {
  const ChatsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('Building chats_list...');
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          return ListTile(
            title: Text(
                'Chat ${index + 1}'),
          );
        },
        childCount: 20,
      ),
    );
  }
}
