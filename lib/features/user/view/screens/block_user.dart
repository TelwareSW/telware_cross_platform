import 'package:flutter/material.dart';
import 'package:telware_cross_platform/core/contact_service.dart';
import 'package:telware_cross_platform/features/user/view/widget/empty_chats.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/features/user/view/widget/user_chats.dart';
import 'package:hive/hive.dart';
import 'package:telware_cross_platform/core/models/contact_model.dart';
import 'package:flexible_scrollbar/flexible_scrollbar.dart';

import 'package:telware_cross_platform/features/auth/view/widget/confirmation_dialog.dart';

class BlockUserScreen extends StatefulWidget {
  static const String route = '/block-user';

  const BlockUserScreen({super.key});

  @override
  State<BlockUserScreen> createState() => _BlockUserScreen();
}

class _BlockUserScreen extends State<BlockUserScreen>
    with TickerProviderStateMixin {
  final ContactService _contactService = ContactService();
  late List<Map<String, dynamic>> userChats;
  late List<Map<String, dynamic>> userContacts;
  late AnimationController _duckController;
  late TabController _tabController;
  final ScrollController scrollController = ScrollController();

  void blockConfirmationDialog(String user) {
    showConfirmationDialog(
      context: context,
      title: 'Block user',
      titleFontWeight: FontWeight.bold,
      titleColor: Palette.primaryText,
      titleFontSize: 18.0,
      subtitle: 'Are you sure you want to block $user?',
      subtitleFontWeight: FontWeight.normal,
      subtitleFontSize: 16.0,
      contentGap: 20.0,
      confirmText: 'Block user',
      confirmColor: const Color.fromRGBO(238, 104, 111, 1),
      confirmPadding: const EdgeInsets.only(left: 40.0),
      cancelText: 'Cancel',
      cancelColor: const Color.fromRGBO(100, 181, 239, 1),
      onConfirm: () => {
        Navigator.of(context).pop(),
        // Close the dialog
        Navigator.of(context).pop(),
        // Return to Blocked Users screen which is the previous screen.
      },
      onCancel: () => {Navigator.of(context).pop()},
      actionsAlignment: MainAxisAlignment.end,
    );
  }

  Future<void> _initializeContacts() async {
    try {
      await _contactService.fetchAndStoreContacts();
      var box = Hive.box<ContactModelBlock>('contacts-block');
      for (var contact in box.values) {
        userContacts[0]["options"].add({
          "text": contact.name,
          "imageMemory": contact.photo,
          "subtext": contact.phone,
        });
      }
      for (var option in userContacts[0]["options"]) {
        option["color"] = Palette.primaryText;
        option["fontSize"] = 15.0;
        option["fontWeight"] = FontWeight.w500;
        option["avatar"] = true;
        option["subtextFontSize"] = 14.0;
        option["imageWidth"] = 47.0;
        option["imageHeight"] = 47.0;
        option["onTap"] = () => blockConfirmationDialog(option["text"]);
      }
      setState(() {});
    } catch (error) {
      debugPrint('Error fetching contacts: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeContacts();
    _duckController = AnimationController(vsync: this);
    _duckController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _duckController.stop();
      }
    });
    _tabController = TabController(vsync: this, length: 2);
    userChats = <Map<String, dynamic>>[
      {
        "options": <Map<String, dynamic>>[
          {
            "trailing": "1:22 AM",
            "text": 'Marwan Mohammed',
            "imagePath": 'assets/imgs/marwan.jpg',
            "subtext": ".",
          },
          {
            "trailing": "12:21 AM",
            "text": 'Ahmed Alaa',
            "imagePath": 'assets/imgs/ahmed.jpeg',
            "subtext": "Check out my new project for watching movies",
          },
          {
            "trailing": "12:02 AM",
            "text": 'Bishoy Wadea',
            "imagePath": 'assets/imgs/bishoy.jpeg',
            "subtext": "Find stickers in the catalog ⬇️",
          },
        ],
      },
    ];
    userContacts = <Map<String, dynamic>>[
      {
        "padding": const EdgeInsets.fromLTRB(11, 16, 11, 20),
        "options": <Map<String, dynamic>>[
          // {
          //   "text": 'Marwan Mohammed',
          //   "imagePath": 'assets/imgs/marwan.jpg',
          //   "subtext": "Last seen recently",
          // },
          // {
          //   "text": 'Ahmed Alaa',
          //   "imagePath": 'assets/imgs/ahmed.jpeg',
          //   "subtext": "Last seen at 5:46 PM",
          // },
          // {
          //   "text": 'Bishoy Wadea',
          //   "imagePath": 'assets/imgs/bishoy.jpeg',
          //   "subtext": "Last seen Aug 19 at 5:46 PM",
          // },
        ],
      },
    ];

    for (var option in userChats[0]["options"]) {
      option["trailingFontSize"] = 13.0;
      option["trailingPadding"] = const EdgeInsets.only(bottom: 20.0);
      option["trailingColor"] = Palette.accentText;
      option["color"] = Palette.primaryText;
      option["fontSize"] = 18.0;
      option["subtextFontSize"] = 14.0;
      option["fontWeight"] = FontWeight.w500;
      option["imageWidth"] = 55.0;
      option["imageHeight"] = 55.0;
      option["onTap"] = () => blockConfirmationDialog(option["text"]);
    }
  }

  @override
  void dispose() {
    _duckController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _restartAnimation() {
    _duckController.reset();
    _duckController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.secondary,
      appBar: AppBar(
        backgroundColor: Palette.tabBar,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back when pressed
          },
        ),
        title: const Text(
          "Blocked Users",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          dividerHeight: 0,
          padding: const EdgeInsets.only(top: 4),
          indicator: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
            border: Border(
              top: BorderSide(
                color: Palette.primary,
                width: 4.0,
              ),
            ),
          ),
          indicatorWeight: 0,
          indicatorPadding: const EdgeInsets.only(top: 44),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Palette.primary,
          ),
          unselectedLabelColor: Palette.accentText,
          labelPadding: const EdgeInsets.only(top: 2),
          tabs: const [
            Tab(text: 'CHATS'),
            Tab(text: 'CONTACTS'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                userChats[0]["options"].length == 0
                    ? EmptyChats(
                        padding: const EdgeInsets.only(top: 50),
                        duckController: _duckController,
                        onTap: _restartAnimation)
                    : SingleChildScrollView(
                        child: UserChats(chatSections: userChats),
                      ),
                FlexibleScrollbar(
                  alwaysVisible: true,
                  controller: scrollController,
                  scrollThumbBuilder: (ScrollbarInfo info) {
                    return AnimatedContainer(
                      width: 5,
                      height: 31,
                      margin: const EdgeInsets.only(
                        right: 10,
                        top: 98,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Palette.scrollBar,
                      ),
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 85),
                      child: UserChats(chatSections: userContacts),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
