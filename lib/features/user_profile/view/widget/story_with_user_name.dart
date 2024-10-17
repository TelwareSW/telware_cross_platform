import 'package:telware_cross_platform/features/user_profile/view/widget/story_Avatar.dart';

import '../../models/story_model.dart';
import 'package:flutter/material.dart';

class StoryWithUserName extends StatelessWidget {
  final StoryModel story;
  const StoryWithUserName({
    super.key, required this.story,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: StoryAvatar(
            storyModel: story,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 80, // Set the maximum width to 50 pixels
            ),
            child: Text(
              story.title,
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