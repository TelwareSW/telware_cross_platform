import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:telware_cross_platform/core/mock/messages_mock.dart';
import 'package:telware_cross_platform/core/models/chat_model.dart';
import 'package:telware_cross_platform/core/models/message_model.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/lottie_viewer.dart';
import 'package:telware_cross_platform/features/chat/view/widget/bottom_input_bar_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/chat_header_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/date_label_widget.dart';
import 'package:telware_cross_platform/features/chat/view/widget/message_tile_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';

class ChatScreen extends StatefulWidget {
  static const String route = '/chat';
  final ChatModel chatModel;

  const ChatScreen({super.key, required this.chatModel});

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> with WidgetsBindingObserver {
  List<dynamic> chatContent = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatType type;
  bool isSearching = false;
  bool isShowAsList = false;
  int _numberOfMatches = 0;
  int _currentMatch = 1;
  int _currentMatchIndex = 0;
  Map<int, List<MapEntry<int, int>>> _messageMatches = {};
  List<int> _messageIndices = [];

  @override
  void initState() {
    super.initState();
    _messageController.text = widget.chatModel.draft ?? "";
    type = widget.chatModel.type;
    WidgetsBinding.instance.addObserver(this);
    final messages = widget.chatModel.id != null ? generateFakeMessages() : <MessageModel>[];
    chatContent = _generateChatContentWithDateLabels(messages);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // Dispose of the ScrollController
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    super.dispose();
  }

  List<dynamic> _generateChatContentWithDateLabels(List<MessageModel> messages) {
    List<dynamic> chatContent = [];
    for (int i = 0; i < messages.length; i++) {
      if (i == 0 || !isSameDay(messages[i - 1].timestamp, messages[i].timestamp)) {
        chatContent.add(DateLabelWidget(label: DateFormat('MMMM d').format(messages[i].timestamp)));
      }
      chatContent.add(messages[i]);
    }
    return chatContent;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
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
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      return true;
    }
    return false;
  }

  void _scrollToTimeStamp(DateTime date) {
    final DateTime timestamp = DateTime(date.year, date.month, date.day);
    final int index = chatContent.indexWhere((element) {
      if (element is MessageModel) {
        return element.timestamp.isAfter(timestamp);
      }
      return false;
    });
    if (index != -1) {
      _scrollController.jumpTo(index * 20.0);
    }
  }

  // Scroll the chat view to the bottom
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _searchForText(searchText) async {
    Map<int, List<MapEntry<int, int>>>  messageMatches = {};
    int numberOfMatches = 0;
    int currentMatchIndex = 0;
    List<int> messageIndices = [];
    for (int i = 0; i < chatContent.length; i++) {
      if (chatContent[i] is! MessageModel) {
        continue;
      }
      List<MapEntry<int, int>> matches = kmp(chatContent[i].content ?? "", searchText);
      if (matches.isNotEmpty && matches[0].value != 0) {
        numberOfMatches += 1;
        messageMatches[i] = matches;
        currentMatchIndex = i;
        messageIndices.add(i);
      }
    }

    setState(() {
      _messageIndices = messageIndices;
      _currentMatchIndex = currentMatchIndex;
      _numberOfMatches = numberOfMatches;
      _messageMatches = messageMatches;
    });
  }

  void _enableSearching() {
    // Implement search functionality here
    setState(() {
      isSearching = true;
    });
  }

