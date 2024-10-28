import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import 'package:telware_cross_platform/features/stories/view/widget/story_with_user_name.dart';
import 'package:telware_cross_platform/features/stories/view_model/contact_view_model.dart';

import 'add_my_story.dart';

class StoriesListWithNames extends ConsumerStatefulWidget {
  const StoriesListWithNames({super.key});

  @override
  _StoriesListWithNamesState createState() => _StoriesListWithNamesState();
}

class _StoriesListWithNamesState extends ConsumerState<StoriesListWithNames> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(usersViewModelProvider);
    final users = viewModelState.contacts;

    if (users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final ContactModel myUser = users.firstWhere(
      (user) => user.userId == 'myUser',
      orElse: () {
        throw StateError('myUser not found');
      },
    );

    List<ContactModel> reorderedUsers = reorderUsers(
      users.where((user) => user.userId != 'myUser').toList(),
    );

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          AddMyStory(myUser: myUser),
          ...reorderedUsers.map((user) {
            return StoryWithUserName(user: user);
          }),
        ],
      ),
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
