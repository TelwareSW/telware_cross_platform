import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:telware_cross_platform/features/user_profile/view/screens/story_screen.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_avatar.dart';
import 'package:flutter/material.dart';

class StoryWithUserName extends StatelessWidget {
  final UserModel user;
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
                    user: user,
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
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        )
      ],
    );
  }
}
