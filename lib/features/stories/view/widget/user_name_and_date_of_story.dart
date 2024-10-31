import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/contact_model.dart';
import '../../models/story_model.dart';
class UserNameAndDateOfStory extends StatelessWidget {
  const UserNameAndDateOfStory({
    super.key,
    required this.user,
    required this.story,
  });

  final ContactModel? user;
  final StoryModel story;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(user!.userImage!),
              fit: BoxFit.cover,
            ),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user!.userId,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('dd-MM-yyyy')
                  .format(story.createdAt),
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}