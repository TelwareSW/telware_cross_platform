import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:story/story_image.dart';
import 'package:story/story_page_view.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

import '../../view_model/story_view_model.dart';


class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({Key? key}) : super(key: key);

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;
  late final storiesList = ref.watch(storyViewModelProvider);
  @override
  void initState() {
    super.initState();
    loadStories();
    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
        IndicatorAnimationCommand.resume);
  }

  // Load stories from Hive
  void loadStories() {
    final viewModel = ref.read(storyViewModelProvider.notifier);
    viewModel.fetchStories(); // Fetch stories from the backend and save to Hive
  }

  FocusNode _focusNode = FocusNode();

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
          final story = storiesList[storyIndex];
          return Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.black),
              ),
              Positioned.fill(
                child: StoryImage(
                  key: ValueKey(story.storyContent),
                  imageProvider: NetworkImage(
                      story.storyContent
                  ),
                  fit: BoxFit.fitWidth,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 44, left: 8),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.center, // Center-align image and text
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(story.userImageUrl),
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text to start
                      mainAxisSize: MainAxisSize
                          .min, // Prevents Column from expanding vertically
                      children: [
                        Text(
                          'user1',
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
              ),
            ],
          );
        },
        gestureItemBuilder: (context, pageIndex, storyIndex) {
          return Stack(children: [
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
                      child: TextField(
                        onTap: () {
                          // Ensure the keyboard is shown
                          _focusNode.requestFocus();
                          indicatorAnimationController.value =
                              IndicatorAnimationCommand.pause;
                        },

                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: Palette.accentText),
                          hintText: 'Reply privately...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.share),
                      onPressed: () {
                        print('bitch');
                      },
                    ),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.heart),
                      onPressed: () {
                        // Handle more options action
                      },
                    ),
                  ],
                ),
              ),
            ),
          ]);
        },
        indicatorAnimationController: indicatorAnimationController,
        initialStoryIndex: (pageIndex) {
          if (pageIndex == 0) {
            return 1;
          }
          return 0;
        },
        pageLength: storiesList.length,
        storyLength: (int pageIndex) {
          return storiesList.length;
        },
        onPageLimitReached: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
