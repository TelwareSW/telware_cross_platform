import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:story/story_image.dart';
import 'package:story/story_page_view.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/stacked_overlapped_images.dart';
import 'package:telware_cross_platform/features/user_profile/view_model/user_view_model.dart';
import '../../models/story_model.dart';

class StoryScreen extends ConsumerStatefulWidget {
  final UserModel user;
  final bool showSeens;
  const StoryScreen({
    super.key,
    required this.user,
    required this.showSeens,
  });

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;
  List<StoryModel> storiesList = [];

  @override
  void initState() {
    super.initState();
    loadStories();
    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
        IndicatorAnimationCommand.resume);
  }

  Future<void> loadStories() async {
    storiesList = widget.user.stories;
    setState(() {});
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: StoryPageView(
        itemBuilder: (context, pageIndex, storyIndex) {
          final story = widget.user.stories[storyIndex];
          if (!story.isSeen) {
            ref
                .read(usersViewModelProvider.notifier)
                .markStoryAsSeen(widget.user.userId, story.storyId);
          }
          return Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.black),
              ),
              Positioned.fill(
                child: StoryImage(
                  key: ValueKey(story.storyContent),
                  imageProvider: NetworkImage(story.storyContent),
                  fit: BoxFit.fitWidth,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 44, left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(widget.user.imageUrl),
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
                              widget.user.userId,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('dd-MM-yyyy').format(story.createdAt),
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          story.storyCaption,
                          style: const TextStyle(color: Colors.white, fontSize: 17),
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
        gestureItemBuilder: (context, pageIndex, storyIndex) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        color: Colors.white,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        color: Colors.white,
                        icon: const Icon(Icons.list),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: widget.showSeens == false
                            ? TextField(
                                onTap: () {
                                  _focusNode.requestFocus();
                                  indicatorAnimationController.value =
                                      IndicatorAnimationCommand.pause;
                                },
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  hintStyle: const TextStyle(
                                      color: Palette.accentText),
                                  hintText: 'Reply privately...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                              )
                            : Row(
                                children: [
                                  widget.user.stories[storyIndex].seens.isEmpty
                                      ? const Text(
                                          'No views yet',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                          ),
                                        )
                                      : Row(
                                          children: [
                                            StackedOverlappedImages(
                                              users: widget.user
                                                  .stories[storyIndex].seens,
                                              showBorder: false,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '${widget.user.stories[storyIndex].seens.length} views',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                              ),
                                            )
                                          ],
                                        ),
                                ],
                              ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.share),
                        onPressed: () {},
                      ),
                      widget.showSeens == false ? IconButton(
                        icon: const FaIcon(FontAwesomeIcons.heart),
                        onPressed: () {},
                      ):const SizedBox(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        indicatorAnimationController: indicatorAnimationController,
        initialStoryIndex: (pageIndex) {
          return 0;
        },
        pageLength: 1,
        storyLength: (int pageIndex) {
          return widget.user.stories.length;
        },
        onPageLimitReached: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
