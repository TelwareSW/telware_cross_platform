import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:story/story_image.dart';
import 'package:story/story_page_view.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/user_profile/models/user_model.dart';
import 'package:telware_cross_platform/features/user_profile/view_model/user_view_model.dart';
import '../../models/story_model.dart';


class StoryScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const StoryScreen({super.key, required this.user});

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
          if(!story.isSeen){
            ref.read(usersViewModelProvider.notifier).markStoryAsSeen(widget.user.userId, story.storyId);
          }
          return Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.black),
              ),
              Positioned.fill(
                child: StoryImage(
                  key: ValueKey(widget.user.imageUrl),
                  imageProvider: NetworkImage(widget.user.imageUrl),
                  fit: BoxFit.fitWidth,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 44, left: 8),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize
                          .min,
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
                          DateFormat('dd-MM-yyyy').format(widget.user.stories[storyIndex].createdAt),
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
                          _focusNode.requestFocus();
                          indicatorAnimationController.value =
                              IndicatorAnimationCommand.pause;
                        },
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Palette.accentText),
                          hintText: 'Reply privately...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.share),
                      onPressed: () {
                      },
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.heart),
                      onPressed: () {
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
