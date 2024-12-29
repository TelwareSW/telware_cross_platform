import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/view/widget/animated_snack_bar_widget.dart';
import 'package:telware_cross_platform/features/user/repository/user_local_repository.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_radio_button_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';
import 'package:telware_cross_platform/features/user/view_model/user_state.dart';
import 'package:telware_cross_platform/features/user/view_model/user_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelfDestructScreen extends ConsumerStatefulWidget {
  static const String route = '/privacy/self-destruct';

  const SelfDestructScreen({super.key});

  @override
  ConsumerState<SelfDestructScreen> createState() => _SelfDestructScreen();
}

class _SelfDestructScreen extends ConsumerState<SelfDestructScreen> with TickerProviderStateMixin {
  late String _destructTimerSelectedOption;
  late final String _destructTimerInitValue;
  bool _showSaveButton = false;
  late GifController _controller;
  late Image _preloadedGif;
  late final ImageStreamListener _imageListener;

  @override
  void initState() {
    super.initState();
    // ignore: unused_local_variable
    final UserModel user = ref.read(userLocalRepositoryProvider).getUser()!;
    _destructTimerSelectedOption = "off";
    _destructTimerInitValue = _destructTimerSelectedOption;
    _controller = GifController(vsync: this);
    _preloadedGif = Image.asset("assets/gifs/self-destruct-timer.gif");

    _imageListener = ImageStreamListener((_, __) {
      if (mounted) {
        // ignore: invalid_use_of_protected_member
        _controller.repeat(period: _controller.duration);
      }
    });

    _preloadedGif.image.resolve(const ImageConfiguration()).addListener(_imageListener);
  }

  @override
  void dispose() {
    _preloadedGif.image.resolve(const ImageConfiguration()).removeListener(_imageListener);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updatePrivacy() async {
    await ref.read(userViewModelProvider.notifier).changeInvitePermissions(_destructTimerSelectedOption);
  }

  void _handleInvitePermissionsPrivacy(String value) {
    setState(() {
      if ((value != _destructTimerInitValue) != _showSaveButton) {
        _showSaveButton = !_showSaveButton;
      }
      _destructTimerSelectedOption = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserState>(userViewModelProvider, (previous, next) {
      if (next.type == UserStateType.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AnimatedSnackBarWidget(
              icon: const Icon(Icons.upgrade_rounded),
              text: next.message ?? 'Invite permissions updated successfully',
            ),
          ),
        );
        context.pop();
      } else if (next.type == UserStateType.fail) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AnimatedSnackBarWidget(
              icon: const Icon(Icons.error_outline_rounded),
              text: next.message ?? 'Failed to update invite permissions',
            ),
            backgroundColor: Palette.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: ToolbarWidget(
        title: "Auto-Delete Messages",
        actions: [
          if (_showSaveButton)
            IconButton(
              onPressed: _updatePrivacy,
              icon: const Icon(Icons.check),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Gif(
              image: _preloadedGif.image,
              controller: _controller,
              autostart: Autostart.no,
              height: 130,
            ),
            const SizedBox(height: 24),
            SettingsSection(
              containerKey: ValueKey("self-destruct-timer${WidgetKeys.settingsSectionSuffix.value}"),
              title: "Self-Destruct Timer",
              settingsOptions: const [],
              actions: [
                SettingsRadioButtonWidget(
                  key: ValueKey("self-destruct-timer-off${WidgetKeys.settingsRadioOptionSuffix.value}"),
                  text: "Off",
                  isSelected: _destructTimerSelectedOption == "off",
                  onTap: () => _handleInvitePermissionsPrivacy("off"),
                ),
                SettingsRadioButtonWidget(
                  key: ValueKey("self-destruct-timer-1-day${WidgetKeys.settingsRadioOptionSuffix.value}"),
                  text: "After 1 day",
                  isSelected: _destructTimerSelectedOption == "1_day",
                  onTap: () => _handleInvitePermissionsPrivacy("1_day"),
                ),
                SettingsRadioButtonWidget(
                  key: ValueKey("self-destruct-timer-1-week${WidgetKeys.settingsRadioOptionSuffix.value}"),
                  text: "After 1 week",
                  isSelected: _destructTimerSelectedOption == "1_week",
                  onTap: () => _handleInvitePermissionsPrivacy("1_week"),
                ),
                SettingsRadioButtonWidget(
                  key: ValueKey("self-destruct-timer-1-month${WidgetKeys.settingsRadioOptionSuffix.value}"),
                  text: "After 1 month",
                  isSelected: _destructTimerSelectedOption == "1_month",
                  onTap: () => _handleInvitePermissionsPrivacy("1_month"),
                  showDivider: false,
                ),
              ],
              trailing: "If enabled, all new messages in chats you start will be automatically deleted for everyone at some point after they are sent. You can also apply this setting for your existing chats.",
            ),
          ],
        ),
      ),
    );
  }
}
