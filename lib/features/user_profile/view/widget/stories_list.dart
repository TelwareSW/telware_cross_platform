import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_Avatar.dart';
import '../../models/user_model.dart';
import '../screens/story_screen.dart';

class StoriesList extends StatelessWidget {
  final List<UserModel> usersWithStories = [

  ];



  StoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: usersWithStories.map((user) {
            return StoryAvatar(user: user, screenType: StoryScreen,);
          }).toList(),
        ),
      ),
    );
  }
}