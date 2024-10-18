import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_Avatar.dart';

import '../../models/story_model.dart';
import '../../models/user_model.dart';

class ColapsedStorySection extends StatelessWidget
    implements PreferredSizeWidget {
  TextDirection direction = TextDirection.ltr;
  double size = 50;
  double xShift = 25;

  final List<UserModel> usersWithStories = [
    UserModel(
      userName: 'rings of power',
      imageUrl:
          'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      stories: [
        StoryModel(
          userName: 'rings of power',
          userImageUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          createdAt: DateTime.now(),
          storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
        ),
        StoryModel(
          userName: 'game of thrones',
          userImageUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
        ),
      ],
    ),
    UserModel(
      userName: 'game of thrones',
      imageUrl:
          'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      stories: [
        StoryModel(
          userName: 'rings of power',
          userImageUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          createdAt: DateTime.now(),
          storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
        ),
        StoryModel(
          userName: 'game of thrones',
          userImageUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/2.jpeg',
        ),
        StoryModel(
          userName: 'rings of power',
          userImageUrl:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
          createdAt: DateTime.now(),
          storyContent:
              'https://raw.githubusercontent.com/Bishoywadea/hosted_images/refs/heads/main/1.jpg',
        ),
      ],
    ),
  ];

  ColapsedStorySection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Container> allItems = _buildStackedStories();

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
            '${usersWithStories.length} Story',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  List<Container> _buildStackedStories() {
    final items = usersWithStories
        .take(3)
        .map((user) => StoryAvatar(
              user: user,
            ))
        .toList();

    final allItems = items
        .asMap()
        .map((index, item) {
          final left = size - xShift;
          final value = Container(
            child: item,
            margin: EdgeInsets.only(left: left * index),
          );
          return MapEntry(index, value);
        })
        .values
        .toList();
    return allItems;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
