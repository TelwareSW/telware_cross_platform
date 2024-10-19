import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_Avatar.dart';
import '../../../../core/theme/palette.dart';
import '../screens/add_my_story_screen.dart';

class AddMyStory extends StatelessWidget {
  const AddMyStory({
    super.key,
    required this.myUser,
  });

  final UserModel myUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Stack(
            children: [
              StoryAvatar(
                user: myUser,
                screenType: CameraApp,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors
                        .white,
                  ),
                  padding:
                  EdgeInsets.all(4),
                  child: Icon(
                    Icons.add,
                    size: 15,
                    color: Palette.secondary, // Icon color
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text(
            "My Story",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}