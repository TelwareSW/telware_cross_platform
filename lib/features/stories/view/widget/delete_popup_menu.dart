import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/palette.dart';

class DeletePopUpMenu extends StatelessWidget {
  const DeletePopUpMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      color: Palette.secondary,
      icon: const Icon(
          Icons.menu), // Icon for the menu
      onSelected: (String result) {
        if (result == 'delete') {
          // Perform delete action here
          // You can show a confirmation dialog or execute the delete function
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title:
                const Text("Confirm Deletion"),
                content: const Text(
                    "Are you sure you want to delete this?"),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(context), // Close dialog
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      // Perform the delete action
                      // Add your delete logic here
                      context.pop(); // Close the dialog after deleting
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                          color: Colors.white),
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
