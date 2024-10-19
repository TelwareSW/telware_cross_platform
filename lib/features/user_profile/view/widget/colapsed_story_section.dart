import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/user_profile/view/screens/story_screen.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_Avatar.dart';
import '../../models/user_model.dart';

class ColapsedStorySection extends StatelessWidget
    implements PreferredSizeWidget {
  final TextDirection direction = TextDirection.ltr;
  final double size = 50;
  final double xShift = 25;

  final List<UserModel> usersWithStories = [
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
              user: user, screenType: StoryScreen,
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
