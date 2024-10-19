import 'package:flutter/material.dart';

class ToolbarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const ToolbarWidget({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
  });

  // Defines the size of the AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton
          ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Navigate back when pressed
            },
          )
          : null, // If no back button needed, set leading to null
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: actions,
    );
  }
}
