import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/stories/view/widget/stacked_overlapped_images.dart';
import '../../../../core/theme/sizes.dart';
import '../../models/contact_model.dart';
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

    final ContactModel myUser = users.firstWhere(
          (user) => user.userId == 'myUser',
      orElse: () {
        throw StateError('myUser not found');
      },
    );

    return Row(
      children: [
        Expanded(child: StackedOverlappedImages(users: reorderedUsers)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${myUser.stories.isEmpty?users.length - 1:users.length} Story',
            style: const TextStyle(
                fontSize: Sizes.primaryText, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  List<ContactModel> reorderUsers(List<ContactModel> users) {
    List<ContactModel> unseenStoriesUsers = [];
    List<ContactModel> seenStoriesUsers = [];
    for (var user in users) {
      bool allSeen = user.stories.every((story) => story.isSeen);
      allSeen ? seenStoriesUsers.add(user) : unseenStoriesUsers.add(user);
    }
    return [...unseenStoriesUsers, ...seenStoriesUsers];
  }
}
