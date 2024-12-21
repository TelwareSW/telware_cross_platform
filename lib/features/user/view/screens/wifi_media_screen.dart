import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/providers/user_provider.dart';
import 'package:telware_cross_platform/core/routes/routes.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/features/auth/view/widget/confirmation_dialog.dart';
import 'package:telware_cross_platform/features/user/view/screens/invites_permissions_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/blocked_users.dart';
import 'package:telware_cross_platform/features/user/view/screens/last_seen_privacy_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/phone_privacy_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/profile_photo_privacy_screen.dart';
import 'package:telware_cross_platform/features/user/view/screens/self_destruct_screen.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_toggle_switch_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';

class WifiMediaScreen extends ConsumerStatefulWidget {
  static const String route = '/data-and-storage/wifi';

  const WifiMediaScreen({super.key});

  @override
  ConsumerState<WifiMediaScreen> createState() =>
      _WifiMediaScreen();
}

class _WifiMediaScreen extends ConsumerState<WifiMediaScreen> {
  late List<Map<String, dynamic>> profileSections;
  bool photos = true;
  bool videos = true;
  bool files = true;
  bool stories = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ToolbarWidget(
        title: "Data and Storage",
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              const SettingsSection(
                title: 'Data usage',
                settingsOptions: [],
                actions: [
                  LowMediumHighSlider(),
                ],
              ),
              const SizedBox(height: Dimensions.sectionGaps),
              SettingsSection(
                title: 'Types of media',
                settingsOptions: const [],
                actions: [
                  SettingsToggleSwitchWidget(
                    text: 'Photos',
                    subtext: photos ? 'On in all chats' : 'Off',
                    isChecked: photos,
                    onToggle: (value) => setState(() {
                      photos = value;
                    }),
                    onTap: (context) {},
                    oneFunction: false,
                  ),
                  SettingsToggleSwitchWidget(
                    text: 'Videos',
                    subtext: videos ? 'Up to 15.0 MB in all chats' : 'Off',
                    isChecked: videos,
                    onToggle: (value) => setState(() {
                      videos = value;
                    }),
                    onTap: (context) {},
                    oneFunction: false,
                  ),
                  SettingsToggleSwitchWidget(
                    text: 'Files',
                    subtext: files ? 'Up to 3.0 MB in all chats' : 'Off',
                    isChecked: files,
                    onToggle: (value) => setState(() {
                      files = value;
                    }),
                    onTap: (context) {},
                    oneFunction: false,
                  ),
                  SettingsToggleSwitchWidget(
                    text: 'Stories',
                    subtext: stories ? 'On' : 'Off',
                    isChecked: stories,
                    onToggle: (value) => setState(() {
                      stories = value;
                    }),
                    onTap: (context) {},
                    oneFunction: false,
                    showDivider: false,
                  ),
                ],
                trailing: "Voice messages are tiny, so they're always downloaded automatically.",
              ),
            ],
          )),
    );
  }
}

class LowMediumHighSlider extends StatefulWidget {
  const LowMediumHighSlider({super.key});

  @override
  _LowMediumHighSliderState createState() => _LowMediumHighSliderState();
}

class _LowMediumHighSliderState extends State<LowMediumHighSlider> {
  double _currentValue = 0; // Start at Low

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Low"),
            Text("Medium"),
            Text("High"),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Palette.primary,
            inactiveTrackColor: Palette.primary.withOpacity(0.3),
            thumbColor: Palette.primary,
            overlayColor: Palette.primary.withOpacity(0.2),
            valueIndicatorColor: Palette.primary,
            activeTickMarkColor: Palette.primary,
            inactiveTickMarkColor: Palette.primary.withOpacity(0.5),
            trackHeight: 4.0,
            tickMarkShape: _CustomTickMarkShape(
              tickMarkRadius: 5.0,
              borderColor: Palette.secondary,
            ),
            thumbShape: _CustomThumbShape(
              thumbRadius: 7.0,
              borderColor: Palette.secondary,
            ),
          ),
          child: Slider(
            value: _currentValue,
            min: 0,
            max: 2,
            divisions: 2, // Divide into three steps
            onChanged: (value) {
              setState(() {
                _currentValue = value;
              });
            },
          ),
        ),
      ],
    );
  }
}

class _CustomTickMarkShape extends SliderTickMarkShape {
  final double tickMarkRadius;
  final Color borderColor;

  _CustomTickMarkShape({
    required this.tickMarkRadius,
    required this.borderColor,
  });

  @override
  Size getPreferredSize({
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
  }) {
    return Size.fromRadius(tickMarkRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required bool isEnabled,
        required TextDirection textDirection,
        required Offset thumbCenter,
      }) {
    final double opacity = isEnabled ? 1.0 : 0.2;

    final Paint borderPaint = Paint()
      ..color = borderColor.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint fillPaint = Paint()
      ..color = (sliderTheme.activeTickMarkColor ?? Colors.transparent).withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Draw the filled circle
    context.canvas.drawCircle(center, tickMarkRadius, fillPaint);
    // Draw the border around the circle
    context.canvas.drawCircle(center, tickMarkRadius, borderPaint);
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final Color borderColor;
  final double borderWidth;

  _CustomThumbShape({
    required this.thumbRadius,
    required this.borderColor,
    this.borderWidth = 2.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required Size sizeWithOverflow,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double textScaleFactor,
        required double value,
      }) {
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final Paint fillPaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.transparent
      ..style = PaintingStyle.fill;

    // Draw the filled circle
    context.canvas.drawCircle(center, thumbRadius, fillPaint);
    // Draw the border around the circle
    context.canvas.drawCircle(center, thumbRadius, borderPaint);
  }
}

