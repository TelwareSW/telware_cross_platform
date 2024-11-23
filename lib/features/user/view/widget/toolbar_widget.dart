import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ToolbarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;

  const ToolbarWidget({
    super.key,
    this.title,
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
              context.pop(); // Navigate back when pressed
            },
          )
          : null, // If no back button needed, set leading to null
      title: title != null ? Text(
        title!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ) : null,
      actions: actions,
    );
  }
}
