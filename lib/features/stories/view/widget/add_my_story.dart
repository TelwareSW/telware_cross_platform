import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import 'package:telware_cross_platform/features/stories/view/widget/story_avatar.dart';

class AddMyStory extends StatelessWidget {
  final ContactModel myUser;

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
                screenType:
                    myUser.stories.isEmpty ? 'CameraApp' : 'myStoryScreen',
                onTap: () async {
                  myUser.stories.isEmpty ? context.push(Routes.addMyStory) : 
                    context.push(
                      Routes.storyScreen,
                      extra: {'userId': myUser.userId, 'showSeens': true},
                    );
                },
              ),
              myUser.stories.isEmpty
                  ? Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.add,
                          size: 15,
                          color: Palette.secondary,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text(
            "My Story",
            style:
                TextStyle(color: Colors.white, fontSize: Sizes.secondaryText),
          ),
        ),
      ],
    );
  }
}
