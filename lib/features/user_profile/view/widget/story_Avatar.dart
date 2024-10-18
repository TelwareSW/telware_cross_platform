import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:telware_cross_platform/features/user_profile/view/screens/story_screen.dart';
import '../../../../core/theme/palette.dart';
import '../../view_model/story_view_model.dart';

class StoryAvatar extends ConsumerWidget {
  final UserModel user;
  const StoryAvatar({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await ref.read(storyViewModelProvider.notifier).fetchStories();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StoryScreen()),
        );
      },
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
                user.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
