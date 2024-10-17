import 'package:flutter/material.dart';

class ChatsList extends StatelessWidget {
  const ChatsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          return ListTile(
            title: Text(
                'Chat ${index + 1}'), // Placeholder for chat list items
          );
        },
        childCount: 20, // Number of chat items
      ),
    );
  }
}
