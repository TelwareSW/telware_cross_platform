import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story/story_page_view.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import 'package:telware_cross_platform/features/stories/view_model/contact_view_model.dart';
import '../../models/story_model.dart';
import '../widget/bottom_actions_story_screen.dart';
import '../widget/passive_content_story_screen.dart';
import '../widget/top_actions_story_screen.dart';
import 'package:go_router/go_router.dart';

class StoryScreen extends ConsumerStatefulWidget {
  static const String route = '/story';
  final String userId;
  final bool showSeens;

  const StoryScreen({
    super.key,
    required this.userId,
    required this.showSeens,
  });

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;
  ContactModel? user;
  List<StoryModel> storiesList = [];

  @override
  void initState() {
    super.initState();
    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
        IndicatorAnimationCommand.resume);
    loadStories();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          indicatorAnimationController.value = IndicatorAnimationCommand.resume;
        });
      }
    });
  }

  Future<void> loadStories() async {
    user = await ref
        .read(usersViewModelProvider.notifier)
        .getContactById(widget.userId);
    setState(() {
      storiesList = user?.stories ?? [];
    });
  }

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    indicatorAnimationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: StoryPageView(
        itemBuilder: (context, pageIndex, storyIndex) {
          final story = user!.stories[storyIndex];
          return PassiveContent(
              story: story, ref: ref, widget: widget, user: user);
        },
        gestureItemBuilder: (context, pageIndex, storyIndex) {
          final story = user!.stories[storyIndex];

          return ActiveContentStoryScreen(
            storyId: story.storyId,
            seenIds: story.seenIds,
            showSeens: widget.showSeens,
            ref: ref,
            focusNode: _focusNode,
          );
        },
        indicatorAnimationController: indicatorAnimationController,
        initialStoryIndex: (pageIndex) {
          return 0;
        },
        pageLength: 1,
        storyLength: (int pageIndex) {
          return user!.stories.length;
        },
        onPageLimitReached: () {
          context.pop();
        },
      ),
    );
  }
}

class ActiveContentStoryScreen extends StatelessWidget {
  final String storyId;
  final List<String> seenIds;
  final bool showSeens;
  final WidgetRef ref;
  final FocusNode focusNode;

  const ActiveContentStoryScreen({
    super.key,
    required this.storyId,
    required this.seenIds,
    required this.showSeens,
    required this.ref,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ContactModel>>(
      future: ref
          .read(usersViewModelProvider.notifier)
          .getListOfContactsFromHive(seenIds),
      builder: (context, seenSnapshot) {
        if (seenSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (seenSnapshot.hasError || !seenSnapshot.hasData) {
          return Center(
            child: Text(seenSnapshot.error.toString()),
          );
        }
        final seensUsers = seenSnapshot.data!;
        return Stack(
          children: [
            TopActionsStoryScreen(
              showSeens: showSeens,
              ref: ref,
              storyId: storyId,
            ),
            BottomActionsStoryScreen(
              showSeens: showSeens,
              focusNode: focusNode,
              seenIds: seenIds,
              seensUsers: seensUsers,
            ),
          ],
        );
      },
    );
  }
}
