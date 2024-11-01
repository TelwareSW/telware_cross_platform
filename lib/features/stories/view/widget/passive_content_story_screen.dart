import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story/story_image.dart';
import 'package:telware_cross_platform/features/stories/view/widget/user_name_and_date_of_story.dart';
import '../../models/contact_model.dart';
import '../../models/story_model.dart';
import '../../utils/utils_functions.dart';
import '../../view_model/contact_view_model.dart';
import '../screens/story_screen.dart';

class PassiveContent extends StatelessWidget {
  const PassiveContent({
    super.key,
    required this.story,
    required this.ref,
    required this.widget,
    required this.user,
  });

  final StoryModel story;
  final WidgetRef ref;
  final StoryScreen widget;
  final ContactModel? user;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: story.storyContent == null
          ? downloadImage(story.storyContentUrl)
          : Future.value(story.storyContent),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Error loading image'));
        }

        final imageData = snapshot.data!;
        ref.read(usersViewModelProvider.notifier)
            .handleStoryImageAndSeenStatus(story, user!, imageData);

        return Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.black),
            ),
            Positioned.fill(
              child: StoryImage(
                key: ValueKey(imageData),
                imageProvider: MemoryImage(imageData),
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 44, left: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserNameAndDateOfStory(user: user, story: story),
                  Column(
                    children: [
                      Text(
                        story.storyCaption,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 17),
                      ),
                      const SizedBox(
                        height: 64,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}