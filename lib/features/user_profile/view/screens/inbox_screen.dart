import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/user_profile/view/widget/colapsed_story_section.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/theme/sizes.dart';
import '../../view_model/contact_view_model.dart';
import '../widget/chats_list.dart';
import '../widget/expanded_stories_section.dart';
import 'add_my_story_screen.dart';

class InboxScreen extends ConsumerStatefulWidget {
  static const String route = '/profile';
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
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

  Future<void> _refreshPage() async {
    await ref.read(usersViewModelProvider.notifier).fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          floatingActionButton: kIsWeb
              ? const SizedBox()
              : FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMyStoryScreen(),
                ),
              );
            },
            shape: const CircleBorder(),
            backgroundColor: Palette.accent,
            child: const Icon(Icons.camera_alt_rounded,
                size: Sizes.iconSize),
          ),
          body: RefreshIndicator(
            onRefresh: _refreshPage,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Palette.secondary,
                  expandedHeight: kIsWeb
                      ? 150
                      : constraints.maxWidth > 600
                      ? 150
                      : 140,
                  floating: false,
                  snap: false,
                  pinned: true,
                  leading: const Icon(Icons.menu, size: Sizes.iconSize),
                  title: isAppBarCollapsed
                      ? const ColapsedStorySection()
                      : const Text(
                    'TelWare',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Palette.primaryText,
                        fontSize: Sizes.primaryText),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: !isAppBarCollapsed
                        ? const ExpandedStoriesSection()
                        : Container(),
                  ),
                  actions: const [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(
                        Icons.search_rounded,
                        size: Sizes.iconSize,
                      ),
                    )
                  ],
                ),
                const ChatsList(),
              ],
            ),
          ),
        );
      }
    );
  }
}
