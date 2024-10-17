import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/user_profile/models/story_model.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/stories_list_with_names.dart';


class ExpandedStoriesSection extends StatelessWidget
    implements PreferredSizeWidget {
  ExpandedStoriesSection({
    super.key,
  });

  StoryModel myStory = new StoryModel(
      userName: 'My Story',
      userImageUrl:
          'https://t4.ftcdn.net/jpg/01/24/65/69/360_F_124656969_x3y8YVzvrqFZyv3YLWNo6PJaC88SYxqM.jpg',
      createdAt: DateTime(2023, 10, 16));
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: kToolbarHeight + 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Flexible(child: StoriesListWithNames()),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
