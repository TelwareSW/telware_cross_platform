import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:telware_cross_platform/features/user_profile/view/screens/story_screen.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_Avatar.dart';
import 'package:flutter/material.dart';

class StoryWithUserName extends StatelessWidget {
  final UserModel user;
  const StoryWithUserName({
    super.key, required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: StoryAvatar(
            user: user,
            screenType: StoryScreen,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 80, // Set the maximum width to 50 pixels
            ),
            child: Text(
              user.userName,
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis, // Trim with ellipsis if text exceeds the width
              maxLines: 1, // Limit to a single line
            ),
          ),
        )
      ],
    );
  }
}