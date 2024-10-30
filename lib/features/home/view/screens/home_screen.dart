import 'package:flutter/material.dart';

import 'inbox_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String route = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Default width for inboxPart
      double inboxPartWidth = 150;

      if (constraints.maxWidth < 600) {
        inboxPartWidth = constraints.maxWidth;
      } else {
        inboxPartWidth = 350;
      }

      // Building the UI
      return constraints.maxWidth < 600
          ? const InboxScreen() // Single screen for smaller devices
          : Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: inboxPartWidth,
              minWidth: 200, // Ensuring minWidth does not conflict
            ),
            child: const InboxScreen(),
          ),
          const Expanded(
            child: Text('Chat Screen'),
          ),
        ],
      );
    });
  }
}
