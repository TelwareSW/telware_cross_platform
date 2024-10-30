import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/palette.dart';
import '../widget/section_title_widget.dart';
import '../widget/toolbar_widget.dart';

class DevicesScreen extends StatelessWidget {
  static const String route = '/devices';

  const DevicesScreen({super.key});

  static const List<Map<String, dynamic>> profileSections = [
    {
      "title": "Current session",
      "options": [
        {
          "icon": FontAwesomeIcons.android,
          "phoneName": 'Redmi Redmi Note 8 Pro',
          "telegramVersion": "Telegram Android 11.2.3",
          "location": "Cairo, Egypt",
          "state": "online"
        },
        {
          "icon": FontAwesomeIcons.hand,
          "phoneName": 'Terminate All Other Sessions',
          "color": Colors.red
        },
      ],
      "trailing": "Logs out all devices except this one"
    },
    {
      "title": "Active sessions",
      "options": [
        {
          "icon": FontAwesomeIcons.android,
          "phoneName": 'Redmi Redmi Note 8 Pro',
          "telegramVersion": "Telegram Android 11.2.3",
          "location": "Cairo, Egypt",
          "state": "online"
        },
        {
          "icon": FontAwesomeIcons.edge,
          "phoneName": 'Microsoft Edge 130',
          "telegramVersion": "Telegram Web 11.2.3",
          "location": "Texas, USA",
          "state": "8:33 PM"
        },
        {
          "icon": FontAwesomeIcons.apple,
          "phoneName": 'iPhone 15 Pro',
          "telegramVersion": "Telegram iOS 11.2.3",
          "location": "Texas, USA",
          "state": "online"
        },
      ],
      "trailing": "The official Telegram app is available for Android, iPhone, iPad, Windows, macOS and Linux."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ToolbarWidget(title: "Devices"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...List.generate(profileSections.length, (index) {
              final section = profileSections[index];
              final title = section["title"] ?? "";
              final options = section["options"];
              final trailing = section["trailing"] ?? "";

              return Column(
                children: [
                  Container(
                    color: Palette.secondary,
                    child: Column(
                      children: [
                        SectionTitleWidget(title: title),
                        Consumer(
                          builder: (context, ref, _) {
                            return Column(
                              children: List.generate(options.length, (index) {
                                final option = options[index];
                                return SessionTile(
                                  icon: option["icon"],
                                  text: option["phoneName"],
                                  telegramPlatform: option["telegramVersion"] ?? "",
                                  location: option["location"] ?? "",
                                  color: option["color"] ?? Palette.primaryText,
                                  iconColor: option["iconColor"] ?? Palette.accentText,
                                  showDivider: index != options.length - 1,
                                  showContainer: option["color"] == null,
                                );
                              }),
                            );
                          },
                        ),
                        const SizedBox(height: Dimensions.sectionGaps),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(11, 16, 11, 7),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        trailing,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Palette.accentText,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class LeadingIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final bool showContainer;

  const LeadingIcon({
    super.key,
    required this.icon,
    this.iconColor = Colors.white,
    this.showContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = (icon == FontAwesomeIcons.android || icon == FontAwesomeIcons.apple)
        ? Colors.green
        : Colors.pinkAccent;

    return showContainer
        ? Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: FaIcon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    )
        : Center(
      child: FaIcon(
        icon,
        color: Colors.red,
        size: 30,
      ),
    );
  }
}

class SessionTile extends StatelessWidget {
  final IconData? icon;
  final String text;
  final String telegramPlatform;
  final String location;
  final double fontSize;
  final Color iconColor;
  final Color color;
  final bool showDivider;
  final bool showContainer;

  const SessionTile({
    super.key,
    this.icon,
    required this.text,
    this.telegramPlatform = "",
    this.location = "",
    this.fontSize = 14,
    this.color = Palette.primaryText,
    this.iconColor = Palette.accentText,
    this.showDivider = true,
    this.showContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          LeadingIcon(icon: icon!, showContainer: showContainer),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          color: color,
                          fontSize: fontSize,
                          fontWeight: FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (telegramPlatform.isNotEmpty)
                        Text(
                          telegramPlatform,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize * 0.8,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      if (location.isNotEmpty)
                        Text(
                          location,
                          style: TextStyle(
                            color: Palette.accentText,
                            fontSize: fontSize * 0.8,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                  onTap: () {},
                ),
                if (showDivider) const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

