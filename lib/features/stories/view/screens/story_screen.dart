import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:story/story_image.dart';
import 'package:story/story_page_view.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/stories/models/contact_model.dart';
import 'package:telware_cross_platform/features/stories/utils/utils_functions.dart';
import 'package:telware_cross_platform/features/stories/view/widget/stacked_overlapped_images.dart';
import 'package:telware_cross_platform/features/stories/view_model/contact_view_model.dart';
import '../../models/story_model.dart';
import 'dart:typed_data';

import '../widget/delete_popup_menu.dart';

class StoryScreen extends ConsumerStatefulWidget {
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
  }

  Future<void> loadStories() async {
    user = await ref
        .read(usersViewModelProvider.notifier)
        .getContactById(widget.userId);
    setState(() {
      storiesList = user?.stories ?? []; // Set storiesList from fetched user
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

    Future<List<ContactModel>> generateSeensList(List<String> userIds) async {
      List<ContactModel> seenUsers = [];
      for (String id in userIds) {
        ContactModel? user = await ref
            .read(usersViewModelProvider.notifier)
            .getContactById(id); // Ensure 'id' is a String
        if (user != null) seenUsers.add(user);
      }
      return seenUsers;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: StoryPageView(
        itemBuilder: (context, pageIndex, storyIndex) {
          final story = user!.stories[storyIndex];
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
              if (story.storyContent == null) {
                ref
                    .read(usersViewModelProvider.notifier)
                    .saveStoryImage(widget.userId, story.storyId, imageData);
                if (!story.isSeen) {
                  ref
                      .read(usersViewModelProvider.notifier)
                      .markStoryAsSeen(user!.userId, story.storyId);
                }
              }
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
                        Row(
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
                        ),
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
        },
        gestureItemBuilder: (context, pageIndex, storyIndex) {
          final story = user!.stories[storyIndex];

          return FutureBuilder<List<ContactModel>>(
            future: generateSeensList(story.seenIds),
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
                        widget.showSeens == true
                            ? const Padding(
                                padding: EdgeInsets.only(top: 32),
                                child: DeletePopUpMenu(),
                              )
                            : const SizedBox(),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      user!.stories[storyIndex].seenIds.isEmpty
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
                                                  users: seensUsers,
                                                  showBorder: false,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  '${user!.stories[storyIndex].seenIds.length} views',
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
                          widget.showSeens == false
                              ? IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.heart),
                                  onPressed: () {},
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
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
          Navigator.pop(context);
        },
      ),
    );
  }
}