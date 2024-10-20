import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/view/screens/story_screen.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_avatar.dart';
import '../../models/user_model.dart';
import '../../view_model/user_view_model.dart';

class ColapsedStorySection extends ConsumerWidget {
  final TextDirection direction = TextDirection.ltr;
  final double size = 50;
  final double xShift = 25;


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usersViewModelProvider);
    final users = state.users;
    final reorderedUsers = reorderUsers(users);
    List<Container> allItems = _buildStackedStories(reorderedUsers);

    debugPrint('Building ColapsedStorySection...');
    return Row(
      children: [
        Stack(
          children: direction == TextDirection.ltr
              ? allItems.reversed.toList()
              : allItems,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${users.length} Story',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  List<Container> _buildStackedStories(List<UserModel> users) {
    final items = users
        .take(3)
        .map((user) => StoryAvatar(
              user: user,
              screenType: StoryScreen,
            ))
        .toList();

    final allItems = items
        .asMap()
        .map((index, item) {
          final left = size - xShift;
          final value = Container(
            margin: EdgeInsets.only(left: left * index),
            child: item,
          );
          return MapEntry(index, value);
        })
        .values
        .toList();
    return allItems;
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
