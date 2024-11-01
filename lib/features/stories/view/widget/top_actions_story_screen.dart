import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'delete_popup_menu.dart';

class TopActionsStoryScreen extends StatelessWidget {
  final bool showSeens;
  final WidgetRef ref;
  final String storyId;
  const TopActionsStoryScreen({
    super.key,
    required this.showSeens,
    required this.ref,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: IconButton(
              padding: EdgeInsets.zero,
              color: Colors.white,
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          showSeens
              ? Padding(
            padding: const EdgeInsets.only(top: 32),
            child: DeletePopUpMenu(ref: ref, storyId: storyId),
          )
              : const SizedBox(),
        ],
      ),
    );
  }
}