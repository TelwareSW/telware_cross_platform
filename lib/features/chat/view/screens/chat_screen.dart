import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg
import 'package:intl/intl.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/chat/enum/chatting_enums.dart';
import 'package:telware_cross_platform/features/chat/providers/chat_provider.dart';
import 'package:telware_cross_platform/features/chat/view/widget/bottom_input_bar_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_header_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/date_label_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/message_tile_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  static const String route = '/chat';
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends ConsumerState<ChatScreen> with WidgetsBindingObserver {
  List<dynamic> chatContent = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatModel? chatModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatModel = ref.read(chatProvider(widget.chatId));
      _controller.text = chatModel!.draft ?? "";
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose(); // Dispose of the ScrollController
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    super.dispose();
  }

  List<dynamic> _generateChatContentWithDateLabels(
      List<MessageModel> messages) {
    List<dynamic> chatContent = [];
    for (int i = 0; i < messages.length; i++) {
      if (i == 0 ||
          !isSameDay(messages[i - 1].timestamp, messages[i].timestamp)) {
        chatContent.add(DateLabelWidget(
            label: DateFormat('MMMM d').format(messages[i].timestamp)));
      }
      chatContent.add(messages[i]);
    }
    return chatContent;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Called when the keyboard visibility changes
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (_scrollController.hasClients && _isAtBottom()) {
      // When the keyboard is shown and the user is at the bottom, scroll to the bottom
      _scrollToBottom();
    }
  }

  // Check if the user is already at the bottom of the scroll view
  bool _isAtBottom() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      return true;
    }
    return false;
  }

  // Scroll the chat view to the bottom
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatModel = ref.watch(chatProvider(widget.chatId))!;

    final type = chatModel.type;
    final String title = chatModel.title;
    final membersNumber = chatModel.userIds.length;
    final String subtitle = chatModel.type == ChatType.private
        ? "last seen a long time ago"
        : "$membersNumber Member${membersNumber > 1 ? "s" : ""}";
    final imageBytes = chatModel.photoBytes;
    final photo = chatModel.photo;
    final messages =
          chatModel.id != null ? chatModel.messages : <MessageModel>[];
      chatContent = _generateChatContentWithDateLabels(messages);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back when pressed
          },
        ),
        title: ChatHeaderWidget(
          title: title,
          subtitle: subtitle,
          photo: photo,
          imageBytes: imageBytes,
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Hide the keyboard when tapping outside of text field
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Chat content area (with background SVG)
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/svg/default_pattern.svg',
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  Palette.trinary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: chatContent.isEmpty
                      ? Center(
                          child: Container(
                            width: 210,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            padding: const EdgeInsets.all(22.0),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(4, 86, 57, 0.30),
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'No messages here yet...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.primaryText,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Send a message or tap the greeting below.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Palette.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                LottieViewer(
                                  path: getRandomLottieAnimation(),
                                  width: 100,
                                  height: 100,
                                  isLooping: true,
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          controller:
                              _scrollController, // Use the ScrollController
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(
                              children: chatContent.map((item) {
                                if (item is DateLabelWidget) {
                                  return item;
                                } else if (item is MessageModel) {
                                  return MessageTileWidget(
                                    messageModel: item,
                                    isSentByMe: item.senderId == ref.read(userProvider)!.id,
                                    showInfo: type == ChatType.group,
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }).toList(),
                            ),
                          ),
                        ),
                ),
                // The input bar at the bottom
                BottomInputBarWidget(controller: _controller),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getRandomLottieAnimation() {
    // List of Lottie animation paths
    List<String> lottieAnimations = [
      'assets/tgs/curious_pigeon.tgs',
      'assets/tgs/fruity_king.tgs',
      'assets/tgs/graceful_elmo.tgs',
      'assets/tgs/hello_anteater.tgs',
      'assets/tgs/hello_astronaut.tgs',
      'assets/tgs/hello_badger.tgs',
      'assets/tgs/hello_bee.tgs',
      'assets/tgs/hello_cat.tgs',
      'assets/tgs/hello_clouds.tgs',
      'assets/tgs/hello_duck.tgs',
      'assets/tgs/hello_elmo.tgs',
      'assets/tgs/hello_fish.tgs',
      'assets/tgs/hello_flower.tgs',
      'assets/tgs/hello_food.tgs',
      'assets/tgs/hello_fridge.tgs',
      'assets/tgs/hello_ghoul.tgs',
      'assets/tgs/hello_king.tgs',
      'assets/tgs/hello_lama.tgs',
      'assets/tgs/hello_monkey.tgs',
      'assets/tgs/hello_pigeon.tgs',
      'assets/tgs/hello_possum.tgs',
      'assets/tgs/hello_rat.tgs',
      'assets/tgs/hello_seal.tgs',
      'assets/tgs/hello_shawn_sheep.tgs',
      'assets/tgs/hello_snail_rabbit.tgs',
      'assets/tgs/hello_virus.tgs',
      'assets/tgs/hello_water_animal.tgs',
      'assets/tgs/hello_whales.tgs',
      'assets/tgs/muscles_wizard.tgs',
      'assets/tgs/plague_doctor.tgs',
      'assets/tgs/screaming_elmo.tgs',
      'assets/tgs/shy_elmo.tgs',
      'assets/tgs/sick_wizard.tgs',
      'assets/tgs/snowman.tgs',
      'assets/tgs/spinny_jelly.tgs',
      'assets/tgs/sus_moon.tgs',
      'assets/tgs/toiletpaper.tgs',
    ];

    // Generate a random index
    Random random = Random();
    int randomIndex =
        random.nextInt(lottieAnimations.length); // Gets a random index

    // Return the randomly chosen Lottie animation path
    return lottieAnimations[randomIndex];
  }
}
