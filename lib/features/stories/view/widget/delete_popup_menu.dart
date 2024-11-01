import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/palette.dart';
import '../../view_model/contact_view_model.dart';

class DeletePopUpMenu extends StatelessWidget {
  final WidgetRef ref;
  final String storyId;
  const DeletePopUpMenu({
    super.key,
    required this.ref,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      color: Palette.secondary,
      icon: const Icon(
          Icons.menu),
      onSelected: (String result) {
        if (result == 'delete') {
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
                    onPressed: (){
                      Navigator.pop(
                          context);
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      final contactViewModel = ref.read(usersViewModelProvider.notifier);
                      contactViewModel.deleteStory(storyId);
                      Navigator.pop(
                          context);
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
