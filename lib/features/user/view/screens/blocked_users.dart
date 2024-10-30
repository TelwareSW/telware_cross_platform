import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class BlockedUsersScreen extends StatefulWidget {
  static const String route = '/blocked-users';

  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreen();
}

class _BlockedUsersScreen extends State<BlockedUsersScreen> {
  // Define a GlobalKey for the IconButton

  late List<Map<String, dynamic>> blockSections;

  void unblockMenu(GlobalKey iconButtonKey) {
    // Get the position of the IconButton using the GlobalKey
    final RenderBox renderBox =
        iconButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    showMenu(
      color: Palette.quaternary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      menuPadding: const EdgeInsets.all(0),
      elevation: 0,
      popUpAnimationStyle: AnimationStyle(curve: Curves.linear),
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx, // X-coordinate of the button
        position.dy + size.height, // Y-coordinate + button height to show below
        position.dx + size.width, // To align the right side
        0, // Bottom coordinate (ignored)
      ),
      items: <PopupMenuEntry<int>>[
        const PopupMenuItem<int>(
          value: 0,
          child: Text(
            ' Unblock user',
          ),
        ),
      ],
    ).then((int? result) {
      if (result == 0) {
        //todo Handle unblock action
        if (mounted) {
          context.push(Routes.blockUser);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    blockSections = [
      {
        "trailingFontSize": 13.0,
        "padding": const EdgeInsets.fromLTRB(25, 12, 9, 7),
        "lineHeight": 1.2,
        "options": [
          {
            "imagePath": 'assets/imgs/invite.png',
            "imageHeight": 16.0,
            "imageWidth": 16.0,
            "imageRadius": 0.0,
            "color": Palette.primary,
            "fontSize": 15.5,
            "text": 'Block user',
            "routes": "/block-user",
          }
        ],
        "trailing":
            "Blocked users can't send you messages or add you to groups. They will not see your profile photos, stories, online and last    seen status."
      },
      {
        "title": "blocked users",
        "titleFontSize": 15.0,
        "options": <Map<String, dynamic>>[
          {
            "text": 'Marwan Mohammed',
            "imagePath": 'assets/imgs/marwan.jpg',
            "subtext": "+201093401932",
          },
          {
            "text": 'Ahmed Alaa',
            "imagePath": 'assets/imgs/ahmed.jpeg',
            "subtext": "+201093401932",
          },
          {
            "text": 'Bishoy Wadea ',
            "imagePath": 'assets/imgs/bishoy.jpeg',
            "subtext": "+201093401932",
          },
          {
            "text": 'Moamen Hefny',
            "imagePath": 'assets/imgs/moamen.jpeg',
            "subtext": "+201093401932",
          },
        ],
      },
    ];
    // Loop through each section and set the trailingIconAction

    for (var option in blockSections[1]["options"]) {
      option["iconKey"] = GlobalKey();
      option["trailingIcon"] = Icons.more_vert_rounded;
      option["trailingColor"] = Palette.accentText;
      option["color"] = Palette.primaryText;
      option["fontSize"] = 18.0;
      option["subtextFontSize"] = 14.0;
      option["fontWeight"] = FontWeight.w500;
      option["trailingIconAction"] = () => unblockMenu(option["iconKey"]);
      option["subtext"] = formatPhoneNumber(option["subtext"]);
    }

    int optionsLength = blockSections[1]["options"].length;
    blockSections[1]["title"] =
        optionsLength == 1 ? "1 blocked user" : "$optionsLength blocked users";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ToolbarWidget(
        title: "Blocked Users",
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...List.generate(
              blockSections.length,
              (index) {
                final section = blockSections[index];
                final title = section["title"] ?? "";
                final trailingFontSize = section["trailingFontSize"];
                final lineHeight = section["lineHeight"];
                final padding = section["padding"];
                final options = section["options"];
                final trailing = section["trailing"] ?? "";
                final titleFontSize = section["titleFontSize"];
                return Column(
                  children: [
                    SettingsSection(
                      titleFontSize: titleFontSize,
                      title: title,
                      padding: padding,
                      trailingFontSize: trailingFontSize,
                      trailingLineHeight: lineHeight,
                      settingsOptions: options,
                      trailing: trailing,
                    ),
                    const SizedBox(height: Dimensions.sectionGaps),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
