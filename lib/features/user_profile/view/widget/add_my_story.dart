import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_Avatar.dart';
import '../../../../core/theme/palette.dart';
import '../../models/story_model.dart';

class AddMyStory extends StatelessWidget {
  const AddMyStory({
    super.key,
    required this.myStory,
  });

  final StoryModel myStory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Stack(
            children: [
              StoryAvatar(
                storyModel: myStory,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors
                        .white, // Background color of the "+" icon
                  ),
                  padding:
                  EdgeInsets.all(4), // Padding around the "+" icon
                  child: Icon(
                    Icons.add, // "+" icon
                    size: 15,
                    color: Palette.secondary, // Icon color
                  ),
                ),
              ),
            ],
          ), // Add your avatar model here
        ),
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text(
            "My Story",
            style: TextStyle(color: Colors.white),
          ), // Add the avatar title here
        ),
      ],
    );
  }
}