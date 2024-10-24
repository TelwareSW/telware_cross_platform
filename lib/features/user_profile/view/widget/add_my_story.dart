import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:telware_cross_platform/features/user_profile/view/screens/story_screen.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_avatar.dart';
import '../../../../core/theme/palette.dart';
import '../../../../core/theme/sizes.dart';
import '../screens/add_my_story_screen.dart';

class AddMyStory extends StatelessWidget {
  final UserModel myUser;

  const AddMyStory({
    super.key,
    required this.myUser,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('Building AddMyStory...');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Stack(
            children: [
              StoryAvatar(
                user: myUser,
                screenType: myUser.stories.isEmpty ? 'CameraApp' : 'myStoryScreen', onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => myUser.stories.isEmpty ?  const AddMyStoryScreen() : StoryScreen(
                        userId: myUser.userId, showSeens: true,
                      ),
                  ),
                );
              },
              ),
              myUser.stories.isEmpty ? Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors
                        .white,
                  ),
                  padding:
                  const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.add,
                    size: 15,
                    color: Palette.secondary,
                  ),
                ),
              ):const SizedBox(),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text(
            "My Story",
            style: TextStyle(color: Colors.white,fontSize: Sizes.secondaryText),
          ),
        ),
      ],
    );
  }
}