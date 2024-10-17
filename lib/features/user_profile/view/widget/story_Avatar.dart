import 'package:flutter/material.dart';
import '../../../../core/theme/palette.dart';
import '../../models/story_model.dart';

class StoryAvatar extends StatelessWidget {
  final StoryModel storyModel;
  const StoryAvatar({
    super.key,
    required this.storyModel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Container(
          padding: EdgeInsets.all(2),
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.greenAccent, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(2),
            width: 45,
            height: 45,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Palette.secondary),
            child: ClipOval(
              child: Image.network(
                storyModel.userImageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
