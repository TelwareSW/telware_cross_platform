import 'package:flutter/material.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/story_Avatar.dart';

import '../../models/story_model.dart';

class StoriesList extends StatelessWidget {
  final List<StoryModel> stories = [
    StoryModel(
      userName: 'Bishoy',
      userImageUrl: 'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'Ahmed',
      userImageUrl: 'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'Moamen',
      userImageUrl: 'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'marwan',
      userImageUrl: 'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'marwan',
      userImageUrl: 'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'marwan',
      userImageUrl: 'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'marwan',
      userImageUrl: 'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
    StoryModel(
      userName: 'marwan',
      userImageUrl: 'https://st2.depositphotos.com/2703645/7304/v/450/depositphotos_73040253-stock-illustration-male-avatar-icon.jpg',
      createdAt: DateTime(2023, 10, 16), // Use a static date for example
    ),
  ];



  StoriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: stories.map((story) {
            return StoryAvatar(storyModel: story,);
          }).toList(),
        ),
      ),
    );
  }
}