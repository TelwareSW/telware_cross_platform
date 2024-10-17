import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_Avatar.dart';

import '../../models/story_model.dart';

class ColapsedStorySection extends StatelessWidget
    implements PreferredSizeWidget {
  TextDirection direction = TextDirection.ltr;
  double size = 50;
  double xShift = 25;

  final List<StoryModel> stories = [
    StoryModel(
      userName: 'Bishoy',
      userImageUrl:
          'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'Ahmed',
      userImageUrl:
          'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'Moamen',
      userImageUrl:
          'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'marwan',
      userImageUrl:
          'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'marwan',
      userImageUrl:
          'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'marwan',
      userImageUrl:
          'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'marwan',
      userImageUrl:
          'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'marwan',
      userImageUrl:
          'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
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
            '${stories.length} Story',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  List<Container> _buildStackedStories() {
    final items = stories
        .take(3)
        .map((story) => StoryAvatar(
              storyModel: story,
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
