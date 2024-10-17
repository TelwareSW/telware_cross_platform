import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_with_user_name.dart';

import '../../models/story_model.dart';
import 'add_my_story.dart';

class StoriesListWithNames extends StatelessWidget {
  StoryModel myStory = new StoryModel(
    userName: 'custom',
    userImageUrl:
        'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
    createdAt: DateTime(2023, 10, 16),
  );

  final List<StoryModel> stories = [
    StoryModel(
      userName: 'Bisfsddshoy',
      userImageUrl:
          'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16),
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

  StoriesListWithNames({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Flexible(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            AddMyStory(myStory: myStory),
            ...stories.map((story) {
              return StoryWithUserName(story: story,);
            }).toList(),
          ]),
        ),
      ),
    );
  }
}




