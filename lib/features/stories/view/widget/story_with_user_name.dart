import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import 'package:telware_cross_platform/features/stories/view/screens/story_screen.dart';
import 'package:telware_cross_platform/features/stories/view/widget/story_avatar.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/sizes.dart';

class StoryWithUserName extends StatelessWidget {
  final ContactModel user;
  const StoryWithUserName({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('Building StoryWithUserName...');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: StoryAvatar(
            user: user,
            screenType: 'othersStoryScreen',
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryScreen(
                    userId: user.userId,
                    showSeens: false,
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 80,
            ),
            child: Text(
              user.userName,
              style: const TextStyle(
                  color: Colors.white, fontSize: Sizes.secondaryText),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        )
      ],
    );
  }
}