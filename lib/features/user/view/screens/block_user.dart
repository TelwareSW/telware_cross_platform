import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';

class BlockUserScreen extends StatefulWidget {
  static const String route = '/block-user';

  const BlockUserScreen({super.key});

  @override
  State<BlockUserScreen> createState() => _BlockUserScreen();
}

class _BlockUserScreen extends State<BlockUserScreen> {
  late List<Map<String, dynamic>> blockSections;

  @override
  void initState() {
    super.initState();
    blockSections = [
      {
        "options": [
          {
            "trailing": "1:22 AM",
            "text": 'Marwan Mohammed',
            "imagePath": 'assets/imgs/marwan.jpg',
            "subtext": ".",
            "dummy": 0.0,
          },
          {
            "trailing": "12:21 AM",
            "text": 'Ahmed Alaa',
            "imagePath": 'assets/imgs/ahmed.jpeg',
            "subtext": "Check out my new project for watching movies",
            "dummy": 0.0,
          },
          {
            "trailing": "12:02 AM",
            "text": 'Bishoy Wadea',
            "imagePath": 'assets/imgs/bishoy.jpeg',
            "subtext": "Find stickers in the catalog ⬇️",
            "dummy": 0.0,
          },
        ],
      },
    ];
    for (var option in blockSections[0]["options"]) {
      option["trailingFontSize"] = 13.0;
      option["trailingHeight"] = 40.0;
      option["trailingColor"] = Palette.accentText;
      option["color"] = Palette.primaryText;
      option["fontSize"] = 18.0;
      option["subtextFontSize"] = 14.0;
      option["fontWeight"] = FontWeight.w500;
      option["imageWidth"] = 55.0;
      option["imageHeight"] = 55.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.secondary,
      appBar: const ToolbarWidget(
        title: "Block User",
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
            Lottie.asset('assets/tgs/EasterDuck.tgs',
                width: 50, height: 50, decoder: LottieComposition.decodeGZip),
          ],
        ),
      ),
    );
  }
}
