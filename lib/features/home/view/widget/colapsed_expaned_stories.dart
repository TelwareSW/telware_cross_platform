import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/stories/view/widget/colapsed_story_section.dart';
import 'package:telware_cross_platform/features/stories/view/widget/expanded_stories_section.dart';

class ColapsedStories extends StatefulWidget {
  final bool Function() resolver;
  final ScrollController scrollController;
  const ColapsedStories({
    super.key,
    required this.resolver,
    required this.scrollController,
  });

  @override
  State<ColapsedStories> createState() => _ColapsedStoriesState();
}

class _ColapsedStoriesState extends State<ColapsedStories> {
  bool isAppBarCollapsed = false;

  void listener() {
    setState(() {
      isAppBarCollapsed = widget.resolver();
    });
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.scrollController.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return isAppBarCollapsed
        ? const ColapsedStorySection()
        : const Text(
            'TelWare',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Palette.primaryText,
                fontSize: Sizes.primaryText),
          );
  }
}

class ExpandedStories extends StatefulWidget {
  final bool Function() resolver;
  final ScrollController scrollController;
  const ExpandedStories({
    super.key,
    required this.resolver,
    required this.scrollController,
  });

  @override
  State<ExpandedStories> createState() => _ExpandedStoriesState();
}

class _ExpandedStoriesState extends State<ExpandedStories> {
  bool isAppBarCollapsed = false;

  void listener() {
    setState(() {
      isAppBarCollapsed = widget.resolver();
    });
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.scrollController.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
                  background: !isAppBarCollapsed
                      ? const ExpandedStoriesSection()
                      : Container(),
                );
  }
}
