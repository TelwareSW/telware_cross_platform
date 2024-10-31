import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import 'package:telware_cross_platform/features/stories/view/widget/story_avatar.dart';

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
              context.push(
                Routes.storyScreen,
                extra: {'userId': user.userId, 'showSeens': false},
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