  void _toggleSearchDisplay() {
    setState(() {
      isShowAsList = !isShowAsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.chatModel.title;
    final membersNumber = widget.chatModel.userIds.length;
    final String subtitle = widget.chatModel.type == ChatType.oneToOne
        ? "last seen a long time ago"
        : "$membersNumber Member${membersNumber > 1 ? "s" : ""}";
    final imageBytes = widget.chatModel.photoBytes;
    final photo = widget.chatModel.photo;
    const menuItemsHeight = 45.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isShowAsList) {
              setState(() {
                isShowAsList = false;
              });
            } else if (isSearching) {
              setState(() {
                isSearching = false;
                _messageMatches.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: !isSearching ? ChatHeaderWidget(
          title: title,
          subtitle: subtitle,
          photo: photo,
          imageBytes: imageBytes,
        ) :
        TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(
                color: Palette.accentText,
                fontWeight: FontWeight.w400
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,

          ),
          onSubmitted: _searchForText,
          onChanged: (value) => {
            if (isShowAsList) {
              setState(() {
                isShowAsList = false;
              })
            }
          },
        ),
        actions: [
          if (!isSearching)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              if (value == 'search') {
                _enableSearching();
              } else {
                showToastMessage("No Bueno");
              }
            },
            color: Palette.secondary,
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context) {
              return [
                 PopupMenuItem<String>(
                  value: 'mute-options',
                  padding: EdgeInsets.zero,
                  height: menuItemsHeight,
                  child: _popupMenuItem(
                    icon: Icons.volume_up_rounded,
                    text: 'Mute',
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Palette.inactiveSwitch,
                      size: 16,
                    )
                  ),
                ),
                const PopupMenuDivider(
                  height: 10,
                ),
                PopupMenuItem<String>(
                  value: 'video-call',
                  padding: EdgeInsets.zero,
                  height: menuItemsHeight,
                  child: _popupMenuItem(
                      icon: Icons.videocam_outlined,
                      text: 'Video Call',
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'search',
                  padding: EdgeInsets.zero,
                  height: menuItemsHeight,
                  child: _popupMenuItem(
                    icon: Icons.search,
                    text: 'Search',
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'change-wallpaper',
                  padding: EdgeInsets.zero,
                  height: menuItemsHeight,
                  child: _popupMenuItem(
                    icon: Icons.wallpaper_rounded,
                    text: 'Change Wallpaper',
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'clear-history',
                  padding: EdgeInsets.zero,
                  height: menuItemsHeight,
                  child: _popupMenuItem(
                    icon: Icons.cleaning_services,
                    text: 'Clear History',
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete-chat',
                  padding: EdgeInsets.zero,
                  height: menuItemsHeight,
                  child: _popupMenuItem(
                    icon: Icons.delete_outline,
                    text: 'Delete Chat',
                  ),
                ),
              ];
            },
          ),
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
                  child: isShowAsList ?
                    Container(
                      color: Palette.background,
                      child: Column(
                        children: _messageIndices.map((index) {
                          MessageModel msg = chatContent[index];
                          return SettingsOptionWidget(
                            imagePath: getRandomImagePath(),
                            text: msg.senderName,
                            subtext: msg.content ?? "",
                            onTap: () => {
                              // TODO (MOAMEN): Create scroll to msg
                            },
                          );
                        }).toList(),
                      ),
                    )
                  : chatContent.isEmpty ?
                    Center(
                      child: Container(
                        width: 210,
                        margin: const EdgeInsets.symmetric(horizontal: 24.0),
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
                      :
                    SingleChildScrollView(
                    controller: _scrollController, // Use the ScrollController
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        children: chatContent.mapIndexed((index, item) {
                          if (item is DateLabelWidget) {
                            return item;
                          } else if (item is MessageModel) {
                            return MessageTileWidget(
                              messageModel: item,
                              isSentByMe: item.senderName == "John Doe",
                              showInfo: type == ChatType.group,
                              highlights: _messageMatches[index] ?? const [MapEntry(0, 0)],
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
                if (!isSearching)
                  BottomInputBarWidget(controller: _messageController)
                else
                  Container(
                    color: Palette.trinary,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_calendar),
                          onPressed: () {
                            // Show the Cupertino Date Picker when the icon is pressed
                            DatePicker.showDatePicker(
                              context,
                              pickerTheme: const DateTimePickerTheme(
                                backgroundColor: Palette.secondary,
                                itemTextStyle: TextStyle(
                                  color: Palette.primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                confirm: Text(
                                  'Jump to date',
                                  style: TextStyle(
                                    color: Palette.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                cancel: null,
                              ),
                              minDateTime: DateTime.now().subtract(const Duration(days: 365 * 10)),
                              maxDateTime: DateTime.now(),
                              initialDateTime: DateTime.now(),
                              dateFormat: 'dd-MMMM-yyyy',
                              locale: DateTimePickerLocale.en_us,
                              onConfirm: (date, time) {
                                _scrollToTimeStamp(date);
                              },
                            );
                          },
                        ),
                        if (_numberOfMatches != 0)
                        Text(
                          _numberOfMatches == 0 ? 'No results' :
                          isShowAsList ?
                          '$_numberOfMatches result${_numberOfMatches != 1 ? 's' :''}' :
                          '$_currentMatch of $_numberOfMatches',
                          style: TextStyle(
                            color: Palette.primaryText,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                _toggleSearchDisplay();
                              },
                              child: Text(
                                isShowAsList ? 'Show as Chat' : 'Show as List',
                                style: const TextStyle(
                                  color: Palette.accent,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
    int randomIndex = random.nextInt(lottieAnimations.length);  // Gets a random index

    // Return the randomly chosen Lottie animation path
    return lottieAnimations[randomIndex];
  }


}

// Popup menu item widget
Widget _popupMenuItem({Key? key, required IconData icon, required String text, Widget? trailing, Function? onTap}) {
  return Container(
      color: Palette.secondary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Row(
          children: [
            Icon(icon, color: Palette.accentText,),
            const SizedBox(width: 16),
            Text(text,
              style: const TextStyle(
                color: Palette.primaryText,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: trailing ?? const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      )
  );
}
