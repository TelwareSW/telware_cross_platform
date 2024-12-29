import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/theme/sizes.dart';
import 'package:telware_cross_platform/features/chat/view/screens/create_chat_screen.dart';
import 'package:telware_cross_platform/features/chat/view/widget/call_overlay_widget.dart';
import 'package:telware_cross_platform/features/chat/view_model/chatting_controller.dart';
import 'package:telware_cross_platform/features/home/view/widget/colapsed_expaned_stories.dart';
import 'package:telware_cross_platform/features/home/view/widget/drawer.dart';
import 'package:telware_cross_platform/features/stories/view/widget/chats_list.dart';
import 'package:telware_cross_platform/features/stories/view_model/contact_view_model.dart';

import '../../../../core/models/chat_model.dart';

class InboxScreen extends ConsumerStatefulWidget {
  static const String route = '/inbox-screen';
  final Function(ChatModel) onChatSelected;
  const InboxScreen({super.key, required this.onChatSelected});

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
    // ref.read(chattingControllerProvider).getUserChats().then((_) {
    //   setState(() {});
    // });
  }

  bool _scrollListener() {
    const double appBarHeight = 35.0;
    if (_scrollController.offset > appBarHeight && !isAppBarCollapsed) {
      return isAppBarCollapsed = true;
    } else if (_scrollController.offset <= appBarHeight && isAppBarCollapsed) {
      return isAppBarCollapsed = false;
    }
    return isAppBarCollapsed;
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
            physics: const AlwaysScrollableScrollPhysics(),
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
                title: ColapsedStories(
                  resolver: _scrollListener,
                  scrollController: _scrollController,
                ),
                flexibleSpace: ExpandedStories(
                  resolver: _scrollListener,
                  scrollController: _scrollController,
                ),
                actions: [
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: IconButton(
                          key: ChatKeys.createChatButton,
                          onPressed: () =>
                              {context.push(CreateChatScreen.route)},
                          icon: const Icon(
                            Icons.search_rounded,
                            size: Sizes.iconSize,
                          )))
                ],
              ),
              const SliverToBoxAdapter(
                child: CallOverlay(),
              ),
              ChatsList(onChatSelected: widget.onChatSelected),
            ],
          ),
        ),
      );
    },);
  }
}
