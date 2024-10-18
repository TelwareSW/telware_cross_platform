import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/colapsed_story_section.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../widget/chats_list.dart';
import '../widget/expanded_stories_section.dart';

class InboxScreen extends StatefulWidget {
  static const String route = '/profile';
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ScrollController _scrollController = ScrollController();
  bool isAppBarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    const double appBarHeight = 35.0;
    if (_scrollController.offset > appBarHeight && !isAppBarCollapsed) {
      setState(() => isAppBarCollapsed = true);
    } else if (_scrollController.offset <= appBarHeight && isAppBarCollapsed) {
      setState(() => isAppBarCollapsed = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints){
      return Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Palette.secondary,
              expandedHeight: kIsWeb ? 150 : constraints.maxWidth > 600 ? 140 : 130,
              floating: false,
              snap: false,
              pinned: true,
              leading: Icon(Icons.menu),
              title: isAppBarCollapsed
                  ? ColapsedStorySection()
                  : Text(
                      'TelWare',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              flexibleSpace: FlexibleSpaceBar(
                background: ExpandedStoriesSection()
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(
                    Icons.search_rounded,
                    size: 30,
                  ),
                )
              ],
            ),
            ChatsList(),
          ],
        ),
      );},
    );
  }
}
