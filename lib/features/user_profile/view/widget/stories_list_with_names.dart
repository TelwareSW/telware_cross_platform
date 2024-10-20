import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_with_user_name.dart';
import 'package:telware_cross_platform/features/user_profile/view_model/user_view_model.dart';

import '../../models/story_model.dart';
import 'add_my_story.dart';

class StoriesListWithNames extends ConsumerWidget {
  final UserModel myUser = UserModel(
    userName: 'game of thrones',
    imageUrl:
        'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
    stories: [
      StoryModel(
        storyId: 'idd11',
        createdAt: DateTime.now(),
        storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
        isSeen: true,
      ),
      StoryModel(
        storyId: 'idd12',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
        isSeen: true,
      ),
      StoryModel(
        storyId: 'idd13',
        createdAt: DateTime.now(),
        storyContent:
            'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
        isSeen: true,
      ),
    ],
    userId: 'idd1',
  );

  StoriesListWithNames({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelState = ref.watch(usersViewModelProvider);

    final users = viewModelState.users;
    List<UserModel> reorderedUsers = reorderUsers(users);
    debugPrint('Building StoriesListWithNames...');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        AddMyStory(myUser: myUser),
        ...reorderedUsers.map((user) {
          return StoryWithUserName(
            user: user,
          );
        }),
      ]),
    );
  }

  List<UserModel> reorderUsers(List<UserModel> users) {
    List<UserModel> unseenStoriesUsers = [];
    List<UserModel> seenStoriesUsers = [];
    for (var user in users) {
      bool allSeen = user.stories.every((story) => story.isSeen);
      allSeen ? seenStoriesUsers.add(user) : unseenStoriesUsers.add(user);
    }
    return [...unseenStoriesUsers, ...seenStoriesUsers];
  }
}
