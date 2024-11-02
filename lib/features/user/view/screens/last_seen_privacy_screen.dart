import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:telware_cross_platform/core/constants/keys.dart';
import 'package:telware_cross_platform/core/models/user_model.dart';
import 'package:telware_cross_platform/core/theme/dimensions.dart';
import 'package:telware_cross_platform/core/theme/palette.dart';
import 'package:telware_cross_platform/core/utils.dart';
import 'package:telware_cross_platform/core/view/widget/animated_snack_bar_widget.dart';
import 'package:telware_cross_platform/features/user/repository/user_local_repository.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_option_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_radio_button_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_section.dart';
import 'package:telware_cross_platform/features/user/view/widget/settings_toggle_switch_widget.dart';
import 'package:telware_cross_platform/features/user/view/widget/toolbar_widget.dart';
import 'package:telware_cross_platform/features/user/view_model/user_state.dart';
import 'package:telware_cross_platform/features/user/view_model/user_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LastSeenPrivacyScreen extends ConsumerStatefulWidget {
  static const String route = '/privacy/last-seen';

  const LastSeenPrivacyScreen({super.key});

  @override
  ConsumerState<LastSeenPrivacyScreen> createState() => _LastSeenPrivacyScreen();
}

class _LastSeenPrivacyScreen extends ConsumerState<LastSeenPrivacyScreen> {
  late String _seeLastSeenSelectedOption;
  late bool _isHideReadTime;
  late final String _seeLastSeenInitValue;
  late final bool _isHideReadTimeInitValue;
  bool _showSaveButton = false;

  @override
  void initState() {
    super.initState();
    final UserModel user = ref.read(userLocalRepositoryProvider).getUser()!;
    _seeLastSeenSelectedOption = user.lastSeenPrivacy;
    _seeLastSeenInitValue = _seeLastSeenSelectedOption;
    _isHideReadTime = true;
    _isHideReadTimeInitValue = _isHideReadTime;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _updatePrivacy() async {
    await ref.read(userViewModelProvider.notifier).changeLastSeenPrivacy(_seeLastSeenSelectedOption);
  }

  void _handleSeeLastSeenPrivacy(String value) {
    setState(() {
      _seeLastSeenSelectedOption = value;
      _checkChange();
    });
  }

  void _handleHideReadTime(bool value) {
    setState(() {
      _isHideReadTime = value;
      _checkChange();
    });
  }

  void _checkChange() {
    bool hasChanged = (_seeLastSeenSelectedOption != _seeLastSeenInitValue)
    ||  (_seeLastSeenSelectedOption != "Everybody" && _isHideReadTime != _isHideReadTimeInitValue);
    setState(() {
      _showSaveButton = hasChanged;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserState>(userViewModelProvider, (previous, next) {
      if (next.type == UserStateType.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AnimatedSnackBarWidget(
              icon: const Icon(Icons.upgrade_rounded),
              text: next.message ?? 'Last seen privacy updated successfully'
            )
          ),
        );
        context.pop();
      } else if (next.type == UserStateType.fail) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AnimatedSnackBarWidget(
              icon: const Icon(Icons.error_outline_rounded),
              text: next.message ?? 'Failed to update last seen privacy'
            ),
            backgroundColor: Palette.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: ToolbarWidget(
        title: "Last Seen & Online",
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
              SettingsSection(
                containerKey: ValueKey("see-last-seen-privacy${WidgetKeys.settingsRadioOptionSuffix.value}"),
                title: "Who can see my last seen time?",
                settingsOptions: const [],
                actions: [
                  SettingsRadioButtonWidget(
                    key: ValueKey("see-last-seen-everybody${WidgetKeys.settingsRadioOptionSuffix.value}"),
                    text: "Everybody",
                    isSelected: _seeLastSeenSelectedOption == "everyone",
                    onTap: () => _handleSeeLastSeenPrivacy("everyone"),
                  ),
                  SettingsRadioButtonWidget(
                    key: ValueKey("see-last-seen-contacts${WidgetKeys.settingsRadioOptionSuffix.value}"),
                    text: "My Contacts",
                    isSelected: _seeLastSeenSelectedOption == "contacts",
                    onTap: () => _handleSeeLastSeenPrivacy("contacts"),
                  ),
                  SettingsRadioButtonWidget(
                    key: ValueKey("see-last-seen-nobody${WidgetKeys.settingsRadioOptionSuffix.value}"),
                    text: "Nobody",
                    isSelected: _seeLastSeenSelectedOption == "nobody",
                    onTap: () => _handleSeeLastSeenPrivacy("nobody"),
                    showDivider: false,
                  ),
                ],
                trailing: "Unless you are a Premium user, you won't see Last Seen "
                    "or Online Statuses for people with whom you don't share yours."
                    " Approximate times will be shown instead (recently, within a week, within a month).",
              ),
              const SizedBox(height: Dimensions.sectionGaps),
              SettingsSection(
                title: "Add exceptions",
                settingsOptions: const [],
                actions: [
                  if (_seeLastSeenSelectedOption != "everyone")
                    SettingsOptionWidget(
                      text: "Always Share With",
                      trailing: "Add Users",
                      onTap: () => showToastMessage("Coming Soon..."),
                      showDivider: _seeLastSeenSelectedOption != "nobody",
                    ),
                  if (_seeLastSeenSelectedOption != "nobody")
                    SettingsOptionWidget(
                      text: "Never Share With",
                      trailing: "Add Users",
                      onTap: () => showToastMessage("Coming Soon..."),
                      showDivider: false,
                    ),
                ],
                trailing: "You can add users or entire groups as exceptions that "
                    "will override the settings above.",
              ),
              if (_seeLastSeenSelectedOption != "everyone") ...[
                const SizedBox(height: Dimensions.sectionGaps),
                SettingsSection(
                  title: "Add exceptions",
                  settingsOptions: const [],
                  actions: [
                    SettingsToggleSwitchWidget(
                      text: "Hide Read Time",
                      isChecked: _isHideReadTime,
                      onToggle: _handleHideReadTime,
                      showDivider: false,
                    )
                  ],
                  trailing: "Hide the time when you read messages from people who "
                      "can't see your last seen. If you turn this on, their read time will"
                      " also be hidden from you (unless you are a Premium user).",
                ),
              ]
            ],
          )
      ),
    );
  }
}