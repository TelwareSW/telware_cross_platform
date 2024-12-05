import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/chat/view/screens/create_chat_screen.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';
import 'package:telware_cross_platform/features/home/view/widget/drawer.dart';
import 'package:telware_cross_platform/features/stories/view/widget/chats_list.dart';
import 'package:telware_cross_platform/features/stories/view/widget/colapsed_story_section.dart';
import 'package:telware_cross_platform/features/stories/view/widget/expanded_stories_section.dart';
import 'package:telware_cross_platform/features/stories/view_model/contact_view_model.dart';

class InboxScreen extends ConsumerStatefulWidget {
  static const String route = '/inbox-screen';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chattingControllerProvider).init();
    });
    ref.read(chattingControllerProvider).getUserChats().then((_) {
      setState(() {});
    });
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
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        drawer: const AppDrawer(),
        floatingActionButton: kIsWeb
            ? const SizedBox()
            : FloatingActionButton(
                onPressed: () {
                  context.push(Routes.addMyStory);
                },
                shape: const CircleBorder(),
                backgroundColor: Palette.accent,
                child:
                    const Icon(Icons.camera_alt_rounded, size: Sizes.iconSize),
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
                actions: [
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: IconButton(
                          onPressed: () =>
                              {context.push(CreateChatScreen.route)},
                          icon: const Icon(
                            Icons.search_rounded,
                            size: Sizes.iconSize,
                          )))
                ],
              ),
              const ChatsList(),
            ],
          ),
        ),
      );
    });
  }
}
