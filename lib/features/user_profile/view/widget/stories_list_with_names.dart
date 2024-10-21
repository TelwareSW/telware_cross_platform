import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_with_user_name.dart';
import 'package:telware_cross_platform/features/user_profile/view_model/contact_view_model.dart';

import 'add_my_story.dart';

class StoriesListWithNames extends ConsumerWidget {

  const StoriesListWithNames({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelState = ref.watch(usersViewModelProvider);

    final users = viewModelState.contacts;

    if (users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final UserModel myUser = users.firstWhere(
          (user) => user.userId == 'myUser',
      orElse: () {
        throw StateError('myUser not found'); // or handle accordingly
      },
    );

    List<UserModel> reorderedUsers = reorderUsers(users.where((user) => user.userId != 'myUser').toList());
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
