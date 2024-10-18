import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_with_user_name.dart';

import '../../models/story_model.dart';
import 'add_my_story.dart';

class StoriesListWithNames extends StatelessWidget {
  UserModel myUser = new UserModel(
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
  );

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

  StoriesListWithNames({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Flexible(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            AddMyStory(myUser: myUser),
            ...usersWithStories.map((user) {
              return StoryWithUserName(
                user: user,
              );
            }).toList(),
          ]),
        ),
      ),
    );
  }
}
