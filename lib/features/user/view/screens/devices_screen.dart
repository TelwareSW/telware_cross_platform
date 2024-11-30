import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/palette.dart';
import '../../../../core/view/widget/lottie_viewer.dart';
import '../../view_model/devices_view_model.dart';
import '../widget/section_title_widget.dart';
import '../widget/toolbar_widget.dart';

class DevicesScreen extends ConsumerWidget {
  static const String route = '/devices';

  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(devicesViewModelProvider);

    if (sessionsAsync.isLoading) {
      ref.read(devicesViewModelProvider.notifier).fetchSessions(context);
    }

    return Scaffold(
      appBar: const ToolbarWidget(title: "Devices"),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('No sessions available'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Palette.secondary,
                  child: const Column(
                    children: [
                      LottieViewer(
                        path: 'assets/tgs/laptop_devices_screen.tgs',
                        width: 125,
                        height: 125,
                      ),
                      Text('Track the current sessions of your account',style: TextStyle(color: Colors.white),),
                      SizedBox(
                        height: Dimensions.sectionGaps,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                ...sessions.asMap().entries.map((entry) {
                  int sectionIndex = entry.key;
                  final section = entry.value;
                  final title = section.title;
                  final options = section.options;
                  final trailing = section.trailing;

                  return Column(
                    key: Key("section_$sectionIndex"),
                    children: [
                      Container(
                        color: Palette.secondary,
                        child: Column(
                          children: [
                            SectionTitleWidget(
                              title: title,
                              key: Key("section_title_$sectionIndex"),
                            ),
                            Column(
                              children: List.generate(options.length, (index) {
                                final option = options[index];
                                return SessionTile(
                                  key: Key(
                                      "session_tile_${sectionIndex}_$index"),
                                  icon: option.icon,
                                  text: option.phoneName,
                                  telegramPlatform: option.telegramVersion,
                                  location: option.location,
                                  color: option.color ?? Palette.primaryText,
                                  iconColor: option.color ?? Palette.accentText,
                                  showDivider: index != options.length - 1,
                                  showContainer: option.color == null,
                                  onTap: option.onTap ?? () {},
                                );
                              }),
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
                            key: Key("section_trailing_$sectionIndex"),
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
          );
        },
      ),
    );
  }
}

class AlertTerminateSessionConformation extends StatelessWidget {
  final String body;
  final String title;
  final String conformationText;
  final Function functionOnConfirmed;
  const AlertTerminateSessionConformation({
    super.key,
    required this.body,
    required this.title,
    required this.conformationText,
    required this.functionOnConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Palette.secondary,
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            functionOnConfirmed;
            Navigator.of(context).pop();
          },
          child: Text(
            conformationText,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
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
    Color backgroundColor =
        (icon == FontAwesomeIcons.android || icon == FontAwesomeIcons.apple)
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
  final VoidCallback onTap;

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
    required this.onTap,
  });

  static void _defaultOnTap() {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
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
      ),
    );
  }
}
