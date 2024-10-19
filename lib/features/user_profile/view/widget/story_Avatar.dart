import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:telware_cross_platform/features/user_profile/view/screens/add_my_story_screen.dart';
import 'package:telware_cross_platform/features/user_profile/view/screens/story_screen.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/add_my_story.dart';
import '../../../../core/theme/palette.dart';
import '../../view_model/user_view_model.dart';

class StoryAvatar extends ConsumerWidget {
  final UserModel user;
  final Type screenType; // Accept the screen type

  const StoryAvatar({
    super.key,
    required this.user,
    required this.screenType
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => screenType == StoryScreen ? StoryScreen(
                user: user,
              ):CameraApp()
          ),
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
