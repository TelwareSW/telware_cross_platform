import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/stacked_overlapped_images.dart';
import '../../models/user_model.dart';
import '../../view_model/contact_view_model.dart';

class ColapsedStorySection extends ConsumerWidget {
  final TextDirection direction = TextDirection.ltr;
  final double size = 50;
  final double xShift = 25;

  const ColapsedStorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usersViewModelProvider);
    final users = state.contacts;
    final reorderedUsers = reorderUsers(users);

    debugPrint('Building ColapsedStorySection...');
    return Row(
      children: [
        Expanded(child: StackedOverlappedImages(users: reorderedUsers)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${users.length} Story',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }


  List<UserModel> reorderUsers(List<UserModel> users) {
    List<UserModel> unseenStoriesUsers = [];
    List<UserModel> seenStoriesUsers = [];
    for (var user in users) {
      bool allSeen = user.stories.every((story) => story.isSeen);
      allSeen ? seenStoriesUsers.add(user) : unseenStoriesUsers.add(user);
    }
    return [...unseenStoriesUsers, ...seenStoriesUsers];
  }
}
