import 'package:telware_cross_platform/features/stories/view/widget/story_avatar.dart';

import '../../models/contact_model.dart';
import 'package:flutter/material.dart';

class StackedOverlappedImages extends StatelessWidget {
  final List<ContactModel> users;
  final double size;
  final double xShift;
  final bool showBorder;

  const StackedOverlappedImages({
    super.key,
    required this.users,
    this.size = 50.0,
    this.xShift = 25.0,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final List<Container> allItems = _buildStackedStories(users, context);

    return Stack(
      children: allItems,
    );
  }

  List<Container> _buildStackedStories(
      List<ContactModel> users, BuildContext context) {
    final items = users.take(3).map((user) {
      return StoryAvatar(
        user: user,
        screenType: 'StoryScreen',
        onTap: () async {},
        showBorder: showBorder,
      );
    }).toList();

    return items
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
  }
}
